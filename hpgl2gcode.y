%{
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <math.h>

#define PI (acos(-1.0))
#define DEG2RAD(d) ((d) * PI / 180.0)

#define U2UM(u) ((u) * 25)
#define U2MM_IP(u) (U2UM(u) / 1000)
#define U2MM_FP(u) (U2UM(u) % 1000)

int yywrap();
void yyerror(const char *s);

void sc(unsigned minx, unsigned maxx, unsigned miny, unsigned maxy);
void pu();
void pd();
void pa(unsigned x, unsigned y);
void aa(unsigned cx, unsigned cy, double theta);

unsigned feedrate = 1200;

unsigned curx = 0;
unsigned cury = 0;

unsigned p1x = 0;
unsigned p1y = 0;
unsigned p2x = 100;
unsigned p2y = 100;
%}
%union {
    int i;
    double d;
}
%token <i> NUMBER
%token <d> DOUBLE
%type  <d> double
%token IN IP SC SP PU PD PA AA
%start list
%%
double: DOUBLE
      | NUMBER {$$ = (double) $1;}

list: /* nothing */
    | list ';'
    | list command ';'

command: IN
       | SP NUMBER /* ignore */
       | ip
       | sc
       | pa
       | aa
       | pu
       | pd

ip: IP                                         {p1x = 0; p1y = 0; p2x = 100; p2y = 100;}
  | IP NUMBER ',' NUMBER ',' NUMBER ',' NUMBER {p1x = $2; p1y = $4; p2x = $6; p2y = $8;}

sc: SC                                         {sc(0, 100, 0, 100);}
  | SC NUMBER ',' NUMBER ',' NUMBER ',' NUMBER {sc($2, $4, $6, $8);}

pa: PA NUMBER ',' NUMBER     {pa($2, $4);}
  | pa ',' NUMBER ',' NUMBER {pa($3, $5);}

pu: PU {pu();}
  | pu_pa

pu_pa: PU NUMBER ',' NUMBER        {pu(); pa($2, $4);}
     | pu_pa ',' NUMBER ',' NUMBER {pa($3, $5);}

pd: PD {pd();}
  | pd_pa

pd_pa: PD NUMBER ',' NUMBER        {pd(); pa($2, $4);}
     | pd_pa ',' NUMBER ',' NUMBER {pa($3, $5);}

aa: AA NUMBER ',' NUMBER ',' double            {aa($2, $4, $6);}
  | AA NUMBER ',' NUMBER ',' double ',' NUMBER {aa($2, $4, $6);}
%%
void sc(unsigned minx, unsigned maxx, unsigned miny, unsigned maxy)
{
    /* unused, for now */
}

void pu()
{
    puts("G1 Z5.0 F1500");
}

void pd()
{
    puts("G1 Z0.0 F1500");
}

void pa(unsigned x, unsigned y)
{
    printf("G1 X%u.%03u Y%u.%03u F%u\n",
           U2MM_IP(x),
           U2MM_FP(x),
           U2MM_IP(y),
           U2MM_FP(y),
           feedrate); 

    curx = x;
    cury = y;
}

void aa(unsigned cx, unsigned cy, double theta)
{
    while (theta > 360.0) {
        theta -= 360.0;
    }

    while (theta < -360.0) {
        theta += 360.0;
    }

    if (fabs(theta) == 360.0) {
        aa(cx, cy, 180.0);
        aa(cx, cy, 180.0);

        return;
    }

    double s = sin(DEG2RAD(theta));
    double c = cos(DEG2RAD(theta));

    int px = curx - cx;
    int py = cury - cy;

    double tx = px * c - py * s;
    double ty = px * s + py * c;
    
    unsigned x = tx + cx;
    unsigned y = ty + cy;

    int i = cx - curx;
    int j = cy - cury;
    
    printf("G%c X%u.%03u Y%u.%03u I%d.%03d J%d.%03d F%u\n",
           theta < 0 ? '2' : '3',
           U2MM_IP(x), U2MM_FP(x),
           U2MM_IP(y), U2MM_FP(y),
           U2MM_IP(i), abs(U2MM_FP(i)),
           U2MM_IP(j), abs(U2MM_FP(j)),
           feedrate);

    curx = x;
    cury = y;
}

int yywrap() {
    return 1;
}

void yyerror(const char *s)
{
    fprintf(stderr, "%s\n", s);
}

void init()
{
    puts("M104 S0\n"
         "M140 S0\n"
         "G21\n"
         "G90\n"
         "G92\n"
         "M107\n"
         "M117 Plotting...");
    pu();
}

void finalize()
{
    pu();
    puts("G28 X0 Y0\n"
         "M84");
}

int main(int argc, char *argv[])
{
    if (argc > 3) {
        puts("Too many arguments");
        return 1;
    }

    if (argc > 1) {
        if (!freopen(argv[1], "r", stdin)) {
            perror(argv[1]);
            return 1;
        }

        if (argc > 2) {
            if (!freopen(argv[2], "w", stdout)) {
                perror(argv[2]);
                return 1;
            }
        } else {
            char *inname = argv[1];
            char *dot = strrchr(inname, '.');
            int len;
            if (dot == NULL || strcmp(dot, ".hpgl") != 0) {
                len = strlen(inname);
            } else {
                len = dot - inname;
            }

            char *outname = malloc((len + 6 + 1) * sizeof *outname);
            strncpy(outname, inname, len);
            strcpy(outname+len, ".gcode");

            if (!freopen(outname, "w", stdout)) {
                perror(outname);
                return 1;
            }

            free(outname);
        }
    }

    init();
    yyparse();
    finalize();
}

