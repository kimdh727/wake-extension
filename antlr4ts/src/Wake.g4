/** Define a grammar Wake v0.20.1 */
grammar Wake;

tokens {INDENT, DEDENT, END} // TODO handle INDENT & DEDENT

wake
  : (wake_package
    | wake_from
    | wake_topic
    | wake_tuple
    | wake_data
    | wake_publish
    | wake_def
    | wake_target
    | EOL)* EOF
  ;

wake_package
  : PACKAGE parse_package
  ;

wake_from
  : FROM parse_from_importexport
  ;

wake_topic
  : GLOBAL? EXPORT? TOPIC parse_topic
  ;

wake_tuple
  : GLOBAL? EXPORT? TUPLE parse_tuple
  ;

wake_data
  : GLOBAL? EXPORT? DATA parse_data
  ;

wake_publish
  : PUBLISH parse_def_publish
  ;

wake_def
  : GLOBAL? EXPORT? DEF parse_decl_def
  ;

wake_target
  : GLOBAL? EXPORT? TARGET parse_decl_target
  ;

parse_binary
  : parse_unary
    (OPERATOR parse_binary
    | COLON parse_ast
    | (MATCH | LAMBDA | ID | LITERAL | PRIM | HERE | SUBSCRIBE | IF | POPEN) parse_binary
    | EOL)*
  ;

parse_unary
  : OPERATOR parse_binary
  | MATCH parse_match
  | LAMBDA parse_ast parse_binary
  | ID
  | LITERAL
  | PRIM LITERAL
  | HERE
  | SUBSCRIBE ID
  | POPEN /*INDENT*/ parse_block EOL? PCLOSE
  | IF parse_block EOL? THEN parse_block EOL? ELSE parse_block
  ;

parse_match
  : parse_binary+ EOL
    parse_ast
    (IF /*INDENT*/ parse_block EOL?)?
    EQUALS parse_block /*DEDENT*/ EOL
  ;

parse_package
  : ID EOL
  ;

parse_from_importexport
  : ID (IMPORT parse_import | EXPORT parse_export)
  ;

parse_from_import
  : ID IMPORT parse_import
  ;

parse_import
  : (DEF | TYPE | TOPIC)?
    (UNARY | BINARY)?
    (ID EQUALS ID | OPERATOR EQUALS OPERATOR | ID | OPERATOR)* EOL
  ;

parse_export
  : (DEF | TYPE | TOPIC)
    (UNARY | BINARY)?
    (ID EQUALS ID | OPERATOR EQUALS OPERATOR | ID | OPERATOR)* EOL
  ;

parse_topic
  : ID COLON parse_ast EOL
  ;

parse_ast
  : parse_unary_ast parse_ast_
  ;

parse_ast_
  : (OPERATOR parse_ast | (LITERAL | ID | POPEN) parse_ast? | COLON parse_ast)*
  ;

parse_unary_ast
  : OPERATOR parse_ast
  | ID
  | POPEN parse_ast PCLOSE
  ;

parse_tuple // TODO: How to handle EOL case ??
  : parse_type_def /*INDENT*/ EOL
    (GLOBAL? EXPORT? parse_ast /*DEDENT*/ EOL)*
  ;

parse_type_def
  : parse_ast EQUALS
  ;

parse_data // TODO: How to handle EOL case ??
  : parse_type_def (/*INDENT*/ EOL (parse_data_elt /*DEDENT*/ EOL)* | parse_data_elt)
  ;

parse_data_elt
  : parse_ast
  ;

parse_def
  : POPEN? parse_ast EQUALS parse_block EOL
  ;

parse_def_target
  : POPEN? parse_ast (LAMBDA parse_ast)? EQUALS parse_block EOL
  ;

parse_def_publish
  : POPEN? parse_ast EQUALS parse_block EOL
  ;

parse_block
  : /*INDENT*/ EOL parse_block_body /*DEDENT*/
  | parse_binary
  ;

parse_block_body
  : ((FROM parse_decl_from
    | TARGET parse_decl_target
    | DEF parse_decl_def))* ((REQUIRE parse_require) | parse_binary)
  ;

parse_decl_from
  : parse_from_import
  ;

parse_decl_def
  : parse_def
  ;

parse_decl_target
  : parse_def_target
  ;

parse_require
  : parse_ast EQUALS parse_block
    (EOL (ELSE parse_block EOL)? | ((ELSE parse_block EOL) | EOL))
    parse_block_body
  ;

// RE2C
fragment Sk_notick : [\p{Sk}] ; // TODO: How to remove '`' ??
fragment MODIFIER  : ([\p{Lm}]|[\p{M}]) ;
fragment UPPER     : ([\p{Lt}]|[\p{Lu}]) ;

// Sm categorized by operator precedence
fragment Sm_id     : [϶∂∅∆∇∞∿⋮⋯⋰⋱▷◁◸◹◺◻◼◽◾◿⟀⟁⦰⦱⦲⦳⦴⦵⦽⧄⧅⧈⧉⧊⧋⧌⧍⧖⧗⧝⧞⧠⧨⧩⧪⧫⧬⧭⧮⧯⧰⧱⧲⧳] ;
fragment Sm_nfkc   : [⁄⁺⁻⁼₊₋₌⅀−∕∖∣∤∬∭∯∰∶∼≁⨌⩴⩵⩶﬩﹢﹤﹥﹦＋＜＝＞｜～￢￩￪￫￬] ;
fragment Sm_norm   : [؆؇⁒℘⅁⅂⅃⅄⅋∊∍∗∽∾⊝⋴⋷⋼⋾⟂⟋⟍⟘⟙⟝⟞⦀⦂⧵⧸⧹⨟⨾⫞⫟⫠] ;
fragment Sm_unop   : [√∛∜] ;
fragment Sm_comp   : [∘⊚⋆⦾⧇] ;
fragment Sm_produ  : [∏⋂⨀⨂⨅⨉] ;
fragment Sm_prodb  : [×∙∩≀⊓⊗⊙⊛⊠⊡⋄⋅⋇⋈⋉⋊⋋⋌⋒⟐⟕⟖⟗⟡⦁⦻⦿⧆⧑⧒⧓⧔⧕⧢⨝⨯⨰⨱⨲⨳⨴⨵⨶⨷⨻⨼⨽⩀⩃⩄⩋⩍⩎] ;
fragment Sm_divu   : [∐] ;
fragment Sm_divb   : [÷⊘⟌⦸⦼⧶⧷⨸⫻⫽] ;
fragment Sm_sumu   : [∑∫∮∱∲∳⋃⨁⨃⨄⨆⨊⨋⨍⨎⨏⨐⨑⨒⨓⨔⨕⨖⨗⨘⨙⨚⨛⨜⫿] ;
fragment Sm_sumb   : [+~¬±∓∔∪∸∹∺∻≂⊌⊍⊎⊔⊕⊖⊞⊟⊹⊻⋓⧺⧻⧾⧿⨢⨣⨤⨥⨦⨧⨨⨩⨪⨫⨬⨭⨮⨹⨺⨿⩁⩂⩅⩊⩌⩏⩐⩪⩫⫬⫭⫾] ;
fragment Sm_lt     : [<≤≦≨≪≮≰≲≴≶≸≺≼≾⊀⊂⊄⊆⊈⊊⊏⊑⊰⊲⊴⊷⋐⋖⋘⋚⋜⋞⋠⋢⋤⋦⋨⋪⋬⟃⟈⧀⧏⧡⩹⩻⩽⩿⪁⪃⪅⪇⪉⪋⪍⪏⪑⪓⪕⪗⪙⪛⪝⪟⪡⪣⪦⪨⪪⪬⪯⪱⪳⪵⪷⪹⪻⪽⪿⫁⫃⫅⫇⫉⫋⫍⫏⫑⫓⫕⫷⫹] ;
fragment Sm_gt     : [>≥≧≩≫≯≱≳≵≷≹≻≽≿⊁⊃⊅⊇⊉⊋⊐⊒⊱⊳⊵⊶⋑⋗⋙⋛⋝⋟⋡⋣⋥⋧⋩⋫⋭⟄⟉⧁⧐⩺⩼⩾⪀⪂⪄⪆⪈⪊⪌⪎⪐⪒⪔⪖⪘⪚⪜⪞⪠⪢⪧⪩⪫⪭⪰⪲⪴⪶⪸⪺⪼⪾⫀⫂⫄⫆⫈⫊⫌⫎⫐⫒⫔⫖⫸⫺] ;
fragment Sm_eq     : [=≃≄≅≆≇≈≉≊≋≌≍≎≏≐≑≒≓≔≕≖≗≘≙≚≛≜≝≞≟≠≡≢≣≭⊜⋍⋕⧂⧃⧎⧣⧤⧥⧦⧧⩆⩇⩈⩉⩙⩦⩧⩨⩩⩬⩭⩮⩯⩰⩱⩲⩳⩷⩸⪤⪥⪮⫗⫘] ;
fragment Sm_test   : [∈∉∋∌∝∟∠∡∢∥∦≬⊾⊿⋔⋲⋳⋵⋶⋸⋹⋺⋻⋽⋿⍼⟊⟒⦛⦜⦝⦞⦟⦠⦡⦢⦣⦤⦥⦦⦧⦨⦩⦪⦫⦬⦭⦮⦯⦶⦷⦹⦺⩤⩥⫙⫚⫛⫝̸⫝⫡⫮⫲⫳⫴⫵⫶⫼] ;
fragment Sm_andu   : [⋀] ;
fragment Sm_andb   : [∧⊼⋏⟎⟑⨇⩑⩓⩕⩘⩚⩜⩞⩟⩠] ;
fragment Sm_oru    : [⋁] ;
fragment Sm_orb    : [|∨⊽⋎⟇⟏⨈⩒⩔⩖⩗⩛⩝⩡⩢⩣] ;
fragment Sm_Sc     : [♯] ;
fragment Sm_larrow : [←↑↚⇷⇺⇽⊣⊥⟣⟥⟰⟲⟵⟸⟻⟽⤂⤆⤉⤊⤌⤎⤒⤙⤛⤝⤟⤣⤦⤧⤪⤱⤲⤴⤶⤺⤽⤾⥀⥃⥄⥆⥉⥒⥔⥖⥘⥚⥜⥞⥠⥢⥣⥪⥫⥳⥶⥷⥺⥻⥼⥾⫣⫤⫥⫨⫫⬰⬱⬲⬳⬴⬵⬶⬷⬸⬹⬺⬻⬼⬽⬾⬿⭀⭁⭂⭉⭊⭋] ;
fragment Sm_rarrow : [→↓↛↠↣↦⇏⇒⇴⇶⇸⇻⇾⊢⊤⊦⊧⊨⊩⊪⊫⊬⊭⊮⊯⊺⟢⟤⟱⟳⟴⟶⟹⟼⟾⟿⤀⤁⤃⤅⤇⤈⤋⤍⤏⤐⤑⤓⤔⤕⤖⤗⤘⤚⤜⤞⤠⤤⤥⤨⤩⤭⤮⤯⤰⤳⤵⤷⤸⤹⤻⤼⤿⥁⥂⥅⥇⥓⥕⥗⥙⥛⥝⥟⥡⥤⥥⥬⥭⥰⥱⥲⥴⥵⥸⥹⥽⥿⧴⫢⫦⫧⫪⭃⭄⭇⭈⭌] ;
fragment Sm_earrow : [↔↮⇎⇔⇵⇹⇼⇿⟚⟛⟠⟷⟺⤄⤡⤢⤫⤬⥈⥊⥋⥌⥍⥎⥏⥐⥑⥦⥧⥨⥩⥮⥯⫩] ;
fragment Sm_quant  : [∀∁∃∄∎∴∵∷] ;
fragment Sm_wtf    : [؈⊸⟓⟔⟜⟟⦙⦚⧜⧟⨞⨠⨡⫯⫰⫱] ;
fragment Sm_multi  : [⌠⌡⍼⎛⎜⎝⎞⎟⎠⎡⎢⎣⎤⎥⎦⎧⎨⎩⎪⎫⎬⎭⎮⎯⎰⎱⎲⎳⏜⏝⏞⏟⏠⏡] ;
fragment Sm_op     : Sm_nfkc | Sm_norm | Sm_unop | Sm_comp | Sm_produ | Sm_prodb | Sm_divu | Sm_divb | Sm_sumu | Sm_sumb | Sm_lt | Sm_gt | Sm_eq | Sm_test | Sm_andu | Sm_andb | Sm_oru | Sm_orb | Sm_Sc | Sm_larrow | Sm_rarrow | Sm_earrow | Sm_quant ;

fragment NLC   : [\n\f\r\u0085\u2028\u2029] ;
fragment NL    : NLC | '\r\n' ;
fragment NOTNL : ~ [\n\f\r\u0085\u2028\u2029] ;
fragment LWS   : [\t \u00a0\u1680\u2000-\u200A\u202F\u205F\u3000] ;

// whitespace
fragment WHITESPACE // TODO nl lws* / ("#"|nl)
  : LWS+
  ;

WS      : WHITESPACE -> skip ;
COMMENT : '#' NOTNL* -> skip ;
EOL     : NL LWS* ;

LITERAL
  : RSTR
  | SSTR
  | DSTR
  | DOUBLE
  | INTEGER
  ;

// character and string literals
fragment RSTR : '`' (~'`')* '`' ;
fragment SSTR : '\'' (~'\'')* '\'' ;
fragment DSTR : '"' (~'"')* '"' ;   // TODO: ESCAPE rules

// double literals
fragment DEC       : [1-9][0-9_]* ;
fragment DOUBLE10  : (DEC|'0') '.' [0-9_]+ ([eE] [+-]? [0-9_]+)? ;
fragment DOUBLE10e : (DEC|'0') [eE] [+-]? [0-9_]+ ;
fragment DOUBLE16  : '0x' [0-9a-fA-F_]+ '.' [0-9a-fA-F_]+ ([pP] [+-]? [0-9a-fA-F_]+)? ;
fragment DOUBLE16e : '0x' [0-9a-fA-F_]+ [pP] [+-]? [0-9a-fA-F_]+ ;
DOUBLE
  : DOUBLE10
  | DOUBLE10e
  | DOUBLE16
  | DOUBLE16e
  ;

// integer literals
fragment OCT : '0'[0-7_]* ;
fragment HEX : '0x' [0-9a-fA-F_]+ ;
fragment BIN : '0b' [01_]+ ;
INTEGER
  : DEC
  | OCT
  | HEX
  | BIN
  ;

// keywords
DEF       : 'def' ;
TUPLE     : 'tuple' ;
DATA      : 'data' ;
GLOBAL    : 'global' ;
TARGET    : 'target' ;
PUBLISH   : 'publish' ;
SUBSCRIBE : 'subscribe' ;
PRIM      : 'prim' ;
IF        : 'if' ;
THEN      : 'then' ;
ELSE      : 'else' ;
HERE      : 'here' ;
MATCH     : 'match' ;
REQUIRE   : 'require' ;
PACKAGE   : 'package' ;
IMPORT    : 'import' ;
EXPORT    : 'export' ;
FROM      : 'from' ;
TYPE      : 'type' ;
TOPIC     : 'topic' ;
UNARY     : 'unary' ;
BINARY    : 'binary' ;
LAMBDA    : '\\' ;
EQUALS    : '=' ;
COLON     : ':' ;
POPEN     : '(' ;
PCLOSE    : ')' ;
BOPEN     : '{' ;
BCLOSE    : '}' ;

// operators
fragment Po_reserved : [?@] ;
fragment Po_special  : ["#'\\] ;
fragment Po_op       : [!%&*,./:;] ;
// !!! TODO: Po, Pd(without -)
fragment OP : (Sk_notick|[\p{Sc}]|Sm_op|Po_op|'-')+ ; // [^] is Sk
OPERATOR : OP ;

// identifiers
fragment START : [\p{L}]|[\p{So}]|Sm_id|[\p{Nl}]|'_' ;
fragment BODY  : [\p{L}]|[\p{So}]|Sm_id|[\p{N}]|[\p{Pc}]|[\p{Lm}]|[\p{M}] ;
ID : MODIFIER* START BODY* ;
