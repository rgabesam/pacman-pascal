program pacmanHRA;              {https://www.freepascal.org/docs-html/rtl/crt/window.html ... dalo by se pouzit na zrychleni ve vypisovani}
uses
  sysutils,crt;

type
  bunka = record
    vzdalenostOdPac:integer;
    znak:char;
    volno, zradlo, jeTu, duch,krizovatka:boolean;
  end;
  dvouPole = array [1..127, 1..127] of bunka;
  souradnice = record
    x,y:shortint;
  end;
  phledani=^hledani;
  hledani = record
    x,y:shortint;
    next:phledani;
  end;

var
  input:text;
  a,b,x,y,i,j,pocetDuchu,endOfGame,obtiznost:shortint;
  bludiste:dvouPole;
  c:char;
  puvodniSmer, smer, pacman:souradnice;
  pocetZradla:integer;
  prvni,posledni:phledani;
  duchove,smerDuchu:array [1..127] of souradnice;
  slovo:string;
  score, cas:longint;


procedure najdiPac();
var pom:phledani;
  i,j:shortint;
begin
  for i:=-1 to 1 do begin
    for j:=-1 to 1 do begin
      if ((bludiste[prvni^.x + i, prvni^.y + j].vzdalenostOdPac = - 1)and (bludiste[prvni^.x + i, prvni^.y + j].volno)and ((abs(i)-abs(j))<>0)) then begin
        new(posledni^.next);
        posledni:=posledni^.next;
        posledni^.next:= nil;
        posledni^.x:=prvni^.x + i;
        posledni^.y:=prvni^.y + j;
        bludiste[prvni^.x + i, prvni^.y + j].vzdalenostOdPac:= bludiste[prvni^.x, prvni^.y].vzdalenostOdPac + 1;
      end;
    end;
  end;
  pom:=prvni;
  prvni:=prvni^.next;
  dispose(pom);
  if (prvni <> posledni) then
    najdiPac;
end;

procedure init(pacman:souradnice);
var i,j:shortint;
begin
  prvni:=nil;
  new(prvni);
  prvni^.x:=pacman.x;
  prvni^.y:=pacman.y;
  posledni:=prvni;
  prvni^.next:=nil;
  for j:=1 to y do begin
    for i:=1 to x do begin
      bludiste[i,j].vzdalenostOdPac:=-1;
    end;
  end;
  bludiste[pacman.x,pacman.y].vzdalenostOdPac:=0;
end;

procedure pohybDuchu(duchNo:shortint);
var
  i,j:shortint;
  pohnulSe:boolean;
begin
  pohnulSe:=false;
  Randomize;
  if ((bludiste[duchove[duchNo].x, duchove[duchNo].y].vzdalenostOdPac) <= obtiznost) then begin                    {pokud je pacman v dosahu}
        for i:=-1 to 1 do begin
          for j:=-1 to 1 do begin
            if (((abs(i)-abs(j))<>0) and (bludiste[duchove[duchNo].x + i, duchove[duchNo].y + j].volno)) then begin
              if ((bludiste[duchove[duchNo].x + i, duchove[duchNo].y + j].vzdalenostOdPac)
              < (bludiste[duchove[duchNo].x, duchove[duchNo].y].vzdalenostOdPac)) then begin
                bludiste[duchove[duchNo].x, duchove[duchNo].y].duch:=false;
                bludiste[duchove[duchNo].x + i, duchove[duchNo].y + j].duch:=true;
                gotoxy(duchove[duchNo].x, duchove[duchNo].y);
                if (bludiste[duchove[duchNo].x, duchove[duchNo].y].zradlo) then
                  write('.')
                else
                  write(' ');
                gotoxy(duchove[duchNo].x + i, duchove[duchNo].y + j);
                write('Q');
                duchove[duchNo].x := duchove[duchNo].x + i;
                duchove[duchNo].y := duchove[duchNo].y + j;
                exit;
              end;
            end;
          end;
        end;
  end else begin
     if not(bludiste[duchove[duchNo].x, duchove[duchNo].y].krizovatka) then begin                       {duch jde nahodne rovne dokud nenarazi na krizovatku}
        bludiste[duchove[duchNo].x + smerDuchu[duchNo].x, duchove[duchNo].y + smerDuchu[duchNo].y].duch:=true;
        bludiste[duchove[duchNo].x, duchove[duchNo].y].duch:=false;
        gotoxy(duchove[duchNo].x, duchove[duchNo].y);
        if (bludiste[duchove[duchNo].x, duchove[duchNo].y].zradlo) then
          write('.')
        else
          write(' ');
        gotoxy(duchove[duchNo].x + smerDuchu[duchNo].x, duchove[duchNo].y + smerDuchu[duchNo].y);
        write('Q');
        duchove[duchNo].x := duchove[duchNo].x + smerDuchu[duchNo].x;
        duchove[duchNo].y := duchove[duchNo].y + smerDuchu[duchNo].y;
     end else begin                {ducha narazil na krizovatku - hleda novy random smer}
       repeat
          smerDuchu[duchNo].x:=(Random(3)-1);
          smerDuchu[duchNo].y:=(Random(3)-1);
          if (((abs(smerDuchu[duchNo].x)-abs(smerDuchu[duchNo].y))<>0)
          and (bludiste[duchove[duchNo].x + smerDuchu[duchNo].x, duchove[duchNo].y + smerDuchu[duchNo].y].volno)) then begin
            bludiste[duchove[duchNo].x, duchove[duchNo].y].duch:=false;
            bludiste[duchove[duchNo].x + smerDuchu[duchNo].x, duchove[duchNo].y + smerDuchu[duchNo].y].duch:=true;
            gotoxy(duchove[duchNo].x, duchove[duchNo].y);
            if (bludiste[duchove[duchNo].x, duchove[duchNo].y].zradlo) then
               write('.')
            else
            write(' ');
            gotoxy(duchove[duchNo].x + smerDuchu[duchNo].x, duchove[duchNo].y + smerDuchu[duchNo].y);
            write('Q');
            duchove[duchNo].x := duchove[duchNo].x + smerDuchu[duchNo].x;
            duchove[duchNo].y := duchove[duchNo].y + smerDuchu[duchNo].y;
            pohnulSe:=true;
          end;
        until pohnulSe;
     end;
  end;
end;

begin

  repeat
    ClrScr;
    repeat                    {obtiznost}
      writeln('Zvol si obtiznost, respektive jak daleko duchove uvidi');
      readln(slovo);
      endOfGame:=1;
      Try
        obtiznost:=(StrToInt(slovo));
      except
        On E : EConvertError do begin
          ClrScr;
          Writeln ('Musis cislo');
          endOfGame:=-1;
        end;
      end;
    until (endOfGame=1);

    ClrScr;
    assign(input,'bludiste.txt');
    reset(input);
    readln(input,x);
    readln(input,y);
    for j:=1 to y do begin
      for i:=1 to x do begin
        bludiste[i,j].volno:=false;
        bludiste[i,j].zradlo:=false;
        bludiste[i,j].jeTu:=false;
        bludiste[i,j].krizovatka:=false;
      end;
    end;
    pocetZradla:=0;
    pocetDuchu:=0;
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
          'Q':begin
            bludiste[i,j].volno:=true;
            bludiste[i,j].zradlo:=true;
            bludiste[i,j].znak:=c;
            inc(pocetDuchu);
            duchove[pocetDuchu].x := i;
            duchove[pocetDuchu].y := j;
          end;
        end;
      end;
      readln(input);
    end;
    close(input);

    for j:=1 to y do begin                              {ulozeni krizovatek}
      for i:=1 to x do begin
        if (bludiste[i,j].volno) then begin
          if ((bludiste[i+1,j].volno and bludiste[i,j+1].volno) or (bludiste[i+1,j].volno and bludiste[i,j-1].volno)
          or (bludiste[i-1,j].volno and bludiste[i,j+1].volno) or (bludiste[i-1,j].volno and bludiste[i,j-1].volno)) then begin
            bludiste[i,j].krizovatka:=true;
          end;
        end;
      end;
    end;

    puvodniSmer.x := 0;
    puvodniSmer.y := 0;
    smer.x := 0;
    smer.y := 0;
    for i:=1 to pocetDuchu do begin
      repeat
        smerDuchu[i].x:=(Random(3)-1);
        smerDuchu[i].y:=(Random(3)-1);
      until (((abs(smerDuchu[i].x)-abs(smerDuchu[i].y))<>0) and (bludiste[duchove[i].x+smerDuchu[i].x,duchove[i].y+smerDuchu[i].y].volno));
    end;


    score:=0;
    cas:=1;

    for j:=1 to y do begin             {vypis bludiste}
      for i:=1 to x do begin
        write(bludiste[i,j].znak)
      end;
      writeln();
    end;

    //init(pacman);
    //najdiPac();
    {for j:=1 to y do begin
      for i:=1 to x do begin
        write(bludiste[i,j].vzdalenostOdPac:3)
      end;
      writeln();
    end;}

    repeat                   {dokud hrac nezmackne klavesu, hra nezacne}
    until KeyPressed ;

    repeat                  {HRA}
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
        if (bludiste[pacman.x, pacman.y].znak = '.') then begin
          bludiste[pacman.x, pacman.y].zradlo:=false;
          pocetZradla:=pocetZradla - 1;
          score:=score+(100000 div cas);
        end;
        gotoxy(pacman.x, pacman.y);
        write('C');
        //bludiste[pacman.x, pacman.y].znak:='C';
        puvodniSmer.x := smer.x;
        puvodniSmer.y := smer.y;
        sound(400);
      end else if (bludiste[pacman.x + puvodniSmer.x, pacman.y + puvodniSmer.y].volno) then begin
        bludiste[pacman.x, pacman.y].jeTu:=false;
        gotoxy(pacman.x, pacman.y);
        write(' ');
        bludiste[pacman.x, pacman.y].znak:=' ';
        pacman.x := pacman.x + puvodnismer.x;
        pacman.y := pacman.y + puvodnismer.y;
        if (bludiste[pacman.x, pacman.y].znak = '.') then begin
          pocetZradla:=pocetZradla - 1;
          bludiste[pacman.x, pacman.y].zradlo:=false;
          score:=score+(100000 div cas);
        end;
        bludiste[pacman.x, pacman.y].jeTu:=true;
        gotoxy(pacman.x, pacman.y);
        write('C');
        sound(400);
        //bludiste[pacman.x, pacman.y].znak:='C';
      end;

      if (pocetZradla = 0) then
        endOfGame:=0; {vyhra - snedl vsechno}

      init(pacman);
      najdiPac();
      for i:=1 to pocetDuchu do begin
        pohybDuchu(i);
        if ((duchove[i].x = pacman.x) and (duchove[i].y = pacman.y)) then begin
          endOfGame:=-1;      {prohra - zabil ho duch}
          break;
        end;
      end;
      cas:=cas + 2;
      delay(250);
      NoSound;

    until (endOfGame < 1);        {konec hry}

    clrscr;
    case endOfGame of
      -1:begin
        for i:=10 downto 1 do begin
          sound(i*250);
          delay(200);
        end;
        delay(400);
        NoSound;
        writeln('prohral jsi');
        writeln('score:',score);
        writeln('pro konec zmackni ENTER...');
      end;
      0:begin
      writeln('vyhral jsi');
      writeln('score:',score);
      writeln('pro konec zmackni ENTER...');
    end;
    end;

    WriteLn;
    writeln('...pro novou hru napis 1 a zmackni enter');
    readln(slovo);
    if (slovo = '1') then
      endOfGame:=1;
  until endOfGame <> 1;


end.

