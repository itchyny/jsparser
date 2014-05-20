p = document.getElementById 'prg'
t = document.getElementById 'result'
as = document.getElementsByTagName 'a'
semi = document.getElementById 'semicount'
parser = jsparser

output = (s) ->
  t.value = t.innerText = s

outputSemi = (s) ->
  semi.innerText = semi.innerHTML = s

unline = (x) -> x.split '\n'
join = (x) -> x.join '\n'

saveInsertion = (linenum, colnum) ->
  parser.semicolonInsertion[parser.semicolonInsertion.length] = (linenum + 1) + '-' +  colnum

opoprgx = /^\s*(\+\+|--)/

fix = (s, loc, e) ->
  linenum = loc.first_line - 1
  col = loc.first_column
  ss = unline s if s.split?
  currentline = ss[linenum]
  prevlinenum = +((e.message.split '\n')[0].replace /.*(\d+).*/, '$1') - 1
  prevline = ss[prevlinenum]
  if opoprgx.test prevline
    i = prevline.indexOf RegExp.$1
    ss[prevlinenum] = (prevline.slice 0, i) + ';' + (prevline.slice i)
  else if (/^\s*}/.test currentline.slice col) or (/^\s*$/.test currentline.slice 0, col)
    saveInsertion linenum, col
    ss[linenum] = (currentline.slice 0, col) + ';' + (currentline.slice col)
  else
    throw new Error
  return join ss

iswhite = /^\s*$/
comment = /\/\//
noterminator = /.*(return|throw|continue|break)\s*$/


preconvert = (s) ->
  ss = unline s
  for l,i in ss
    if (noterminator.test l) and (not comment.test l)
      while iswhite.test ss[++i]
        l = ss[i]
      l = ss[i]
      ss[i] = if l then ';' + l else ';'
      saveInsertion i, 1
  return join ss


calc = (s) ->
  parser.semicolonInsertion = []
  i = 0
  flg = true
  loc = {}
  s = preconvert s
  while i++ < 1000 and flg
    try
      ans = parser.parse s
      flg = false
    catch e
      first_error = e if i is 1
      _loc = parser.lexer.yylloc
      if _loc.first_column is loc.first_column and _loc.first_line is loc.first_line
        ans = e
        flg = false
      loc = _loc
      ans = e
      try
        s = fix s, loc, e
      catch e
        ans = e
        flg = false
  if ans.constructor is Error
    throw first_error
  return ans

reflesh = (e) ->
  if renewCheck(e, p.value)
    try
      output toString calc p.value
    catch e
      output e
    refleshSemicount()

convert = (s) ->
  s.replace(/&lt;/g, '<')
   .replace(/&gt;/g, '>')
   .replace(/&amp;/g, '&')

refleshEvent = (e) ->
  (65 <= e.which) && (not e.ctrlKey)



renewCheck = (->
  _s = ''
  i = 0
  (e, s) ->
    a = _s.length != s.length || refleshEvent e
    _s = s
    if (!a)
      i++
      console.log 'not reflesh'
    else
      console.log 'reflesh'
      i = 0
    return a
)()

refleshSemicount = ->
  xs = unline t.value || t.innerText
  m = /semicolonInsertion: true/
  n = 0
  for x in xs
    ++n if m.test x
  outputSemi 'semicolon insertion: ' + n

keyEvent = (e) ->
  d = e.target.nextSibling
  s = d.innerText || convert d.innerHTML
  p.value = p.innerText = s
  reflesh()

toString = (obj, indent) ->
  indent = indent || ''
  s = ''
  s += '<' + (if obj then obj.constructor.name else '') + '>'
  for key, val of obj
    s += '\n' + indent
    s += key + ': ' if key isnt 'value' and key isnt 'id'
    if typeof val is 'object'
      s += toString val, indent + ' '
    else if typeof val is 'function'
      s += val.name
    else
      s += val || ''
  return s

window.onload = () ->
  d = document
  p = p || d.getElementById 'prg'
  t = t || d.getElementById 'result'
  as = as || d.getElementsByTagName 'a'
  semi = semi || document.getElementById 'semicount'
  p.addEventListener 'keydown',
    (e) -> setTimeout (-> reflesh(e)), 20,
    false
  for a in as
    try
      a.addEventListener 'mousedown',
       keyEvent,
       false
    catch e
      log e
  true



