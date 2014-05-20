
# 肯定先読み
# (?=X)
# 否定先読み
# (?!X)
# 肯定あと読み
# (?<=X)
# 否定あと読み
# (?<!X)

# Type check functions
isundefined = (x) -> typeof x is undefined
isarray = (x) -> not isundefined x.length
isfunction = (x) -> x.constructor is Function

# For strict code, arguments check
# After defining a function, which convert String to RegExp
#   build = (x) -> new RegExp x
# you should restrict the argument to String as:
#   build = arg [String], (x) -> new RegExp x
###
arg = (x, y) ->
  throw 'first argument of function arg should be an Array' if not isarray x
  throw 'second argument of function arg should be a Function' if not isfunction y
  () ->
    throw 'Arguments length is something wrong' if arguments.length isnt x.length
    for z,i in arguments
      throw 'Too many arguments' if isundefined x[i]
      throw (i + 1) + 'th argument should be a ' + x[i].name if z.constructor isnt x[i]
    y.apply this, arguments
###
arg = (x, y) ->
  throw 'first argument of arg should be an Array' if x.length is undefined
  throw 'second argument of arg should be a Function' if y.constructor isnt Function
  () ->
    throw 'Arguments length is different' if arguments.length isnt x.length
    for z,i in arguments
      throw 'Too many arguments' if isundefined x[i]
      throw (i + 1) + 'th argument should be a ' + x[i].name if z.constructor isnt x[i]
    y.apply this, arguments





# Basic small functions
map = arg [Function, Array], (f, a) -> (f i for i in a)
join = arg [String, Array], (x, y) -> y.join x
paren = arg [String], (x) ->
  len = x.length
  if x[0] is '(' and x[len - 1] is ')'
    i = -1
    count = 0
    escp = false
    while (i++ <= len)
      if x[i] is '\\'
        escp = not escp
      else if x[i - 1] is '\\' and escp
        escp = false
      if x[i] is '(' and not escp
        ++count
      if x[i] is ')' and not escp
        --count
        if count is 0 then return '(?:' + x + ')'
    return if count is 0 then x else '(?:' + x + ')'
  else return '(?:' + x + ')'
bracket = arg [String], (x) -> '[' + x + ']'
build = arg [String], (x) -> new RegExp x
convertescape = arg [String], (x) -> ((((((x
  .replace '[', '\\[')
  .replace ']', '\\]')
  .replace '.', '\\.')
  .replace '*', '\\*')
  .replace '/', '\\/')
  .replace '\\', '\\\\')
opt = arg [RegExp], (x) -> build if x.source.slice(-1) is '+' then x.source.slice(0, -1) + '*' else (paren x.source) + '?'
tostr = (x) -> if x.constructor is RegExp then x.source else convertescape x
$ = (x) -> x


# 
Reg =
  or: arg [Array], $ (x) -> build paren join '|', map tostr,x
  bracket: arg [Array], $ (x) -> build bracket join '', map tostr,x
  concat: arg [Array], $ (x) -> build paren join '', map tostr, x
  concatregexclass: arg [Array], $ (x) ->
    a = map tostr, x
    s = '['
    for i in a
      if i[0] isnt '[' or i[i.length - 1] isnt ']'
        throw 'arguments RegExp for concatregexclass should be [ac-f] or something like that. \n' + i
      if i[1] is '^'
        throw 'arguments RegExp cannot be [^abc].\n ' + i
      s += i.slice 1, -1
    build s + ']'
  repeat: arg [RegExp], $ (x) -> build x.source + '+'
  replicate: arg [Number, RegExp], $ (x, y) -> build (paren tostr y) + '{' + x + '}'
  not: arg [RegExp], $ (x) -> build '[^' + x.source.slice(1)   # argument RegExp should be like [ac-exyz]
  regex: []
  name: []
  map: arg [Function], $ (x, y) -> (x i, y for i in @regex)
  register: arg [String, RegExp], $ (x, y) ->
    Reg.name.push x
    Reg.regex.push y
    this[x] = y
    this[x].name = x
    eval x + '=' + y
    y

Reg.register 'SourceCharacter', /./
Reg.register 'WhiteSpace', Reg.or([
  /\u0009/  # <TAB> Tab
  /\u000B/  # <VT> Vertical Tab
  /\u000C/  # <FF> Form Feed
  /\u0020/  # <SP> Space
  /\u00A0/  # <NBSP> No-break space
  /[\u1680\u180E\u2000-\u2009\u200A\u2028\u202F\u205F\u3000]/  # <USP> ??
])
Reg.register 'LineTerminator', Reg.bracket([
  /\u000A/  # <LF> Line Feed
  /\u000D/  # <CR> Carriage Return
  /\u2028/  # <LS> Line separator
  /\u2029/  # <PS> Paragraph separator
])
Reg.register 'LineTerminatorSequence', Reg.or([
  /\u000A/  # <LF> Line Feed
  /\u000D/  # <CR> Carriage Return
  /\u2028/  # <LS> Line separator
  /\u2029/  # <PS> Paragraph separator
  /\u000D\u2029/  # <CR><LF>
])
Reg.register 'InputElementDiv', Reg.or([
  WhiteSpace
  LineTerminator
#  Comment           #TODO
#  Token
#  DivPunctuator
])

Reg.register 'MultiLineCommentChars', /TODO/
Reg.register 'MultiLineComment', Reg.concat([
  /\/\*/
  opt MultiLineCommentChars
  /\*\//
])
Reg.register 'SingleLineCommentChar', Reg.not LineTerminator
Reg.register 'SingleLineCommentChars', Reg.repeat SingleLineCommentChar
Reg.register 'SingleLineComment', Reg.concat([
  /\/\//
  opt SingleLineCommentChars
])
Reg.register 'Comment', Reg.or([
  MultiLineComment
  SingleLineComment
])
# NumericLiteral
Reg.register 'ExponentIndicator', /[eE]/
Reg.register 'DecimalDigit', /[0-9]/
Reg.register 'NonZeroDigit', /[1-9]/
Reg.register 'HexDigit', /[0-9a-fA-F]/
Reg.register 'DecimalDigits', Reg.repeat DecimalDigit
Reg.register 'DecimalIntegerLiteral', Reg.or([
  /0/
  Reg.concat([
    NonZeroDigit
    opt DecimalDigits
  ])
])
Reg.register 'SignedInteger', Reg.concat([
  /[+-]?/
  DecimalDigits
])
Reg.register 'HexIntegerLiteral', Reg.concat([
  /0[xX]/
  Reg.repeat HexDigit
])
Reg.register 'ExponentPart', Reg.concat([
  ExponentIndicator
  SignedInteger
])
Reg.register 'DecimalLiteral', Reg.or([
  Reg.concat([
    DecimalIntegerLiteral
    opt Reg.concat([
      /\./
      opt DecimalDigits
    ])
    opt ExponentPart
  ])
  Reg.concat([
    /\./
    DecimalDigits
    opt ExponentPart
  ])
])


Reg.register 'NumericLiteral', Reg.or([
  DecimalLiteral
  HexIntegerLiteral
])
Reg.register 'UnicodeEscapeSequence', Reg.concat([
  /u/
  Reg.replicate 4, HexDigit
])
Reg.register 'UnicodeLetter', Reg.or([
  /[A-Z]/   # Uppercase letter
  /[a-z]/   # Lowercase letter
  # Titlecase letter
  # Modifier letter
  # Other Letter
  # Letter number
])
Reg.register 'IdentifierStart', Reg.or([
  UnicodeLetter
  /\$/
  /_/
  Reg.concat([
    /\\/
    UnicodeEscapeSequence
  ])
])
Reg.register 'UnicodeDigit', /[0-9]/  # is not exact
Reg.register 'IdentifierPart', Reg.or([
  IdentifierStart
  # UnicodeCombiningMark
  UnicodeDigit
  # UnicodeConnectorPunctuation
])
Reg.register 'IdentifierName', Reg.or([  # is not exact definition
  Reg.concat([
    IdentifierStart
    Reg.repeat IdentifierPart
  ])
  IdentifierStart
])

Reg.register 'Keyword', /break|case|catch|continue|debugger|default|delete|do|else|finally|for|function|if|in|instanceof|new|return|switch|this|throw|try|typeof|var|void|while|with/
Reg.register 'FutureReservedWord', /class|enum|export|extends|import|super|implements|interface|let|package|private|protected|public|static|yield/

Reg.register 'NullLiteral', /null/
Reg.register 'BooleanLiteral', /true|false/

Reg.register 'RegularExpressionNonTerminator', Reg.not LineTerminator
Reg.register 'RegularExpressionClassChar', Reg.not Reg.concatregexclass([
  /[\]\\]/
  LineTerminator
])
Reg.register 'RegularExpressionClassChars', Reg.or([
  ''
  Reg.repeat RegularExpressionClassChar
])
Reg.register 'RegularExpressionBackslashSequence', Reg.concat([
  /\\/
  RegularExpressionNonTerminator
])
Reg.register 'RegularExpressionClass', Reg.concat([
  /\[/
  RegularExpressionClassChars
  /\]/
])
Reg.register 'RegularExpressionFirstChar', Reg.or([
  Reg.not Reg.concatregexclass([
    /[\*\\\/\[]/
    LineTerminator
  ])
  RegularExpressionBackslashSequence
  RegularExpressionClass
])
Reg.register 'RegularExpressionChar', Reg.or([
  Reg.not Reg.concatregexclass([
    /[\\\/\[]/
    LineTerminator
  ])
  RegularExpressionBackslashSequence
  RegularExpressionClass
])
Reg.register 'RegularExpressionChars', Reg.or([
  ''
  Reg.repeat RegularExpressionChar
])
Reg.register 'RegularExpressionBody', Reg.concat([
  RegularExpressionFirstChar
  RegularExpressionChars
])
Reg.register 'RegularExpressionFlags', Reg.or([
  ''
  Reg.repeat IdentifierPart
])
Reg.register 'RegularExpressionLiteral', Reg.concat([
  /\//
  RegularExpressionBody
  /\//
  RegularExpressionFlags
])

Reg.register 'DoubleStringCharacter', Reg.not Reg.concatregexclass([
  /["\\]/
  LineTerminator
])
Reg.register 'DoubleStringCharacters', Reg.repeat DoubleStringCharacter



Reg.register 'ReservedWord', Reg.or([
  Keyword
  FutureReservedWord
  NullLiteral
  BooleanLiteral
])


###
Reg.register 'StringLiteral', Reg.or([
  Reg.concat([
    '"'
    opt DoubleStringCharacters
    '"'
  ])
  Reg.concat([
    "'"
    opt SingleStringCharacters
    "'"
  ])
])


Reg.register 'Literal', Ref.or([
  NullLiteral
  BooleanLiteral
  NumericLiteral
  StringLiteral
])


###

Reg.map((x) ->
  console.log x.name
  console.log x.source
  console.log '-------------------------------------'
)



