UNIT mytime;
INTERFACE
uses sysutils;
type Ttime=record
           s: longint;
           ss: byte;
           end;
function  dt(x1,x2: ttime): Ttime;
function  MoyGetAbsTime: ttime;{abs}
procedure StartTime;
function  MoyGetTime: Ttime;
procedure StopGoTime;

var timefrost: boolean;
    time0: ttime;
{в остановленном состоянии time0 - время со старта
в идущем - время старта
!!!не учиьывает полночь}
IMPLEMENTATION

function  dt(x1,x2: ttime): Ttime;
          var i,z: integer;
              rez: TTime;
          BEGIN
          i:=x1.ss-x2.ss;
          if i<0
          then begin
               rez.ss:=100+i;
               z:=1;
               end
          else begin
               rez.ss:=i;
               z:=0;
               end;
          rez.s:=x1.s-x2.s-z;
          dt:=rez;
          END;
function  moyGetAbsTime: ttime;{abs}
          var t: Ttime;
              Hour, Minute, Second, MilliSecond: Word;
          BEGIN
//          gettime(h,m,s,ss);
          DecodeTime(Now,Hour, Minute, Second, MilliSecond);
          t.s:=(Hour*60+Minute)*60+second;
          t.ss:=trunc(millisecond/10);
          moyGetAbsTime := t;
          END;
procedure starttime;
          BEGIN
          timefrost:=false;
          time0:=moygetabstime;
          END;
function  moyGetTime: ttime;
          BEGIN
          if timefrost
          then moygettime:=time0
          else begin
               MoyGetTime:=dt(moygetabstime,time0);
               end
          END;
procedure stopgotime;
          BEGIN
          time0:=dt(moygetabstime,time0);
          timefrost:=not timefrost;
          END;
END.