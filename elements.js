function Accessor1 (x, y) { this.id = x; this.expr = y; }
function Accessor2 (x, y) { this.id = x; this.expr = y; }
function Add (x, y, z) { this.left = x; this.right = y; this.op = z; }
function ArgumentList (x, y) { this.value = lr(x, y); }
function Arguments (x) { this.value = x == 0 ? ({}) : x; }
function ArrayLiteral (x, y) { this.value = lr(x, y); }
function AssignExpression (x, w) { this.value = x; if (w) this.NoIn = w; }
function Assign (x, y, z, w) { this.left = x; this.op = y; this.right = z; if (w) this.NoIn = w; }
function BinaryLogical (x, y, z, w) { this.left = x; this.op = y; this.right = z; if (w) this.NoIn = w; }
function BitOper (x, y, z, w) { this.left = x; this.op = y; this.right = z; if (w) this.NoIn = w; }
function BitwiseNot (x) { this.value = x; }
function Block (x) { this.value = x == 0 ? ({}) : x; }
function BooleanLiteral (x) { this.value = x; }
function Break (x, y) { this.value = x; if (y) this.semicolonInsertion = y; }
function CaseBlock (x, y, z) { this.value = y === 0 ? [x] : [x, y, z]; }
function CaseClause (x, y) { this.value = x; this.expr = y; }
function Catch (x, y) { this.id = x; this.body = y; }
function ClauseList (x, y) { this.value = lr(x, y); }
function Comma (x, y, w) { this.value = lr(x, y); if (w) this.NoIn = w; }
function Conditional (x, y, z, w) { this.cond = x; this.expr1 = y; this.expr2 = z; if (w) this.NoIn = w; }
function Continue (x, y) { this.id = x; if(y) this.semicolonInsertion = y; } 
function Delete (x) { this.expr = x; }
function DoWhile (x, y) { this.body = x; this.expr = y; }
function Element (x, y, z) { var value = []; if (z === undefined) { value[x] = y; } else { value = x.value; value[value.length + y] = z; }; this.value = value; }
function EmptyStatement () {}
function Equal (x, y, z, w) { this.left = x; this.op = y; this.right = z; if (w) this.NoIn = w; }
function ExpressionStatement (x, y) { this.value = x; if(y) this.semicolonInsertion = y; }
function Finally (x) { this.body = x; } 
function ForIn (x, y, z) { this.id = x; this.expr = y; this.body = z; }
function For (x, y, z, w) { this.expr1 = x; this.expr2 = y; this.expr3 = z; this.body = w; }
function FuncDecl (x, y, z) { this.id = x; this.args = y === 0 ? [] : y; this.body = z; }
function FuncExpression (x, y, z) { this.args = x === 0 ? [] : x; this.body = y; if (z) this.id = z; }
function FunctionBody (x) { this.value = x; }
function FunctionCall (x, y) { this.func = x; this.args = y; }
function Group (x) { this.value = x; }
function Identifier (x) { this.value = x; }
function If (x, y, z) { this.expr = x; this.statement1 = y; this.statement2 = z; }
function Label (x, y) { this.label = x; this.body = y; }
function LogicalNot (x) { this.value = x; }
function Mult (x, y, z) { this.left = x; this.right = y; this.op = z; }
function Negate (x) { this.value = x; }
function NewExpression (x, y) { this.value = x; this.args = y; }
function Null () {}
function NumberLiteral (x) { this.value = x; }
function ObjectLiteral (x) { this.value = x; }
function OpAnd () {}
function OpAndEq () {}
function OpBitAnd () {}
function OpBitOr () {}
function OpBitXOr () {}
function OpDivEq () {}
function OpEqEq () {}
function OpEqual () {}
function OpGreater () {}
function OpGreaterEq () {}
function OpIn () {}
function OpInstanceOf () {}
function OpLShift () {}
function OpLess () {}
function OpLessEq () {}
function OpMinusEq () {}
function OpMinusMinus () {}
function OpModEq () {}
function OpMultEq () {}
function OpNotEq () {}
function OpOr () {}
function OpOrEq () {}
function OpPlusEq () {}
function OpPlusPlus () {}
function OpRShift () {}
function OpStrEq () {}
function OpStrNEq () {}
function OpURShift () {}
function OpXOrEq () {} 
function Parameter (x, y) { this.value = lr(x, y); }
function Postfix (x, y) { this.expr = x; this.op = y; }
function Prefix (x, y) { this.expr = y; this.op = x; }
function Program (x) { this.value = x; }
function Property (x) { this.value = x; }
// function PropertyValue (x, y, z) { var value = []; if (z === undefined) { value = [ {name: x, expr: y} ] } else { value = z.value; value.push({name: x, expr: y}) }; this.value = value; }
function PropertyValue (x, y) { this.id = x; this.value = y; }
function Getter (x, y) { this.id = x; this.body = y; }
function Setter (x, y, z) { this.id = x; this.arg = y; this.body = z; }
function RegExpLiteral (x) { this.value = x; }
function Relational (x, y, z, w) { this.left = x; this.op = y; this.right = z; if (w) this.NoIn = w; }
function Return (x, y) { this.value = x; if (y) this.semicolonInsertion = y; }
function Shift (x, y, z) { this.left = x; this.op = y; this.right = z; }
function SourceElements (l, r) { this.value = lr(l, r); }
function StatList (l, r) { this.value = lr(l, r); }
function StringLiteral (x) { this.value = x; }
function Switch (x, y) { this.expr = x; this.body = y; }
function This () {}
function Throw (x, y) { this.expr = x; if(y) this.semicolonInsertion = y; } 
function Try (x, y, z) { this.body = x; this.catchBlock = y; this.finallyBlock = z; }
function TypeOf (x) { this.value = x; }
function UnaryPlus (x) { this.value = x; }
function VarDeclList (l, r, w) { this.value = lr(l, r); if (w) this.NoIn = w; }
function VarDecl (x, y, w) { this.id = x; this.init = y; if (w) this.NoIn = w; }
function VarStatement (x, y, z) { this.value = x; if(y) this.semicolonInsertion = y; if (z) this.constant = z; }
function Void (x) { this.value = x; }
function While (x, y) { this.expr = x; this.body = y; }
function With (x, y) { this.expr = x; this.body = y; }

function lr (l, r) { var value = []; if (r === undefined) { value = [ l ]; } else { value = l.value; value.push(r); } return value; }


function semicolonCheck () {
  var loc = jsparser.lexer.yylloc.first_line + '-' + (jsparser.lexer.yylloc.first_column - 1);
  var flg = jsparser.semicolonInsertion.indexOf(loc) >= 0;
  loc = jsparser.lexer.yylloc.first_line + '-1';
  flg |= jsparser.semicolonInsertion.indexOf(loc) >= 0;
  return flg ? true : false;
}




