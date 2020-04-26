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
  gd, gm, i, j, x0, y0: smallint;
  f_peniaze: file of budget; 
  f_autoPeniaze: file of autoBudget;
  f_odomknutia: file of boolean;
  peniaze: budget;
  autoPeniaze: autoBudget;

  volba: sur;
  obchod: array [1..riadky, 1..stlpce] of udaj;
  koniec, naspat: boolean;
  _s: word;
  menu_volba: integer;

// HRA
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
  if(volba.riadok = riadky) then naspat := true

  else if(obchod[volba.riadok, volba.stlpec].odomknute) and
         (obchod[volba.riadok, volba.stlpec].jeKlik) then
    peniaze := peniaze + obchod[volba.riadok, volba.stlpec].hodnota

  else if(obchod[volba.riadok, volba.stlpec].cena <= peniaze) then nakup(volba);

  vypisText(x0, y0, zostatok + vypisCislo(peniaze), true);
  vypisText(x0, y0 + 20, vypisCislo(autoPeniaze) + ' / sek', true);
end;

procedure tlacitka(volba: sur; x0, y0: integer);
var i, j, sirka, vyska, okraj: integer;
begin
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
      vypisText(x0, y0, zostatok + vypisCislo(peniaze), false);
      vypisText(x0, y0 + 20, vypisCislo(autoPeniaze) + ' / sek', false);
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

  obchod[5, 1].text := 'Spat';
  obchod[5, 2].text := 'Spat';
  obchod[5, 3].text := 'Spat';
  obchod[5, 1].odomknute := true;
  obchod[5, 2].odomknute := true; 
  obchod[5, 3].odomknute := true;
end;

procedure pripocitajAutoPeniaze(var _s: word);
var h, m, s, s100: word;
begin   
  gettime(h, m, s, s100);
  if(s <> _s) then
  begin
    vypisText(x0, y0, zostatok + vypisCislo(peniaze), false);
    peniaze := peniaze + autoPeniaze;
    vypisText(x0, y0, zostatok + vypisCislo(peniaze), true);
  end;

  _s := s;
end;

procedure hraj();
begin
  volba.riadok := 1;
  volba.stlpec := 1;

  // vykreslenie obchodu a zostatku
  vypisText(x0, y0, zostatok + vypisCislo(peniaze), true);
  vypisText(x0, y0 + 20, vypisCislo(autoPeniaze) + ' / sek', true);
  tlacitka(volba, x0, y0 + 40);

  repeat
    if(keypressed) then
    begin
      kurzor(volba);
      presiahnutieRozsahu(volba);
      tlacitka(volba, x0, y0 + 40);
    end;

    pripocitajAutoPeniaze(_s);
  until naspat;
end;

// MENU
procedure nadpis();
begin
  setfillstyle(1, white);
  settextstyle(1, 0, 6);
  outtextxy(x0 - 60, y0 + 80, 'Click Bajt');
  settextstyle(1, 0, 1);
end;

procedure menu_tlacitka(volba: integer);
var napisy: array[1..4] of string;
    i, sirka, vyska, okraj, x0, y0: integer;
begin
  sirka := 150;
  vyska := 50;
  okraj := 15;
  setfillstyle(1, lightgray);

  x0 := getmaxx div 2 - sirka div 2;
  y0 := (getmaxy div 2) - (length(napisy) div 2 * (vyska + okraj));

  napisy[1] := 'Hra';
  napisy[2] := 'Ulozit';
  napisy[3] := 'Vymazat priebeh';
  napisy[4] := 'Koniec';

  for i := 1 to length(napisy) do
  begin
    bar(x0, y0 + (i - 1) * (vyska + okraj), x0 + sirka, y0 + (i - 1) * (vyska + okraj) + vyska);

    if(volba = i) then setcolor(yellow)
    else setcolor(white);

    outtextxy(x0 + 15, y0 + (i - 1) * (vyska + okraj) + vyska div 2, napisy[i]);
  end;
end;

procedure menu(var volba: integer);
var ch: char;
begin
  repeat
    menu_tlacitka(volba);

    ch := readkey;
    case ch of
      #072: volba := volba - 1; // hore
      #080: volba := volba + 1; // dole
    end;

    if(volba < 1) then volba := 4;
    if(volba > 4) then volba := 1;
  until ch = chr(13);
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

procedure vymazatObrazovku();
begin
  setfillstyle(1, black);
  bar(1, 1, getmaxx, getmaxy);
end;

// PROGRAM LOOP
begin
  gd := detect;
  initgraph(gd, gm, ''); 
  assign(f_peniaze, 'peniaze.txt');   
  assign(f_autoPeniaze, 'autoPeniaze.txt');
  assign(f_odomknutia, 'odomknutia.txt'); 

  // inicializacia

  x0 := getmaxx div 2 - (100 * stlpce div 2);
  y0 := 50; 
  koniec := false;
  nastavUdaje();

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
      read(f_odomknutia, obchod[(i - 1) div stlpce + 1, stlpce].odomknute)
    else
      read(f_odomknutia, obchod[(i - 1) div stlpce + 1, i mod stlpce].odomknute);
  end;

  repeat
    vymazatObrazovku();
    menu_volba := 1;
    naspat := false;

    nadpis();
    menu(menu_volba);
    case menu_volba of
      1:
      begin
        vymazatObrazovku();
        hraj();
      end;
      2: ulozit();
      3: vymazat();
      4: koniec := True;
    end;

  until koniec;

  closegraph();
end.

