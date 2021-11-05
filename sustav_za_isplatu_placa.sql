DROP DATABASE IF EXISTS isplata_placa;
CREATE DATABASE isplata_placa;
USE isplata_placa;

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


Dostavljač služi za to kada kupac naruči auto, naš dostavljač odveze auto do njega.
Dostavljač će imati poseban bonus, za putne troškove.


		Vrste plaćanja
plaćanje poduzećem (za velike firme)
plaćanje karticom
plaćanje u kešu
	
    moguće je plaćat na rate 
    do 60 rata = 5 godina
*/

CREATE TABLE pozicija (
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
	ime VARCHAR(30),
    opis TEXT,
    novac_po_satu INTEGER NOT  NULL,
    UNIQUE (ime, opis)
);

CREATE TABLE zaposlenik(
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
	ime VARCHAR(20) NOT NULL,
	prezime VARCHAR(30) NOT NULL,
    id_pozicija INTEGER NOT NULL,
    oib CHAR(11) NOT NULL UNIQUE,
    email VARCHAR(50) NOT NULL UNIQUE,
    UNIQUE (ime, prezime),
    CONSTRAINT zaposlenik_email_ck CHECK (email LIKE "%@%"),
    CONSTRAINT zaposlenik_pozicija_fk FOREIGN KEY (id_pozicija) REFERENCES pozicija(id)
);

CREATE TABLE isplata (
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
    id_zaposlenik INTEGER NOT NULL,
	broj_sati INTEGER DEFAULT 0,
	bonus FLOAT DEFAULT 0,
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id)
);

CREATE TABLE klasa (
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
	naziv VARCHAR(30) NOT NULL UNIQUE,
    stopa_bonusa FLOAT DEFAULT 0
);

CREATE TABLE automobil(
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
	naziv VARCHAR(50) NOT NULL UNIQUE,
	id_klasa INTEGER NOT NULL,
    cijena INTEGER NOT NULL,
    CONSTRAINT automobil_cijena_ck CHECK (cijena > 0),
    CONSTRAINT automobil_klasa_fk FOREIGN KEY (id_klasa) REFERENCES klasa(id)
);

CREATE TABLE bonus_sati (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    tip_bonusa VARCHAR(20) NOT NULL UNIQUE,
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
	id INTEGER PRIMARY KEY AUTO_INCREMENT, 
	ime VARCHAR(20) NOT NULL,
	prezime VARCHAR(30) NOT NULL,
	email VARCHAR(50) NOT NULL UNIQUE,
	broj_mobitela VARCHAR(10) UNIQUE,
	iban VARCHAR(50) UNIQUE,
    UNIQUE (ime, prezime),
	CONSTRAINT kupac_email_ck CHECK (email LIKE "%@%")
);

CREATE TABLE servis (
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
    vrsta_servisa VARCHAR(20) UNIQUE,
    cijena_servisa INTEGER NOT NULL
);

CREATE TABLE placanje (
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
    naziv VARCHAR(20) UNIQUE
);


CREATE TABLE racun (
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
    datum_izdavanja DATETIME DEFAULT NOW(),
	id_zaposlenik INTEGER NOT NULL,
	id_automobil INTEGER NOT NULL,
    id_placanje INTEGER NOT NULL,
    id_kupac INTEGER NOT NULL,
    id_servis INTEGER,
    CONSTRAINT racun_datum_izdavanja_ck CHECK (datum_izdavanja > NOW()),
	CONSTRAINT racun_zaposlenik_fk FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id),
	CONSTRAINT racun_automobil_fk FOREIGN KEY (id_automobil) REFERENCES automobil(id),
    CONSTRAINT racun_placanje_fk FOREIGN KEY (id_placanje) REFERENCES placanje(id),
    CONSTRAINT racun_kupac_fk FOREIGN KEY (id_kupac) REFERENCES kupac(id),
    CONSTRAINT racun_servis_fk FOREIGN KEY (id_servis) REFERENCES servis(id)
);

INSERT INTO pozicija (ime, opis) VALUES
	("Direktor", "Voditelj firme"),
	("Tajnik", "Dogovara sastanke i vodi upravne poslove"),
	("Knjigovođa", "Vodi knjige vezane uz finacije i druge aspekte firme"),
	("Voditelje prodaje", "Nadgleda prodavače i mehaničare"),
	("Prodavač automobila", "Prodaje automobile"),
	("Prodavač auto dijelova", "Prodaje dijelove za automobile"),
	("Automehaničar", "Popravlja mehaničke poteškoće to jest kvarove na automobilima"),
	("Autoelektričar", "Popravlja elektroničke poteškoće to jest kvarove na automobilima"),
	("Informatičar", "Vodi aplikaciju i online stranicu vezanu uz firmu"),
	("Zaštitar", "Brine o sigurnosti radnika i vlasništva firme"),
	("Dostavljač", "Dostavlja prodane proizvode njihovim kupcima"),
	("Čistać", "Održava radno mjesto čistim"),
	("Čistać Automobila", "Održava automobile u izložbenom stanju");

INSERT INTO zaposlenik (ime, prezime, id_pozicija, oib, email) VALUES
	("Mlohael", "Ether", 1, "95841550335", "mether@luxecars.com"),
	("Luka", "Dudak", 2, "70125027634", "ldudak@luxecars.com"),
	("Karlo", "Lugomer", 3, "92670682735", "klugomer@luxecars.com"),
	("Jessica", "Zoranović", 2, "16096814870", "jzoranovic@luxecars.com"),
	("Andrej", "Konki", 4, "83871296540", "konkay69420@luxecars.com"),
	("Branimir", "Horvat", 4, "97236274923", "bhorvat@luxecars.com"),
	("Stipe", "Stup", 5, "17398368702", "sstup@luxecars.com"),
	("Velimir", "Kralj", 5, "37610633755", "vkralj@luxecars.com"),
	("Vladimir", "Jugić", 5, "98345756419", "vjugic@luxecars.com"),
	("Tihomir", "Tatić", 7, "60064731762", "ttatić@luxecars.com"),
	("Teuta", "Miškić", 5, "11289379123", "tmiskic@luxecars.com"),
	("Karolina", "Tunjić", 7, "60896521870", "ktunjić@luxecars.com"),
	("Mirko", "Barkica", 7, "35675273263", "mbarkica@luxecars.com"),
	("Vjekoslav", "Vukovoje", 7, "64685408891", "vvukovoje@luxecars.com"),
	("Goran", "Strujić", 8, "77352474271", "gstrujic@luxecars.com"),
	("Golub", "Gvozdenko", 8, "56198404250", "ggvozdenko@luxecars.com"),
	("Mario", "Valjak", 10, "69233667398", "mvaljak@luxecars.com"),
	("Mladen", "Jantoš", 10, "20761707492", "mjantos@luxecars.com"),
	("Robert", "Butkić", 10, "07698168587", "rbutkic@luxecars.com"),
	("Siniša", "Miščević", 10, "23587461757", "smiscevic@luxecars.com"),
	("Travan", "Dilović", 6, "15865867042", "tdilovic@luxecars.com"),
	("Jovana", "Kreketić", 6, "89714241090", "jkreketic@luxecars.com"),
	("Tomas", "Crnić", 9, "65013824596", "tcrnic@luxecars.com"),
	("Ernjoslav", "Negomir", 9, "33658723917", "enegomir@luxecars.com"),
	("Alan", "Šibanović", 9, "68956555044", "asibanovic@luxecars.com"),
	("Tamara", "Galić", 11, "65013824796", "tgalic@luxecars.com"),
	("Andrijana", "Brzić", 11, "08728711594", "abrzić@luxecars.com"),
	("Mihael", "Bokser", 12, "11006286754", "mbokser@luxecars.com"),
	("Jeffery", "Bizos", 12, "87017816387", "jbizos@luxecars.com"),
	("Orianna", "Ombretta", 13, "07151025941", "oombretta@luxecars.com"),
	("Danko", "Bananković", 13, "01405821019", "dbanankovic@luxecars.com");

INSERT INTO satnica (id_pozicija, novac_po_satu, broj_sati, bonus) VALUES
	(1, 120, NULL, NULL),
	(2, 70, NULL, NULL),
	(3, 90, NULL, NULL),
	(4, 100, NULL, NULL),
	(5, 60, NULL, NULL),
	(6, 55, NULL, NULL),
	(7, 40, NULL, NULL),
	(8, 40, NULL, NULL),
	(9, 100, NULL, NULL),
	(10, 40, NULL, NULL),
	(11, 35, NULL, NULL),
	(12, 30, NULL, NULL),
	(13, 35, NULL, NULL);

INSERT INTO klasa (naziv, stopa_bonusa) VALUES
	("Mali gradski auto", 1.5),
	("Kompaktni gradski auto", 3),
	("Gradski auto", 4),
	("Gradska limuzina", 5),
	("Luksuzna limuzina", 8), 
	("SUV", 6),
	("Luksuzni SUV", 8),
	("Terenac", 4),
	("Luksuzni terenac", 7),
	("Sportski automobil", 10),
	("Putnički Kombi", 5),
	("Električni automobili", 13),
	("Pick-up", 5);

INSERT INTO bonus_sati (tip_bonusa, postotak) VALUES
	("Rad vikendom", 50),
	("Rad blagdanom", 100),
	("Noćni rad", 50),
	("Rad prekovremeno", 25);

INSERT INTO automobil (naziv, id_klasa, cijena) VALUES
	("Volkswagen UP", 1, 94953),
	("Škoda CitigoE IV", 1, 52300),
	("Hyundai I10", 1, 78980),
	("Opel Corsa", 2, 98032),
	("Citroen C3 Feel", 2, 109420),
	("Seat Ibiza", 2, 113267),
	("Volkswagen Golf 8", 3, 145890),
	("Opel Astra", 3, 139767),
	("Kia Ceed", 3, 140094),
	("Hyundai I30", 3, 128760),
	("Seat Leon", 3, 142865),
	("Mini Cooper Clubman", 3, 150000),
	("BMW Serija 1 F52", 3, 189321),
	("Mercedes A Klasa", 3, 196541),
	("Škoda Octavia", 4, 157868),
	("Volkswagen Passat", 4, 177409),
	("Ford Mondeo", 4, 160412),
	("Peugeot 508", 4, 176960),
	("Mazda 6", 4, 185435),
	("BMW Serija 5", 5, 230193),
	("Mercedes E klasa", 5, 240534),
	("Jaguar F Type", 10, 329432),
	("Rolls Royce Phantom", 5, 890123),
	("Jaguar XF", 5, 320412),
	("Peugeot 3008", 6, 276095),
	("Škoda Kodiaq", 6, 280912),
	("Audi Q3", 6, 264509),
	("BMW X5", 7, 503000),
	("Lamborghini Urus", 7, 2000000),
	("Range Rover Evoque", 7, 410000),
	("Mercedes GLA", 7, 560932),
	("Range Rover Velar", 9, 532039),
	("Volvo XC60", 8, 430210),
	("Toyota Land Cruiser", 8, 510321),
	("Mercedes G klasa", 9, 753214),
	("BMW X7", 9, 680318),
	("Rolls Royce Cullinan", 9, 932310),
	("Aston Martin DBS", 10, 912000),
	("Porsche 911 Spyder", 10, 8700000),
	("BMW Serije 8 coupe", 10, 910003),
	("Lamborghini Huracan", 10, 1948929),
	("Ferrari 812", 10, 1495249),
	("Nissan GT-R", 10, 901239),
	("Bentley Continental GT", 10, 2343776),
	("Mercedes E klasa coupe", 10, 842199),
	("Opel Vivaro", 11, 210434),
	("Mercedes V klasa", 11, 431003),
	("Peugeot Partner", 11, 190320),
	("Tesla Model S", 12, 540000),
	("Tesla Model 3", 12, 451999),
	("Tesla Model X", 12, 490300),
	("Tesla Model Y", 12, 453951),
	("Opel Corsa Electric", 12, 230000),
	("Mercedes X klasa", 13, 640210),
	("Ford Raptor", 13, 511000);

INSERT INTO kupac (ime, prezime, email, broj_mobitela, iban) VALUES
	("Lea", "Krolo", "lkrolo@gmail.com", "021371084", "HR7025000093496599413"),
	("Gabriel", "Kovačić", "gkovacic@gmail.com", "031613270", "HR3323400096189952688"),
	("Tara", "Pavić", "tpavic@gmail.com", "043231556", "HR1624020062631837981"),
	("Tara", "Babić", "tbabic@gmail.com", "098269316", "HR4724020064367149769"),
	("Nino", "Srna", "nsrna@gmail.com", "021380731", "HR8324840083928744265"),
	("Patrik", "Matić", "pmatic@gmail.com", "023251865", "HR1423400099524543273"),
	("Adrian", "Abramović", "aabramovic@gmail.com", "012422829", "HR9224020069175682817"),
	("Niko", "Maras", "nmaras@gmail.com", "021631088", "HR8724020066154982142"),
	("Branislav", "Janković", "bjankovic@gmail.com", "016111531", "HR3524840089832569134"),
	("Marija", "Modrić", "mmodric@gmail.com", "051321911", "HR1223400092176878184"),
	("Leon", "Kasun", "lkasun@gmail.com", "023385370", "HR2023400093372382379"),
	("Tomislav", "Župan", "tzupan@gmail.com", "052624269", "HR5123600003847174167"),
	("Vanesa", "Vuka", "vvuka@gmail.com", "098256009", "HR9023400093732212416"),
	("Ela", "Pavletić", "epavletic@gmail.com", "040384148", "HR6525000093219268646"),
	("Dunja", "Zorić", "dzoric@gmail.com", "044547584", "HR2923600009341135835");

INSERT INTO placanje (naziv) VALUES
	("Gotovina"),
    ("Kartica-jednokratna"),
    ("Poduzece"),
    ("Kartica-na-rate");

INSERT INTO racun (datum_izdavanja, id_zaposlenik, id_automobil, id_placanje, id_kupac) VALUES
	("2020-04-30 19:21:31", 7, 1, 2, 15),
	("2019-11-09 17:52:45", 8, 4, 1, 14),
	("2021-01-04 15:47:59", 9, 8, 3, 13),
	("2020-03-21 17:25:00", 11, 17, 4, 12),
	("2019-04-17 18:00:45", 7, 20, 2, 11),
	("2020-05-10 10:52:50", 8, 28, 4, 10),
	("2020-08-27 11:41:41", 9, 29, 1, 9),
	("2021-03-07 12:52:12", 11, 33, 2, 8),
	("2021-02-28 15:56:14", 7, 37, 1, 7),
	("2019-12-10 20:11:59", 7, 41, 3, 6),
	("2019-11-15 10:15:22", 11, 48, 1, 5),
	("2019-12-02 09:02:24", 11, 49, 3, 4),
	("2019-12-22 20:21:32", 8, 23, 2, 3),
	("2020-03-07 19:41:16", 9, 44, 3, 2),
	("2020-08-11 17:35:42", 8, 51, 1, 1);