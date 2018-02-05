package pasito.syntax;

import java_cup.runtime.ComplexSymbolFactory.Location;
import java_cup.runtime.ComplexSymbolFactory;
import java.io.IOException;
import java_cup.runtime.Symbol;
import java.io.FileInputStream;


%%

%debug

// nome da classe a ser gerada pelo jflex
%class PasitoScanner 

// privacidade da scanner gerado  
%public

%unicode 

// habilita contagem de linhas (yyline -- começa na linha 0)
%line
// habilita contagem de caracteres (yychar -- começa na coluna 0)
%char  
// habilita contagem de colunas (yycolumn -- começa em 0)
%column 

/*
* yytext(): palavra de entrada (lexema)
* yylenght(): comprimento do lexema
*/

%cup 
	
// implementa a classe sym gerada pelo cup
%implements sym

%{
	private ComplexSymbolFactory symbolFactory;
    private Symbol ultimoSimbolo;

    public PasitoScanner(java.io.Reader reader, ComplexSymbolFactory sf) {
      this(reader);
      symbolFactory = sf;
    }

    /*
    * Método fábricas de símbolos
    * O símbolo retornado é uma instância de ComplexSymbolFactory, implementada pelo CUP
    */
    public Symbol symbol(String nome, int code) {
    	ultimoSimbolo = symbolFactory.newSymbol(nome, code,
                            new Location(yyline+1, yycolumn+1, yychar),
                            new Location(yyline+1, yycolumn+yylength(), yychar+yylength()));
        return ultimoSimbolo;
    }

    public Symbol symbol(String nome, int code, Object value) {
    	ultimoSimbolo = symbolFactory.newSymbol(nome, code,
                            new Location(yyline+1, yycolumn+1, yychar),
                            new Location(yyline+1, yycolumn+yylength(), yychar+yylength()),
                            value);
        return ultimoSimbolo;
    }

%}

/*
%eofval{
  return symbol("EOF",EOF);
%eofval}
*/
// início das definições regulares

/* Comentários */   
Comentario_bloco = "/*" ~"*/"
Comentario_linha = "//" .*
Comentario = {Comentario_bloco} | {Comentario_linha}

/* Delimitadores */
Fim_linha = \r\n | [\r\n\u2028\u2029\u000B\u000C\u0085] // fim de linha
Espaco_Branco = {Fim_linha} | [\t\f ] // espaço em branco
espacos = {Espaco_Branco}* | {Comentario} // tudo isso será ignorado

/* Literais Numéricos */
Digito = [:digit:]       // Unicode digits
DigitoInt = [0-9]
Decimal_lit = 0 | [1-9] {DigitoInt}*
Octal_lit = 0[0-7]+
Hex_lit = 0 [xX] ({DigitoInt} | [a-fA-F])+
Numero_int = {Decimal_lit} |  {Octal_lit} | {Hex_lit}

// Floating-point literals
Numero_float = ({Digito}+)? (\.{Digito}+) (E[+\-]? {Digito}+)? //

/* Identificadores */
//********* Não está compatível com GO
Letra = [:letter:]  // Unicode letters
  Id = {Letra} ( {Letra} | {Digito} )*

%%

// Tokens com suas ações correspondentes
<YYINITIAL> {
	{Fim_linha}    	{ if ( ultimoSimbolo.sym == ID ||
						   ultimoSimbolo.sym == INT32 ||
						   ultimoSimbolo.sym == FLOAT64 ||
						   ultimoSimbolo.sym == FLOAT_NUMBER
						   // || ...  <--- Ver https://golang.org/ref/spec#Semicolons
						 ) 
					     return symbol("SEMICOLON", SEMICOLON); }
	{espacos}		{ }

	// *** Estes tokens deveriam ser tratados como identificadores
	boolean  		{ return symbol("BOOLEAN", BOOLEAN); }
	int32  			{ return symbol("INT32", INT32); }
	float64  		{ return symbol("FLOAT64", FLOAT64); }
	
	// Keywords
	var  			{ return symbol("VAR", VAR); }
	default  		{ return symbol("DEFAULT", DEFAULT); }
	case  			{ return symbol("CASE", CASE); }
	else  			{ return symbol("ELSE", ELSE); }
	const  			{ return symbol("CONST", CONST); }
	for  			{ return symbol("FOR", FOR); }
	range     		{ return symbol("RANGE", RANGE); }
	func  			{ return symbol("FUNC", FUNC); }
	struct 			{ return symbol("STRUCT", STRUCT); }
	switch  		{ return symbol("SWITCH", SWITCH); }
	fallthrough 	{ return symbol("FALLTHROUGH", FALLTHROUGH); } //Walan: essa linha estava comentada
	return  		{ return symbol("RETURN", RETURN); }
	interface  		{ return symbol("INTERFACE", INTERFACE); }
	type  			{ return symbol("TYPE", TYPE); }
	if 				{ return symbol("IF", IF); }
	
	// Walan Keywords
	break			{ return symbol("BREAK", BREAK); }
	chan				{ return symbol("CHAN", CHAN); }
	continue			{ return symbol("CONTINUE", CONTINUE); }
	defer			{ return symbol("DEFER", DEFER); }
	go				{ return symbol("GO", GO); }
	goto				{ return symbol("GOTO", GOTO); }
	import			{ return symbol("IMPORT", IMPORT); }
	map				{ return symbol("MAP", MAP); }
	package			{ return symbol("PACKAGE", PACKAGE); }
	select			{ return symbol("SELECT", SELECT); }
	
	
	
	//*** Não compatível com GO -- atributos dos tokens não estão sendo calculados
	{Numero_int}	{ return symbol("INT_NUMBER", INT_NUMBER); }
	{Numero_float} 	{ return symbol("FLOAT_NUMBER", FLOAT_NUMBER); }
	
	"<"				{ return symbol("LT", LT); }
	"=="			{ return symbol("EQ", EQ); }
	"+"				{ return symbol("PLUS", PLUS); }
	"-"				{ return symbol("MINUS", MINUS); }
	"*"				{ return symbol("TIMES", TIMES); }
	"/"				{ return symbol("DIV", DIV); }
	"&&" 			{ return symbol("AND", AND); }
	"!"				{ return symbol("NOT", NOT); } //**** Walan: mudei o nome do simbolo
	
	// Walan Operators
	"&"				{ return symbol("BITAND", BITAND); }
	"+="				{ return symbol("PLUSASSIGN", PLUSASSIGN); }
	"&="				{ return symbol("ANDASSIGN", ANDASSIGN); }
	"!="				{ return symbol("NOTEQ", NOTEQ); }
	"|"				{ return symbol("BITOR", BITOR); }
	"-="				{ return symbol("MINUSASSIGN", MINUSASSIGN); }
	"|="				{ return symbol("ORASSIGN", ORASSIGN); }
	"||"				{ return symbol("OR", OR); }
	"<="				{ return symbol("LE", LE); }
	"^"				{ return symbol("BITXOR", BITXOR); }
	"*="				{ return symbol("TIMESASSIGN", TIMESASSIGN); }
	"^="				{ return symbol("EXCLORASSIGN", EXCLORASSIGN); }
	"<-"				{ return symbol("CHANNEL", CHANNEL); }
	">"				{ return symbol("GT", GT); }
	">="				{ return symbol("GE", GE); }
	"<<"				{ return symbol("LSHIFT", LSHIFT); }
	"/="				{ return symbol("DIVASSIGN", DIVASSIGN); }
	"<<="			{ return symbol("LSHIFTASSIGN", LSHIFTASSIGN); }
	"++"				{ return symbol("PLUSPLUS", PLUSPLUS); }
	"%"				{ return symbol("MOD", MOD); }
	">>"				{ return symbol("RSHIFT", RSHIFT); }
	"%="				{ return symbol("MODASSIGN", MODASSIGN); }
	">>="			{ return symbol("RSHIFTASSIGN", RSHIFTASSIGN); }
	"--"				{ return symbol("MINUSMINUS", MINUSMINUS); }
	"&^"				{ return symbol("BITCLR", BITCLR); }
	"&^="			{ return symbol("BITCLRASSIGN", BITCLRASSIGN); }
	
	","				{ return symbol("COMMA", COMMA); }
	"="				{ return symbol("ASSIGN", ASSIGN); }
	":="			{ return symbol("DASSIGN", DASSIGN); }
	";"				{ return symbol("SEMICOLON", SEMICOLON); }
	"..."			{ return symbol("DOTDOTDOT", DOTDOTDOT); }
	":"				{ return symbol("COLON", COLON); }
	"."		    	{ return symbol("DOT", DOT);}
	
	"("				{ return symbol("LPAR", LPAR); }
	")"				{ return symbol("RPAR", RPAR); }
	"["				{ return symbol("LSBRACK", LSBRACK); }
	"]"				{ return symbol("RSBRACK", RSBRACK); }
	"{"				{ return symbol("LBRACK", LBRACK); }
	"}"				{ return symbol("RBRACK", RBRACK); }
	{Id}			{ return symbol("ID", ID); }
	.				{ System.out.println(
						"Scanner warning >> " + 
						"Unrecognized character '" + yytext() + "' -- ignored" + " at line" +
                		(yyline+1) + ", column " + (yycolumn+1) ); }
}
