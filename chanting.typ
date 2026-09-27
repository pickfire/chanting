#set page(
  paper: "a3",
  flipped: true,
  margin: 1cm,
)

#let draw-single-note(n) = {
  // Fixed size box for all symbols so they align identically
  box(width: 4.8pt, height: 4.8pt, align(center + horizon)[
    #if n == "o" or n == "O" or n == "○" or n == "。" {
      place(center + horizon, circle(radius: 0.9pt, stroke: 0.5pt + rgb("1E88E5"))) // Blue
    } else if n == "◎" or n == "@" {
      box(width: 3.6pt, height: 3.6pt)[
        #place(center + horizon, circle(radius: 1.5pt, stroke: 0.5pt + rgb("1E88E5"))) // Blue
        #place(center + horizon, circle(radius: 0.4pt, fill: rgb("1E88E5"))) // Blue
      ]
    } else if n == "△" or n == "^" {
      // Right triangle rotated 90 degrees (proportioned to the golden ratio φ ≈ 1.618)
      place(center + top, polygon(
        fill: none,
        stroke: (paint: rgb("E53935"), thickness: 0.5pt, miter-limit: 10.0), // Red
        (0pt, 0pt),
        (3.6pt, 0pt),
        (3.6pt, 2.225pt),
      ))
    } else if n == "⊥" or n == "T" {
      box(width: 3.6pt, height: 3.6pt)[
        #place(line(start: (1.8pt, 0pt), end: (1.8pt, 3.6pt), stroke: 0.5pt + rgb("E53935"))) // Red
        #place(line(start: (0pt, 3.6pt), end: (3.6pt, 3.6pt), stroke: 0.5pt + rgb("E53935"))) // Red
      ]
    } else if n == "_" or n == " " or n == "" { none } else if n == "-" {
      // Horizontal dash - centered vertically using place!
      place(center + horizon, line(length: 3pt, stroke: 0.5pt + rgb("E53935"))) // Red
    } else {
      text(7.2pt, fill: rgb("E53935"), weight: "bold", n)
    }
  ])
}

#let draw-note(n) = {
  let notes = n.clusters()
  stack(
    dir: ttb,
    spacing: -1.5pt,
    ..notes.map(char => draw-single-note(char)),
  )
}

#let char-pinyin-note-vertical(c, p, n, is_last_bar: false, bold: false) = {
  if bold {
    box(width: 13.2pt, height: 20.4pt, align(top)[
      #box(width: 13.2pt, height: 12pt, align(center + horizon)[
        #text(9.6pt, font: "AR PL New Kai", weight: "bold", c)
      ])
    ])
  } else {
    let n_rest_temp = n.replace("|", "")
    let top-pad = if n.contains("^") { 0pt } else if n_rest_temp == "-" { 6.9pt } else { 3.6pt }
    let has_left_line = n.contains("|")
    let line_len = if is_last_bar { 16.8pt } else { 20.4pt }
    let n_rest = n.replace("|", "")
    let r1_note = if n_rest == "--" { "-" } else if n_rest == "o-" { "o" } else { n_rest }
    let r2_note = if n_rest == "--" or n_rest == "o-" { "-" } else { "" }

    grid(
      columns: (13.2pt, auto),
      rows: (12pt, 8.4pt),
      align: (center + horizon, left + top),
      // Row 1: Character (col 1), Note (col 2)
      box(width: 13.2pt, height: 12pt)[
        #if has_left_line {
          place(left + top, line(angle: 90deg, length: line_len, stroke: 0.9pt + rgb("999999")))
        }
        #place(center + horizon, text(9.6pt, font: "AR PL New Kai", weight: "regular", c))
      ],
      if r1_note != "" and r1_note != " " and r1_note != "　" { pad(top: top-pad, draw-note(r1_note)) } else { [] },
      // Row 2: Pinyin (col 1), empty (col 2)
      move(dy: -2.4pt, text(4.5pt, fill: rgb("666"), p)), if r2_note != "" { move(dy: -2.4pt, pad(top: top-pad, draw-note(r2_note))) } else { [] },
    )
  }
}

#let vline(cn, py: "", notes: "", subscript: "", bold: false) = {
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

    cells.push(char-pinyin-note-vertical(c, p, n, is_last_bar: is_last_bar, bold: bold))
  }

  let col = stack(dir: ttb, spacing: 2pt, ..cells)
  if subscript != "" {
    let sub_chars = subscript.clusters()
    let sub_stack = stack(dir: ttb, spacing: 1.2pt, ..sub_chars.map(c => {
      let t = text(7.2pt, font: "AR PL New Kai", fill: rgb("333"), c)
      if c == "（" or c == "）" or c == "(" or c == ")" {
        rotate(90deg, t)
      } else {
        t
      }
    }))
    let sub_box = box(width: 13.2pt, height: 40.8pt, align(center + horizon, sub_stack))
    col = stack(dir: ttb, spacing: 2pt, col, sub_box)
  }
  if bold {
    box(width: 24pt, align(left)[#rect(stroke: 0.8pt + black, inset: 0pt, outset: (top: 6pt, bottom: -0.4pt, left: 1.5pt, right: 1.5pt), radius: 2pt, col)])
  } else {
    box(width: 24pt, align(left)[#col])
  }
}



// --- FULL PAGE LAYOUT ---
#align(right)[
  #grid(
    columns: (100%,),
    rows: (auto, 1fr, auto),
    box[
      #set align(top + right)
      #stack(
        dir: rtl,
        spacing: 5.2546pt,
        vline("南无本师释迦牟尼佛　", py: "ná mó běn shī shì jiā móu ní fó ", notes: "^ _ o o o o o o o o"),
        vline("南无本师释迦牟尼佛　", py: "ná mó běn shī shì jiā móu ní fó ", notes: "^o o o o o o o o o o"),
        vline("南无本师释迦牟尼佛　", py: "ná mó běn shī shì jiā móu ní fó ", notes: "^o o o- o o o o o o o"),
        vline("开经偈", bold: true),
        vline("无上甚深微妙法　百千万劫难遭遇", py: "wú shàng shén shēn wéi miào fǎ  bǎi qiān wàn jié nàn zāo yù", notes: "^o _ o o o o o- _ o o o o o o o"),
        vline("我今见闻得受持　愿解如来真实义", py: "wǒ jīn jiàn wén dé shòu chí  yuàn jiě rú lái zhēn shí yì", notes: "o o o o o o o _ o o o o o- o o-"),
        vline("般若波罗蜜多心经", py: "bō rě bō luó mì duō xīn jīng", notes: "^o _ o o o o o o-"),
        vline("观自在菩萨行深般若波罗蜜多时照", py: "guān zì zài pú sà xíng shēn bō rě bō luó mì duō shí zhào", notes: "o o o o o o o o o o o o o o o"),
        vline("见五蕴皆空度一切苦厄舍利子色不", py: "jiàn wǔ yùn jiē kōng dù yī qiē kǔ è shè lì zǐ sè bù", notes: "o o o o o o o o o o o o o o o"),
        vline("异空空不异色色即是空空即是色受", py: "yì kōng kōng bù yì sè sè jí shì kōng kōng jí shì sè shòu", notes: "o o o o o o o o o o o o o o o"),
        vline("想行识亦复如是舍利子是诸法空相", py: "xiǎng xíng shí yì fù rú shì shè lì zǐ shì zhū fǎ kōng xiāng", notes: "o o o o o o o o o o o o o o o"),
        vline("不生不灭不垢不净不增不减是故空", py: "bù shēng bù miè bù gòu bù jìng bù zēng bù jiǎn shì gù kōng", notes: "o o o o o o o o o o o o o o o"),
        vline("中无色无受想行识无眼耳鼻舌身意", py: "zhōng wú sè wú shòu xiǎng xíng shí wú yǎn ěr bí shé shēn yì", notes: "o o o o o o o o o o o o o o o"),
        vline("无色声香味触法无眼界乃⾄无意识", py: "wú sè shēng xiāng wèi chù fǎ wú yǎn jiè nǎi zhì wú yì shí", notes: "o o o o o o o o o o o o o o o"),
        vline("界无无明亦无无明尽乃⾄无老死亦", py: "jiè wú wú míng yì wú wú míng jìn nǎi zhì wú lǎo sǐ yì", notes: "o o o o o o o o o o o o o o o"),
        vline("无老死尽无苦集灭道无智亦无得以", py: "wú lǎo sǐ jìn wú kǔ jí miè dào wú zhì yì wú dé yǐ", notes: "o o o o o o o o o o o o o o o"),
        vline("无所得故菩提萨埵依般若波罗蜜多", py: "wú suǒ dé gù pú tí sà duǒ yī bō rě bō luó mì duō", notes: "o o o o o o o o o o o o o o o"),
        vline("故心无挂碍无挂碍故无有恐怖远离", py: "gù xīn wú guà ài wú guà ài gù wú yǒu kǒng bù yuǎn lí", notes: "o o o o o o o o o o o o o o o"),
        vline("颠倒梦想究竟涅槃三世诸佛依般若", py: "diān dǎo mèng xiǎng jiū jìng niè pán sān shì zhū fó yī bō rě", notes: "o o o o o o o o o o o o o o o"),
        vline("波罗蜜多故得阿耨多罗三藐三菩提", py: "bō luó mì duō gù dé ā nuò duō luó sān miǎo sān pú tí", notes: "o o o o o o o o o o o o o o o"),
        vline("故知般若波罗蜜多是大神咒是大明", py: "gù zhī bō rě bō luó mì duō shì dà shén zhòu shì dà míng", notes: "o o o o o o o o o o o o o o o"),
        vline("咒是无上咒是无等等咒能除一切苦", py: "zhòu shì wú shàng zhòu shì wú děng děng zhòu néng chú yī qiē kǔ", notes: "o o o o o o o o o o o o o o o"),
        vline("真实不虚故说般若波罗蜜多咒即说", py: "zhēn shí bù xū gù shuō bō rě bō luó mì duō zhòu jí shuō", notes: "o o o o o o o o o o o o o o o"),
        vline("咒⽈揭谛揭谛波罗揭谛波罗僧揭谛", py: "zhòu yuē jiē dì jiē dì bō luó jiē dì bō luó sēng jiē dì", notes: "o o- o o o o o o o o o o o- o o"),
        vline("菩提萨婆诃　", py: "pú tí sà pó hē", notes: "o o o- _ o- o-"),
        vline("摩诃般若波罗蜜多", py: "mó hē bō rè bō luó mí duō", notes: "^o -- o o o o o o"),
        vline("普陀⼭琉璃世界", py: "pǔ tuó shān liú lí shì jiè", notes: "^o o o o o o o"),
        vline("大慈大悲观世⾳菩萨", py: "dà cí dà bēi guān shì yīn pú sà", notes: "o o o o o o o o o"),
        vline("南无观世⾳菩萨", py: "ná mó guān shì yīn pú sà", notes: "_ o o o o o o"),
      )
    ],
    align(center + horizon)[
      #line(length: 100%, stroke: 0.5pt)
    ],
    box[
      #set align(top + right)
      #stack(
        dir: rtl,
        spacing: 5.2546pt,
        vline("转念四字", bold: true),
        vline("观音菩萨", py: "guān yīn pú sà", notes: "- _ - o"),
        vline("观音菩萨", py: "guān yīn pú sà", notes: "- _ - o"),
        vline("观音菩萨", py: "guān yīn pú sà", notes: "- _ - o"),
        vline("观音菩萨", py: "guān yīn pú sà", notes: "o- _ o- o"),
        vline("观音菩萨", py: "guān yīn pú sà", notes: "o- _ o- o"),
        vline("观音菩萨", py: "guān yīn pú sà", notes: "o- _ o- o"),
        vline("观音菩萨", py: "guān yīn pú sà", notes: "o- _ o- o"),
        vline("普贤十大愿", bold: true),
        vline("一者礼敬诸佛　二者称赞如来", py: "yī zhě lǐ jìng zhū fó  èr zhě chēng zàn rú lái", notes: "_ _ _ _ _ oo _ _ _ _ _ _ oo"),
        vline("三者广修供养　四者忏悔业障", py: "sān zhě guǎng xiū gong yǎng  sì zhě chàn huǐ yè zhàng", notes: "_ _ _ _ _ oo _ o _ o _ o oo"),
        vline("五者随喜功德　六者请转法轮", py: "wǔ zhě suí xǐ gong dé  liù zhě qǐng zhuǎn fǎ lún", notes: "o _ o _ o oo _ o _ o _ o oo"),
        vline("七者请佛住世　八者常随佛学", py: "qī zhě qǐng fó zhù shì  bā zhě cháng suí fó xué", notes: "o _ o _ o oo _ o _ o _ o oo"),
        vline("九者恒顺众生　十者普皆回向", py: "jiǔ zhě héng shùn zhòng shēng  shí zhě pǔ jiē huí xiàng", notes: "o _ o _ o oo _ o _ o _ o oo"),
        vline("十方三世一切佛　一切菩萨摩诃萨", py: "shí fāng sān shì yī qiè fó  yī qiè pú sà mó hē sà", notes: "o _ o _ o _ oo _ _ _ _ _ _ _ _"),
        vline("摩诃般若波罗蜜", py: "mó hē bō rě bō luó mì", notes: ""),
        vline("三皈依", bold: true),
        vline("自皈依佛当愿众生体解大道发无上心", py: "zì guī yī fó dāng yuàn zhòng shēng tǐ jiě dà dào fā wú shàng xīn", notes: "o _ o oo _ _ o _ _ _ o _ _ _ o oo"),
        vline("自皈依法当愿众生深入经藏智慧如海", py: "zì guī yī fǎ dāng yuàn zhòng shēng shēn rù jīng zàng zhì huì rú hǎi", notes: "o _ o oo _ _ o _ _ _ o _ _ _ o oo"),
        vline("自皈依僧当愿众生统理大众一切无碍", py: "zì guī yī sēng dāng yuàn zhòng shēng tǒng lǐ dà zhòng yī qiè wú ài", notes: "o _ o oo _ _ o _ _ _ o _ _ _ o oo"),
        vline("回向偈", bold: true),
        vline("愿消三障诸烦恼　愿得智慧真明了", py: "yuàn xiāo sān zhàng zhū fán nǎo  Yuàn dé zhì huì zhēn míng liǎo", notes: "o _ o _ o _ o _ o _ o _ o _ o"),
        vline("普愿罪障悉消除　世世常行菩萨道", py: "pǔ yuàn zuì zhàng xī xiāo chú  shì shì cháng xíng pú sà dào", notes: "o _ o _ o _ o _ o _ o _ o _ oo"),
        vline("四光明想", bold: true),
        vline("祈愿佛光注照身心和安", py: "qí yuàn fó guāng zhù zhào shēn xīn hé ān", notes: "_ _ _ _ _ _ _ _ _ o"),
        vline("祈愿甘露法雨长养慈悲", py: "qí yuàn gān lù fǎ yǔ zhǎng yǎng cí bēi", notes: ""),
        vline("祈愿三业清净心无挂碍", py: "qí yuàn sān yè qīng jìng xīn wú guà ài", notes: "_ _ _ _ _ _ _ _ _ o"),
        vline("祈愿菩萨行愿福慧圆满", py: "qi yuàn pú sà xíng yuàn fú huì yuán mǎn", notes: "o _ _ _ _ _ _ o _ o"),
        vline("阿弥陀佛", py: "ā mí tuó fó"),
        vline("回向偈", bold: true),
        vline("愿以此功德庄严佛净土", py: "yuàn yǐ cǐ gōng dé zhuāng yán fó jìng tǔ"),
        vline("上报四重恩下济三途苦", py: "shàng bào sì zhòng ēn xià jì sān tú kǔ"),
        vline("若有见闻者悉发菩提心", py: "ruò yǒu jiàn wén zhě xī fā pú tí xīn"),
        vline("常行菩萨道广度诸有情", py: "cháng xìn pú sà dào guǎng dù zhū yǒu qíng"),
        vline("阿弥陀佛", py: "ā mí tuó fó"),
      )
    ],
  )
]
