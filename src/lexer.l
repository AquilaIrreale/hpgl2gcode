%{
#include <config.h>

#include <stdlib.h>
#include "parser.h"
%}
%%
[ \n\r\t\v\f\b]+ {; /* Ignore */}

IN {return IN;}
IP {return IP;}
SC {return SC;}
SP {return SP;}
PU {return PU;}
PD {return PD;}
PA {return PA;}
AA {return AA;}
VS {return VS;}

-?[0-9]*\.[0-9]+ {yylval.d = atof(yytext); return DOUBLE;}
-[0-9]+          {yylval.d = atof(yytext); return DOUBLE;}
[0-9]+           {yylval.i = atoi(yytext); return NUMBER;}

. {return *yytext;}
%%
