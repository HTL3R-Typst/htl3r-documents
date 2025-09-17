# Typst Template

## How-To

1. Installieren mit `install.sh`
2. Im Directory, in dem ein neuer Dokument-Ordner liegen soll: `typst init @htl3r/<Template-Name> <Dok-Name>`

### Beispiel
```bash
cd nwtk
typst init @htl3r/document bgp
```
ergibt folgende Filestruktur
```
nwtk
  └ bgp
      └ main.typ
```

### Erklärung:

- `@htl3r`: Bezeichnung für einen Package-Namespace. (andere Namespaces sind "@preview" (öffentliches Typst-Package Repo) und "@local")
- `document`: Packagebezeichnung
- `main.typ`: das beim Import erstellte Dokument mit Basiskonfiguration

> [!TIP]
> Der Import im Dokument (z.B. `#import "@htl3r/document:0.1.0": conf`) ist unabhängig von der Relation zum Template-Repo. \
> Das Installationsskript installiert das Template in einen vordefinierten Ordner (meist `~/.local/share/typst/packages/<Namespace>`).
