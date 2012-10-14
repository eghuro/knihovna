program knihovna;

const	max_knih=100;
	max_knihoven=100;

type 	index = 0 .. max_knih;
	index2 = 0 .. max_knihoven;
	pole = array[1..max_knihoven] of index;
	pole2 = array[1..max_knihoven,1..2] of index2;

var	soubor_knih:text;
	knihoven,knih,i,j,k:integer;
	next:boolean;
	vyskyt: array [1..max_knih,1..max_knihoven] of boolean;
	nova_knihovna: pole2;

function transformuj(p:pole):pole2;
var i:integer; nk:pole2;
begin
	{pokud bych ted zacal pole knihovna tridit, ztratim referenci -> soucasny index mi totiz indexuje knihovnu a obsahem pole je pocet vyskytu}
	{nejprve predelam pole knihovna takto: nova_knihovna:array[1..knihoven,1..2] of integer;}
	{nova_knihovna[i,1]:=i (puvodni reference); nova_knihovna[i,2]:=knihovna[i] (pocet vyskytu)}
	{po setrideni budu mit v nova_knihovna[1,2] nejvetsi cislo a v knihovna[1,1] puvodni index}
	for i:=1 to max_knihoven do
		for j:=1 to 2 do
			nk[i,j]:=0;
	for i:=1 to knihoven do begin
		nk[i,1]:=i;
		nk[i,2]:=p[i];
	end;
	transformuj:=nk;
end;

function input():boolean;
var return:boolean; i,j,k,m:integer; knihovna:pole;
begin
	return:=true;
	{nacteme seznam knihoven pro kazdou knihu v souboru knihy.txt}
	{soubor zacina cislem knihoven, oznacujicim poctem existujicich knihoven;}
	{dale cislem knih, oznacujicim pocet knih k nacteni}
	{kniha obsahuje na radku: cislo m a dale seznam m celych cisel od 1 do maximalne max_knihoven oddelenych mezerami}
	assign(soubor_knih,'knihy.txt');
	reset(soubor_knih);
	read(soubor_knih,knihoven);
	read(soubor_knih,knih);

	for i:=1 to knih do for j:=1 to knihoven do vyskyt[i,j]:=false;
	for i:=1 to knihoven do knihovna[i]:=0;

	if (knih<=max_knih) and (knih>0) then for i:=1 to knih do begin
		read(soubor_knih,m); {m je pocet knihoven na radku i}
		if (m<=knihoven) and (m>0) then begin
			for j:=1 to m do begin
				read(soubor_knih,k);
				if (k>=1) and (k<=knihoven) then begin
					vyskyt[i,k]:=true;
					knihovna[k]:=knihovna[k]+1;
				end
				else begin
					writeln('Spatne cislo knihovny ',j,' na radku ',i,' - cislo knihovny musi byt z intervalu <1;',knihoven,'>');
					return:=false;
				end
			end
		end else begin
			writeln('Spatny pocet knihoven na radku ',i, ' - pocet knihoven musi byt z intervalu <1;',knihoven,'>');
			return:=false;
		end;
	end else begin 
		writeln('Pocet knih musi byt z intervalu <1;',max_knih,'> !');
		return:=false;
	end;
	nova_knihovna:=transformuj(knihovna);
	input:=return;
end;

procedure QuickSort(var A:pole2;l, r:integer);
{l .. zacatek pole, r..konec pole}
var i,j,pivot,pom:integer;
begin
 i:=l; j:=r;
 pivot:=A[(i+j) div 2,2]; {volba pivota}
 repeat
	while A[i,2]<pivot do i:=i+1;
	while A[j,2]>pivot do j:=j-1;
	if i<=j then begin
		pom:=A[i,2]; A[i,2]:=A[j,2]; A[j,2]:=pom;
		i:=i+1;
		j:=j-1;
	end;
 until i>=j;
 if j>l then QuickSort(A,l,j);
 if i<r then QuickSort(A,i,r);
end;

procedure filter(var kn:pole2);
var stop:boolean;
begin
	{v prvni knihovne je nejvice svazku, ktere potrebuji - nepujdu si pro ne jinam}
	for i:=1 to knihoven do
		{vezmu knihovnu, projdu radek matice a ve vsech sloupcich nastavim false
		mimo muj radek, zaroven pro patricnou knihovnu snizim pocet svazku}
		for j:=1 to knih do begin
			for k:=(kn[i,1]-1) downto i do{vracim se k maximalne i-te k}
				if vyskyt[j,k]=true then begin
					vyskyt[j,k]:=false;
					kn[k,2]:=kn[k,2]-1;
				end;
			for k:=(kn[i,1]+1) to knihoven do 
				if vyskyt[j,k]=true then begin
					vyskyt[j,k]:=false;
					kn[k,2]:=kn[k,2]-1;
				end;
			{poradi knihoven se mohlo zmenit}
			QuickSort(kn,i+1,knihoven);{setridim od nasledujici do posledni}
			{podivame se, zda-li posledni knihovny jiz neobsahuji 0 knih}
			stop:=false;
			repeat 
				if kn[knihoven,2]=0 then knihoven:=knihoven-1
				else stop:=true;
			until stop;
		end;
end;

begin
	next:=input();
	if next then begin
		{setridim si pole nova_knihovna sestupne quicksortem, pro trideni uvaziji jen nova_knihovna[i,2]}
		QuickSort(nova_knihovna,1,knihoven);
		{filtruji knihovny k nalezeni nejmensiho poctu knihoven obsahujiciho vsechny zadane knihy}
		filter(nova_knihovna);
		output(nova_knihovna);
	end
end.