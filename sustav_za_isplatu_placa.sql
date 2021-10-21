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
CREATE TABLE zaposlenik(
	id INTEGER NOT NULL PRIMARY KEY,
	ime VARCHAR(20) NOT NULL,
	prezime VARCHAR(30) NOT NULL,
    pozicija VARCHAR(30) NOT NULL
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