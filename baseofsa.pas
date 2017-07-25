unit baseofsa;
interface
uses moy;
const hmax=100;
      lmax=100;
      cfnop=9;
function mina(y,x:byte):boolean;
function flag(y,x:byte):boolean;
function cifra(y,x:byte):byte;
function notopen(y,x:byte):boolean;
procedure pmina(y,x:byte;m:boolean);
procedure pflag(y,x:byte;f:boolean);
procedure pcifra(y,x,c:byte);
procedure initpole(h0,l0:byte);

implementation
var pole:array[1..hmax,1..lmax]of byte;
{главное поле(формат байта:7-мина;6-флаг;остальное- цифра)}
{присутствие мины(в нек.точке) ни от чего не зависит
если флага
нет: если сифра =cfnop
   то клетка не открыта
     иначе на экран отображается эта цифра
есть то цифра показывает автора этого флага
}
function mina(y,x:byte):boolean;
     begin                         {mesp('mina');{}
         if bit(pole[y,x],7)=1
         then mina:=true
         else mina:=false;
         end;
function flag(y,x:byte):boolean;
     begin                         {mesp('flag');{}
         if bit(pole[y,x],6)=1
         then flag:=true
         else flag:=false;
         end;
function cifra(y,x:byte):byte;
     begin                         {mesp('cifra');{}
         cifra:=pole[y,x]mod 64;
         end;
function notopen(y,x:byte):boolean;
     begin                         {mesp('notopen');{}
         notopen:=flag(y,x)or(cifra(y,x)=cfnop);
         end;
procedure pmina(y,x:byte;m:boolean);
      begin                        {mesp('pmina'); {}
          if mina(y,x)xor m
          then if m
               then inc(pole[y,x],128)
               else dec(pole[y,x],128);
          end;
procedure pflag(y,x:byte;f:boolean);
        begin                        {mesp('pflag');   {}
          if flag(y,x)xor f
          then if f
               then inc(pole[y,x],64)
               else dec(pole[y,x],64);
          end;
procedure pcifra(y,x,c:byte);
      begin                        {mesp('pcifra');    {}
          pole[y,x]:=pole[y,x]+c-cifra(y,x);
          end;
procedure initpole(h0,l0:byte);
      var i,j:byte;
          BEGIN
          for i:=1 to h0
          do for j:=1 to l0
        do pole[i,j]:=cfnop;
          END;
end.