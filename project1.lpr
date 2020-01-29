program project1;
uses wincrt, graph;

const
  stlpce = 2;
  riadky = 5;

type
  budget = integer;
  sur = record
    riadok, stlpec: integer;
  end;

  udaj = record
    text: string;
    cena, hodnota: integer;
    odomknute: boolean;
  end;

var gd, gm: smallint;
  f_peniaze: file of budget;
  peniaze: budget;

  volba: sur;
  obchod: array [1..riadky, 1..stlpce] of udaj;
  koniec: boolean;
  ch: char;

function vypisCislo(cislo: integer): string;
begin
  str(cislo, vypisCislo);
end;

procedure vypisText(x, y: integer; text: string; vypis: boolean);
begin
  if(vypis) then setcolor(white)
  else setcolor(black);

  outtextxy(x, y, text);
end;

procedure inicObchod(riadok, stlpec, hodnota, cena: integer);
begin
  obchod[riadok, stlpec].text := vypisCislo(hodnota);
  obchod[riadok, stlpec].hodnota := hodnota;
  obchod[riadok, stlpec].cena := hodnota * 100;
  obchod[riadok, stlpec].odomknute := false;
end;

procedure nakup(volba: sur);
begin
  peniaze := peniaze - obchod[volba.riadok, volba.stlpec].cena;
  obchod[volba.riadok, volba.stlpec].odomknute := true;
end;

procedure vyberMoznosti(volba: sur);
begin
  if(volba.riadok = riadky) then koniec := true

  else if(obchod[volba.riadok, volba.stlpec].odomknute) then
    peniaze := peniaze + obchod[volba.riadok, volba.stlpec].hodnota

  else if(obchod[volba.riadok, volba.stlpec].cena <= peniaze) then nakup(volba);
end;

procedure tlacitka(volba: sur);
var i, j, x0, y0, medzera: integer;
begin
  x0 := 10;
  y0 := 10;
  medzera := 20;

  for i := 1 to riadky do

    for j := 1 to stlpce do
    begin
      if(volba.riadok = i) and (volba.stlpec = j) then
        setcolor(yellow)
      else setcolor(white);

      if(i <> riadky) or (j <> stlpce) then
        outtextxy(x0 + (j - 1) * medzera,
                  y0 + (i - 1) * medzera,
                  obchod[i, j].text);
    end;

end;

procedure presiahnutieRozsahu(var volba: sur);
begin
  if(volba.riadok < 1) then volba.riadok := riadky;
  if(volba.riadok > riadky) then volba.riadok := 1;

  if(volba.stlpec < 1) then volba.stlpec := stlpce;
  if(volba.stlpec > stlpce) then volba.stlpec := 1;

  if(volba.riadok = riadky) and (volba.stlpec = stlpce) then
    volba.stlpec := 1;
end;

procedure vyberTlacitka(var volba: sur);
var ch: char;
begin
  ch := readkey;
  case ch of
    #072: volba.riadok := volba.riadok - 1; // hore
    #080: volba.riadok := volba.riadok + 1; // dole
    #075: volba.stlpec := volba.stlpec - 1; // vlavo
    #077: volba.stlpec := volba.stlpec + 1; // vpravo
    chr(13):                                // ENTER
    begin
      vypisText(100, 100, vypisCislo(peniaze), false);
      vyberMoznosti(volba);
    end;
  end;
end;

begin
  gd := detect;
  initgraph(gd, gm, '');

  // inicializacia
  volba.riadok := 1;
  volba.stlpec := 1;

  inicObchod(1, 1, 1, 1);
  inicObchod(2, 1, 3, 3);
  inicObchod(3, 1, 5, 5);
  inicObchod(4, 1, 7, 7);
  inicObchod(1, 2, 10, 10);
  inicObchod(2, 2, 30, 30);
  inicObchod(3, 2, 50, 50);
  inicObchod(4, 2, 70, 70);

  obchod[5, 1].text := 'Koniec';
  obchod[5, 2].text := 'Koniec';

  koniec := false;

  // nacitanie zostatku penazi
  assign(f_peniaze, 'peniaze.txt');
  reset(f_peniaze);
  read(f_peniaze, peniaze);

  vypisText(100, 100, vypisCislo(peniaze), true);
  repeat
    tlacitka(volba);
    vyberTlacitka(volba);
    presiahnutieRozsahu(volba);

    vypisText(100, 100, vypisCislo(peniaze), true);
  until koniec;

  rewrite(f_peniaze);
  write(f_peniaze, peniaze);
  close(f_peniaze);

  closegraph();
end.

