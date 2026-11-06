#import "@preview/codly:1.3.0": *
#let inc_script(content, type: "", title: "", ranges: none) = {
  local(
    ranges: ranges,
    raw(
      content.trim(),
      lang: type,
      block: true,
    ),
  )
}

#let img_after_item(img) = {
  img
  v(1em)
}

#import "@preview/note-me:0.4.0": admonition
#let infobox(body, title: "Anmerkung") = {
  admonition(
    icon-path: "icons/info.svg",
    title: title,
    color: rgb(9, 105, 218),
    [
      #v(-1em)
      #body
    ],
  )
}
