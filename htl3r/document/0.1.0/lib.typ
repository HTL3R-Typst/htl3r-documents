#import "@preview/codly:1.0.0": *
#import "@preview/cheq:0.2.2": checklist

#let conf(
  title: none,
  subtitle: none,
  authors: (),
  language: "de",
  fach: "Fach",
  thema: "Themengebiet",
  schuljahr: "2024/25",
  enumerate: true,
  doc,
) = {
  set text(font: "Latin Modern Roman", size: 11pt)
  set page(
    paper: "a4", 
    margin: (top: 110pt, bottom: 70pt),
    header-ascent: -10pt,
    footer-descent: 10pt,
    header: context [
      #set par(justify: true, spacing: 2em, leading: 0.75em)
      #set text(font: "Latin Modern Roman", size: 11pt)
      #place(
        left + horizon, 
        image("HTL3RLogoRGB.png", width: 35mm), 
        dy: -5pt
      )
      #set align(right + horizon)
      *#fach:* #thema \
      Schuljahr #schuljahr an der HTL Wien 3 Rennweg \
      Rennweg 89b, 1030 Wien
      #v(-10pt)
      #line(length: 100%, stroke: 0.5pt)
    ], 
    footer: context [
      #set text(font: "Latin Modern Roman", size: 11pt)
      #line(length: 100%, stroke: 0.5pt)
      #v(-10pt)
      Version vom #datetime.today().display("[day].[month].[year]")
      #h(1fr)
      #counter(page).display(
      "1 / 1",
      both: true,
      )
    ]
  )
  show: codly-init.with()
  show: checklist

  // General page settings
  set align(left)
  set text(lang: language, size: 12pt)
  show heading: set text(font: "Latin Modern Sans")
  show heading: set block(above: 2em, below: 1.5em)
  set par(justify: true, spacing: 2em, leading: 0.8em)
  set figure(gap: 1em)
  show figure.caption: caption => {
    caption
    v(1em)
  }
  set list(spacing: 1em)
  show list: set block(above: auto, below: auto)

  // Set numbering style
  set heading(
    numbering: 
      if enumerate {
        "1.1.1"
      } else {
        none
      }
  )

  if title != none {
    set align(center)
    text(title, size: 20pt, font: "Latin Modern Sans", weight: "bold")
    
    if subtitle != none {
      v(-2em)
      text(subtitle, font: "Latin Modern Sans", weight: "regular")
      v(1em)
    } else {
      v(-1em)
    }

    text({
      if authors.len() > 1 {
        [*Autoren:* #authors.join(", ")]
      } else {
        [*Autor:* #authors.at(0)]
      }
    })

    v(2em)

    set align(left)
    outline(
      title: [Inhaltsverzeichnis],
      indent: 
        if enumerate {
          auto 
        } else {
          1em
        }
    )

    pagebreak()
  }

  doc
}
