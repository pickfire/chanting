#set page(
  paper: "a3",
  flipped: true,
  margin: 1cm,
)

#let hei-font = ("Noto Sans CJK SC", "Source Han Sans", "MiSans")
#set text(font: hei-font)
#let blue-note = rgb("1E88E5")
#let red-note = rgb("E53935")

#let draw-single-note(n) = box(width: 6pt, height: 6pt, align(center + horizon, {
  if n in ("o", "O", "○", "。") {
    place(center + horizon, circle(radius: 1.2pt, stroke: 0.7pt + blue-note))
  } else if n in ("◎", "@") {
    box(width: 5pt, height: 5pt, {
      place(center + horizon, circle(radius: 2.0pt, stroke: 0.7pt + blue-note))
      place(center + horizon, circle(radius: 0.5pt, fill: blue-note))
    })
  } else if n in ("△", "^") {
    place(center + top, polygon(
      fill: none,
      stroke: (paint: red-note, thickness: 0.7pt, miter-limit: 10.0),
      (0pt, 0pt),
      (5pt, 0pt),
      (5pt, 3.09pt),
    ))
  } else if n in ("⊥", "T") {
    box(width: 5pt, height: 5pt, {
      place(line(start: (2.5pt, 0pt), end: (2.5pt, 5pt), stroke: 0.7pt + red-note))
      place(line(start: (0pt, 5pt), end: (5pt, 5pt), stroke: 0.7pt + red-note))
    })
  } else if n == "-" {
    place(center + horizon, line(length: 4pt, stroke: 0.7pt + red-note))
  } else if n not in ("_", " ", "") {
    text(9.5pt, fill: red-note, weight: "bold", n)
  }
}))

#let draw-note(n) = stack(
  dir: ttb,
  spacing: -2.0pt,
  ..n.clusters().map(draw-single-note),
)

#let char-pinyin-note-vertical(c, p, n, is_last_bar: false) = {
  let n_rest = n.replace("|", "")
  let top_pad = if n.contains("^") { 0pt } else if n_rest in ("-", "--") { 9.0pt } else { 4.5pt }
  let line_len = if is_last_bar { 18.0pt } else { 22.8pt }

  let (r1_note, r2_note) = if n_rest == "--" {
    ("-", "-")
  } else if n_rest.contains("_-") {
    (n_rest.replace("_-", ""), "-")
  } else {
    (n_rest, "")
  }

  grid(
    columns: (17pt, auto),
    rows: (15.5pt, 5.8pt),
    align: (center + horizon, left + top),
    // Row 1: Character (col 1), Note (col 2)
    box(width: 17pt, height: 15.5pt, {
      if n.contains("|") {
        place(left + top, line(angle: 90deg, length: line_len, stroke: 1.2pt + rgb("999999")))
      }
      place(center + horizon, text(13pt, font: hei-font, weight: "medium", c))
    }),
    if r1_note not in ("", " ", "　") { move(dy: top_pad, draw-note(r1_note)) } else { [] },
    // Row 2: Pinyin (col 1), empty (col 2)
    move(dy: -2.5pt, text(4.5pt, fill: rgb("666"), p)), if r2_note != "" { move(dy: -0.8pt, draw-note(r2_note)) } else { [] },
  )
}

#let title-column(cn) = {
  let cells = cn.clusters().map(c => box(width: 17pt, height: 22.8pt, align(top, box(width: 17pt, height: 15.5pt, align(center + horizon, text(13pt, font: hei-font, weight: "bold", c))))))
  let title_box = rect(
    stroke: 1.0pt + black,
    inset: 0pt,
    outset: (top: 8pt, bottom: -0.5pt, left: 2.0pt, right: 2.0pt),
    radius: 2.5pt,
    stack(dir: ttb, spacing: 0pt, ..cells),
  )
  box(width: 25pt, align(left, stack(box(height: 10.5pt), title_box)))
}

#let render-subscript(subscript) = {
  let sub_stack = stack(dir: ttb, spacing: 1.5pt, ..subscript
    .clusters()
    .map(c => {
      let t = text(9.5pt, font: hei-font, weight: "medium", fill: rgb("333"), c)
      if c in "（）()" { rotate(90deg, t) } else { t }
    }))
  box(width: 17pt, height: auto, align(center + top, move(dy: 5pt, sub_stack)))
}

#let vline(cn, py: "", notes: "", subscript: "", bold: false) = {
  if bold { return title-column(cn) }

  let c_arr = cn.clusters()
  let p_arr = if py != "" { py.split(" ") } else { () }

  // Use split(" ") to allow grouping multiple notes to one character!
  let n_arr = if notes != "" { notes.split(" ") } else { () }

  let top_note = ""
  if n_arr.at(0, default: "").contains("^") {
    top_note = n_arr.at(0)
    n_arr.at(0) = ""
  }

  let top_row = grid(
    columns: (17pt, auto),
    rows: (10.5pt,),
    align: (center + horizon, left + top),
    [], if top_note != "" { draw-note(top_note) },
  )

  let max_len = calc.max(c_arr.len(), p_arr.len(), n_arr.len())
  let cells = (
    top_row,
    ..range(max_len).map(i => {
      let c = c_arr.at(i, default: "　")
      let p = p_arr.at(i, default: " ")
      let n = n_arr.at(i, default: "")
      if n in (" ", "　") { n = "" }
      if c in (" ", "") { c = "　" }
      let is_last_bar = n.contains("|") and not n_arr.at(i + 1, default: "").contains("|")
      char-pinyin-note-vertical(c, p, n, is_last_bar: is_last_bar)
    }),
  )

  let col = stack(dir: ttb, spacing: 1.5pt, ..cells)
  if subscript != "" {
    col = stack(dir: ttb, spacing: 2.5pt, col, render-subscript(subscript))
  }

  box(width: 25pt, align(left, col))
}

#let chant-section(..lines) = box[
  #set align(top + right)
  #stack(dir: rtl, spacing: 4.8pt, ..lines)
]

// --- FULL PAGE LAYOUT ---
#align(right)[
  #grid(
    columns: (100%,),
    rows: (auto, 1fr, auto),
    chant-section(
      vline("", subscript: "（问讯、礼佛三拜、问讯）"),
      vline("南无本师释迦牟尼佛", py: "ná mó běn shī shì jiā móu ní fó", notes: "^o _ o o o o o o o- o"),
      vline("南无本师释迦牟尼佛", py: "ná mó běn shī shì jiā móu ní fó", notes: "o o o o o o o o o o"),
      vline("南无本师释迦牟尼佛", py: "ná mó běn shī shì jiā móu ní fó", notes: "o o o- o o o o o o"),
      vline("开经偈", bold: true),
      vline("无上甚深微妙法　百千万劫难遭遇", py: "wú shàng shén shēn wéi miào fǎ  bǎi qiān wàn jié nàn zāo yù", notes: "^o _ o o o o o- o o o o o o o o o"),
      vline("我今见闻得受持　愿解如来真实义", py: "wǒ jīn jiàn wén dé shòu chí  yuàn jiě rú lái zhēn shí yì", notes: "o o o o o o o o o- o o o o- o o-", subscript: "（过门）"),
      vline("般若波罗蜜多心经", py: "bō rě bō luó mì duō xīn jīng", notes: "^o _ o o o o o o-"),
      vline("观自在菩萨行深般若波罗蜜多时照", py: "guān zì zài pú sà xíng shēn bō rě bō luó mì duō shí zhào", notes: "o o o o o o o o o o o o o o o"),
      vline("见五蕴皆空度一切苦厄舍利子色不", py: "jiàn wǔ yùn jiē kōng dù yī qiē kǔ è shè lì zǐ sè bù", notes: "o o o o o o o o o o o o o o o"),
      vline("异空空不异色色即是空空即是色受", py: "yì kōng kōng bù yì sè sè jí shì kōng kōng jí shì sè shòu", notes: "o o o o o o o o o o o o o o o"),
      vline("想行识亦复如是舍利子是诸法空相", py: "xiǎng xíng shí yì fù rú shì shè lì zǐ shì zhū fǎ kōng xiāng", notes: "o o o o o o o o o o o o o o o"),
      vline("不生不灭不垢不净不增不减是故空", py: "bù shēng bù miè bù gòu bù jìng bù zēng bù jiǎn shì gù kōng", notes: "o o o o o o o o o o o o o o o-"),
      vline("中无色无受想行识无眼耳鼻舌身意", py: "zhōng wú sè wú shòu xiǎng xíng shí wú yǎn ěr bí shé shēn yì", notes: "o o o o o o o o- o o o o o o o"),
      vline("无色声香味触法无眼界乃至无意识", py: "wú sè shēng xiāng wèi chù fǎ wú yǎn jiè nǎi zhì wú yì shí", notes: "o o o o o o o o o o o o o o o"),
      vline("界无无明亦无无明尽乃至无老死亦", py: "jiè wú wú míng yì wú wú míng jìn nǎi zhì wú lǎo sǐ yì", notes: "o o o o o o o o o o o o o o o"),
      vline("无老死尽无苦集灭道无智亦无得以", py: "wú lǎo sǐ jìn wú kǔ jí miè dào wú zhì yì wú dé yǐ", notes: "o o o o o o o o o o o o o o o"),
      vline("无所得故菩提萨埵依般若波罗蜜多", py: "wú suǒ dé gù pú tí sà duǒ yī bō rě bō luó mì duō", notes: "o o o o o o o o o o o o o o o"),
      vline("故心无挂碍无挂碍故无有恐怖远离", py: "gù xīn wú guà ài wú guà ài gù wú yǒu kǒng bù yuǎn lí", notes: "o o o o o o o o o o o o o o o"),
      vline("颠倒梦想究竟涅槃三世诸佛依般若", py: "diān dǎo mèng xiǎng jiū jìng niè pán sān shì zhū fó yī bō rě", notes: "o o o o o o o o o o o o- o o o"),
      vline("波罗蜜多故得阿耨多罗三藐三菩提", py: "bō luó mì duō gù dé ā nuò duō luó sān miǎo sān pú tí", notes: "o o o o o o o o o o o o o o o"),
      vline("故知般若波罗蜜多是大神咒是大明", py: "gù zhī bō rě bō luó mì duō shì dà shén zhòu shì dà míng", notes: "o o o o o o o o o o o o o o o"),
      vline("咒是无上咒是无等等咒能除一切苦", py: "zhòu shì wú shàng zhòu shì wú děng děng zhòu néng chú yī qiē kǔ", notes: "o o o o o o o o o o o o o o o"),
      vline("真实不虚故说般若波罗蜜多咒即说", py: "zhēn shí bù xū gù shuō bō rě bō luó mì duō zhòu jí shuō", notes: "o o o o o o o o o o o o o o o"),
      vline("咒曰揭谛揭谛波罗揭谛波罗僧揭谛", py: "zhòu yuē jiē dì jiē dì bō luó jiē dì bō luó sēng jiē dì", notes: "o o- o o o o o o o o o o o- o o"),
      vline("菩提萨婆诃　", py: "pú tí sà pó hē", notes: "o o o- o o -- o"),
      vline("摩诃般若波罗蜜多　", py: "mó hē bō rè bō luó mí duō", notes: "^o -- o -- o -- o_- o --"),
      vline("摩诃般若波罗蜜多　", py: "mó hē bō rè bō luó mí duō", notes: "o -- o -- o -- o_- o --"),
      vline("摩诃般若波罗蜜多　", py: "mó hē bō rè bō luó mí duō", notes: "o -- o -- o -- o_- o -- o", subscript: "（过门）"),
      vline("普陀山琉璃世界　", py: "pǔ tuó shān liú lí shì jiè ", notes: "^o |- |- o -- o_- o --"),
      vline("大慈大悲　观世音菩萨", py: "dà cí dà bēi  guān shì yīn pú sà", notes: "o -- o_- o -- o -- o_- o_- o"),
      vline("南无观世音菩萨", py: "ná mó guān shì yīn pú sà", notes: "^o _ o- _ o- _ o", subscript: "（多次）"),
      vline("南无观世音菩萨", py: "ná mó guān shì yīn pú sà", notes: "o _ o- _ o- - o", subscript: "（转念四字打法）"),
      vline("观音菩萨观音菩萨观音菩萨", py: "guān yīn pú sà guān yīn pú sà guān yīn pú sà", notes: "- - o _ - - o _ - - o _"),
      vline("观音菩萨", py: "guān yīn pú sà", notes: "o - o o"),
      vline("观音菩萨", py: "guān yīn pú sà", notes: "o- o o- o", subscript: "（多次）"),
      vline("观音菩萨", py: "guān yīn pú sà", notes: "o- o o- o-", subscript: "（通知煞板）"),
      vline("观音菩萨", py: "guān yīn pú sà", notes: "o- o o-- o", subscript: "（煞板、过门）"),
    ),
    align(center + horizon, line(length: 100%, stroke: 0.5pt)),
    chant-section(
      vline("普贤十大愿", bold: true),
      vline("一者礼敬诸佛　二者称赞如来　", py: "yī zhě lǐ jìng zhū fó  èr zhě chēng zàn rú lái", notes: "- - - - - - - - - - - - - -"),
      vline("三者广修供养　四者忏悔业障　", py: "sān zhě guǎng xiū gong yǎng  sì zhě chàn huǐ yè zhàng", notes: "- - - - - - - - - - - - - -"),
      vline("五者随喜功德　六者请转法轮　", py: "wǔ zhě suí xǐ gong dé  liù zhě qǐng zhuǎn fǎ lún", notes: "- - - - - - - - - - - - - -"),
      vline("七者请佛住世　八者常随佛学　", py: "qī zhě qǐng fó zhù shì  bā zhě cháng suí fó xué", notes: "- - - - - - - - - - - - - -"),
      vline("九者恒顺众生　十者普皆回向　", py: "jiǔ zhě héng shùn zhòng shēng  shí zhě pǔ jiē huí xiàng", notes: "- - - - - - - - - - - - - -"),
      vline("十方三世一切佛　一切菩萨摩诃萨　", py: "shí fāng sān shì yī qiè fó  yī qiè pú sà mó hē sà", notes: "- - - - - - - - - - - - - - - -"),
      vline("摩诃般若波罗蜜", py: "mó hē bō rě bō luó mì", notes: "- - - - - -- -", subscript: "（过门）"),
      vline("三皈依", bold: true),
      vline("自皈依佛　当愿众生", py: "zì guī yī fó  dāng yuàn zhòng shēng", notes: "^o o-- o-- o-- o-- o-- o-- o-- o-- o--"),
      vline("体解大道　发无上心", py: "tǐ jiě dà dào  fā wú shàng xīn", notes: "o-- o-- o-- o-- o-- o-- o-- o-- o-", subscript: "（拜）"),
      vline("自皈依法　当愿众生", py: "zì guī yī fǎ  dāng yuàn zhòng shēng", notes: "^o o-- o-- o-- o-- o-- o-- o-- o-- o--"),
      vline("深入经藏　智慧如海", py: "shēn rù jīng zàng  zhì huì rú hǎi", notes: "o-- o-- o-- o-- o-- o-- o-- o-- o-", subscript: "（拜）"),
      vline("自皈依僧　当愿众生", py: "zì guī yī sēng  dāng yuàn zhòng shēng", notes: "^o o-- o-- o-- o-- o-- o-- o-- o-- o--"),
      vline("统理大众　一切无碍", py: "tǒng lǐ dà zhòng  yī qiè wú ài", notes: "o-- o-- o-- o-- o-- o-- o-- o-- o-", subscript: "（拜、问讯）"),
      vline("回向偈", bold: true),
      vline("愿消三障　诸烦恼", py: "yuàn xiāo sān zhàng  zhū fán nǎo", notes: "^o _ o-- o-- o-- o-- o-- o-- o--"),
      vline("愿得智慧　真明了", py: "yuàn dé zhì huì  zhēn míng liǎo", notes: "o-- o-- o-- o-- o-- o-- o-- o-- o--"),
      vline("普愿罪障　悉消除", py: "pǔ yuàn zuì zhàng  xī xiāo chú", notes: "o-- o-- o-- o-- o-- o-- o-- o-- o--"),
      vline("世世常行　菩萨道", py: "shì shì cháng xíng  pú sà dào", notes: "o-- o-- o-- o-- o-- o-- o-- o-"),
      vline("四光明想", bold: true),
      vline("祈愿佛光注照身心和安", py: "qí yuàn fó guāng zhù zhào shēn xīn hé ān", notes: "^ _ _ _ _ _ _ _ _ -"),
      vline("祈愿甘露法雨长养慈悲", py: "qí yuàn gān lù fǎ yǔ zhǎng yǎng cí bēi", notes: ""),
      vline("祈愿三业清净心无挂碍", py: "qí yuàn sān yè qīng jìng xīn wú guà ài", notes: ""),
      vline("祈愿菩萨行愿福慧圆满", py: "qi yuàn pú sà xíng yuàn fú huì yuán mǎn", notes: "- _ _ _ _ _ _ - _ -", subscript: "（礼佛三拜、问讯）"),
    ),
  )
]
