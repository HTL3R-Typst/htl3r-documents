#!/bin/bash

DATADIR=${XDG_DATA_HOME:-"${HOME}/.local/share"}
PACKAGEDIR="typst/packages"
INSTALLPATH="${DATADIR}/${PACKAGEDIR}"
SYSTEM_FONTPATH="/usr/local/share/fonts/otf" # may be different depending on your system. this is for arch linux
TMPDIR="$(mktemp -d)"

# ------------------------------------------------------------------------------------------------------------------------------------------------
# This is (probably) the only place where you should change variables
# ------------------------------------------------------------------------------------------------------------------------------------------------
# namespace should be equal to a directory
PACKAGENAMESPACES=("htl3r") # reminder: a bash array doesn't use commas!
# only otf fonts are supported at the moment - implementing shouldn't be to difficult, just add a 3rd field for the type in the requirements file
FONT_REQUIREMENTS_FILE="required_fonts.txt" # don't break the formatting in this file, shit will probably happen
# ------------------------------------------------------------------------------------------------------------------------------------------------

debugmsg() {
	# example: debugmsg "This is a message"
	local LIGHTBLUE='\033[1;34m'
	local NC='\033[0m'
	echo -e "${NC}[${LIGHTBLUE}DEBUG${NC}] ${*}" >&2
}

errormsg() {
	# example: errormsg "This is an error"
	local RED='\033[0;31m'
	local NC='\033[0m'
	echo -e "${NC}[${RED}ERROR${NC}] ${*}" >&2
}

successmsg() {
	# example: successmsg "All went well"
	local GREEN='\033[0;32m'
	local NC='\033[0m'
	echo -e "${NC}[${GREEN}SUCCESS${NC}] ${*}" >&2
}

fail() {
	# example: fail "aborting script"
	errormsg "$@"
	exit 1
}

install_font() {
	# installs a font to the directory provided in SYSTEM_FONTPATH (currently otf fonts only)
	# usage: install_font <font_dir>
	# example: install_font fonts/Latin-Modern-Sans
	if [ -z "$1" ]; then
		errormsg "No source folder specified."
		return 1
	fi

	local FONT_SRC="$1"

	if [ ! -d "$FONT_SRC" ]; then
		errormsg "Font \"$FONT_SRC\" does not exist or is not a directory"
		return 1
	fi

	if ! sudo mkdir -p "$SYSTEM_FONTPATH"; then
		errormsg "Failed to create destination directory \"$SYSTEM_FONTPATH\""
		return 1
	fi

	if ! sudo cp -r "$FONT_SRC" "$SYSTEM_FONTPATH"; then
		errormsg "Failed to copy folder \"$FONT_SRC\" to \"$SYSTEM_FONTPATH\""
		return 1
	fi

	if ! sudo fc-cache -f; then
		errormsg "Failed to refresh font cache"
		return 1
	fi

	successmsg "Font \"$FONT_SRC\" installed successfully to \"$SYSTEM_FONTPATH\""
	return 0
}

handle_fonts() {
	# handles font dependencies
	[[ -f "$FONT_REQUIREMENTS_FILE" ]] || return 1
	local FONTREQ_PAIR
	mapfile -t FONTREQ_PAIR < <(sed "1d" <"$FONT_REQUIREMENTS_FILE")
	FONTQUERY_TEMPFILE="$(mktemp)"
	for FONTREQ_ENTRY in "${FONTREQ_PAIR[@]}"; do
		FONTNAME="$(cut -d';' -f1 <<<"$FONTREQ_ENTRY")"
		FONTPATH="$(cut -d';' -f2 <<<"$FONTREQ_ENTRY")"
		debugmsg "Searching for font \"$FONTNAME\""
		typst fonts >"$FONTQUERY_TEMPFILE"
		if grep -q -a "$FONTNAME" "$FONTQUERY_TEMPFILE"; then
			successmsg "\"$FONTNAME\" successfully found"
		else
			debugmsg "\"$FONTNAME\" not found. Starting font installation"
			install_font "$FONTPATH" || errormsg "Failed to install $FONTNAME"
		fi
	done
	successmsg "Font checks completed"
	return 0
}

install_package() {
	# (re)installs a typst package (all versions!!!)
	# usage: install_package <package_to_be_installed> <namespace>
	# example: install_package "htl3r/document" "htl3r"
	if [[ -z "$1" || -z "$2" ]]; then
		debugmsg "ERROR: No source folder specified." >&2
		return 1
	fi

	local PACKAGE_SRC="$1"
	local PACKAGE_BASENAME
	PACKAGE_BASENAME="$(basename "$PACKAGE_SRC")"
	local PACKAGE_NAMESPACE="$2"

	debugmsg "Installing package \"$PACKAGE_SRC\" to \"${INSTALLPATH}/${PACKAGE_NAMESPACE}\""

	if [[ ! -d "$PACKAGE_SRC" ]]; then
		debugmsg "ERROR: Package \"$PACKAGE_SRC\" does not exist or is not a directory"
		return 1
	fi

	if ! mkdir -p "${INSTALLPATH}/${PACKAGE_NAMESPACE}"; then
		debugmsg "ERROR: Failed to create destination directory \"$INSTALLPATH\""
		return 1
	fi

	if [[ -d "${INSTALLPATH}/${PACKAGE_NAMESPACE}/${PACKAGE_BASENAME}" ]]; then
		debugmsg "Removing old version"
		if ! mv "${INSTALLPATH}/${PACKAGE_NAMESPACE}/${PACKAGE_BASENAME}" "$TMPDIR"; then
			debugmsg "ERROR: Couldn't move the old files to a temporary backup"
			local NOBACKUP="1"
		fi
	fi

	if ! cp -r "$PACKAGE_SRC" "${INSTALLPATH}/${PACKAGE_NAMESPACE}"; then
		debugmsg "ERROR: Failed to copy package \"$PACKAGE_SRC\" to \"${INSTALLPATH}/${PACKAGE_NAMESPACE}\""
		if [[ "$NOBACKUP" -ne "1" ]]; then
			debugmsg "attempting to restore previous version"
			if mv "${TMPDIR}}/${PACKAGE_BASENAME}" "${INSTALLPATH}/${PACKAGE_NAMESPACE}"; then
				debugmsg "Restore completed"
			else
				debugmsg "ERROR: Restore failed"
			fi
		fi
		return 1
	else
		successmsg "Successfully installed \"$PACKAGE_SRC\""
	fi
}

cd "$(dirname "$0")" || fail "Couldn't change to script directory"

if [[ "$(uname -s)" == "Linux" ]]; then
	handle_fonts
else
	debugmsg "WARNING: Font installation only supported for Linux systems!"
	debugmsg "Skipping..."
fi

for NAMESPACE in "${PACKAGENAMESPACES[@]}"; do
	debugmsg "Processing namespace \"${NAMESPACE}\""
	find htl3r -mindepth 1 -maxdepth 1 -type d | while read -r PACKAGE_FULLPATH; do
		PACKAGE="${PACKAGE_FULLPATH##*/}"
		if ! install_package "$PACKAGE_FULLPATH" "$NAMESPACE"; then
			errormsg "Failed to install ${PACKAGE}"
		fi
	done
done

debugmsg "Script completed"
