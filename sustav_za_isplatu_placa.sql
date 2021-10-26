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
	id_zaposlenik INTEGER NOT NULL,
    novac_po_satu INTEGER NOT NULL,
	broj_sati INTEGER DEFAULT 0,
	bonus FLOAT DEFAULT 0,
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id)
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
	rad_vikendom FLOAT DEFAULT 0,
	nocna_smjena FLOAT DEFAULT 0,
	rad_blagdanom FLOAT DEFAULT 0,
    putni_trosak  FLOAT DEFAULT 0
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