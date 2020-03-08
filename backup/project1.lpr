program project1;
uses wincrt, graph, dos;

const
  stlpce = 3;
  riadky = 5;
  zostatok = 'Zostatok: ';

type
  budget = integer;
  autoBudget = integer;

  sur = record
    riadok, stlpec: integer;
  end;

  udaj = record
    text: string;
    cena, hodnota: integer;
    odomknute, jeKlik, jeAuto: boolean;
  end;

var
  gd, gm, i, j: smallint;
  f_peniaze: file of budget; 
  f_autoPeniaze: file of autoBudget;
  f_odomknutia: file of boolean;
  peniaze: budget;
  autoPeniaze: autoBudget;

  volba: sur;
  obchod: array [1..riadky, 1..stlpce] of udaj;
  koniec: boolean;
  _s: word;

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

procedure inicObchod(riadok, stlpec, hodnota, cena: integer; jeKlik, jeAuto: boolean);
begin
  obchod[riadok, stlpec].text := vypisCislo(hodnota);
  obchod[riadok, stlpec].hodnota := hodnota;
  //obchod[riadok, stlpec].cena := cena;
  obchod[riadok, stlpec].cena := hodnota * 100;
  obchod[riadok, stlpec].odomknute := false;  
  obchod[riadok, stlpec].jeKlik := jeKlik;
  obchod[riadok, stlpec].jeAuto := jeAuto;
end;

procedure nakup(volba: sur);
begin
  peniaze := peniaze - obchod[volba.riadok, volba.stlpec].cena;
  obchod[volba.riadok, volba.stlpec].odomknute := true;

  if(obchod[volba.riadok, volba.stlpec].jeAuto) then
    autoPeniaze := autoPeniaze + obchod[volba.riadok, volba.stlpec].hodnota;
end;

procedure vyberMoznosti(volba: sur);
begin
  if(volba.riadok = riadky) then koniec := true

  else if(obchod[volba.riadok, volba.stlpec].odomknute) and
         (obchod[volba.riadok, volba.stlpec].jeKlik) then
    peniaze := peniaze + obchod[volba.riadok, volba.stlpec].hodnota

  else if(obchod[volba.riadok, volba.stlpec].cena <= peniaze) then nakup(volba);
end;

procedure tlacitka(volba: sur);
var i, j, x0, y0, sirka, vyska, okraj: integer;
begin
  x0 := 10;
  y0 := 10;

  okraj := 15;
  sirka := 100;
  vyska := 50;

  for i := 1 to riadky do

    for j := 1 to stlpce do
    begin
      if(i <> riadky) or (j = 1) then
      begin
        if(not obchod[i, j].odomknute) then setcolor(darkgray)
        else setcolor(white);

        if(volba.riadok = i) and (volba.stlpec = j) then
          setcolor(yellow);

        if(i <> riadky) or (j <> stlpce) then
        begin
          setfillstyle(1, lightgray);
          bar(x0 + (j - 1) * (sirka + okraj), y0 + (i - 1) * (vyska + okraj),
              x0 + (j - 1) * (sirka + okraj) + sirka, y0 + (i - 1) * (vyska + okraj) + vyska);

          if(obchod[i, j].jeKlik) then
            outtextxy(x0 + (j - 1) * (sirka + okraj) + 5,
                      y0 + (i - 1) * (vyska + okraj) + 5, '+ ' + obchod[i, j].text)

          else if(obchod[i, j].jeAuto) then
            outtextxy(x0 + (j - 1) * (sirka + okraj) + 5,
                      y0 + (i - 1) * (vyska + okraj) + 5, obchod[i, j].text + ' / sek')

          else
            outtextxy(x0 + (j - 1) * (sirka + okraj) + 5,
                      y0 + (i - 1) * (vyska + okraj) + 5, obchod[i, j].text);

          if(not obchod[i, j].odomknute) or (obchod[i, j].jeAuto) then
            outtextxy(x0 + (j - 1) * (sirka + okraj) + 5,
                      y0 + (i - 1) * (vyska + okraj) + 20, vypisCislo(obchod[i, j].cena) + '$');
        end;

      end;

    end;

end;

procedure presiahnutieRozsahu(var volba: sur);
begin
  if(volba.riadok < 1) then volba.riadok := riadky;
  if(volba.riadok > riadky) then volba.riadok := 1;

  if(volba.stlpec < 1) then volba.stlpec := stlpce;
  if(volba.stlpec > stlpce) then volba.stlpec := 1;

  if(volba.riadok = riadky) and (volba.stlpec > 1) then
    volba.stlpec := 1;
end;

procedure kurzor(var volba: sur);
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
      vypisText(500, 500, zostatok + vypisCislo(peniaze), false); 
      vypisText(500, 520, vypisCislo(autoPeniaze) + ' / sek', false);
      vyberMoznosti(volba);
    end;
  end;
end;

procedure nastavUdaje();
begin
  inicObchod(1, 1, 1, 1, True, False);
  inicObchod(2, 1, 3, 3, True, False);
  inicObchod(3, 1, 5, 5, True, False);
  inicObchod(4, 1, 7, 7, True, False);

  inicObchod(1, 2, 10, 10, True, False);
  inicObchod(2, 2, 30, 30, True, False);
  inicObchod(3, 2, 50, 50, True, False);
  inicObchod(4, 2, 70, 70, True, False); 

  inicObchod(1, 3, 10, 10, False, True);
  inicObchod(2, 3, 30, 30, False, True);
  inicObchod(3, 3, 50, 50, False, True);
  inicObchod(4, 3, 70, 70, False, True);

  obchod[1, 1].odomknute := true;

  obchod[5, 1].text := 'Koniec';
  obchod[5, 2].text := 'Koniec'; 
  obchod[5, 3].text := 'Koniec';
  obchod[5, 1].odomknute := true;
  obchod[5, 2].odomknute := true; 
  obchod[5, 3].odomknute := true;
end;

procedure pripocitajAutoPeniaze(var _s: word);
var h, m, s, s100: word;
begin   
  gettime(h, m, s, s100);

  vypisText(500, 500, zostatok + vypisCislo(peniaze), false);
  if(s <> _s) then peniaze := peniaze + autoPeniaze;

  _s := s;
end;

procedure ulozit();
begin
  // peniaze
  rewrite(f_peniaze);
  write(f_peniaze, peniaze);
  close(f_peniaze); 

  // autoPeniaze
  rewrite(f_autoPeniaze);
  write(f_autoPeniaze, autoPeniaze);
  close(f_autoPeniaze);

  // odomknutia
  rewrite(f_odomknutia);
  for i := 1 to riadky do
    for j := 1 to stlpce do
      write(f_odomknutia, obchod[i, j].odomknute);
  close(f_odomknutia);
end;

procedure vymazat();
begin
  peniaze := 0;
  autoPeniaze := 0;

  for i := 1 to riadky do
    for j := 1 to stlpce do
      obchod[i, j].odomknute := false;

  nastavUdaje();
end;

begin
  gd := detect;
  initgraph(gd, gm, ''); 
  assign(f_peniaze, 'peniaze.txt');   
  assign(f_autoPeniaze, 'autoPeniaze.txt');
  assign(f_odomknutia, 'odomknutia.txt');

  // inicializacia

  volba.riadok := 1;
  volba.stlpec := 1;
  nastavUdaje();
  koniec := false;

  // nacitanie zostatku penazi

  reset(f_peniaze);
  read(f_peniaze, peniaze); 

  // nacitanie autoPenazi

  reset(f_autoPeniaze);
  read(f_autoPeniaze, autoPeniaze);

  // nacitanie odomknuti

  i := 0;
  reset(f_odomknutia);
  while not EOF(f_odomknutia) do
  begin
    i := i + 1;

    if(i mod stlpce = 0) then
      read(f_odomknutia, obchod[(i + 1) div stlpce, stlpce].odomknute)
    else
      read(f_odomknutia, obchod[(i + 1) div stlpce, i mod stlpce].odomknute);
  end;

  vypisText(500, 500, zostatok + vypisCislo(peniaze), true);
  vypisText(500, 520, vypisCislo(autoPeniaze) + ' / sek', true); 
  tlacitka(volba);

  repeat
    if(keypressed) then
    begin
      kurzor(volba);
      tlacitka(volba);
      presiahnutieRozsahu(volba);
    end;

    pripocitajAutoPeniaze(_s);

    vypisText(500, 500, zostatok + vypisCislo(peniaze), true);
    vypisText(500, 520, vypisCislo(autoPeniaze) + ' / sek', true);
  until koniec;

  //vymazat();

  ulozit();

  closegraph();
end.

