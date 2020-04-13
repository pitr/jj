import tables, strutils, sequtils, math

type
  ElType = enum eInt, eBox
  El = ref object
    case kind: ElType
      of eInt: i: int
      of eBox: a: Arr
  Arr* = ref object
    depth: seq[int]
    data: seq[El]
  TokenType = enum tNum, tVar, tVerb
  Token = ref object
    case kind: TokenType
      of tNum: number: int
      of tVar: variable: string
      of tVerb: ix: int

proc `$`*(a: Arr): string =
  for i, d in a.data:
    if d.kind == eBox: result.add "<" & $d.a & ">" else: result.add $d.i
    if i < a.data.len-1: result.add(" ")

proc newArr(depth, data: seq[int]): Arr =
  Arr(depth: depth, data: data.mapIt(El(kind: eInt, i: it)))
proc tr(d: seq[int]): int = d.foldl(a*b, 1)

# monadic
proc id(a: Arr): Arr = a
proc size(a: Arr): Arr =
  newArr(@[], @[if a.data.anyIt(it.kind == eBox): a.depth[0] else: 1])
proc iota(a: Arr): Arr = newArr(@[a.data[0].i], toSeq(0..<a.data[0].i))
proc box(a: Arr): Arr = Arr(depth: @[], data: @[El(kind: eBox, a: a)])
proc sha(a: Arr): Arr = newArr(@[a.depth.len], a.depth)

# dyadic
proc plus(a, b: Arr): Arr =
  newArr(b.depth, zip(a.data, b.data).mapIt(it[0].i+it[1].i))
proc frm(a, b: Arr): Arr =
  let d = b.depth[1..<b.depth.len];
  let n = tr(d)
  newArr(d, toSeq(0..<n).mapIt(b.data[n * a.data[0].i + it].i))
proc rsh(a, b: Arr): Arr =
  let n = if a.depth.len == 0: a.data[0].i
    else: tr(a.data[0..<a.depth[0]].mapIt(it.i))
  Arr(
    depth: a.data.mapIt(it.i),
    data: b.data.cycle(toInt(ceil(n/b.data.len)))[0..<n]
  )
proc cat(a, b: Arr): Arr =
  Arr(depth: @[tr(a.depth) + tr(b.depth)], data: concat(a.data, b.data))

const verbs = "+{~<#,="
const vm = @[id, size, iota, box, sha]
const vd = @[plus, frm, nil, nil, rsh, cat]

proc eval*(tt: seq[Token], env: TableRef[string, Arr]): Arr =
  if tt.len == 0: return newArr(@[], @[])
  let t = tt[0]
  if t.kind == tVar:
    if tt.len > 1 and tt[1].kind == tVerb and verbs[tt[1].ix] == '=':
      env[t.variable] = eval(tt[2..<tt.len], env)
      return env[t.variable]
    else: result = env[t.variable]
  elif t.kind == tNum: result = newArr(@[], @[t.number])

  if t.kind == tVerb: result = vm[t.ix](eval(tt[1..<tt.len], env))
  elif tt.len > 1 and tt[1].kind == tVerb:
    result = vd[tt[1].ix](result, eval(tt[2..<tt.len], env))

proc parse*(s: string): seq[Token] =
  var i = 0
  while i < s.len:
    while s[i] == ' ': inc(i)
    let j = i
    while i < s.len and s[i] >= '0' and s[i] <= '9': inc(i)
    if i > j: result.add Token(kind: tNum, number: parseInt(s[j..<i])); continue
    while i < s.len and s[i] >= 'a' and s[i] <= 'z': inc(i)
    if i > j: result.add Token(kind: tVar, variable: s[j..<i]); continue
    result.add Token(kind: tVerb, ix: verbs.find(s[i]))
    inc(i)

when isMainModule:
  var env = newTable[string, Arr]()
  write(stdout, "2020 jj\n  ")
  for line in lines stdin: write(stdout, $eval(parse line, env) & "\n  ")
