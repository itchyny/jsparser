
%lex
%%



"//"[^\n]*                       /* skip SingleLineComment */
"/*"(.|\n|\r)*?"*/"              /* skip MultiLineComment */
\"("\\\\"|'\"'|[^"\n\r])*\"         return 'STRING'
"'"("\\\\"|"\'"|[^'\n\r])*"'"       return 'STRING'
(("0"|[1-9][0-9]*)("."[0-9]*)?|"."[0-9]+)([eE][+-]?[0-9]+)?|[0][xX][0-9a-fA-F]+  return 'NUMBER'
"/"([^\n\r*\\\/\[]|"\\"[^\n\r]|"["([^\n\r]|"\\]"|"\\"[^\n\r])*"]")([^\n\r\\\/\[]|"\\"[^\n\r]|"["([^\n\r]|"\\]"|"\\"[^\n\r])*"]")*"/"[a-zA-Z0-9]*  return 'REGEXP'
">>>="                return 'URSHIFTEQUAL'
"!=="                 return 'STRNEQ'
"==="                 return 'STREQ'
">>>"                 return 'URSHIFT'
"<<="                 return 'LSHIFTEQUAL'
">>="                 return 'RSHIFTEQUAL'
"%="                  return 'MODEQUAL'
"&&"                  return 'AND'
"&="                  return 'ANDEQUAL'
"*="                  return 'MULTEQUAL'
"++"                  return 'PLUSPLUS'
"+="                  return 'PLUSEQUAL'
"--"                  return 'MINUSMINUS'
"-="                  return 'MINUSEQUAL'
"/="                  return 'DIVEQUAL'
"<<"                  return 'LSHIFT'
"<="                  return 'LE'
">="                  return 'GE'
"=="                  return 'EQEQ'
">>"                  return 'RSHIFT'
"^="                  return 'XOREQUAL'
"|="                  return 'OREQUAL'
"||"                  return 'OR'
"&"                   return "&"
"%"                   return "%"
"!="                  return 'NE'
"("                   return '('
")"                   return ')'
"+"                   return '+'
"*"                   return '*'
","                   return ','
"-"                   return '-'
"!"                   return '!'
"."                   return '.'
"/"                   return '/'
":"                   return ':'
";"                   return ';'
"<"                   return '<'
"="                   return '='
">"                   return '>'
"?"                   return '?'
"["                   return '['
"]"                   return ']'
"^"                   return '^'
"{"                   return '{'
"}"                   return '}'
"|"                   return '|'
"~"                   return '~'
"&"                   return '&'
"break"               return 'BREAK'
"case"                return 'CASE'
"catch"               return 'CATCH'
"continue"            return 'CONTINUE'
"default"             return 'DEFAULT'
"delete"              return 'DELETE'
"do"                  return 'DO'
"else"                return 'ELSE'
"false"               return 'FALSETOKEN'
"finally"             return 'FINALLY'
"for"                 return 'FOR'
"function"            return 'FUNCTION'
"get"                 return 'GET'
"if"                  return 'IF'
"in"                  return 'IN'
"instanceof"          return 'INSTANCEOF'
"new"                 return 'NEW'
"null"                return 'NULLTOKEN'
"return"              return 'RETURN'
"set"                 return 'SET'
"switch"              return 'SWITCH'
"this"                return 'THIS'
"throw"               return 'THROW'
"true"                return 'TRUETOKEN'
"try"                 return 'TRY'
"typeof"              return 'TYPEOF'
"var"                 return 'VAR'
"const"               return 'CONST'
"void"                return 'VOID'
"while"               return 'WHILE'
"whith"               return 'WITH'
(((([A-Z]|[a-z])|"$"|"_"|("\\"("u"([0-9a-fA-F]){4})))((([A-Z]|[a-z])|"$"|"_"|("\\"("u"([0-9a-fA-F]){4})))|[0-9])+)|(([A-Z]|[a-z])|"$"|"_"|("\\"("u"([0-9a-fA-F]){4})))) return 'IDENT'
\s+                   /* skip whitespace */
\n                    /* */
<<EOF>>               return 'EOF'
.                     return 'INVALID'

/lex


%start Program



%%

Statement
  : Block
  | VariableStatement
  | EmptyStatement
  | ExpressionStatement
  | IfStatement
  | IterationStatement
  | ContinueStatement
  | BreakStatement
  | ReturnStatement
  | WithStatement
  | LabelledStatement
  | SwitchStatement
  | ThrowStatement
  | TryStatement
;

Statement_error
  : VariableStatement_error
  | ExpressionStatement_error
  | IfStatement_error
  | IterationStatement_error
  | ContinueStatement_error
  | BreakStatement_error
  | ReturnStatement_error
  | WithStatement_error
  | ThrowStatement_error
  | LabelledStatement_error
;

VariableStatement_error
  : VAR VariableDeclarationList                    { $$ = new VarStatement($2, true); }
  | CONST VariableDeclarationList                  { $$ = new VarStatement($2, true, true); }
;

ExpressionStatement_error  /* DONE: lookahead not in { '{' , 'function' } */
  : ExpressionNoBrace                                      { $$ = new ExpressionStatement($1, true); }
;

IfStatement_error /* shift/reduce conflict due to dangling else */
  : IF '(' Expression ')' Statement_error                    { $$ = new If($3, $5, 0); }
  | IF '(' Expression ')' Statement ELSE Statement_error     { $$ = new If($3, $5, $7); }
;

ReturnStatement_error
  : Return                             { $$ = new Return(undefined, true);  }
  | Return Expression                  { $$ = new Return($2, true);  }
;

IterationStatement_error        // TODO: NO semicolonInsertion
  : DO Statement_error WHILE '(' Expression ')' { $$ = new DoWhile($2, $5);}
  | FOR '(' IDENT IN Expression ')' Statement_error                             { $$ = new ForIn($3, 0, $5, $7); }
  | WHILE '(' Expression ')' Statement_error   { $$ = new While($3, $5); }
  | FOR '(' ExpressionNoInOpt ';' ExpressionOpt ';' ExpressionOpt ')' Statement_error              { $$ = new For($3, $5, $7, $9); }
  | FOR '(' VAR VariableDeclarationListNoIn ';' ExpressionOpt ';' ExpressionOpt ')' Statement_error        { $$ = new For($4, $6, $8, $10); }
  | FOR '(' VariableDeclarationListNoIn ';' ExpressionOpt ';' ExpressionOpt ')' Statement_error            { $$ = new For($3, $5, $7, $9); }
  | FOR '(' LeftHandSideExpression IN Expression ')' Statement_error            { $$ = new ForIn($3, $5, $7); }
  | FOR '(' VAR VariableDeclarationNoIn IN Expression ')' Statement_error       { $$ = new ForIn($4, $6, $8); }
  | FOR '(' VAR IDENT IN Expression ')' Statement_error                         { $$ = new ForIn($4, 0, $6, $8); }
  /*
  | FOR '(' VAR IDENT Initializer IN Expression ')' Statement_error             { $$ = new ForIn($4, $5, $7, $9); }
  */
;

BreakStatement_error
  : Break                             { $$ = new Break(undefined, true);  }
;

ContinueStatement_error /* DONE: No line terminator */
  : Continue                          { $$ = new Continue(undefined, true);  }
  | Break Ident                       { $$ = new Break($2, true);  }
  | Continue Ident                    { $$ = new Continue($2, true);  }
;

WithStatement_error
  : WITH '(' Expression ')' Statement_error    { $$ = new With($3, $5); }
;

LabelledStatement_error
  : IDENT ':' Statement_error                  { $3.label = $1; $$ = $3; }
;

ThrowStatement_error
  : Throw Expression                  { $$ = new Throw($2, true);  }
;

Block
  : '{' '}'                                            { $$ = new Block(0); }
  | '{' StatementList '}'                             { $$ = new Block($2); }
  | '{' StatementList_error '}'                             { $$ = new Block($2); }
;

Literal
  : IDENT
  | GET
  | SET
  | NULLTOKEN                      { $$ = new Null(); }
  | TRUETOKEN                      { $$ = new BooleanLiteral(true); }
  | FALSETOKEN                     { $$ = new BooleanLiteral(false); }
  | REGEXP                         { $$ = new RegExpLiteral($1); }
  | NUMBER                         { $$ = new NumberLiteral($1); }
  | STRING                         { $$ = new StringLiteral($1); }
;

PrimaryExpression
  : THIS                           { $$ = new This(); }
  | Literal
  | ArrayLiteral
  | ObjectLiteral
  | '(' Expression ')'                   { $$ = new Group($2); }
;

ArrayLiteral
  : '[' ElisionOpt ']'                   { $$ = new ArrayLiteral($2); }
  | '[' ElementList ']'                  { $$ = new ArrayLiteral($2); }
  | '[' ElementList ',' ElisionOpt ']'   { $$ = new ArrayLiteral($4, $2); }
;

ElementList
  : ElisionOpt AssignmentExpression      { $$ = new Element($1, $2); }
  | ElementList ',' ElisionOpt AssignmentExpression
                                         { $$ = new Element($1, $3, $4); }
;

ElisionOpt
  : /* nothing */                        { $$ = 0; }
  | Elision
;

Elision
  : ','                                  { $$ = 1; }
  | Elision ','                          { $$ = $1 + 1; }
;

ObjectLiteral
  : '{' '}'                              { $$ = new ObjectLiteral(0); }
  | '{' PropertyNameAndValueList '}'     { $$ = new ObjectLiteral($2); }
  | '{' PropertyNameAndValueList ',' '}' { $$ = new ObjectLiteral($2); }
;

PropertyNameAndValueList
  : PropertyAssignment                   { $$ = [ $1 ]; }
  | PropertyNameAndValueList ',' PropertyAssignment
                                           { $1.push($3); $$ = $1; }
;

PropertyAssignment
  : PropertyName ':' AssignmentExpression  { $$ = new PropertyValue($1, $3); }
  | GET PropertyName '(' ')' FunctionBody  { $$ = new Getter($2, $5); }
  | SET PropertyName '(' PropertySetParameterList ')' FunctionBody  { $$ = new Setter($2, $4, $6); }
;

PropertyName
  : IDENT                          { $$ = new Identifier($1); }
  | STRING                         { $$ = new Identifier($1); }
  | NUMBER                         { $$ = new Identifier($1); }
  | BREAK                          { $$ = new Identifier($1); }
  | CATCH                          { $$ = new Identifier($1); }
  | CONTINUE                       { $$ = new Identifier($1); }
  | DELETE                         { $$ = new Identifier($1); }
  | DO                             { $$ = new Identifier($1); }
  | ELSE                           { $$ = new Identifier($1); }
  | FALSETOKEN                     { $$ = new Identifier($1); }
  | FINALLY                        { $$ = new Identifier($1); }
  | FOR                            { $$ = new Identifier($1); }
  | FUNCTION                       { $$ = new Identifier($1); }
  | GET                            { $$ = new Identifier($1); }
  | IF                             { $$ = new Identifier($1); }
  | IN                             { $$ = new Identifier($1); }
  | INSTANCEOF                     { $$ = new Identifier($1); }
  | NEW                            { $$ = new Identifier($1); }
  | NULLTOKEN                      { $$ = new Identifier($1); }
  | RETURN                         { $$ = new Identifier($1); }
  | SET                            { $$ = new Identifier($1); }
  | SWITCH                         { $$ = new Identifier($1); }
  | THIS                           { $$ = new Identifier($1); }
  | THROW                          { $$ = new Identifier($1); }
  | TRUETOKEN                      { $$ = new Identifier($1); }
  | TRY                            { $$ = new Identifier($1); }
  | TYPEOF                         { $$ = new Identifier($1); }
  | VAR                            { $$ = new Identifier($1); }
  | CONST                          { $$ = new Identifier($1); }
  | VOID                           { $$ = new Identifier($1); }
  | WHILE                          { $$ = new Identifier($1); }
  | WITH                           { $$ = new Identifier($1); }
;

PropertySetParameterList
  : IDENT                          { $$ = new Identifier($1);  }
;

IdentifierName
  : IDENT
  | BREAK
  | CASE
  | CATCH
  | CONTINUE
  | DEFAULT
  | DELETE
  | DO
  | ELSE
  | FALSETOKEN
  | FINALLY
  | FOR
  | FUNCTION
  | GET
  | IF
  | IN
  | INSTANCEOF
  | NEW
  | NULLTOKEN
  | RETURN
  | SET
  | SWITCH
  | THIS
  | THROW
  | TRUETOKEN
  | TRY
  | TYPEOF
  | VAR
  | CONST
  | VOID
  | WHILE
  | WITH
;

MemberExpression
  : PrimaryExpression
  | FunctionExpression
  | MemberExpression '[' Expression ']'        { $$ = new Accessor1($1, $3); }
  | MemberExpression '.' IdentifierName        { $$ = new Accessor2($1, $3);  }
  | NEW MemberExpression Arguments             { $$ = new NewExpression($2, $3); }
;

NewExpression
  : MemberExpression
  | NEW NewExpression                          { $$ = new NewExpression($2); }
;

CallExpression
  : MemberExpression Arguments                 { $$ = new FunctionCall($1, $2); }
  | CallExpression Arguments                   { $$ = new FunctionCall($1, $2); }
  | CallExpression '[' Expression ']'          { $$ = new Accessor1($1, $3); }
  | CallExpression '.' IdentifierName          { $$ = new Accessor2($1, $3); }
;

Arguments
  : '(' ')'                                    { $$ = new Arguments(0); }
  | '(' ArgumentList ')'                       { $$ = new Arguments($2); }
;

ArgumentList
  : AssignmentExpression                       { $$ = new ArgumentList($1); }
  | ArgumentList ',' AssignmentExpression      { $$ = new ArgumentList($1, $3); }
;

LeftHandSideExpression
  : NewExpression                                { LeftHandSideExpressionlineno = yylineno; }
  | CallExpression                               { LeftHandSideExpressionlineno = yylineno; }
;

PostfixExpression    /* DONE: no line terminator here */
  : LeftHandSideExpression
  | LeftHandSideExpression PLUSPLUS              {
                        if (LeftHandSideExpressionlineno !== yylineno)
                          throw new Error('Parse error on line ' + (yylineno + 1) + ':\n' + jsparser.lexer.showPosition() + '\n'
                            + 'There should not be LineTerminator before "++".');
                        $$ = new Postfix($1, new OpPlusPlus); }
  | LeftHandSideExpression MINUSMINUS            {
                        if (LeftHandSideExpressionlineno !== yylineno)
                          throw new Error('Parse error on line ' + (yylineno + 1) + ':\n' + jsparser.lexer.showPosition() + '\n'
                            + 'There should not be LineTerminator before "--".');
                        $$ = new Postfix($1, new OpMinusMinus); }
;

UnaryExpression
  : PostfixExpression
  | DELETE UnaryExpression                       { $$ = new Delete($2); }
  | VOID UnaryExpression                         { $$ = new Void($2); }
  | TYPEOF UnaryExpression                       { $$ = new TypeOf($2); }
  | PLUSPLUS UnaryExpression                     { $$ = new Prefix(OpPlusPlus, $2); }
  | AUTOPLUSPLUS UnaryExpression                 { $$ = new Prefix(OpPlusPlus, $2); }
  | MINUSMINUS UnaryExpression                   { $$ = new Prefix(OpMinusMinus, $2); }
  | AUTOMINUSMINUS UnaryExpression               { $$ = new Prefix(OpMinusMinus, $2); }
  | '+' UnaryExpression                          { $$ = new UnaryPlus($2); }
  | '-' UnaryExpression                          { $$ = new Negate($2); }
  | '~' UnaryExpression                          { $$ = new BitwiseNot($2); }
  | '!' UnaryExpression                          { $$ = new LogicalNot($2); }
;

MultiplicativeExpression
  : UnaryExpression
  | MultiplicativeExpression '*' UnaryExpression { $$ = new Mult($1, $3, '*'); }
  | MultiplicativeExpression '/' UnaryExpression { $$ = new Mult($1, $3, '/'); }
  | MultiplicativeExpression '%' UnaryExpression { $$ = new Mult($1, $3, '%'); }
;

AdditiveExpression
  : MultiplicativeExpression
  | AdditiveExpression '+' MultiplicativeExpression { $$ = new Add($1, $3, '+'); }
  | AdditiveExpression '-' MultiplicativeExpression { $$ = new Add($1, $3, '-'); }
;

ShiftExpression
  : AdditiveExpression
  | ShiftExpression LSHIFT AdditiveExpression  { $$ = new Shift($1, new OpLShift, $3); }
  | ShiftExpression RSHIFT AdditiveExpression  { $$ = new Shift($1, new OpRShift, $3); }
  | ShiftExpression URSHIFT AdditiveExpression { $$ = new Shift($1, new OpURShift, $3); }
;

RelationalExpression
  : ShiftExpression
  | RelationalExpression '<' ShiftExpression               { $$ = new Relational($1, new OpLess, $3); }
  | RelationalExpression '>' ShiftExpression               { $$ = new Relational($1, new OpGreater, $3); }
  | RelationalExpression LE ShiftExpression                { $$ = new Relational($1, new OpLessEq, $3); }
  | RelationalExpression GE ShiftExpression                { $$ = new Relational($1, new OpGreaterEq, $3); }
  | RelationalExpression INSTANCEOF ShiftExpression        { $$ = new Relational($1, new OpInstanceOf, $3); }
  | RelationalExpression IN ShiftExpression                { $$ = new Relational($1, new OpIn, $3); }
;

RelationalExpressionNoIn
  : ShiftExpression
  | RelationalExpressionNoIn '<' ShiftExpression           { $$ = new Relational($1, new OpLess, $3, true); }
  | RelationalExpressionNoIn '>' ShiftExpression           { $$ = new Relational($1, new OpGreater, $3, true); }
  | RelationalExpressionNoIn LE ShiftExpression            { $$ = new Relational($1, new OpLessEq, $3, true); }
  | RelationalExpressionNoIn GE ShiftExpression            { $$ = new Relational($1, new OpGreaterEq, $3, true); }
  | RelationalExpressionNoIn INSTANCEOF ShiftExpression    { $$ = new Relational($1, new OpInstanceOf, $3, true); }
;

EqualityExpression
  : RelationalExpression
  | EqualityExpression EQEQ RelationalExpression           { $$ = new Equal($1, new OpEqEq, $3); }
  | EqualityExpression NE RelationalExpression             { $$ = new Equal($1, new OpNotEq, $3); }
  | EqualityExpression STREQ RelationalExpression          { $$ = new Equal($1, new OpStrEq, $3); }
  | EqualityExpression STRNEQ RelationalExpression         { $$ = new Equal($1, new OpStrNEq, $3);}
;

EqualityExpressionNoIn
  : RelationalExpressionNoIn
  | EqualityExpressionNoIn EQEQ RelationalExpressionNoIn   { $$ = new Equal($1, new OpEqEq, $3, true); }
  | EqualityExpressionNoIn NE RelationalExpressionNoIn     { $$ = new Equal($1, new OpNotEq, $3, true); }
  | EqualityExpressionNoIn STREQ RelationalExpressionNoIn  { $$ = new Equal($1, new OpStrEq, $3, true); }
  | EqualityExpressionNoIn STRNEQ RelationalExpressionNoIn { $$ = new Equal($1, new OpStrNEq, $3, true);}
;

BitwiseANDExpression
  : EqualityExpression
  | BitwiseANDExpression '&' EqualityExpression { $$ = new BitOper($1, new OpBitAnd, $3); }
;

BitwiseANDExpressionNoIn
  : EqualityExpressionNoIn
  | BitwiseANDExpressionNoIn '&' EqualityExpressionNoIn { $$ = new BitOper($1, new OpBitAnd, $3, true); }
;

BitwiseXORExpression
  : BitwiseANDExpression
  | BitwiseXORExpression '^' BitwiseANDExpression { $$ = new BitOper($1, new OpBitXOr, $3); }
;

BitwiseXORExpressionNoIn
  : BitwiseANDExpressionNoIn
  | BitwiseXORExpressionNoIn '^' BitwiseANDExpressionNoIn { $$ = new BitOper($1, new OpBitXOr, $3, true); }
;

BitwiseORExpression
  : BitwiseXORExpression
  | BitwiseORExpression '|' BitwiseXORExpression { $$ = new BitOper($1, new OpBitOr, $3); }
;

BitwiseORExpressionNoIn
  : BitwiseXORExpressionNoIn
  | BitwiseORExpressionNoIn '|' BitwiseXORExpressionNoIn { $$ = new BitOper($1, new OpBitOr, $3, true); }
;

LogicalANDExpression
  : BitwiseORExpression
  | LogicalANDExpression AND BitwiseORExpression { $$ = new BinaryLogical($1, new OpAnd, $3); }
;

LogicalANDExpressionNoIn
  : BitwiseORExpressionNoIn
  | LogicalANDExpressionNoIn AND BitwiseORExpressionNoIn { $$ = new BinaryLogical($1, new OpAnd, $3, true); }
;

LogicalORExpression
  : LogicalANDExpression
  | LogicalORExpression OR LogicalANDExpression { $$ = new BinaryLogical($1, new OpOr, $3); }
;

LogicalORExpressionNoIn
  : LogicalANDExpressionNoIn
  | LogicalORExpressionNoIn OR LogicalANDExpressionNoIn { $$ = new BinaryLogical($1, new OpOr, $3, true); }
;

ConditionalExpression
  : LogicalORExpression
  | LogicalORExpression '?' AssignmentExpression ':' AssignmentExpression { $$ = new Conditional($1, $3, $5); }
;

ConditionalExpressionNoIn
  : LogicalORExpressionNoIn
  | LogicalORExpressionNoIn '?' AssignmentExpressionNoIn ':' AssignmentExpressionNoIn { $$ = new Conditional($1, $3, $5, true); }
;

AssignmentExpression
  : ConditionalExpression
  | LeftHandSideExpression AssignmentOperator AssignmentExpression { $$ = new Assign($1, $2, $3);}
;

AssignmentExpressionNoIn
  : ConditionalExpressionNoIn
  | LeftHandSideExpressionNoIn AssignmentOperator AssignmentExpressionNoIn { $$ = new Assign($1, $2, $3, true);}
;

AssignmentOperator
  : '='                            { $$ = new OpEqual; }
  | PLUSEQUAL                      { $$ = new OpPlusEq; }
  | MINUSEQUAL                     { $$ = new OpMinusEq; }
  | MULTEQUAL                      { $$ = new OpMultEq; }
  | DIVEQUAL                       { $$ = new OpDivEq; }
  | LSHIFTEQUAL                    { $$ = new OpLShift; }
  | RSHIFTEQUAL                    { $$ = new OpRShift; }
  | URSHIFTEQUAL                   { $$ = new OpURShift; }
  | ANDEQUAL                       { $$ = new OpAndEq; }
  | XOREQUAL                       { $$ = new OpXOrEq; }
  | OREQUAL                        { $$ = new OpOrEq; }
  | MODEQUAL                       { $$ = new OpModEq; }
;

Expression
  : AssignmentExpression                               { Expressionlineno = yylineno; $$ = new Comma($1); }
  | Expression ',' AssignmentExpression                { Expressionlineno = yylineno; $$ = new Comma($1, $3); }
;

ExpressionNoIn
  : AssignmentExpressionNoIn                           { $$ = new Comma($1, undefined, true); }
  | ExpressionNoIn ',' AssignmentExpressionNoIn        { $$ = new Comma($1, $3, true); }
;

StatementList
  : Statement                                          { $$ = new StatList($1); }
  | StatementList Statement                            { $$ = new StatList($1, $2); }
;

StatementList_error
  : Statement_error                                          { $$ = new StatList($1); }
  | StatementList Statement_error                            { $$ = new StatList($1, $2); }
;

VariableStatement
  : VAR VariableDeclarationList ';'                    { $$ = new VarStatement($2, semicolonCheck()); }
  | CONST VariableDeclarationList ';'                  { $$ = new VarStatement($2, semicolonCheck(), true); }
;

VariableDeclarationList
  : VariableDeclaration                                { $$ = new VarDeclList($1); }
  | VariableDeclarationList ',' VariableDeclaration    { $$ = new VarDeclList($1, $3); }
;

VariableDeclarationListNoIn
  : VariableDeclarationNoIn                            { $$ = new VarDeclList($1, undefined, true); }
  | VariableDeclarationListNoIn ',' VariableDeclarationNoIn { $$ = new VarDeclList($1, $3, true); }
;

VariableDeclaration
  : Ident                                              { $$ = new VarDecl($1, 0); }
  | Ident Initializer                                  { $$ = new VarDecl($1, $2); }
;

VariableDeclarationNoIn
  : Ident                                              { $$ = new VarDecl($1, 0, true); }
  | Ident InitializerNoIn                              { $$ = new VarDecl($1, $2, true); }
;

Initializer
  : '=' AssignmentExpression                           { $$ = new AssignExpression($2); }
;

InitializerNoIn
  : '=' AssignmentExpressionNoIn                       { $$ = new AssignExpression($2, true); }
;

EmptyStatement
  : ';'                                                { $$ = new EmptyStatement(); }
;

ExpressionStatement  /* DONE: lookahead not in { '{' , 'function' } */
  : ExpressionNoBrace ';'                                     { $$ = new ExpressionStatement($1, semicolonCheck()); }
;

IfStatement /* shift/reduce conflict due to dangling else */
  : IF '(' Expression ')' Statement                    { $$ = new If($3, $5, 0); }
  | IF '(' Expression ')' Statement ELSE Statement     { $$ = new If($3, $5, $7); }
;

IterationStatement    // TODO: No semicolonInsertion
  : DO Statement WHILE '(' Expression ')' { $$ = new DoWhile($2, $5);}
  | FOR '(' IDENT IN Expression ')' Statement                             { $$ = new ForIn($3, 0, $5, $7); }
  | WHILE '(' Expression ')' Statement   { $$ = new While($3, $5); }
  | FOR '(' ExpressionNoInOpt ';' ExpressionOpt ';' ExpressionOpt ')' Statement              { $$ = new For($3, $5, $7, $9); }
  | FOR '(' VAR VariableDeclarationListNoIn ';' ExpressionOpt ';' ExpressionOpt ')' Statement        { $$ = new For($4, $6, $8, $10); }
  | FOR '(' VariableDeclarationListNoIn ';' ExpressionOpt ';' ExpressionOpt ')' Statement            { $$ = new For($3, $5, $7, $9); }
  | FOR '(' LeftHandSideExpression IN Expression ')' Statement            { $$ = new ForIn($3, $5, $7); }
  | FOR '(' VAR VariableDeclarationNoIn IN Expression ')' Statement       { $$ = new ForIn($4, $6, $8); }
  | FOR '(' VAR IDENT IN Expression ')' Statement                         { $$ = new ForIn($4, 0, $6, $8); }
  /*
  | FOR '(' VAR IDENT Initializer IN Expression ')' Statement             { $$ = new ForIn($4, $5, $7, $9); }
  */
;

ExpressionOpt
  : /* nothing */                        { $$ = 0; }
  | Expression
;

ExpressionNoInOpt
  : /* nothing */                        { $$ = 0; }
  | ExpressionNoIn
;

ContinueStatement: /* DONE: No line terminator */
    Continue ';'                         { $$ = new Continue(undefined, semicolonCheck());  }
  | Continue Ident ';'                   { $$ = new Continue($2, semicolonCheck());  }
;

Continue
  : CONTINUE                             { Continuelineno = yylineno; }
;

Ident
  : IDENT                                { Identlineno = yylineno; }
  | GET
  | SET
;

BreakStatement
  : Break ';'                            { $$ = new Break(undefined, semicolonCheck());  }
  | Break Ident ';'                      { $$ = new Break($2, semicolonCheck());  }
;

Break
  : BREAK                                { Breaklineno = yylineno; }
;

ReturnStatement
  : Return ';'                            { $$ = new Return(undefined, semicolonCheck());  }
  | Return Expression ';'                 { $$ = new Return($2, semicolonCheck());  }
;

Return
  : RETURN                               { Returnlineno = yylineno; }
;

WithStatement
  : WITH '(' Expression ')' Statement    { $$ = new With($3, $5); }
;

SwitchStatement
  : SWITCH '(' Expression ')' CaseBlock  { $$ = new Switch($3, $5); }
;

CaseBlock
  : '{' CaseClausesOpt '}'               { $$ = new CaseBlock($2, 0, 0); }
  | '{' CaseClausesOpt DefaultClause CaseClausesOpt '}'
                                         { $$ = new CaseBlock($2, $3, $4); }
  | '{' CaseClausesOpt_error '}'               { $$ = new CaseBlock($2, 0, 0); }
  | '{' CaseClausesOpt DefaultClause CaseClausesOpt_error '}'
                                         { $$ = new CaseBlock($2, $3, $4); }
  | '{' CaseClausesOpt DefaultClause_error '}'
                                         { $$ = new CaseBlock($2, $3); }
;

CaseClausesOpt
  : /* nothing */                        { $$ = 0; }
  | CaseClauses
;

CaseClausesOpt_error
  : CaseClauses_error                    { $$ = 0; }
;

CaseClauses
  : CaseClause                           { $$ = new ClauseList($1); }
  | CaseClauses CaseClause               { $$ = new ClauseList($1, $2); }
;

CaseClauses_error
  : CaseClause_error                           { $$ = new ClauseList($1); }
  | CaseClauses CaseClause_error               { $$ = new ClauseList($1, $2); }
;

CaseClause
  : CASE Expression ':'                  { $$ = new CaseClause($2, 0); }
  | CASE Expression ':' StatementList    { $$ = new CaseClause($2, $4); }
;

CaseClause_error
  : CASE Expression ':' StatementList_error    { $$ = new CaseClause($2, $4); }
;

DefaultClause
  : DEFAULT ':'                          { $$ = new CaseClause(0, 0);; }
  | DEFAULT ':' StatementList            { $$ = new CaseClause(0, $3); }
;

DefaultClause_error
  : DEFAULT ':' StatementList_error            { $$ = new CaseClause(0, $3); }
;

LabelledStatement
  : IDENT ':' Statement                  { $3.label = $1; $$ = $3; }
;

ThrowStatement
  : Throw Expression ';'                 { $$ = new Throw($2, semicolonCheck());  }
;

Throw
  : THROW                                { Throwlineno = yylineno; }
;

TryStatement
  : TRY Block Catch                      { $$ = new Try($2, $3); }
  | TRY Block Finally                    { $$ = new Try($2, 0, $3); }
  | TRY Block Catch Finally              { $$ = new Try($2, $3, $4); }
;

Catch
  : CATCH '(' IDENT ')' Block            { $$ = new Catch($3, $5);  }
;

Finally
  : FINALLY Block                        { $$ = new Finally($2); }
;

NoReserved
  : GET
  | SET
;

FunctionDeclaration  /* function get () {} */
  : FUNCTION IDENT '(' ')' FunctionBody    { $$ = new FuncDecl($2, 0, $5); }
  | FUNCTION IDENT '(' FormalParameterList ')' FunctionBody
                                           { $$ = new FuncDecl($2, $4, $6); }
  | FUNCTION NoReserved '(' ')' FunctionBody    { $$ = new FuncDecl($2, 0, $5); }
  | FUNCTION NoReserved '(' FormalParameterList ')' FunctionBody
                                           { $$ = new FuncDecl($2, $4, $6); }
;

FunctionExpression
  : FUNCTION '(' ')' FunctionBody                     { $$ = new FuncExpression(0, $4); }
  | FUNCTION '(' FormalParameterList ')' FunctionBody { $$ = new FuncExpression($3, $5); }
  | FUNCTION IDENT '(' ')' FunctionBody               { $$ = new FuncExpression(0, $5, $2); }
  | FUNCTION IDENT '(' FormalParameterList ')' FunctionBody { $$ = new FuncDecl($4, $6, $2); }
  | FUNCTION NoReserved '(' ')' FunctionBody               { $$ = new FuncExpression(0, $5, $2); }
  | FUNCTION NoReserved '(' FormalParameterList ')' FunctionBody { $$ = new FuncDecl($4, $6, $2); }
;

FormalParameterList
  : Ident                                             { $$ = new Parameter($1);  }
  | FormalParameterList ',' Ident                     { $$ = new Parameter($1, $3);  }
;

FunctionBody
  : '{' '}'                                           { $$ = new FunctionBody(0); }
  | '{' SourceElements '}'                            { $$ = new FunctionBody($2); }
  | '{' SourceElements_error '}'                      { $$ = new FunctionBody($2); }
;

Program
  : /* nothing, empty script */ EOF                   { return new Program(0); }
  | SourceElements EOF                              { return new Program($1); }
  | SourceElements_error EOF                              { return new Program($1); }
;

SourceElements
  : SourceElement                                     { $$ = new SourceElements($1); }
  | SourceElements SourceElement                      { $$ = new SourceElements($1, $2); }
;

SourceElements_error
  : SourceElement_error                                     { $$ = new SourceElements($1); }
  | SourceElements SourceElement_error                      { $$ = new SourceElements($1, $2); }
;

SourceElement
  : Statement                                         { $$ = $1; }
  | FunctionDeclaration                               { $$ = $1; }
;

SourceElement_error
  : Statement_error                                         { $$ = $1; }
;





























PrimaryExpressionNoBrace
  : THIS                           { $$ = new This(); }
  | Literal
  | ArrayLiteral
  | '(' Expression ')'                   { $$ = new Group($2); }
;

MemberExpressionNoBrace
  : PrimaryExpressionNoBrace
  | MemberExpressionNoBrace '[' Expression ']'        { $$ = new Accessor1($1, $3); }
  | MemberExpressionNoBrace '.' IdentifierName        { $$ = new Accessor2($1, $3);  }
  | NEW MemberExpression Arguments             { $$ = new NewExpression($2, $3); }
;

NewExpressionNoBrace
  : MemberExpressionNoBrace
  | NEW NewExpression                          { $$ = new NewExpression($2); }
;

CallExpressionNoBrace
  : MemberExpressionNoBrace Arguments                 { $$ = new FunctionCall($1, $2); }
  | CallExpressionNoBrace Arguments                   { $$ = new FunctionCall($1, $2); }
  | CallExpressionNoBrace '[' Expression ']'          { $$ = new Accessor1($1, $3); }
  | CallExpressionNoBrace '.' IdentifierName          { $$ = new Accessor2($1, $3); }
;

LeftHandSideExpressionNoBrace
  : NewExpressionNoBrace                                { LeftHandSideExpressionlineno = yylineno; }
  | CallExpressionNoBrace                               { LeftHandSideExpressionlineno = yylineno; }
;

PostfixExpressionNoBrace    /* DONE: no line terminator here */
  : LeftHandSideExpressionNoBrace 
  | LeftHandSideExpressionNoBrace PLUSPLUS              {
                        if (LeftHandSideExpressionlineno !== yylineno)
                          throw new Error('Parse error on line ' + (yylineno + 1) + ':\n' + jsparser.lexer.showPosition() + '\n'
                            + 'There should not be LineTerminator before "++".');
                        $$ = new Postfix($1, new OpPlusPlus); }
  | LeftHandSideExpressionNoBrace MINUSMINUS            {
                        if (LeftHandSideExpressionlineno !== yylineno)
                          throw new Error('Parse error on line ' + (yylineno + 1) + ':\n' + jsparser.lexer.showPosition() + '\n'
                            + 'There should not be LineTerminator before "--".');
                        $$ = new Postfix($1, new OpMinusMinus); }
;

UnaryExpressionNoBrace
  : PostfixExpressionNoBrace
  | DELETE UnaryExpressionNoBrace                       { $$ = new Delete($2); }
  | VOID UnaryExpressionNoBrace                         { $$ = new Void($2); }
  | TYPEOF UnaryExpressionNoBrace                       { $$ = new TypeOf($2); }
  | PLUSPLUS UnaryExpressionNoBrace                     { $$ = new Prefix(OpPlusPlus, $2); }
  | AUTOPLUSPLUS UnaryExpressionNoBrace                 { $$ = new Prefix(OpPlusPlus, $2); }
  | MINUSMINUS UnaryExpressionNoBrace                   { $$ = new Prefix(OpMinusMinus, $2); }
  | AUTOMINUSMINUS UnaryExpressionNoBrace               { $$ = new Prefix(OpMinusMinus, $2); }
  | '+' UnaryExpression                          { $$ = new UnaryPlus($2); }
  | '-' UnaryExpression                          { $$ = new Negate($2); }
  | '~' UnaryExpression                          { $$ = new BitwiseNot($2); }
  | '!' UnaryExpression                          { $$ = new LogicalNot($2); }
;

MultiplicativeExpressionNoBrace
  : UnaryExpressionNoBrace
  | MultiplicativeExpressionNoBrace '*' UnaryExpression { $$ = new Mult($1, $3, '*'); }
  | MultiplicativeExpressionNoBrace '/' UnaryExpression { $$ = new Mult($1, $3, '/'); }
  | MultiplicativeExpressionNoBrace '%' UnaryExpression { $$ = new Mult($1, $3,'%'); }
;

AdditiveExpressionNoBrace
  : MultiplicativeExpressionNoBrace
  | AdditiveExpressionNoBrace '+' MultiplicativeExpression { $$ = new Add($1, $3, '+'); }
  | AdditiveExpressionNoBrace '-' MultiplicativeExpression { $$ = new Add($1, $3, '-'); }
;

ShiftExpressionNoBrace
  : AdditiveExpressionNoBrace
  | ShiftExpressionNoBrace LSHIFT AdditiveExpression  { $$ = new Shift($1, new OpLShift, $3); }
  | ShiftExpressionNoBrace RSHIFT AdditiveExpression  { $$ = new Shift($1, new OpRShift, $3); }
  | ShiftExpressionNoBrace URSHIFT AdditiveExpression { $$ = new Shift($1, new OpURShift, $3); }
;

RelationalExpressionNoBrace
  : ShiftExpressionNoBrace
  | RelationalExpressionNoBrace '<' ShiftExpression               { $$ = new Relational($1, new OpLess, $3); }
  | RelationalExpressionNoBrace '>' ShiftExpression               { $$ = new Relational($1, new OpGreater, $3); }
  | RelationalExpressionNoBrace LE ShiftExpression                { $$ = new Relational($1, new OpLessEq, $3); }
  | RelationalExpressionNoBrace GE ShiftExpression                { $$ = new Relational($1, new OpGreaterEq, $3); }
  | RelationalExpressionNoBrace INSTANCEOF ShiftExpression        { $$ = new Relational($1, new OpInstanceOf, $3); }
  | RelationalExpressionNoBrace IN ShiftExpression                { $$ = new Relational($1, new OpIn, $3); }
;

EqualityExpressionNoBrace
  : RelationalExpressionNoBrace
  | EqualityExpressionNoBrace EQEQ RelationalExpression           { $$ = new Equal($1, new OpEqEq, $3); }
  | EqualityExpressionNoBrace NE RelationalExpression             { $$ = new Equal($1, new OpNotEq, $3); }
  | EqualityExpressionNoBrace STREQ RelationalExpression          { $$ = new Equal($1, new OpStrEq, $3); }
  | EqualityExpressionNoBrace STRNEQ RelationalExpression         { $$ = new Equal($1, new OpStrNEq, $3);}
;

BitwiseANDExpressionNoBrace
  : EqualityExpressionNoBrace
  | BitwiseANDExpressionNoBrace '&' EqualityExpression { $$ = new BitOper($1, new OpBitAnd, $3); }
;

BitwiseXORExpressionNoBrace
  : BitwiseANDExpressionNoBrace
  | BitwiseXORExpressionNoBrace '^' BitwiseANDExpression { $$ = new BitOper($1, new OpBitXOr, $3); }
;

BitwiseORExpressionNoBrace
  : BitwiseXORExpressionNoBrace
  | BitwiseORExpressionNoBrace '|' BitwiseXORExpression { $$ = new BitOper($1, new OpBitOr, $3); }
;

LogicalANDExpressionNoBrace
  : BitwiseORExpressionNoBrace
  | LogicalANDExpressionNoBrace AND BitwiseORExpression { $$ = new BinaryLogical($1, new OpAnd, $3); }
;

LogicalORExpressionNoBrace
  : LogicalANDExpressionNoBrace
  | LogicalORExpressionNoBrace OR LogicalANDExpression { $$ = new BinaryLogical($1, new OpOr, $3); }
;

LogicalORExpressionNoInNoBrace
  : LogicalANDExpressionNoBrace
  | LogicalORExpressionNoBrace OR LogicalANDExpressionNoIn { $$ = new BinaryLogical($1, new OpOr, $3, true); }
;

ConditionalExpressionNoBrace
  : LogicalORExpressionNoBrace
  | LogicalORExpressionNoBrace '?' AssignmentExpressionNoIn ':' AssignmentExpressionNoIn { $$ = new Conditional($1, $3, $5, true); }
;

AssignmentExpressionNoBrace
  : ConditionalExpressionNoBrace
  | LeftHandSideExpressionNoBrace AssignmentOperator AssignmentExpression { $$ = new Assign($1, $2, $3);}
;

ExpressionNoBrace
  : AssignmentExpressionNoBrace                               { Expressionlineno = yylineno; $$ = new Comma($1); }
  | ExpressionNoBrace ',' AssignmentExpression                { Expressionlineno = yylineno; $$ = new Comma($1, $3); }
;

%%

