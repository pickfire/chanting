#set page(
  paper: "a4",
  flipped: true,
  margin: 1.5cm,
)

#let draw-single-note(n) = {
  // Fixed size box for all symbols so they align identically
  box(width: 8pt, height: 8pt, align(center + horizon)[
    #if n == "o" or n == "O" or n == "○" or n == "。" {
      place(center + horizon, circle(radius: 1.5pt, stroke: 0.8pt + rgb("1E88E5"))) // Blue
    } else if n == "◎" or n == "@" {
      box(width: 6pt, height: 6pt)[
        #place(center + horizon, circle(radius: 2.5pt, stroke: 0.8pt + rgb("1E88E5"))) // Blue
        #place(center + horizon, circle(radius: 0.6pt, fill: rgb("1E88E5"))) // Blue
      ]
    } else if n == "△" or n == "^" {
      // Right triangle rotated 90 degrees (proportioned to the golden ratio φ ≈ 1.618)
      place(center + top, polygon(
        fill: none,
        stroke: (paint: rgb("E53935"), thickness: 0.8pt, miter-limit: 10.0), // Red
        (0pt, 0pt),
        (6pt, 0pt),
        (6pt, 3.708pt),
      ))
    } else if n == "⊥" or n == "T" {
      box(width: 6pt, height: 6pt)[
        #place(line(start: (3pt, 0pt), end: (3pt, 6pt), stroke: 0.8pt + rgb("E53935"))) // Red
        #place(line(start: (0pt, 6pt), end: (6pt, 6pt), stroke: 0.8pt + rgb("E53935"))) // Red
      ]
    } else if n == "-" {
      // Horizontal dash - centered vertically using place!
      place(center + horizon, line(length: 5pt, stroke: 0.8pt + rgb("E53935"))) // Red
    } else {
      text(12pt, fill: rgb("E53935"), weight: "bold", n)
    }
  ])
}

#let draw-note(n) = {
  let notes = n.clusters()
  stack(
    dir: ttb,
    spacing: -2.5pt,
    ..notes.map(char => draw-single-note(char)),
  )
}

#let char-pinyin-note-vertical(c, p, n, is_last_bar: false) = box(width: 1em)[ // increased box width so notes don't overflow
  #set align(left) // FoRCE left alignment so the 2em character column NEVER shifts
  #let n_rest_temp = n.replace("|", "")
  #let top-pad = if n.contains("^") { 0pt } else if n_rest_temp == "-" { 11.5pt } else { 6pt }
  #let has_left_line = n.contains("|")
  #let line_len = if is_last_bar { 28pt } else { 34pt }
  #let n_rest = n.replace("|", "")
  #grid(
    columns: (2em, auto),
    rows: (20pt, 14pt),
    align: (center + horizon, left + top),
    // Row 1: Character (col 1), Note (col 2)
    box(width: 2em, height: 20pt)[
      #if has_left_line {
        place(left + top, line(angle: 90deg, length: line_len, stroke: 1.5pt + rgb("999999")))
      }
      #place(center + horizon, text(16pt, font: "AR PL New Kai", c))
    ],
    if n_rest != "" and n_rest != " " and n_rest != "　" { pad(top: top-pad, draw-note(n_rest)) } else { [] },
    // Row 2: Pinyin (col 1), empty (col 2)
    move(dy: -4pt, text(7.5pt, fill: rgb("666"), p)), [],
  )
]

#let vline(cn, py: "", notes: "", subscript: "") = {
  let c_arr = cn.clusters()
  let p_arr = if py != "" { py.split(" ") } else { () }

  // Use split(" ") to allow grouping multiple notes to one character!
  let n_arr = if notes != "" { notes.split(" ") } else { () }

  let max_len = calc.max(c_arr.len(), p_arr.len(), n_arr.len())

  let cells = ()
  for i in range(max_len) {
    let c = c_arr.at(i, default: "　")
    let p = p_arr.at(i, default: " ")
    let n = n_arr.at(i, default: "")
    if n == " " or n == "　" { n = "" }
    if c == " " or c == "" { c = "　" }

    let is_last_bar = false
    if n.contains("|") {
      let next_n = n_arr.at(i + 1, default: "")
      if not next_n.contains("|") {
        is_last_bar = true
      }
    }

    cells.push(char-pinyin-note-vertical(c, p, n, is_last_bar: is_last_bar))
  }

  let col = stack(dir: ttb, spacing: 0pt, ..cells)
  if subscript != "" {
    let sub_chars = subscript.clusters()
    let sub_stack = stack(dir: ttb, spacing: 2pt, ..sub_chars.map(c => {
      let t = text(12pt, font: "AR PL New Kai", fill: rgb("333"), c)
      if c == "（" or c == "）" or c == "(" or c == ")" {
        rotate(90deg, t)
      } else {
        t
      }
    }))
    let sub_box = box(width: 1em, height: 68pt, align(center + horizon, sub_stack))
    col = stack(dir: ttb, spacing: 0pt, col, sub_box)
  }
  box(col)
}

#let sutra-block(..lines) = {
  align(top + right)[
    #stack(
      dir: rtl,
      spacing: 2.5em,
      ..lines,
    )
  ]
}

// --- DEMo oF ALL SYMBoLS ---
#sutra-block(
  vline("法器符号演示", py: "fǎ qì fú hào yǎn shì", notes: "o @ ^o o- oo T"),
  vline("　", py: " ", notes: " "), // Spacer
  vline("普陀山", py: "pǔ tuó shān", notes: "| |  "),
  vline("　", py: " ", notes: " "), // Spacer
  vline("南无观世音菩萨", py: "ná mó guān shì yīn pú sà"),
  vline("观音菩萨", py: "guān yīn pú sà", notes: "- - o "),
  vline("观音菩萨", py: "guān yīn pú sà", notes: "- - o "),
  vline("观音菩萨", py: "guān yīn pú sà", notes: "- - o "),
  vline("观音菩萨", py: "guān yīn pú sà", notes: "o-  o- o"),
  vline("观音菩萨", py: "guān yīn pú sà", notes: "o- o o- o"),
  vline("观音菩萨", py: "guān yīn pú sà", notes: "o- o o- o"),
  vline("观音菩萨", py: "guān yīn pú sà", notes: "o- o o- o"),
)
