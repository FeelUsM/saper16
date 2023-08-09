UNIT moy;
INTERFACE
uses crt;
function  minim(a,b: longint): longint;  {n.u.}
function  max(a,b: integer): integer;
function  st(x,y: integer): longint;
function  bit(x,n: byte): byte;
procedure pbit(var x: byte; n: byte; b: boolean);

procedure writeyx(y,x: byte; s: string);
function  bts(x: boolean): string;{не использ.}
function  its(x,l: longint): string;{не использ.}
procedure mes(s: string);
procedure mes_(s: string);

IMPLEMENTATION
function  minim(a,b: longint): longint;  {n.u.}
          BEGIN                                    {    mesp('minim');{}
          if a>b
             then minim:=b
             else minim:=a;
          END;
function  max(a,b: integer): integer;
          BEGIN
          if a>b
             then max:=a
             else max:=b;
          END;
function  st(x,y: integer): longint;
          BEGIN
          st:=round(exp(ln(x)*y));
          END;
function  bit(x,n: byte): byte;
          BEGIN
          bit:=x div(st(2,n))mod 2;
          END;
procedure pbit(var x: byte; n: byte; b: boolean);
          BEGIN
          if (bit(x,n)=1)xor b
          then if b
               then inc(x,st(2,n))
               else dec(x,st(2,n));
          END;
function  bts(x: boolean): string;{не использ.}
          var s: string;
          BEGIN
          if x
             then s:='true'
             else s:='false';
          bts:=s;
          END;
function  its(x,l: longint): string;{не использ.}
          var s: string;
          BEGIN
          str(x:l,s);
          its:=s;
          END;
procedure writeyx(y,x: byte; s: string);
          BEGIN
          gotoxy(x,y);
          write(s);
          END;
procedure mes_(s: string);
          BEGIN
          writeyx(1,20,s);
          END;
procedure mes(s: string);
          BEGIN
          mes_(s);
          readln;
          END;
END.