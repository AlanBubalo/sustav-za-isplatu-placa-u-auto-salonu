DROP DATABASE IF EXISTS isplata_placa;
CREATE DATABASE isplata_placa;
/* 
	 **Pozicije u firmi**
	 - Izvršni Direkton
     - Prodavač (auta)
     - Direktor
     - Čistačica 
     - Automehaničar
     - Zaštitar
     - Prodavač (za djelove)
     - Informatičar
     - Elektroničar
     - Tajnica
     - Knjigovođa
     - Dostavljač
*/

/*
		**Klase**
A: City Car    Smart Fortwo
B: Niska klasa    Fiat Punto
C: Srednja klasa    VW Golf
D: Viša srednja klasa    Opel Vectra
E: Viša klasa    Audi A6
F: Luksuzna klasa    Mercedes S-klasa
S: Sportski automobil
*/

/*
Dostavljač služi za to kada kupac naruči auto, naš dostavljač odveze auto do njega.
Dostavljač će imati poseban bonus, za putne troškove.
*/

/*
		Vrste plaćanja
plaćanje poduzećem (za velike firme)
plaćanje karticom
plaćanje u kešu
	
    moguće je plaćat na rate 
    d0 60 rata = 5 godina
*/

CREATE TABLE zaposlenik(
	id INTEGER NOT NULL PRIMARY KEY,
	ime VARCHAR(20) NOT NULL,
	prezime VARCHAR(30) NOT NULL,
    id_pozicija INTEGER NOT NULL,
    oib CHAR(11) NOT NULL,
    email VARCHAR(50) NOT NULL,
    CHECK (email LIKE "%@%"),
    FOREIGN KEY (id_pozicija) REFERENCES pozicija(id)
);

CREATE TABLE satnica(
	id_pozicija INTEGER NOT NULL PRIMARY KEY,
    novac_po_satu INTEGER NOT NULL,
	broj_sati INTEGER DEFAULT 0,
	bonus FLOAT DEFAULT 0
);

CREATE TABLE automobil(
	id INTEGER NOT NULL PRIMARY KEY,
	naziv VARCHAR(50) NOT NULL,
	klasa CHAR NOT NULL,
    cijena INTEGER NOT NULL,
    FOREIGN KEY (klasa) REFERENCES klasa(id)
);

CREATE TABLE klasa (
	id CHAR NOT NULL PRIMARY KEY,
	naziv VARCHAR(20) NOT NULL,
    stopa_bonusa FLOAT DEFAULT 0
);

CREATE TABLE bonus_sati (
    id INTEGER NOT NULL PRIMARY KEY,
    tip_bonusa VARCHAR(20),
    postotak FLOAT
);

/*
CREATE TABLE dostava (
	broj_dostave INTEGER NOT NULL PRIMARY KEY,
	vrijeme_dostave TIME NOT NULL,
	id_zaposlenik INTEGER NOT NULL,
	id_automobil INTEGER NOT NULL,
	FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id),
	FOREIGN KEY (id_automobil) REFERENCES automobil(id)
);
*/

CREATE TABLE kupac (
id INTEGER NOT NULL PRIMARY KEY, 
ime VARCHAR(20) NOT NULL,
prezime VARCHAR(30) NOT NULL,
email VARCHAR(50) NOT NULL,
broj_mobitela INTEGER,
IBAN VARCHAR(50),
CHECK (email LIKE "%@%")
);

CREATE TABLE racun (
	id INTEGER NOT NULL PRIMARY KEY,
	vrijeme_dostave TIME,
    vrijeme_izdavanja DATETIME NOT NULL,
	id_zaposlenik INTEGER NOT NULL,
	id_automobil INTEGER NOT NULL,
    vrsta_placanja VARCHAR(30) NOT NULL,
    id_kupac INTEGER NOT NULL,
	FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id),
	FOREIGN KEY (id_automobil) REFERENCES automobil(id),
    FOREIGN KEY (id_kupac) REFERENCES kupac(id)
);

CREATE TABLE pozicija (
	id INTEGER PRIMARY KEY NOT NULL,
	ime VARCHAR(30),
    opis TEXT 
);

INSERT INTO zaposlenik VALUES ("1","Mlohael","Ether","1","95841550335","mether@luxecars.com")
							 ,("2","Luka","Dudak","2","70125027634","ldudak@luxecars.com")
							 ,("3","Karlo","Lugomer","3","92670682735","klugomer@luxecars.com")
							 ,("4","Jessica","Zoranović","2","16096814870","jzoranovic@luxecars.com")
							 ,("5","Andrej","Konki","4","83871296540","konkay69420@luxecars.com")
							 ,("6","Branimir","Horvat","4","97236274923","bhorvat@luxecars.com")
							 ,("7","Stipe","Stup","5","17398368702","sstup@luxecars.com")
							 ,("8","Velimir","Kralj","5","37610633755","vkralj@luxecars.com")
							 ,("9","Vladimir","Jugić","5","98345756419","vjugic@luxecars.com")
							 ,("10","Tihomir","Tatić","7","60064731762","ttatić@luxecars.com")
							 ,("11","Teuta","Miškić","5","11289379123","tmiskic@luxecars.com")
							 ,("12","Karolina","Tunjić","7","60896521870","ktunjić@luxecars.com")
							 ,("13","Mirko","Barkica","7","35675273263","mbarkica@luxecars.com")
							 ,("14","Vjekoslav","Vukovoje","7","64685408891 ","vvukovoje@luxecars.com")
							 ,("15","Goran","Strujić","8","77352474271","gstrujic@luxecars.com")
							 ,("16","Golub","Gvozdenko","8","56198404250","ggvozdenko@luxecars.com")
							 ,("17","Mario","Valjak","10","69233667398","mvaljak@luxecars.com")
							 ,("18","Mladen","Jantoš","10","20761707492","mjantos@luxecars.com")
							 ,("19","Robert","Butkić","10","07698168587","rbutkic@luxecars.com")
							 ,("20","Siniša","Miščević","10","23587461757","smiscevic@luxecars.com")
							 ,("21","Travan","Dilović","6","15865867042","tdilovic@luxecars.com")
							 ,("22","Jovana","Kreketić","6","89714241090","jkreketic@luxecars.com")
							 ,("23","Tomas","Crnić","9","65013824596","tcrnic@luxecars.com")
							 ,("24","Ernjoslav","Negomir","9","33658723917","enegomir@luxecars.com")
							 ,("25","Alan","Šibanović","9","68956555044","asibanovic@luxecars.com")
						     ,("26","Tamara","Galić","11","65013824596","tgalic@luxecars.com")
							 ,("27","Andrijana","Brzić","11","08728711594","abrzić@luxecars.com")
							 ,("28","Mihael","Bokser","12","11006286754","mbokser@luxecars.com")
							 ,("29","Jeffery","Bizos","12","87017816387","jbizos@luxecars.com")
							 ,("30","Orianna","Ombretta","13","07151025941","oombretta@luxecars.com")
							 ,("31","Danko","Bananković","13","01405821019","dbanankovic@luxecars.com");
  

INSERT INTO pozicija VALUES  ("1","Direktor","Voditelj firme")
							,("2","Tajnik","Dogovara sastanke i vodi upravne poslove")
							,("3","Knjigovođa","Vodi knjige vezane uz finacije i druge aspekte firme")
							,("4","Voditelje prodaje","Nadgleda prodavače i mehaničare")
							,("5","Prodavač automobila","Prodaje automobile")
							,("6","Prodavač auto dijelova","Prodaje dijelove za automobile")
                            ,("7","Automehaničar","Popravlja mehaničke poteškoće to jest kvarove na automobilima")
                            ,("8","Autoelektričar","Popravlja elektroničke poteškoće to jest kvarove na automobilima")
                            ,("9","Informatičar","Vodi aplikaciju i online stranicu vezanu uz firmu")
                            ,("10","Zaštitar","Brine o sigurnosti radnika i vlasništva firme")
                            ,("11","Dostavljač","Dostavlja prodane proizvode njihovim kupcima")
                            ,("12","Čistać","Održava radno mjesto čistim")
                            ,("13","Čistać Automobila","Odžava automobile u izložbenom stanju");
                            
INSERT INTO satnica VALUES ("1","120","",""),
						   ("2","70","",""), 
                           ("3","90","",""),   
                           ("4","100","",""),   
                           ("5","60","",""),   
                           ("6","55","",""),   
                           ("7","40","",""),   
                           ("8","40","",""),   
                           ("9","100","",""),   
                           ("10","40","",""),   
                           ("11","35","",""),   
                           ("12","30","",""),   
                           ("13","35","",""); 
                           
INSERT INTO klasa VALUES ("1","Mali gradski auto","1.5%"), 
						 ("2","Kompaktni gradski auto","3%"),    
                         ("3","Gradski auto","4%"),    
                         ("4","Gradska limuzina","5%"),    
                         ("5","Luksuzna limuzina","8%"),    
                         ("6","SUV","6%"),    
                         ("7","Luksuzni SUV","8%"),    
                         ("8","Terenac","4%"),    
                         ("9","Luksuzni terenac","7%"),    
                         ("10","Sportski automobil","10%"),    
                         ("11","Putnički Kombi","5$"),    
                         ("12","Električni automobili","13%"),    
                         ("13","Pick-up","5%"); 
                         
INSERT INTO bonus_sati VALUES ("1","Rad vikendom","50%"),
                              ("2","Rad blagdanom","100%"),
                              ("3","Noćni rad","50%"),  
                              ("4","Rad prekovremeno","25%");
                             
                               
                        
                         
					
                         