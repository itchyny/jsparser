(function() {
  var as, calc, comment, convert, fix, iswhite, join, keyEvent, noterminator, opoprgx, output, outputSemi, p, parser, preconvert, reflesh, refleshEvent, refleshSemicount, renewCheck, saveInsertion, semi, t, toString, unline;
  p = document.getElementById('prg');
  t = document.getElementById('result');
  as = document.getElementsByTagName('a');
  semi = document.getElementById('semicount');
  parser = jsparser;
  output = function(s) {
    return t.value = t.innerText = s;
  };
  outputSemi = function(s) {
    return semi.innerText = semi.innerHTML = s;
  };
  unline = function(x) {
    return x.split('\n');
  };
  join = function(x) {
    return x.join('\n');
  };
  saveInsertion = function(linenum, colnum) {
    return parser.semicolonInsertion[parser.semicolonInsertion.length] = (linenum + 1) + '-' + colnum;
  };
  opoprgx = /^\s*(\+\+|--)/;
  fix = function(s, loc, e) {
    var col, currentline, i, linenum, prevline, prevlinenum, ss;
    linenum = loc.first_line - 1;
    col = loc.first_column;
    if (s.split != null) {
      ss = unline(s);
    }
    currentline = ss[linenum];
    prevlinenum = +((e.message.split('\n'))[0].replace(/.*(\d+).*/, '$1')) - 1;
    prevline = ss[prevlinenum];
    if (opoprgx.test(prevline)) {
      i = prevline.indexOf(RegExp.$1);
      ss[prevlinenum] = (prevline.slice(0, i)) + ';' + (prevline.slice(i));
    } else if ((/^\s*}/.test(currentline.slice(col))) || (/^\s*$/.test(currentline.slice(0, col)))) {
      saveInsertion(linenum, col);
      ss[linenum] = (currentline.slice(0, col)) + ';' + (currentline.slice(col));
    } else {
      throw new Error;
    }
    return join(ss);
  };
  iswhite = /^\s*$/;
  comment = /\/\//;
  noterminator = /.*(return|throw|continue|break)\s*$/;
  preconvert = function(s) {
    var i, l, ss, _len;
    ss = unline(s);
    for (i = 0, _len = ss.length; i < _len; i++) {
      l = ss[i];
      if ((noterminator.test(l)) && (!comment.test(l))) {
        while (iswhite.test(ss[++i])) {
          l = ss[i];
        }
        l = ss[i];
        ss[i] = l ? ';' + l : ';';
        saveInsertion(i, 1);
      }
    }
    return join(ss);
  };
  calc = function(s) {
    var ans, first_error, flg, i, loc, _loc;
    parser.semicolonInsertion = [];
    i = 0;
    flg = true;
    loc = {};
    s = preconvert(s);
    while (i++ < 1000 && flg) {
      try {
        ans = parser.parse(s);
        flg = false;
      } catch (e) {
        if (i === 1) {
          first_error = e;
        }
        _loc = parser.lexer.yylloc;
        if (_loc.first_column === loc.first_column && _loc.first_line === loc.first_line) {
          ans = e;
          flg = false;
        }
        loc = _loc;
        ans = e;
        try {
          s = fix(s, loc, e);
        } catch (e) {
          ans = e;
          flg = false;
        }
      }
    }
    if (ans.constructor === Error) {
      throw first_error;
    }
    return ans;
  };
  reflesh = function(e) {
    if (renewCheck(e, p.value)) {
      try {
        output(toString(calc(p.value)));
      } catch (e) {
        output(e);
      }
      return refleshSemicount();
    }
  };
  convert = function(s) {
    return s.replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&amp;/g, '&');
  };
  refleshEvent = function(e) {
    return (65 <= e.which) && (!e.ctrlKey);
  };
  renewCheck = (function() {
    var i, _s;
    _s = '';
    i = 0;
    return function(e, s) {
      var a;
      a = _s.length !== s.length || refleshEvent(e);
      _s = s;
      if (!a) {
        i++;
        console.log('not reflesh');
      } else {
        console.log('reflesh');
        i = 0;
      }
      return a;
    };
  })();
  refleshSemicount = function() {
    var m, n, x, xs, _i, _len;
    xs = unline(t.value || t.innerText);
    m = /semicolonInsertion: true/;
    n = 0;
    for (_i = 0, _len = xs.length; _i < _len; _i++) {
      x = xs[_i];
      if (m.test(x)) {
        ++n;
      }
    }
    return outputSemi('semicolon insertion: ' + n);
  };
  keyEvent = function(e) {
    var d, s;
    d = e.target.nextSibling;
    s = d.innerText || convert(d.innerHTML);
    p.value = p.innerText = s;
    return reflesh();
  };
  toString = function(obj, indent) {
    var key, s, val;
    indent = indent || '';
    s = '';
    s += '<' + (obj ? obj.constructor.name : '') + '>';
    for (key in obj) {
      val = obj[key];
      s += '\n' + indent;
      if (key !== 'value' && key !== 'id') {
        s += key + ': ';
      }
      if (typeof val === 'object') {
        s += toString(val, indent + ' ');
      } else if (typeof val === 'function') {
        s += val.name;
      } else {
        s += val || '';
      }
    }
    return s;
  };
  window.onload = function() {
    var a, d, _i, _len;
    d = document;
    p = p || d.getElementById('prg');
    t = t || d.getElementById('result');
    as = as || d.getElementsByTagName('a');
    semi = semi || document.getElementById('semicount');
    p.addEventListener('keydown', function(e) {
      return setTimeout((function() {
        return reflesh(e);
      }), 20);
    }, false);
    for (_i = 0, _len = as.length; _i < _len; _i++) {
      a = as[_i];
      try {
        a.addEventListener('mousedown', keyEvent, false);
      } catch (e) {
        log(e);
      }
    }
    return true;
  };
}).call(this);
