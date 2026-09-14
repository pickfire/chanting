#set page(
  paper: "a4",
  flipped: true, 
  margin: 1.5cm,
)

#let draw-single-note(n) = {
  // Fixed size box for all symbols so they align identically
  box(width: 8pt, height: 8pt, align(center + horizon)[
    #if n == "。" or n == "." {
      place(center + horizon, circle(radius: 1.5pt, stroke: 1.2pt + rgb("1E88E5"))) // Blue
    } else if n == "◎" or n == "@" {
      box(width: 6pt, height: 6pt)[
        #place(center + horizon, circle(radius: 2pt, stroke: 1pt + rgb("1E88E5"))) // Blue
        #place(center + horizon, circle(radius: 1pt, fill: rgb("1E88E5"))) // Blue
      ]
    } else if n == "△" or n == "^" {
      // Right triangle rotated 90 degrees
      place(center + top, polygon(
        fill: none,
        stroke: 1.2pt + rgb("E53935"), // Red
        (0pt, 0pt), (6pt, 0pt), (0pt, 6pt)
      ))
    } else if n == "x" or n == "X" {
      box(width: 6pt, height: 6pt)[
        #place(center + horizon, circle(radius: 2pt, stroke: 1pt + rgb("E53935"))) // Red circle
        #place(center + horizon, line(start: (1pt, 1pt), end: (5pt, 5pt), stroke: 1pt + rgb("000000"))) // Black X
        #place(center + horizon, line(start: (1pt, 5pt), end: (5pt, 1pt), stroke: 1pt + rgb("000000")))
      ]
    } else if n == "o" or n == "O" or n == "○" {
      place(center + horizon, circle(radius: 2pt, stroke: 1pt + rgb("1E88E5"))) // Blue
    } else if n == "⊥" or n == "T" {
      box(width: 6pt, height: 6pt)[
        #place(line(start: (3pt, 0pt), end: (3pt, 6pt), stroke: 1.2pt + rgb("E53935"))) // Red
        #place(line(start: (0pt, 6pt), end: (6pt, 6pt), stroke: 1.2pt + rgb("E53935"))) // Red
      ]
    } else if n == "-" {
      // Horizontal dash - centered vertically using place!
      place(center + horizon, line(length: 5pt, stroke: 1.5pt + rgb("E53935"))) // Red
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
    ..notes.map(char => draw-single-note(char))
  )
}

#let char-pinyin-note-vertical(c, p, n, is_last_bar: false) = box(width: 1em)[ // increased box width so notes don't overflow
  #set align(left) // FoRCE left alignment so the 2em character column NEVER shifts
  #let top-pad = if n.contains("^") { 0pt } else { 6pt }
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
    move(dy: -4pt, text(7.5pt, fill: rgb("666"), p)),
    []
  )
]

#let vline(cn, py: "", notes: "") = {
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
  
  box(stack(dir: ttb, spacing: 0pt, ..cells))
}

#let sutra-block(..lines) = {
  align(top + right)[
    #stack(
      dir: rtl,
      spacing: 2.5em,
      ..lines
    )
  ]
}

// --- DEMo oF ALL SYMBoLS ---
#sutra-block(
  vline("法器符号演示", py: "fǎ qì fú hào yǎn shì", notes: ". @.. ^- oo T"),
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
  vline("观音菩萨", py: "guān yīn pú sà", notes: "o- o o- o")
)
#pagebreak()

// --- DoCUMENT CoNTENT ---

#sutra-block(
  vline("南无本师释迦牟尼佛", py: "ná mó běn shī shì jiā móu ní fó", notes: "  .  . . . o. o"),
  vline("开经偈", py: "kāi jīng jì"),
  vline("无上甚深微妙法", py: "wú shàng shén shēn wéi miào fǎ", notes: "o.  . . . o^ o"),
  vline("百千万劫难遭遇", py: "bǎi qiān wàn jié nàn zāo yù", notes: "o.  . . . o. o"),
  vline("我今见闻得受持", py: "wǒ jīn jiàn wén dé shòu chí", notes: "o.  . . . o. o"),
  vline("愿解如来真实义", py: "yuàn jiě rú lái zhēn shí yì", notes: "o.  . . . o. o"),
  vline("般若波罗蜜多心经", py: "bō rě bō luó mì duō xīn jīng", notes: "_ . . . . . o _"),
  vline("观自在菩萨", py: "guān zì zài pú sà", notes: "o . . . o"),
  vline("行深般若波罗蜜多时", py: "xíng shēn bō rě bō luó mì duō shí", notes: "o . . . . . . . o"),
  vline("照见五蕴皆空度⼀切苦厄", py: "zhào jiàn wǔ yùn jiē kōng dù yī qiē kǔ è", notes: "o . . . . o o . . . o"),
  vline("舍利子色不异空", py: "shè lì zǐ sè bù yì kōng", notes: "   。   。"),
  vline("空不异色", py: "kōng bù yì sè", notes: "   。"),
  vline("色即是空", py: "sè jí shì kōng", notes: "   。"),
  vline("空即是色", py: "kōng jí shì sè", notes: "   。")
)
#pagebreak()
#sutra-block(
  vline("般若波罗蜜多心经", py: "bō rě bō luó mì duō xīn jīng", notes: "        。"),
  vline("受想行识亦复如是", py: "shòu xiǎng xíng shí yì fù rú shì", notes: ". . . o o . . o"),
  vline("舍利子是诸法空相", py: "shè lì zǐ shì zhū fǎ kōng xiāng", notes: "o . . . . . o o"),
  vline("不生不灭不垢不净不增不减", py: "bù shēng bù miè bù gòu bù jìng bù zēng bù jiǎn", notes: ". . . o o . . o o . . o"),
  vline("是故空中无色", py: "shì gù kōng zhōng wú sè", notes: "o . . . . o"),
  vline("无受想行识", py: "wú shòu xiǎng xíng shí", notes: "o . . . o"),
  vline("般若波罗蜜多心经", py: "bō rě bō luó mì duō xīn jīng", notes: "        。"),
  vline("无眼耳鼻舌身意", py: "wú yǎn ěr bí shé shēn yì", notes: "o . . . . . o"),
  vline("无色声香味触法", py: "wú sè shēng xiāng wèi chù fǎ", notes: "o . . . . . o"),
  vline("无眼界乃⾄无意识界", py: "wú yǎn jiè nǎi zhì wú yì shí jiè", notes: "o . . . o o . . o"),
  vline("无无明亦无无明尽", py: "wú wú míng yì wú wú míng jìn", notes: "o . . . . . . o"),
  vline("乃⾄无老死亦无老死尽", py: "nǎi zhì wú lǎo sǐ yì wú lǎo sǐ jìn", notes: "o . . . o o . . . o"),
  vline("般若波罗蜜多心经", py: "bō rě bō luó mì duō xīn jīng", notes: "        。"),
  vline("无苦集灭道无智亦无得", py: "wú kǔ jí miè dào wú zhì yì wú dé", notes: "o . . . o o . . . o")
)
#pagebreak()
#sutra-block(
  vline("以无所得故菩提萨埵", py: "yǐ wú suǒ dé gù pú tí sà duǒ", notes: "o . . . o o . . o"),
  vline("依般若波罗蜜多故", py: "yī bō rě bō luó mì duō gù", notes: "o . . . . . . o"),
  vline("心无挂碍", py: "xīn wú guà ài", notes: "o . . o"),
  vline("般若波罗蜜多心经", py: "bō rě bō luó mì duō xīn jīng", notes: "        。"),
  vline("无挂碍故无有恐怖", py: "wú guà ài gù wú yǒu kǒng bù", notes: "o . . o o . . o"),
  vline("远离颠倒梦想究竟涅槃", py: "yuǎn lí diān dǎo mèng xiǎng jiū jìng niè pán", notes: "o . . . . o o . . o"),
  vline("三世诸佛依般若波罗蜜多故", py: "sān shì zhū fó yī bō rě bō luó mì duō gù", notes: "o . . o o . . . . . . o"),
  vline("得阿耨多罗三藐三菩提", py: "dé ā nuò duō luó sān miǎo sān pú tí", notes: "o . . . o o . . . o"),
  vline("般若波罗蜜多心经", py: "bō rě bō luó mì duō xīn jīng", notes: "        。"),
  vline("故知般若波罗蜜多", py: "gù zhī bō rě bō luó mì duō", notes: "o . . . . . . o"),
  vline("是大神咒是大明咒", py: "shì dà shén zhòu shì dà míng zhòu", notes: "o . . o o . . o"),
  vline("是无上咒是无等等咒", py: "shì wú shàng zhòu shì wú děng děng zhòu", notes: "o . . o o . . . o"),
  vline("能除⼀切苦真实不虚", py: "néng chú yī qiē kǔ zhēn shí bù xū", notes: "o . . . o o . . o"),
  vline("般若波罗蜜多心经", py: "bō rě bō luó mì duō xīn jīng", notes: "        。")
)
#pagebreak()
#sutra-block(
  vline("故说般若波罗蜜多咒", py: "gù shuō bō rě bō luó mì duō zhòu", notes: "o . . . . . . . o"),
  vline("即说咒⽈", py: "jí shuō zhòu yuē", notes: "o . . o"),
  vline("“揭谛揭谛波罗揭谛", py: "jiē dì jiē dì bō luó jiē dì", notes: " o . . o o . . o"),
  vline("波罗僧揭谛菩提萨婆诃”", py: "bō luó sēng jiē dì pú tí sà pó hē", notes: "o . . . o o . . . o "),
  vline("般若波罗蜜多心经", py: "bō rě bō luó mì duō xīn jīng", notes: "        。"),
  vline("普陀⼭琉璃世界", py: "pǔ tuó shān liú lí shì jiè", notes: "_ . . . . . o"),
  vline("大慈大悲观世⾳菩萨", py: "dà cí dà bēi guān shì yīn pú sà", notes: "o . . . o . . . o"),
  vline("南无观世⾳菩萨", py: "ná mó guān shì yīn pú sà", notes: "_ . . . . . o"),
  vline("转念四字", py: ""),
  vline("观⾳菩萨", py: "guān yīn pú sà"),
  vline("普贤十大愿", py: "pǔ xián shí dà yuàn"),
  vline("⼀者礼敬诸佛", py: "yī zhě lǐ jìng zhū fó"),
  vline("二者称赞如来", py: "èr zhě chēng zàn rú lái"),
  vline("三者广修供养", py: "sān zhě guǎng xiū gong yǎng")
)
#pagebreak()
#sutra-block(
  vline("四者忏悔业障", py: "sì zhě chàn huǐ yè zhàng", notes: "o . . . . o"),
  vline("五者随喜功德", py: "wǔ zhě suí xǐ gong dé", notes: "o . . . . o"),
  vline("普贤十大愿", py: "pǔ xián shí dà yuàn"),
  vline("六者请转法轮", py: "liù zhě qǐng zhuǎn fǎ lún", notes: "o . . . . o"),
  vline("七者请佛住世", py: "qī zhě qǐng fó zhù shì", notes: "o . . . . o"),
  vline("八者常随佛学", py: "bā zhě cháng suí fó xué", notes: "o . . . . o"),
  vline("九者恒顺众生", py: "jiǔ zhě héng shùn zhòng shēng", notes: "o . . . . o"),
  vline("十者普皆回向", py: "shí zhě pǔ jiē huí xiàng", notes: "o . . . . o"),
  vline("普贤十大愿", py: "pǔ xián shí dà yuàn"),
  vline("十方三世⼀切佛", py: "shí fāng sān shì yī qiè fó", notes: "o . . . . . o"),
  vline("⼀切菩萨摩诃萨", py: "yī qiè pú sà mó hē sà"),
  vline("摩诃般若波罗蜜", py: "mó hē bō rě bō luó mì"),
  vline("三皈依", py: "sān guī yī"),
  vline("自皈依佛当愿众生体解大道发无上心", py: "zì guī yī fó dāng yuàn zhòng shēng tǐ jiě dà dào fā wú shàng xīn")
)
#pagebreak()
#sutra-block(
  vline("自皈依法当愿众生深入经藏智慧如海", py: "zì guī yī fǎ dāng yuàn zhòng shēng shēn rù jīng zàng zhì huì rú hǎi", notes: "o . . o o . . o o . . o o . . o"),
  vline("自皈依僧当愿众生统理大众一切无碍", py: "zì guī yī sēng dāng yuàn zhòng shēng tǒng lǐ dà zhòng yī qiè wú ài", notes: "o . . o o . . o o . . o o . . o"),
  vline("回向偈", py: "huí xiàng jì"),
  vline("愿消三障诸烦恼", py: "yuàn xiāo sān zhàng zhū fán nǎo", notes: "o . . . . . o"),
  vline("愿得智慧真明了", py: "Yuàn dé zhì huì zhēn míng liǎo", notes: "o . . . . . o"),
  vline("普愿罪障悉消除", py: "pǔ yuàn zuì zhàng xī xiāo chú", notes: "o . . . . . o"),
  vline("世世常行菩萨道", py: "shì shì cháng xíng pú sà dào", notes: "o . . . . . o"),
  vline("四光明想", py: "sì guāng míng xiǎng"),
  vline("祈愿佛光注照身心和安", py: "qí yuàn fó guāng zhù zhào shēn xīn hé ān", notes: "o . . . . o o . . o"),
  vline("祈愿甘露法雨长养慈悲", py: "qí yuàn gān lù fǎ yǔ zhǎng yǎng cí bēi", notes: "o . . . . o o . . o"),
  vline("祈愿三业清净心无挂碍", py: "qí yuàn sān yè qīng jìng xīn wú guà ài"),
  vline("祈愿菩萨行愿福慧圆满", py: "qi yuàn pú sà xíng yuàn fú huì yuán mǎn"),
  vline("阿弥陀佛", py: "ā mí tuó fó"),
  vline("回向偈", py: "huí xiàng jì")
)
#pagebreak()
#sutra-block(
  vline("愿以此功德庄严佛净土", py: "yuàn yǐ cǐ gōng dé zhuāng yán fó jìng tǔ"),
  vline("上报四重恩下济三途苦", py: "shàng bào sì zhòng ēn xià jì sān tú kǔ"),
  vline("若有见闻者悉发菩提心", py: "ruò yǒu jiàn wén zhě xī fā pú tí xīn"),
  vline("常行菩萨道广度诸有情", py: "cháng xìn pú sà dào guǎng dù zhū yǒu qíng"),
  vline("阿弥陀佛", py: "ā mí tuó fó")
)
