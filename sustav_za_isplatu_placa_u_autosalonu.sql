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
plaćanje pouzećem (za velike firme)
plaćanje karticom
plaćanje u kešu
	
    moguće je plaćat na rate 
    do 60 rata = 5 godina
*/

/*
Sta trebamo napraviti:
	- cijene zaokruziti da budu reasonable
    - 
*/

CREATE TABLE pozicija (
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
	ime VARCHAR(30) NOT NULL UNIQUE,
    opis VARCHAR(100) NOT NULL UNIQUE,
    novac_po_satu INTEGER NOT NULL
);

CREATE TABLE zaposlenik(
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
	ime VARCHAR(20) NOT NULL,
	prezime VARCHAR(30) NOT NULL,
    id_pozicija INTEGER NOT NULL,
    oib CHAR(11) NOT NULL UNIQUE,
    email VARCHAR(50) NOT NULL UNIQUE,
    datum_zaposlenja DATETIME DEFAULT NOW(),
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

CREATE TABLE automobil (
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
	naziv VARCHAR(50) NOT NULL UNIQUE,
	id_klasa INTEGER NOT NULL,
    cijena INTEGER NOT NULL,
    CONSTRAINT automobil_cijena_ck CHECK (cijena > 0),
    CONSTRAINT automobil_klasa_fk FOREIGN KEY (id_klasa) REFERENCES klasa(id)
);

/*
CREATE TABLE bonus_sati (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    tip_bonusa VARCHAR(20) NOT NULL UNIQUE,
    postotak FLOAT
);
*/

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
    vrsta VARCHAR(50) NOT NULL UNIQUE,
    cijena INTEGER NOT NULL
);

CREATE TABLE placanje (
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
    naziv VARCHAR(20) UNIQUE
);

CREATE TABLE racun (
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
    datum_izdavanja DATETIME DEFAULT NOW(),
	id_zaposlenik INTEGER NOT NULL,
    id_kupac INTEGER NOT NULL,
    id_placanje INTEGER NOT NULL,
    id_automobil INTEGER,
    id_servis INTEGER,
    -- CONSTRAINT racun_datum_izdavanja_ck CHECK (datum_izdavanja < NOW()),
    CONSTRAINT racun_auto_or_servis_ck CHECK ((id_servis != NULL AND id_automobil = NULL) OR (id_servis = NULL AND id_automobil != NULL)),
	CONSTRAINT racun_zaposlenik_fk FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id),
    CONSTRAINT racun_kupac_fk FOREIGN KEY (id_kupac) REFERENCES kupac(id),
    CONSTRAINT racun_placanje_fk FOREIGN KEY (id_placanje) REFERENCES placanje(id),
    CONSTRAINT racun_automobil_fk FOREIGN KEY (id_automobil) REFERENCES automobil(id),
    CONSTRAINT racun_servis_fk FOREIGN KEY (id_servis) REFERENCES servis(id)
);

CREATE TABLE praznici (
id INTEGER PRIMARY KEY AUTO_INCREMENT,
naziv VARCHAR(50) NOT NULL,
datum VARCHAR(50) NOT NULL
);

CREATE TABLE prisutnost (
id INTEGER PRIMARY KEY AUTO_INCREMENT,
id_zaposlenik INTEGER NOT NULL,
datum DATETIME DEFAULT NOW(),
broj_sati FLOAT DEFAULT 0,
broj_sati_sa_bonusima FLOAT DEFAULT 0,
CONSTRAINT prisutnost_zaposlenik_fk FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id)
);

INSERT INTO pozicija (ime, opis, novac_po_satu) VALUES
	("Direktor", "Voditelj firme", 120),
	("Tajnik", "Dogovara sastanke i vodi upravne poslove", 70),
	("Knjigovođa", "Vodi knjige vezane uz finacije i druge aspekte firme", 90),
	("Voditelje prodaje", "Nadgleda prodavače i mehaničare", 100),
	("Prodavač automobila", "Prodaje automobile", 60),
	("Prodavač auto dijelova", "Prodaje dijelove za automobile", 55),
	("Automehaničar", "Popravlja mehaničke poteškoće to jest kvarove na automobilima", 40),
	("Autoelektričar", "Popravlja elektroničke poteškoće to jest kvarove na automobilima", 40),
	("Informatičar", "Vodi aplikaciju i online stranicu vezanu uz firmu", 100),
	("Zaštitar", "Brine o sigurnosti radnika i vlasništva firme", 40),
	("Dostavljač", "Dostavlja prodane proizvode njihovim kupcima", 35),
	("Čistać", "Održava radno mjesto čistim", 30),
	("Čistać Automobila", "Održava automobile u izložbenom stanju", 35);

INSERT INTO zaposlenik (ime, prezime, id_pozicija, oib, email, datum_zaposlenja) VALUES
	("Mlohael", "Ether", 1, "95841550335", "mether@luxecars.com", "2019-04-30 12:21:31"),
	("Luka", "Dudak", 2, "70125027634", "ldudak@luxecars.com", "2020-12-30 13:21:51"),
	("Karlo", "Lugomer", 3, "92670682735", "klugomer@luxecars.com", "2020-06-16 16:21:34"),
	("Jessica", "Zoranović", 2, "16096814870", "jzoranovic@luxecars.com", "2020-07-10 14:21:38"),
	("Andrej", "Konki", 4, "83871296540", "konkay69420@luxecars.com", "2020-04-30 15:21:55"),
	("Branimir", "Horvat", 4, "97236274923", "bhorvat@luxecars.com", "2020-04-20 16:21:44"),
	("Stipe", "Stup", 5, "17398368702", "sstup@luxecars.com", "2020-12-16 12:21:39"),
	("Velimir", "Kralj", 5, "37610633755", "vkralj@luxecars.com", "2020-11-30 11:21:32"),
	("Vladimir", "Jugić", 5, "98345756419", "vjugic@luxecars.com", "2020-09-30 12:21:35"),
	("Tihomir", "Tatić", 6, "60064731762", "ttatić@luxecars.com", "2020-08-03 13:21:37"),
	("Teuta", "Miškić", 5, "11289379123", "tmiskic@luxecars.com", "2020-09-10 14:21:36"),
	("Karolina", "Tunjić", 6, "60896521870", "ktunjić@luxecars.com", "2020-10-30 15:21:30"),
	("Mirko", "Barkica", 7, "35675273263", "mbarkica@luxecars.com", "2020-11-22 12:21:35"),
	("Vjekoslav", "Vukovoje", 7, "64685408891", "vvukovoje@luxecars.com", "2020-01-30 13:21:34"),
	("Goran", "Strujić", 8, "77352474271", "gstrujic@luxecars.com", "2020-02-08 11:21:20"),
	("Golub", "Gvozdenko", 8, "56198404250", "ggvozdenko@luxecars.com", "2020-04-09 12:21:19"),
	("Mario", "Valjak", 10, "69233667398", "mvaljak@luxecars.com", "2020-04-10 14:21:19"),
	("Mladen", "Jantoš", 10, "20761707492", "mjantos@luxecars.com", "2020-03-11 16:21:18"),
	("Robert", "Butkić", 10, "07698168587", "rbutkic@luxecars.com", "2020-08-12 14:21:17"),
	("Siniša", "Miščević", 10, "23587461757", "smiscevic@luxecars.com", "2020-10-17 11:21:16"),
	("Travan", "Dilović", 6, "15865867042", "tdilovic@luxecars.com", "2020-05-13 12:21:15"),
	("Jovana", "Kreketić", 6, "89714241090", "jkreketic@luxecars.com", "2020-05-14 11:21:14"),
	("Tomas", "Crnić", 9, "65013824596", "tcrnic@luxecars.com", "2020-06-16 13:21:21"),
	("Ernjoslav", "Negomir", 9, "33658723917", "enegomir@luxecars.com", "2020-02-27 14:21:31"),
	("Alan", "Šibanović", 9, "68956555044", "asibanovic@luxecars.com", "2020-01-22 13:21:31"),
	("Tamara", "Galić", 11, "65013824796", "tgalic@luxecars.com", "2020-03-20 12:21:31"),
	("Andrijana", "Brzić", 11, "08728711594", "abrzić@luxecars.com", "2020-03-10 11:21:31"),
	("Mihael", "Bokser", 12, "11006286754", "mbokser@luxecars.com", "2020-06-15 10:21:31"),
	("Jeffery", "Bizos", 12, "87017816387", "jbizos@luxecars.com", "2020-04-14 12:21:31"),
	("Orianna", "Ombretta", 13, "07151025941", "oombretta@luxecars.com", "2020-08-16 13:21:31"),
	("Danko", "Bananković", 13, "01405821019", "dbanankovic@luxecars.com", "2020-11-30 11:21:31");

INSERT INTO isplata (id_zaposlenik, broj_sati, bonus) VALUES
	(1, NULL, NULL),
	(2, NULL, NULL),
	(3, NULL, NULL),
	(4, NULL, NULL),
	(5, NULL, NULL),
	(6, NULL, NULL),
	(7, NULL, NULL),
	(8, NULL, NULL),
	(9, NULL, NULL),
	(10, NULL, NULL),
	(11, NULL, NULL),
	(12, NULL, NULL),
	(13, NULL, NULL);

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

/*
INSERT INTO bonus_sati (tip_bonusa, postotak) VALUES
	("Rad vikendom", 50),
	("Rad blagdanom", 100),
	("Noćni rad", 50),
	("Rad prekovremeno", 25);
*/

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
	("BMW Serija 1 F21", 3, 189321),
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

INSERT INTO servis (vrsta, cijena) VALUES
	("Mali servis", 450),
    ("Veliki servis", 700),
    ("Zamjena ljetnih/zimskih guma", 200),
    ("Unutarnje i vanjsko pranje vozila", 100);

INSERT INTO placanje (naziv) VALUES
	("Gotovina"),
    ("Kartica jednokratno"),
    ("Pouzece"),
    ("Kartica na rate");

INSERT INTO racun (datum_izdavanja, id_zaposlenik, id_kupac, id_placanje, id_automobil, id_servis) VALUES
	("2020-04-30 19:21:31", 7, 15, 2, 1, NULL),
	("2019-11-09 17:52:45", 8, 14, 1, 4, NULL),
	("2021-01-04 15:47:59", 9, 13, 3, 8, NULL),
	("2020-03-21 17:25:00", 11, 12, 4, 17, NULL),
	("2019-04-17 18:00:45", 10, 11, 2, NULL, 1),
	("2020-05-10 10:52:50", 8, 10, 4, 28, NULL),
	("2020-08-27 11:41:41", 12, 9, 1, NULL, 2),
	("2021-03-07 12:52:12", 11, 8, 2, 33, NULL),
	("2021-02-28 15:56:14", 7, 7, 1, 37, NULL),
	("2019-12-10 20:11:59", 7, 6, 3, 41, NULL),
	("2019-11-15 10:15:22", 11, 5, 1, 48, NULL),
	("2019-12-02 09:02:24", 11, 4, 3, 49, NULL),
	("2019-12-22 20:21:32", 12, 3, 2, NULL, 4),
	("2020-03-07 19:41:16", 9, 2, 3, 44, NULL),
	("2020-08-11 17:35:42", 8, 1, 1, 51, NULL);
    
INSERT INTO praznici (naziv, datum) VALUES 
("Bozic", "-12-25"),
("Nova godina", "-01-01"),
("Praznik rada", "-05-01"),
("Tijelovo","-06-16"),
("Dan svih svetih", "-01-11");

# Zadatak: Okidač nam osigurava da u slučaju ako je zaposlenik radio preko 8 sati u jednome danu, satnica za prekovremene sate mu se nadodaje na satnicu (+50%) 
DROP TRIGGER IF EXISTS bi_prisutnost;
DELIMITER //
CREATE TRIGGER bi_prisutnost
	BEFORE INSERT ON prisutnost
	FOR EACH ROW
BEGIN
DECLARE bonus FLOAT;
DECLARE mjesecdan VARCHAR(6);
SET new.broj_sati_sa_bonusima = new.broj_sati;
SET bonus = new.broj_sati - 8;
SELECT CONCAT("-",DATE_FORMAT(new.datum,"%m"),"-", DATE_FORMAT(new.datum,"%d")) INTO mjesecdan;
IF new.broj_sati > 8 THEN SET new.broj_sati_sa_bonusima = 8 + (bonus * 1.5);
END IF;
IF mjesecdan IN (SELECT datum FROM praznici) THEN SET new.broj_sati_sa_bonusima = new.broj_sati_sa_bonusima + (new.broj_sati * 0.5);
END IF;
IF DAYNAME(new.datum) = "Sunday" THEN SET new.broj_sati_sa_bonusima = new.broj_sati_sa_bonusima + (new.broj_sati * 0.5);
END IF;
END//
DELIMITER ;

INSERT INTO prisutnost (id_zaposlenik, datum, broj_sati) VALUES 
(1,  "2019-05-02 12:21:31", 6),
(2,  "2020-06-03 10:30:21", 8),
(3,  "2020-06-04 10:20:22", 10),
(4,  "2020-06-05 10:10:23", 9),
(5,  "2020-06-06 10:10:26", 5),
(6,  "2020-10-07 10:50:28", 6),
(7,  "2020-11-08 10:50:29", 7),
(8,  "2020-08-09 10:40:21", 8),
(9,  "2020-12-02 10:30:21", 10),
(10,  "2020-11-01 10:20:20", 7),
(11,  "2020-10-01 10:20:20", 5),
(12,  "2020-07-01 10:10:20", 4),
(13,  "2020-04-01 10:10:22", 6),
(14,  "2020-03-01 10:10:23", 7),
(15,  "2020-02-02 10:40:24", 8),
(16,  "2020-01-03 10:30:20", 8),
(17,  "2020-01-04 10:50:26", 8),
(18,  "2020-01-07 10:50:29", 8),
(19,  "2020-01-08 10:40:28", 8),
(20,  "2020-01-02 10:30:25", 8),
(21,  "2020-02-03 10:20:24", 8),
(22,  "2020-03-01 10:10:23", 8),
(23,  "2020-03-06 10:10:22", 10),
(24,  "2020-03-07 10:20:22", 9),
(25,  "2020-03-02 10:20:21", 9),
(26,  "2020-09-03 10:30:22", 9),
(27,  "2020-03-04 10:40:20", 8),
(28,  "2020-04-04 10:20:20", 8),
(29,  "2020-04-05 10:30:20", 8),
(30,  "2020-05-06 10:10:20", 7);


    # Zadatak: Funkcija koja vrača satnicu određenog zaposlenika.
DROP FUNCTION IF EXISTS satnica;
DELIMITER //
CREATE FUNCTION satnica_zaposlenika(p_id_zaposlenik INTEGER) RETURNS INTEGER
DETERMINISTIC
BEGIN
    RETURN (SELECT novac_po_satu
        FROM zaposlenik
            INNER JOIN pozicija
            ON id_pozicija = pozicija.id AND zaposlenik.id = p_id_zaposlenik);
END//
DELIMITER ;

# Primjer:
SELECT satnica_zaposlenika(5) FROM DUAL;


# Zadatak: Funkcija koja vrača broj računa koji je zaposlenik izdao, treba izbaciti -1 ako zaposlenik nije niti jedan račun izdao.
DROP FUNCTION IF EXISTS broj_racuna;
DELIMITER //
CREATE FUNCTION broj_racuna(p_id_zaposlenik INTEGER) RETURNS INTEGER
DETERMINISTIC
BEGIN
    DECLARE result INTEGER DEFAULT 0;
    SELECT COUNT(*) INTO result
    FROM racun
        INNER JOIN zaposlenik
        ON id_zaposlenik = zaposlenik.id AND id_zaposlenik = p_id_zaposlenik
    GROUP BY id_zaposlenik;
    IF result = 0 THEN
        SET result = -1;
    END IF;
    RETURN result;
END//
DELIMITER ;

# Primjer:
SELECT broj_racuna(10) FROM DUAL;

# Zadatak: Okidač koji nam osigura da datum zaposlenja postane trenutni datum ako pokušamo zaposliti nekoga u budućem vremenu.
DROP TRIGGER IF EXISTS bi_zaposlenik;
DELIMITER //
CREATE TRIGGER bi_zaposlenik
	BEFORE INSERT ON zaposlenik
	FOR EACH ROW
BEGIN
DECLARE datum VARCHAR(500);
IF new.datum_zaposlenja > NOW() THEN SET new.datum_zaposlenja = NOW();
END IF;
END//
DELIMITER ;

SELECT * FROM prisutnost
