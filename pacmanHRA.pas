program pacmanHRA;              {https://www.freepascal.org/docs-html/rtl/crt/window.html ... dalo by se pouzit na zrychleni ve vypisovani}
uses
  Crt;

type
  bunka = record
    znak:char;
    volno, zradlo, jeTu:boolean;
  end;
  dvouPole = array [1..127, 1..127] of bunka;
  souradnice = record
    x,y:shortint;
  end;

var
  input:text;
  x,y,i,j:shortint;
  bludiste:dvouPole;
  c:char;
  endOfGame:boolean;
  puvodniSmer, smer, pacman:souradnice;
  pocetZradla:integer;


begin                                    {http://home.pf.jcu.cz/~edpo/program/kap19.html}
  assign(input,'bludiste.txt');
  reset(input);
  readln(input,x);
  readln(input,y);
  for j:=1 to y do begin
    for i:=1 to x do begin
      bludiste[i,j].volno:=false;
      bludiste[i,j].zradlo:=false;
      bludiste[i,j].jeTu:=false;
    end;
  end;
  pocetZradla:=0;
  for j:=1 to y do begin           {inicializace herniho pole}
    for i:=1 to x do begin
      read(input, c);
      case c of
        'C':begin
          bludiste[i,j].volno:=true;
          bludiste[i,j].zradlo:=false;
          bludiste[i,j].znak:=c;
          bludiste[i,j].jeTu:=true;
          pacman.x:=i;
          pacman.y:=j;
        end;
        '#':begin
          bludiste[i,j].volno:=false;
          bludiste[i,j].zradlo:=false;
          bludiste[i,j].znak:=c;
        end;
        '.':begin
          bludiste[i,j].volno:=true;
          bludiste[i,j].zradlo:=true;
          bludiste[i,j].znak:=c;
          inc(pocetZradla);
        end;
      end;
    end;
    readln(input);
  end;
  close(input);

  puvodniSmer.x := 0;
  puvodniSmer.y := 0;
  smer.x := 0;
  smer.y := 0;

  endOfGame:=false;

  for j:=1 to y do begin
    for i:=1 to x do begin
      write(bludiste[i,j].znak)
    end;
    writeln();
  end;

  repeat
    if KeyPressed then begin
      c:=readkey;
      if ord(c) = 0 then begin                  {pokud je na první pokus ord(c)=0 -> znamená to že je stisknutá klávesa extended}
        c:=readkey;                             {nastavení směru pacmana}
        case ord(c) of                          {Up - 72, Down - 80, Left - 75, Right -77}
          72:begin
            smer.x:=0;
            smer.y:=-1;
          end;
          80:begin
            smer.x:=0;
            smer.y:=1;
          end;
          75:begin
            smer.x:=-1;
            smer.y:=0;
          end;
          77:begin
            smer.x:=1;
            smer.y:=0;
          end;
        end;
      end;
    end;

    if (bludiste[(pacman.x + smer.x),(pacman.y + smer.y)].volno) then begin            {posun pacmana}
      bludiste[pacman.x, pacman.y].jeTu:=false;
      gotoxy(pacman.x, pacman.y);
      write(' ');
      bludiste[pacman.x, pacman.y].znak:=' ';
      pacman.x := pacman.x + smer.x;
      pacman.y := pacman.y + smer.y;
      bludiste[pacman.x, pacman.y].jeTu:=true;
      if (bludiste[pacman.x, pacman.y].znak = '.') then
        pocetZradla:=pocetZradla - 1;
      gotoxy(pacman.x, pacman.y);
      write('C');
      //bludiste[pacman.x, pacman.y].znak:='C';
      puvodniSmer.x := smer.x;
      puvodniSmer.y := smer.y;
    end else if (bludiste[pacman.x + puvodniSmer.x, pacman.y + puvodniSmer.y].volno) then begin
      bludiste[pacman.x, pacman.y].jeTu:=false;
      gotoxy(pacman.x, pacman.y);
      write(' ');
      bludiste[pacman.x, pacman.y].znak:=' ';
      pacman.x := pacman.x + puvodnismer.x;
      pacman.y := pacman.y + puvodnismer.y;
      if (bludiste[pacman.x, pacman.y].znak = '.') then
        pocetZradla:=pocetZradla - 1;
      bludiste[pacman.x, pacman.y].jeTu:=true;
      gotoxy(pacman.x, pacman.y);
      write('C');
      //bludiste[pacman.x, pacman.y].znak:='C';
    end;

    {
    for j:=0 to (y-1) do begin
      for i:=0 to (x-1) do begin
        write(bludiste[i,j].znak)
      end;
      writeln();
    end;
    }

    if (pocetZradla = 0) then
      endOfGame:=true;
    delay(250);
  until endOfGame;
  clrscr;
  writeln('vyhral jsi');
  writeln('pro konec zmackni ENTER...');

  readln;
  readln;
end.
