{todo:
определение текущей директории для cfg-файла
справка о том, 
    как закрыть,
    как управлять
    где cfg-файл
    какие цифры что означают
    оставить одного пользователя
    добавить управление стрелками
    правую линейку
}
{программа должна компилироваться в TPW}
program saper_professional;
uses crt,moy,baseofsa,mytime;
{x - горизонталь,y - вертикаль}              {$F+}
const min='*';
      fl='!';
      wfl='x';
      no='-';
      nm=' ';
      cf:array[0..8]of char=(nm,'1','2','3','4','5','6','7','8');
      scrh=23;
      scrl=39;
      otst=4;
      posinf=14;
      nbf=0;
      maxkolvoigr=10;
      configf='config.txt';
      reitingf='';{.....}
      lenghtstack=12760;
type kldetect=function(y,x:byte):boolean;
     kldoing=procedure(y,x:byte;var otv:byte);
var stack:array[0..lenghtstack]of record                {стек}
                  x,y,otv:byte;
                          end;
    stkpointh,stkpointl:word;                           {и все с ним связанное}
    igr :array[1..maxkolvoigr] of record              {для кпаждого игрока:}
                      name:string;
                       up,down,left,right,k1,k2,kurs:char;
                                x,y:byte;
                               end;
    reginput:(nonfluging,standart,fluging1,fluging2);  {режим ввода}
    regproc:(allyouself,auto0,automatic,automatic_);    {режим автоматики}
    fk1_,fk2_,open_:kldoing;
    ppf:array[1..8]of byte;
    h0,l0,kolvoigr:byte;                {размеры поля, и kolvoigr}
    kolvomin:word;                                      {количество мин на поле(константа в течении игры)}
    km:integer;                                         {=kolvomin-количество флажков}
    kl,nopkl:word;                    {количество (всего и неоткрытых) клеток за исключением количества мин;}
    scr:record                       {координаты левого верхнего угла экрана}
        x,y:byte
        end;
    i,j:byte;
    time0:ttime;{}
    start,game:boolean;
    inf:string;//[scrl*2-posinf];
{content procedures
moy.tpu
  ------------------------------------------------стандартные и базовые логические функции
  function minim(a,b:longint):longint;      нез.
  function max(a,b:integer):integer;              нез.
  function st(x,y:integer):longint;               нез.
  function bit(x,n:byte):byte;          нез.
  procedure pbit(var x:byte;n:byte;b:boolean);    пуст.
  ------------------------------------------------стандартные вывода и отладочные
  function bts(x:boolean):string;      нез.
  function its(x,l:longint):string;               нез.
  procedure writeyx(y,x:byte;s:string);           нез.выв.
  procedure mes_(s:string);                       writeyx(20,1,s);
  procedure mes(s:string);                        -||-+readln
baseofsaper.tpu---------------------------------базовые логические функции
  function mina(y,x:byte):boolean;    [pole](7-й бит)use(bit)
  function flag(y,x:byte):boolean;    [pole](6-й бит)use(bit)
  function cifra(y,x:byte):byte;      [pole](биты 0-3)
  function notopen(y,x:byte):boolean;             use(cifra,flag)
  procedure pmina(y,x:byte;m:boolean);            /[pole]use(mina)
  procedure pflag(y,x:byte;f:boolean);            /[pole]use(flag)
  procedure pcifra(y,x,c:byte);                   /[pole]
------------------------------------------------функции времени
mytime.tpu
  procedure dt(var rez:ttime;x1,x2:ttime);        нез.(x1-x2)
  procedure moygettime(var t:ttime);              нез.use_(gettime)
procedure stoptime;            ...gotime        /[time0](time0:=tec-time0)use(moygettime,dt)
procedure outtime;                              [time0,start,game]use(moygettime,dt,writexy,its)
            (выв. (в инф.стр.)с поз.7,6 поз.:if start(if game(tec-time0)else(time0)))
------------------------------------------------вывод
function tinscr(y,x:byte):boolean;    [scr.y,scr.x.scrh,scrl]
function cursinscr(y,x:byte):boolean;    [scr.y,scr.x.scrh,scrl,otst](по1хоже не учитывает краевых эффектов)
function xpr(x:byte;b:boolean):byte;            нез.(b:true - out0 false - outcurs)
procedure out0(y,x:byte);      [game,fl,no,min,wfl,cf,scr.x,scr.y]use(notopen,flag,mina,cifra,writexy,xpr)
            (...точка взрыва)
procedure outcurs0(y,x:byte;kurs:char);         [scr.y,scr.x]use(writexy,xpr)
procedure outmin;                               (выв. (в инф.стр.)сначала,5 поз.)[scrh,km]use(writexy,its)
procedure outinf;                               (inf с posinf)[inf,posinf,scrh]use(outmin,outtime,writexy)
procedure outall;                               [kolvoigr,igr:x,y,kurs;,scr.y,scr.x,scrh,scrl](...виртуальный экран)
            use(out0,outcurs0,tinscr,outinf,outtime)
procedure out(y,x:byte);                       use(tinscr,out0){[scr.x,scr.y,scrh,scrl]use(outall)
procedure outcurs(i:byte);                      /[scr.y,scr.x][scrl,scrh,l0,h0(?),igr[i]:x,y,kurs;otst]
            use(cursinscr,outcurs0,max,outall,)(+inf +...)
procedure clrcurs(y_,x_,n:byte);                (+выводит затертый курсор)[kolvoigr,igr:x,y,kurs]use(tinscr,outcurs0)
------------------------------------------------ядро
procedure win;                        /[nopkl,game,inf]use(stoptime,outall)(dec(nopkl))
procedure gamover(otv:byte);          /[game,inf][ppf,nbf]use(stoptime,outall)use(set)
procedure around(y,x:byte;var otv:byte;detect:kldetect;doing:kldoing);
                        [game](if (y>=1)and(y<=h0)and(x>=1)and(x<=l0)and detect(y,x)and game)
{procedure aroundbit(y,x,otv:byte;var z:byte;detect:kldetect;doing:kldoing);
function all(y,x:byte):boolean;          нез.
function openb(y,x:byte):boolean;        =not notopen(y,x);
procedure fk12(y,x:byte;var otv:byte);      <=>fk2_(y,x,otv);fk1_(y,x,otv);
procedure openz(y,x:byte; var z:byte);          пуст.
procedure automat0(y,x:byte;var otv:byte);      use(openb,cifra,around,all,open_)(var z; around(y,x,z...))
function infstack:string;      [stkpointh,stkpointl,lenghtstack]use(its)(h:5,l:6,razm:6)
procedure automat;
procedure push(y,x:byte;var otv:byte);
procedure putoffflag(y,x,otv:byte);
procedure putonflag(y,x:byte;var otv:byte);
procedure autoflag(y,x:byte;var otv:byte);
procedure incz(y,x:byte;var z:byte);
procedure open(y,x:byte;var otv:byte);
procedure fk2(y,x:byte;var otv:byte);
procedure inczfk1(y,x:byte;var z:byte);
function notflag(y,x:byte):boolean;
procedure fk1(y,x:byte;var otv:byte);
------------------------------------------------старт
function notcurs(ly,lx:byte):boolean;
procedure checcurs(y,x:byte;var z:byte);
procedure newgame;
------------------------------------------------инициализация
function readstr(var s:string;min,max:longint):longint;      [game(:=false если произошла ошибка)]
                        (превращает первую подстроку(s)до запятой в число)(формат строки:повторение(число,запятая)ентер)
procedure options;
procedure error(s:string);
procedure init;
....}
{-------------------------------}
procedure stoptime;
          var tec:ttime;
    begin
          tec:=moygetabstime;
          time0:=dt(time0,tec);
          end;
procedure outtime;
          var h,m,s,ss:word;
              tec,d:ttime;
    begin
          tec:=moygetabstime;
          time0:=dt(d,tec);
          if start
          then if game
               then writeyx(1,7,its(d.s,3)+its(d.ss,3))
               else writeyx(1,7,its(time0.s,3)+its(time0.ss,3));
          end;
{----------------}
function tinscr(y,x:byte):boolean;
      begin
         tinscr:=(y>=scr.y)and(y<=scr.y+scrh-1)and(x>=scr.x)and(x<=scr.x+scrl-1);
         end;
function xpr(x:byte;b:boolean):byte;{true - out0 false - outcurs}
     begin
         if b
         then xpr:=2*x
         else xpr:=2*x-1;
         end;
procedure out0(y,x:byte);
        var q:char;
        begin
          if notopen(y,x)
          then if game
               then if flag(y,x)
                    then q:=fl
                    else q:=no
               else if mina(y,x)
                    then if flag(y,x)
                         then q:=fl
                         else q:=min
                    else if flag(y,x)
                         then q:=wfl
                         else q:=no
          else q:=cf[cifra(y,x)];
          writeyx(y-scr.y+2,xpr(x-scr.x+1,true),q);
          end;
procedure outcurs0(y,x:byte;kurs:char);
      begin
          writeyx(y-scr.y+2,xpr(x-scr.x+1,false),kurs);
          end;
procedure outmin;
        begin
          writeyx(1,1,its(km,5))
          end;
procedure outinf;
        begin;                           {mesp('outmin');  {}
          outmin;
          outtime;
          writeyx(1,posinf,inf+'  ');
          end;
procedure outall;
          var i,j:byte;
        BEGIN
          for i:=scr.y to minim(scr.y+scrh-1,h0)
          do for j:=scr.x to minim(scr.x+scrl-1,l0)
             do out0(i,j);
{          for i:=1 to kolvoigr
          do with igr[i]
             do if tinscr(y,x)
                then outcurs0(y,x,kurs);}
          outinf;
          outtime;
          END;
procedure out(y,x:byte);
    begin
          if tinscr(y,x)
          then out0(y,x)
        {else begin              -показывает все отрывающиеся автоматически клетки
               if y<scr.y        then scr.y:=y;
               if y>scr.y+scrh-1 then scr.y:=y-scrh+1;
               if x<scr.x        then scr.x:=x;
               if x>scr.x+scrl-1 then scr.x:=x-scrl+1;
               outall;
               end{};
          end;
procedure outlineage;
          procedure f(var s,e:byte;pos,len,l,l_:byte);
                    BEGIN
                    s:=round(pos/l*l_);
                    e:=round((pos+len-1)/l*l_);
                    END;
          var i,s,e:byte;
      BEGIN
          f(s,e,scr.x,scrl,l0,xpr(scrl,true)+1);
          gotoxy(1,scrh+2);
          for i:=1 to s-1
          do write(' ');
          for i:=s to e
          do write('@');
          for i:=e+1 to xpr(scrl,true)+1
          do write(' ');                      {}

{          f(s,e,scr.y,scrh,h0,scrh);
          for i:=1 to s-1
          do writeyx(i,xpr(scrl+1,true),' ');
          for i:=s to e
          do writeyx(i,xpr(scrl+1,true),'@');
          for i:=e+1 to xpr(scrl,true)+1
          do writeyx(i,xpr(scrl+1,true),' ');{}

          END;
procedure outcurs(n,y_,x_:byte);
       function cursinscr(y,x:byte):boolean;
           BEGIN
               cursinscr:=not((y<scr.y+otst-1)and(scr.y>1)or
                       (y>scr.y+scrh-otst)and(scr.y<max(h0,scrh)-scrh+1)or
                              (x<scr.x+otst-1)and(scr.x>1)or
                              (x>scr.x+scrl-otst)and(scr.x<max(l0,scrl)-scrl+1));
               END;
      procedure clrcurs(n:byte);
                var i:byte;
              BEGIN
                for i:=1 to kolvoigr
                do with igr[i]
                   do if tinscr(y,x) and (i<>n)
                     then outcurs0(y,x,' ');
                END;
        var b:boolean;
          i:byte;
          label 1;
        BEGIN
          if cursinscr(y_,x_)
          then begin
               for i:=1 to kolvoigr
               do if (i<>n)and(igr[i].x=igr[n].x)and(igr[i].y=igr[n].y)
                  then begin
                       with igr[i]
                       do outcurs0(y,x,kurs);
                       goto 1;
                       end;
               with igr[n]
               do outcurs0(y,x,' ');
1:             with igr[n]
         do begin
                   x:=x_;
                  y:=y_;
                  outcurs0(y,x,kurs);
                  end;
               exit;
               end;
          clrcurs(n);
          with igr[n]
          do begin
             x:=x_;
             y:=y_;
             b:=false;
             if (y<scr.y+otst-1)and(scr.y>1)
             then begin
                 b:=true;
                  scr.y:=y-otst+1;
                  end;
             if (y>scr.y+scrh-otst)and(scr.y<max(h0,scrh)-scrh+1)
             then begin
                 b:=true;
                  scr.y:=y-scrh+otst;
                  end;
             if (x<scr.x+otst-1)and(scr.x>1)
             then begin
                 b:=true;
                  scr.x:=x-otst+1;
                  end;
             if (x>scr.x+scrl-otst)and(scr.x<max(l0,scrl)-scrl+1)
             then begin
                 b:=true;
                  scr.x:=x-scrl+otst;
                  end;
             if b
             then begin
                 for i:=1 to kolvoigr
             do with igr[i]
                do begin
                       if tinscr(y,x)
                        then outcurs0(y,x,kurs);
                      end;
                  with igr[n]
                  do outcurs0(y,x,kurs);
                 outall;
                  outlineage;
                  end
             else mes('ошибка в выв');
             if game
             then inf:=its(y,1)+' '+its(x,1)
             else begin
{                  writexy(1,1,its(length(inf),1)+' '+bts(game));}
                  if length(inf)>=scrl*2-posinf-7
                  then delete(inf,scrl*2-posinf-7,7)
                  else while length(inf)<scrl*2-posinf
                       do inf:=inf+' ';
{                  writexy(2,1,its(length(inf),1)+' '+bts(game));
{                  writexy(3,1,inf+'@');
{                  writexy(4,1,its(y,1)+' '+its(x,1));    {}
                  inf:=inf+its(y,1)+' '+its(x,1)+'  ';
                  end;
             outinf;
             end;
          END;
{--------------------------------}
procedure win;
    begin
          dec(nopkl);
          if nopkl=0
          then begin
               game:=false;
               inf:='win';
               stoptime;
               outall;
               end;
          end;
procedure gamover(otv:byte);
          var i:byte;
              p:set of 1..maxkolvoigr;
    begin                     {     mesp('gamover');{}
          game:=false;
          inf:='gamover:';
          stoptime;
          p:=[otv];
          for i:=1 to 8
          do if ppf[i]<>nbf
             then p:=p+[ppf[i]];
          for i:=1 to kolvoigr
          do if i in p
             then inf:=inf+igr[i].name+' ';
          outall;
          end;
procedure around(y,x:byte;var otv:byte;detect:kldetect;doing:kldoing);
          procedure ifinmatr(y,x:byte);
                     begin                        {        mesp('ifinmatr');{}
                if (y>=1)and(y<=h0)and(x>=1)and(x<=l0)and detect(y,x)and game
                then doing(y,x,otv);
              end;
    begin                          {mesp('apound');   {}
          ifinmatr(y-1,x-1);
          ifinmatr(y-1,x);
          ifinmatr(y-1,x+1);
          ifinmatr(y,x-1);
          ifinmatr(y,x+1);
          ifinmatr(y+1,x-1);
          ifinmatr(y+1,x);
          ifinmatr(y+1,x+1);
          end;
{procedure aroundbit(y,x,otv:byte;var z:byte;detect:kldetect;doing:kldoing);
          procedure ifinmatr(y,x:byte);
                     begin                        {        mesp('ifinmatr');{
                if (y>=1)and(y<=h0)and(x>=1)and(x<=l0)and detect(y,x)and game and
                then doing(y,x,otv);
              end;
    begin                          {mesp('apound');
          ifinmatr(y-1,x-1);
          ifinmatr(y-1,x);
          ifinmatr(y-1,x+1);
          ifinmatr(y,x-1);
          ifinmatr(y,x+1);
          ifinmatr(y+1,x-1);
          ifinmatr(y+1,x);
          ifinmatr(y+1,x+1);
          end;}
function all(y,x:byte):boolean;
   begin                            { mesp('all');      {}
   all:=true;
   end;
function openb(y,x:byte):boolean;
         begin
         openb:=not notopen(y,x);
         end;
procedure fk12(y,x:byte;var otv:byte);
    begin
          fk2_(y,x,otv);
       fk1_(y,x,otv);
          end;
procedure openz(y,x:byte; var z:byte);
    begin
          end;
procedure automat0(y,x:byte;var otv:byte);
    var z:byte;
    begin                             {mes('automat');{}
          if openb(y,x)and(cifra(y,x)=0)
          then begin
               around(y,x,z,all,open_);

               {mes('yes');{}end
          end;
function infstack:string;
     var razm:integer;
      begin
         if game
         then begin
              if stkpointh>=stkpointl
              then razm:=stkpointh-stkpointl
              else razm:=lenghtstack-stkpointl+stkpointh+1;
              infstack:=its(stkpointh,5)+its(stkpointl,6)+its(razm,6);
              {outinf;readkey;}
              end;
         end;
procedure automat;
      begin                           { mesp('automat'); outinf;   {}
          if stkpointh>0
          then dec(stkpointh)
          else stkpointh:=lenghtstack;
                                      {igr[1].kurs:=' ';
                                      if tinscr(stack[stkpointh].y,stack[stkpointh].x)
                                      then outcurs(1,stack[stkpointh].y,stack[stkpointh].x);}
          case regproc of
            automatic_:fk12(stack[stkpointh].y,stack[stkpointh].x,stack[stkpointh].otv);
            automatic :fk1_(stack[stkpointh].y,stack[stkpointh].x,stack[stkpointh].otv);
            auto0      :automat0(stack[stkpointh].y,stack[stkpointh].x,stack[stkpointh].otv);
          end;                             {gldec;outinf;{}
          if game
          then inf:={its(stkpointh,1)+'    '}infstack;
          outinf;
          end;
procedure push(y,x:byte;var otv:byte);
        begin
          if {false                        }tinscr(y,x)
          then begin
               stack[stkpointh].x:=x;
              stack[stkpointh].y:=y;
              stack[stkpointh].otv:=otv;
              {if game
              then inf:=its(stkpointh,1);      {...}
              if stkpointh<lenghtstack
               then if stkpointh+1<>stkpointl
                then inc(stkpointh)
                else inf:=inf+' переполнение'
               else if stkpointl=0
                    then inf:=inf+' переполнение'
                    else stkpointh:=0;
              outinf;
               end
          else begin
               if stkpointl>0
               then if stkpointh+1<>stkpointl
                then dec(stkpointl)
                else inf:=inf+' переполнение'
               else if stkpointh=lenghtstack
                    then inf:=inf+' переполнение'
                    else stkpointl:=lenghtstack;
               stack[stkpointl].x:=x;
              stack[stkpointl].y:=y;
              stack[stkpointl].otv:=otv;
               end;
          if length(inf)>10
          then delete(inf,10,20)
          else while length(inf)<10
               do inf:=inf+' ';
          {outinf;readkey;}
          inf:={inf+}infstack;
          end;
procedure putoffflag(y,x,otv:byte);
    begin                                     {mesp('putofflag');   {};
          if flag(y,x)
          then begin
               pflag(y,x,false);
               pcifra(y,x,cfnop);
               out(y,x);
               inc(km);
               outinf;
               end;
          end;
procedure putonflag(y,x:byte;var otv:byte);
    begin                                       {   mesp('putonflag');     {}
          if notopen(y,x)
          then begin
               pcifra(y,x,otv);
               if not flag(y,x)
               then begin
                    pflag(y,x,true);
                    out(y,x);
                    dec(km);
                    outinf;
                    end;
               end;
          end;
procedure autoflag(y,x:byte;var otv:byte);
    begin                              {  mesp('autoflag'+its(y,1)+its(x,1));outinf;{}
          if notopen(y,x)
          then begin
               pcifra(y,x,otv);
               if not flag(y,x)
               then begin
                    pflag(y,x,true);
                    out(y,x);
                    dec(km);
                    outinf;
                    around(y,x,otv,openb,push)
                    end;
               end;                           { gldec;outinf;       {}
          end;
procedure incz(y,x:byte;var z:byte);
       begin
          inc(z);
          end;

procedure open(y,x:byte;var otv:byte);
    var z:byte;
              b:boolean;
    begin                                                  {mesp('open'+its(y,1)+its(x,1));outinf             ;{}
          if notopen(y,x)and not flag(y,x)
          then if mina(y,x)
               then gamover(otv)
               else begin
                    z:=0;
                    b:=cifra(y,x)=cfnop;
                     around(y,x,z,mina,incz);
              pcifra(y,x,z);
              out(y,x);
                    if b
              then win;
                    push(y,x,otv);
                    around(y,x,otv,openb,push)
                    end;                                               {gldec;outinf;{}
               end;
procedure fk2(y,x:byte;var otv:byte);
          var z:byte;
    begin                               {mesp('fk2'+its(y,1)+its(x,1));outinf; {}
          if openb(y,x)
          then begin
               z:=0;
               around(y,x,z,notopen,incz);
               if z=cifra(y,x)
               then around(y,x,otv,notopen,autoflag);
               end;                             { gldec;outinf;{}
          end;
procedure inczfk1(y,x:byte;var z:byte);
       begin
          inc(z);
          ppf[z]:=cifra(y,x);{виноватые флаги}
          end;
function notflag(y,x:byte):boolean;
   begin
         notflag:=not flag(y,x);
         end;
procedure fk1(y,x:byte;var otv:byte);
    var z:byte;
    begin                               { mesp('fk1'+its(y,1)+its(x,1));outinf;   {}
          if openb(y,x)
          then begin
               z:=0;
               around(y,x,z,flag,inczfk1);
               if z=cifra(y,x)
               then around(y,x,otv,notflag,open);
               for z:=1 to 8
               do ppf[z]:=nbf;
               end;
                                                            {  gldec;outinf;{}
          end;
{--------------------------------------------------------------------}
function notcurs(ly,lx:byte):boolean;
         begin                                {  mesp('notcurs');{}
         notcurs:= not((ly=igr[i].y)and(lx=igr[i].x));
{         mes(bts_(b));}
         end;

procedure checcurs(y,x:byte;var z:byte);
    begin                                {   mesp('sheccurs');{}
          if not notcurs(y,x)
          then z:=0;
          end;
procedure newgame;
          var i,k,x,y:word;
          z:byte;
          b:boolean;
          function ok(y,x:byte):boolean;
               begin                        {      mesp('ok');    {}
                   ok:=not mina(y,x)and notcurs(y,x);
                   end;
      begin                                  {       mesp('newgame');{}
 {         mes('newgame');}
          k:=kolvomin;
          i:=65535;
          repeat x:=random(l0)+1;
                 y:=random(h0)+1;
                 z:=1;
{                 mes(its_(y,1)+' '+its_(x,1)+' '+its_(z,1)+' ');}
                 around(y,x,z,all,checcurs);
                 if ok(y,x)and((i=0)or(z=1))
                 then begin
                      pmina(y,x,true);
                      {mes(its(y,3)+its(x,3));}
                      dec(k);
                      end;
                 keypressed;
{                 mes(its_(i,1)+' '+its_(k,1)+' '+its_(z,1));}
                 if (z=1)and(i<>0)
                 then dec(i);
          until k=0;
          time0:=moygetabstime;
          start:=true;
          end;
{------------------------------------------}
function readstr(var s:string;min,max:longint):longint;
         var subs:string;
             q:char;
             i,j:integer;      // !!! из-за несовместимости с val заменен с word на integer
   begin           {if ... game:=folse}{mesp('readstr');{}          {.......}
         i:=0;
         repeat inc(i)
         until (i=length(s))or(s[i]=',');
         if (i=length(s))and(s[i]<>',')
         then begin
                                                        {mes('');}
              game:=false;
              exit;
              end;
         subs:=copy(s,1,i-1);
         delete(s,1,i);
         Val(subs,j,i);
         readstr:=j;
         if i<>0
         then begin
              game:=false;
              end;
         end;
procedure options;
    var t1,t2:ttime;
        q: char;
    procedure reiting;
                begin                         {mesp('reiting');{}
                    end;
    begin
          clrscr;
          t1:=moygetabstime;
          repeat
                q:=readkey;         {...}
                writeyx(2,2,q);
                if q='q' 
                then halt(0);
          until q=#27;
          if game and start
          then begin
               t2:=moygetabstime;
               t1:=dt(t1,t2);
               t2:=time0;
               time0.ss:=t1.ss+t2.ss;
               time0.s:=t1.s+t2.s;
               if time0.ss>=100
               then begin
                    dec(time0.ss,100);
                    inc(time0.s);
                    end;
               end;
          outall;
          end;
procedure error(s:string);
          var q:char;
    begin                                   {mesp('error');      {}
          clrscr;
          writeyx(10,10,'ошибка файла состояния '+s);
          readln;
          repeat q:=readkey;                                               {выход или новое создание файла......}
          until q=#27;

          options;
          end;
procedure init;
          var f:text;
        s,s1:string;
              i,j:byte;
          label 1;
          BEGIN                                { mesp('init');        {}
          1:
          start:=false;
          game:=true;
          assign(f,configf);
          reset(f);
          readln(f,s);
         if   s='nonflaging'  then reginput:=nonfluging                  {reginput}
          else if s='standart' then reginput:=standart
          else if s='flaging'  then reginput:=fluging1
          else if s='flaging+' then reginput:=fluging2
          else begin
               error(s);
               goto 1;
               end;
          readln(f,s);
          {inf:=s;{}
          if      s='AllYouSelf' then regproc:=allyouself            {regproc}
          else if s='auto0'    then regproc:=auto0
          else if s='auto-'    then regproc:=automatic
          else if s='auto+'    then regproc:=automatic_
          else begin
               error(s);
               goto 1;
               end;
                                                      {mes('reg-ok');    }
          readln(f,s);                                                  {размер и др.}
          h0:=readstr(s,5,hmax);                      {mes('h0');         }
          l0:=readstr(s,5,lmax);                       {mes('l0');         }
          kolvomin:=readstr(s,5,h0*l0*2 div 3);         {      mes('kolvomin');}
          kolvoigr:=readstr(s,1,maxkolvoigr);            { mes('kolvoigr');     }
          if(kolvomin>h0*l0-kolvoigr)
          then kolvomin:=h0*l0-kolvoigr;
          km:=kolvomin;
          kl:=h0*l0-km;
          nopkl:=kl;
          if (not game)
          then begin
                                                         {mes('err');            }

               error(s);
               goto 1;
               end;
          for i:=1 to maxkolvoigr
          do with igr[i]
             do begin
               readln(f,name);
                readln(f,up,down,left,right,k1,k2,kurs); {м.б.ош.}                 {кнопки и символы}
                readln(f,s);
                y:=readstr(s,1,h0);                                      {нач позиция курсоров}
                x:=readstr(s,1,l0);
                end;                                               {...чтобы не совпадало}
                              {...random(x,y)}
          if not game
          then begin
               error('igroki');
               goto 1;
               end;
          close(f);{но он не меняется}
          initpole(h0,l0);
          scr.x:=1;
          scr.y:=1;
          inf:='';
          clrscr;
          outall;
          for i:=1 to kolvoigr
          do with igr[i]
             do if tinscr(y,x)
                then outcurs0(y,x,kurs);
          outlineage;
          end;
procedure maincicl;
    var q:char;
    BEGIN                                      {    mesp('maicicl');{}
      repeat init;                                  {Ц:игра}{init->game=true;start=false}
             repeat repeat outtime;                     {Ц:обработка одной кнопки}{Ц:цикл ожидания}
                          if stkpointh<>stkpointl
                           then automat;
                   until keypressed;
                                                    {igr[1].kurs:='#';}
                   q:=readkey;
                    if q=#27      {esc}             {......}
          then options;
          for i:=1 to kolvoigr
          do with igr[i]
                   do begin
                     if (q=up)and(y>1)
                    then outcurs(i,y-1,x);
                  if (q=down)and(y<h0)
                  then outcurs(i,y+1,x);
                  if (q=left)and(x>1)
                  then outcurs(i,y,x-1);
                  if (q=right)and(x<l0)
                  then outcurs(i,y,x+1);
                          if game                      {после первого жмака start:=true}
                          then begin
                          if q=k1
                        then if notopen(y,x)
                                   then begin
                                       if not start
                                       then newgame;
                                         outcurs(i,y,x);
                                         open(y,x,i)
                                         end
                                     else if (reginput=fluging1)or(reginput=fluging2)
                                       then begin
                                              outcurs(i,y,x);
                                             fk1(y,x,i);
                                              end;
                          if q=k2
                          then if notopen(y,x)
                                   then begin
                                         outcurs(i,y,x);
                                       if flag(y,x)and((reginput=standart)or(reginput=fluging1)or(reginput=fluging2))
                                      then putoffflag(y,x,i)
                                       else putonflag(y,x,i)
                                         end
                                   else if reginput=fluging2
                                      then begin
                                            outcurs(i,y,x);
                                             fk2(y,x,i);
                                              end;
                               end;
                  end;
             until (not game)and(q=#13);
      until false;
      END;
begin
randomize;
fk1_:=fk1;
fk2_:=fk2;
open_:=open;
stkpointh:=0;
stkpointl:=0;
clrscr;
writeyx(15,15,'saper professional........');
writeyx(25,5,#169+'Uskov');
readkey;
maincicl;
end.