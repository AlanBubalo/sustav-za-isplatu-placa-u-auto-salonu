DROP DATABASE IF EXISTS isplata_placa;
CREATE DATABASE isplata_placa;
USE isplata_placa;

/* 
		Pozicije u firmi
	- Direktor
    - Tajnica
	- Knjigovođa
    - Voditelj prodaje
    - Prodavač automobila
    - Prodavač auto dijelova
    - Automehaničar
    - Autoelektričar
    - Informatičar
    - Zaštitar
    - Dostavljač
	- Čistačica 
	- Čistač automobila
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

CREATE TABLE kupac (
	id INTEGER PRIMARY KEY AUTO_INCREMENT, 
	ime VARCHAR(20) NOT NULL,
	prezime VARCHAR(30) NOT NULL,
	email VARCHAR(50) NOT NULL UNIQUE,
	broj_mobitela VARCHAR(10) UNIQUE,
	iban VARCHAR(50) UNIQUE,
    UNIQUE (ime, prezime),
	CONSTRAINT kupac_email_ck CHECK (email LIKE "%@%"),
    CONSTRAINT kupac_iban_ck CHECK (iban LIKE "HR%")
);

CREATE TABLE klasa (
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
	naziv VARCHAR(30) NOT NULL UNIQUE,
    stopa_bonusa FLOAT DEFAULT 1,
    CONSTRAINT klasa_stopa_bonusa_ck CHECK (stopa_bonusa > 0)
);

CREATE TABLE automobil (
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
	naziv VARCHAR(50) NOT NULL UNIQUE,
	id_klasa INTEGER NOT NULL,
    cijena INTEGER NOT NULL,
    CONSTRAINT automobil_cijena_ck CHECK (cijena > 0),
    CONSTRAINT automobil_klasa_fk FOREIGN KEY (id_klasa) REFERENCES klasa(id)
);

CREATE TABLE servis (
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
    vrsta VARCHAR(50) NOT NULL UNIQUE,
    cijena INTEGER NOT NULL,
    CONSTRAINT servis_cijena_ck CHECK (cijena > 0)
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
    broj_rata INTEGER DEFAULT 1,	 # Dozvoljeno plaćanje je do 60 rata, moguće je isključivo karticom na rate.
    CONSTRAINT racun_auto_or_servis_ck CHECK ((id_servis != NULL AND id_automobil = NULL) OR (id_servis = NULL AND id_automobil != NULL)),
	CONSTRAINT racun_zaposlenik_fk FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id),
    CONSTRAINT racun_kupac_fk FOREIGN KEY (id_kupac) REFERENCES kupac(id),
    CONSTRAINT racun_placanje_fk FOREIGN KEY (id_placanje) REFERENCES placanje(id),
    CONSTRAINT racun_automobil_fk FOREIGN KEY (id_automobil) REFERENCES automobil(id),
    CONSTRAINT racun_servis_fk FOREIGN KEY (id_servis) REFERENCES servis(id),
    CONSTRAINT racun_broj_rata_ck CHECK (broj_rata > 0 AND broj_rata<=60)
);

CREATE TABLE praznici (
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
	naziv VARCHAR(50) NOT NULL UNIQUE,
	datum VARCHAR(6) NOT NULL,
    CONSTRAINT praznici_datum_ck CHECK (datum LIKE "-%-%")
);

CREATE TABLE prisutnost (
	id INTEGER PRIMARY KEY AUTO_INCREMENT,
	id_zaposlenik INTEGER NOT NULL,
	datum DATETIME DEFAULT NOW(),
	broj_sati FLOAT NOT NULL,
	broj_sati_sa_bonusima FLOAT DEFAULT 0,
	CONSTRAINT prisutnost_zaposlenik_fk FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id),
    CONSTRAINT prisutnost_broj_sati_ck CHECK (broj_sati > 0)
);

# Zadatak: Trigger se koristi u slučaju ako kupac želi platiti na rate, a nije odabrao karticu na rate kao način plaćanja, broj rata mu se postavlja na jednu (mora platiti odjedanput).

DROP TRIGGER IF EXISTS bi_racun;
DELIMITER //
CREATE TRIGGER bi_racun
	BEFORE INSERT ON racun
	FOR EACH ROW
BEGIN
	IF new.id_placanje != 4 THEN
		SET new.broj_rata = 1;
END IF;
END //
DELIMITER ;

# Zadatak: Napravi okidač koji nam osigurava da u slučaju, 
# ako je zaposlenik radio preko 8 sati u jednom danu, satnica za prekovremene sate mu se nadodaje na satnicu (+50%) te ako je praznik/nedjelja onda mu se svi sati računaju 50% više.

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
	SELECT CONCAT("-", DATE_FORMAT(new.datum, "%m"), "-", DATE_FORMAT(new.datum, "%d")) INTO mjesecdan;
    
	IF new.broj_sati > 8 THEN
		SET new.broj_sati_sa_bonusima = 8 + (bonus * 1.5);
	END IF;
    
	IF mjesecdan IN (SELECT datum FROM praznici) THEN
		SET new.broj_sati_sa_bonusima = new.broj_sati_sa_bonusima + (new.broj_sati * 0.5);
	END IF;
	IF DAYNAME(new.datum) = "Sunday" THEN
		SET new.broj_sati_sa_bonusima = new.broj_sati_sa_bonusima + (new.broj_sati * 0.5);
	END IF;
    
    IF new.datum < (SELECT datum_zaposlenja FROM zaposlenik WHERE id = new.id_zaposlenik) THEN
		SIGNAL SQLSTATE '40000'
		SET MESSAGE_TEXT = 'Zaposlenik nije mogao otići na posao prije nego li se zaposlio (provjerite datum)';
	END IF;
END//
DELIMITER ;

# Zadatak: Okidač koji nam osigura da datum zaposlenja postane trenutni datum ako pokušamo zaposliti nekoga u budućem vremenu.

DROP TRIGGER IF EXISTS bi_zaposlenik;
DELIMITER //
CREATE TRIGGER bi_zaposlenik
	BEFORE INSERT ON zaposlenik
	FOR EACH ROW
BEGIN
	DECLARE datum VARCHAR(500);
	IF new.datum_zaposlenja > NOW() THEN
		SET new.datum_zaposlenja = NOW();
	END IF;
END//
DELIMITER ;

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
	("Luka", "Dudak", 2, "70125027634", "ldudak@luxecars.com", "2020-04-30 13:21:51"),
	("Karlo", "Lugomer", 3, "92670682735", "klugomer@luxecars.com", "2020-04-16 16:21:34"),
	("Jessica", "Zoranović", 2, "16096814870", "jzoranovic@luxecars.com", "2020-03-10 14:21:38"),
	("Andrej", "Konki", 4, "83871296540", "konkay69420@luxecars.com", "2020-04-30 15:21:55"),
	("Branimir", "Horvat", 4, "97236274923", "bhorvat@luxecars.com", "2020-04-20 16:21:44"),
	("Stipe", "Stup", 5, "17398368702", "sstup@luxecars.com", "2020-03-16 12:21:39"),
	("Velimir", "Kralj", 5, "37610633755", "vkralj@luxecars.com", "2020-03-30 11:21:32"),
	("Vladimir", "Jugić", 5, "98345756419", "vjugic@luxecars.com", "2020-04-30 12:21:35"),
	("Tihomir", "Tatić", 6, "60064731762", "ttatić@luxecars.com", "2020-04-03 13:21:37"),
	("Teuta", "Miškić", 5, "11289379123", "tmiskic@luxecars.com", "2020-04-10 14:21:36"),
	("Karolina", "Tunjić", 6, "60896521870", "ktunjić@luxecars.com", "2020-04-30 15:21:30"),
	("Mirko", "Barkica", 7, "35675273263", "mbarkica@luxecars.com", "2020-03-22 12:21:35"),
	("Vjekoslav", "Vukovoje", 7, "64685408891", "vvukovoje@luxecars.com", "2020-01-30 13:21:34"),
	("Goran", "Strujić", 8, "77352474271", "gstrujic@luxecars.com", "2020-02-08 11:21:20"),
	("Golub", "Gvozdenko", 8, "56198404250", "ggvozdenko@luxecars.com", "2020-04-09 12:21:19"),
	("Tomislav", "Valjak", 10, "69233667398", "mvaljak@luxecars.com", "2020-04-10 14:21:19"),
	("Mladen", "Jantoš", 10, "20761707492", "mjantos@luxecars.com", "2020-03-11 16:21:18"),
	("Robert", "Butkić", 10, "07698168587", "rbutkic@luxecars.com", "2020-03-12 14:21:17"),
	("Siniša", "Miščević", 10, "23587461757", "smiscevic@luxecars.com", "2020-03-17 11:21:16"),
	("Travan", "Dilović", 6, "15865867042", "tdilovic@luxecars.com", "2020-04-13 12:21:15"),
	("Jovana", "Kreketić", 6, "89714241090", "jkreketic@luxecars.com", "2020-04-14 11:21:14"),
	("Tomas", "Crnić", 9, "65013824596", "tcrnic@luxecars.com", "2020-04-16 13:21:21"),
	("Ernjoslav", "Negomir", 9, "33658723917", "enegomir@luxecars.com", "2020-04-27 14:21:31"),
	("Alan", "Šibanović", 9, "68956555044", "asibanovic@luxecars.com", "2020-04-22 13:21:31"),
	("Tamara", "Galić", 11, "65013824796", "tgalic@luxecars.com", "2020-04-20 12:21:31"),
	("Andrijana", "Brzić", 11, "08728711594", "abrzić@luxecars.com", "2020-03-10 11:21:31"),
	("Mihael", "Bokser", 12, "11006286754", "mbokser@luxecars.com", "2020-03-15 10:21:31"),
	("Jeffery", "Bizos", 12, "87017816387", "jbizos@luxecars.com", "2020-04-14 12:21:31"),
	("Orianna", "Ombretta", 13, "07151025941", "oombretta@luxecars.com", "2020-04-16 13:21:31"),
	("Danko", "Bananković", 13, "01405821019", "dbanankovic@luxecars.com", "2020-04-30 11:21:31");

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

INSERT INTO automobil (naziv, id_klasa, cijena) VALUES
	("Volkswagen UP", 1, 94000),
	("Škoda CitigoE IV", 1, 52000),
	("Hyundai I10", 1, 78000),
	("Opel Corsa", 2, 98000),
	("Citroen C3 Feel", 2, 109000),
	("Seat Ibiza", 2, 113000),
	("Volkswagen Golf 8", 3, 145000),
	("Opel Astra", 3, 139000),
	("Kia Ceed", 3, 140000),
	("Hyundai I30", 3, 128000),
	("Seat Leon", 3, 142000),
	("Mini Cooper Clubman", 3, 150000),
	("BMW Serija 1 F21", 3, 189000),
	("Mercedes A Klasa", 3, 196000),
	("Škoda Octavia", 4, 157000),
	("Volkswagen Passat", 4, 177000),
	("Ford Mondeo", 4, 160000),
	("Peugeot 508", 4, 176000),
	("Mazda 6", 4, 185000),
	("BMW Serija 5", 5, 230000),
	("Mercedes E klasa", 5, 240000),
	("Jaguar F Type", 10, 329000),
	("Rolls Royce Phantom", 5, 890000),
	("Jaguar XF", 5, 320000),
	("Peugeot 3008", 6, 276000),
	("Škoda Kodiaq", 6, 280000),
	("Audi Q3", 6, 264000),
	("BMW X5", 7, 503000),
	("Lamborghini Urus", 7, 2000000),
	("Range Rover Evoque", 7, 410000),
	("Mercedes GLA", 7, 560932),
	("Range Rover Velar", 9, 532000),
	("Volvo XC60", 8, 430210),
	("Toyota Land Cruiser", 8, 510000),
	("Mercedes G klasa", 9, 753000),
	("BMW X7", 9, 680318),
	("Rolls Royce Cullinan", 9, 932000),
	("Aston Martin DBS", 10, 912000),
	("Porsche 911 Spyder", 10, 8700000),
	("BMW Serije 8 coupe", 10, 910000),
	("Lamborghini Huracan", 10, 1948000),
	("Ferrari 812", 10, 1495000),
	("Nissan GT-R", 10, 901000),
	("Bentley Continental GT", 10, 2343000),
	("Mercedes E klasa coupe", 10, 842000),
	("Opel Vivaro", 11, 210000),
	("Mercedes V klasa", 11, 431000),
	("Peugeot Partner", 11, 190000),
	("Tesla Model S", 12, 540000),
	("Tesla Model 3", 12, 451000),
	("Tesla Model X", 12, 490000),
	("Tesla Model Y", 12, 453000),
	("Opel Corsa Electric", 12, 230000),
	("Mercedes X klasa", 13, 640000),
	("Ford Raptor", 13, 511000);

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

INSERT INTO racun (datum_izdavanja, id_zaposlenik, id_kupac, id_placanje, id_automobil, id_servis, broj_rata) VALUES
	("2020-04-30 19:21:31", 7, 15, 2, 1, NULL, NULL),
	("2019-11-09 17:52:45", 8, 14, 1, 4, NULL, NULL),
	("2021-01-04 15:47:59", 9, 13, 3, 8, NULL, NULL),
	("2020-03-21 17:25:00", 11, 12, 4, 17, NULL, 20),
	("2019-04-17 18:00:45", 10, 11, 2, NULL, 1, NULL),
	("2020-05-10 10:52:50", 8, 10, 4, 28, NULL, 15),
	("2020-08-27 11:41:41", 12, 9, 1, NULL, 2, NULL),
	("2021-03-07 12:52:12", 11, 8, 2, 33, NULL, NULL),
	("2021-02-28 15:56:14", 7, 7, 1, 37, NULL, NULL),
	("2019-12-10 20:11:59", 7, 6, 3, 41, NULL, NULL),
	("2019-11-15 10:15:22", 11, 5, 1, 48, NULL, NULL),
	("2019-12-02 09:02:24", 11, 4, 3, 49, NULL, NULL),
	("2019-12-22 20:21:32", 12, 3, 2, NULL, 4, NULL),
	("2020-03-07 19:41:16", 9, 2, 3, 44, NULL, NULL),
	("2020-08-11 17:35:42", 8, 1, 1, 51, NULL, NULL),
    ("2020-09-11 11:40:4", 8, 15, 1, NULL, 3, NULL),
    ("2019-11-15 15:15:22", 11, 5, 1, 48, NULL, NULL),
	("2019-12-02 11:02:24", 11, 4, 3, 49, NULL, NULL),
	("2019-12-22 14:21:32", 5, 3, 2, NULL, 4, NULL),
	("2020-03-07 22:41:16", 9, 2, 3, 44, NULL, NULL),
	("2020-08-11 16:35:42", 3, 1, 1, 51, NULL, NULL),
    ("2020-09-11 14:40:4", 8, 15, 1, NULL, 3, NULL);
    
INSERT INTO praznici (naziv, datum) VALUES 
	("Bozic", "-12-25"),
	("Nova godina", "-01-01"),
	("Praznik rada", "-05-01"),
	("Tijelovo","-06-16"),
	("Dan svih svetih", "-01-11");

INSERT INTO prisutnost (id_zaposlenik, datum, broj_sati) VALUES 
	(1, "2019-06-02 12:21:31", 6),
	(2, "2020-06-03 10:30:21", 8),
	(3, "2020-06-04 10:20:22", 10),
	(4, "2020-06-05 10:10:23", 9),
	(5, "2020-06-06 10:10:26", 5),
	(6, "2020-10-07 10:50:28", 6),
	(7, "2020-11-08 10:50:29", 7),
	(8, "2020-08-09 10:40:21", 8),
	(9, "2020-12-02 10:30:21", 10),
	(10, "2020-11-01 10:20:20", 7),
	(11, "2020-10-01 10:20:20", 5),
	(12, "2020-07-01 10:10:20", 4),
	(13, "2020-07-01 10:10:22", 6),
	(14, "2020-07-01 10:10:23", 7),
	(15, "2020-07-02 10:40:24", 8),
	(16, "2020-07-03 10:30:20", 8),
	(17, "2020-07-04 10:50:26", 8),
	(18, "2020-07-07 10:50:29", 8),
	(19, "2020-07-08 10:40:28", 8),
	(20, "2020-07-02 10:30:25", 8),
	(21, "2020-07-03 10:20:24", 8),
	(22, "2020-07-01 10:10:23", 8),
	(23, "2020-07-06 10:10:22", 10),
	(24, "2020-07-07 10:20:22", 9),
	(25, "2020-07-02 10:20:21", 9),
	(26, "2020-09-03 10:30:22", 9),
	(27, "2020-07-04 10:40:20", 8),
	(28, "2020-07-04 10:20:20", 8),
	(29, "2020-07-05 10:30:20", 8),
	(30, "2020-05-06 10:10:20", 7),
	(1, "2019-09-02 09:42:41", 8),
	(2, "2020-10-03 11:10:11", 5),
	(3, "2020-10-04 11:45:52", 1),
	(4, "2020-10-05 10:01:13", 6),
	(5, "2020-09-06 10:14:34", 10),
	(6, "2020-09-07 09:52:56", 7),
	(7, "2020-10-08 10:55:13", 7),
	(8, "2020-10-09 08:54:52", 9),
	(9, "2020-10-02 09:53:52", 8),
	(10, "2020-09-01 10:09:20", 8),
	(11, "2020-09-01 09:10:10", 4),
	(12, "2020-10-01 11:14:09", 1),
	(13, "2020-09-01 11:44:54", 4),
	(14, "2020-09-01 11:24:05", 2),
	(15, "2020-09-02 10:42:01", 10),
	(16, "2020-09-03 11:01:42", 9),
	(17, "2020-09-04 09:42:53", 3),
	(18, "2020-10-07 10:10:31", 6),
	(19, "2020-10-08 08:53:41", 7),
	(20, "2020-10-02 10:10:05", 7),
	(21, "2020-09-03 08:41:14", 8),
	(22, "2020-09-01 10:09:03", 7),
	(23, "2020-10-06 10:01:43", 2),
	(24, "2020-10-07 10:46:22", 10),
	(25, "2020-10-02 09:34:21", 5),
	(26, "2020-10-03 11:20:32", 9),
	(27, "2020-09-04 08:13:14", 10),
	(28, "2020-09-04 10:15:40", 5),
	(29, "2020-10-05 10:52:10", 4),
	(30, "2020-09-06 09:31:43", 5),
	(1, "2020-06-02 13:25:35", 7),
	(2, "2020-06-04 11:40:27", 9),
	(3, "2020-06-06 11:15:22", 8),
	(4, "2020-06-08 10:19:59", 7),
	(5, "2020-06-10 10:35:26", 6),
	(6, "2020-06-12 10:43:53", 7),
	(7, "2020-06-14 11:21:29", 8),
	(8, "2020-06-16 12:10:30", 9),
	(9, "2020-06-18 10:39:31", 9),
	(10, "2020-06-20 13:12:13", 6),
	(11, "2020-06-22 10:19:05", 7),
	(12, "2020-06-24 10:15:20", 8),
	(13, "2020-06-26 10:32:22", 9),
	(14, "2020-06-28 10:43:23", 6),
	(15, "2020-06-30 10:50:16", 9),
	(16, "2020-07-01 10:30:20", 8),
	(17, "2020-07-03 10:48:26", 8),
	(18, "2020-07-05 09:50:29", 7),
	(19, "2020-07-07 10:30:28", 10),
	(20, "2020-07-09 10:20:25", 9),
	(21, "2020-07-11 11:10:24", 7),
	(22, "2020-07-13 10:53:23", 8),
	(23, "2020-07-15 10:36:22", 10),
	(24, "2020-07-17 08:20:22", 8),
	(25, "2020-07-19 10:29:57", 7),
	(26, "2020-07-21 10:43:22", 6),
	(27, "2020-07-23 12:24:20", 8),
	(28, "2020-07-25 10:10:20", 9),
	(29, "2020-07-27 10:13:20", 7),
	(30, "2020-07-29 11:05:20", 9),
	(1, "2019-08-15 12:21:31", 6),
	(2, "2020-08-17 10:35:21", 8),
	(3, "2020-08-23 06:24:22", 10),
	(4, "2020-08-07 06:12:23", 9),
	(5, "2020-08-26 06:03:26", 5),
	(6, "2020-08-27 08:53:28", 6),
	(7, "2020-08-21 07:59:29", 7),
	(8, "2020-08-11 08:41:21", 8),
	(9, "2020-08-12 08:31:21", 10),
	(10, "2020-08-13 10:12:20", 7),
	(11, "2020-08-14 13:26:20", 5),
	(12, "2020-08-10 13:07:20", 4),
	(13, "2020-08-16 14:04:22", 6),
	(14, "2020-08-17 14:16:23", 7),
	(15, "2020-08-18 10:48:24", 8),
	(16, "2020-08-01 12:31:20", 8),
	(17, "2020-08-02 12:55:26", 8),
	(18, "2020-08-03 10:52:29", 8),
	(19, "2020-08-10 11:45:28", 8),
	(20, "2020-08-11 11:34:25", 8),
	(21, "2020-08-13 10:24:24", 8),
	(22, "2020-08-15 10:14:23", 8),
	(23, "2020-08-16 10:15:22", 10),
	(24, "2020-08-17 10:22:22", 9),
	(25, "2020-08-19 10:21:21", 9),
	(26, "2020-08-21 09:32:22", 9),
	(27, "2020-08-22 09:42:20", 8),
	(28, "2020-08-24 09:15:20", 8),
	(29, "2020-09-25 08:08:20", 8),
	(30, "2020-09-27 08:08:20", 7),
    (1, "2020-08-12 08:33:23", 5),
	(2, "2020-08-19 10:35:21", 5),
	(3, "2020-08-28 06:24:22", 7),
	(4, "2020-08-19 06:00:23", 9),
	(5, "2020-10-26 09:03:26", 5),
	(6, "2020-12-27 08:53:28", 6),
	(7, "2020-12-21 07:59:29", 7),
	(8, "2020-11-11 08:41:21", 8),
	(9, "2020-10-12 08:31:21", 10),
	(10, "2020-10-13 12:12:20", 7),
	(11, "2020-11-14 13:26:20", 5),
	(12, "2020-11-10 10:07:20", 4),
	(13, "2020-08-24 16:04:22", 6),
	(14, "2020-04-17 14:56:23", 7),
	(15, "2020-06-18 11:48:24", 8),
	(16, "2020-08-21 08:31:20", 8),
	(17, "2020-07-02 16:55:26", 8),
	(18, "2020-05-03 10:52:29", 8),
	(19, "2020-09-10 11:45:28", 8),
	(20, "2020-06-11 11:04:25", 8),
	(21, "2020-08-10 10:24:1", 8),
	(22, "2020-10-15 09:14:23", 8),
	(23, "2020-08-09 10:15:22", 10),
	(24, "2020-08-11 10:22:24", 9),
	(25, "2020-08-10 10:23:21", 9),
	(26, "2020-08-20 09:32:22", 9),
	(27, "2020-08-29 09:40:20", 8),
	(28, "2020-08-01 19:15:20", 8),
	(29, "2020-12-25 08:12:20", 8),
	(30, "2020-12-27 08:08:20", 7);

# Zadatak: Funkcija koja vrača satnicu određenog zaposlenika.

DROP FUNCTION IF EXISTS satnica_zaposlenika;
DELIMITER //
CREATE FUNCTION satnica_zaposlenika(p_id_zaposlenik INTEGER) RETURNS INTEGER
DETERMINISTIC
BEGIN
    RETURN (SELECT novac_po_satu
        FROM zaposlenik
            INNER JOIN pozicija
            ON id_pozicija = pozicija.id AND
				zaposlenik.id = p_id_zaposlenik);
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
			ON id_zaposlenik = zaposlenik.id AND
				id_zaposlenik = p_id_zaposlenik
		GROUP BY id_zaposlenik;
    IF result = 0 THEN
        SET result = -1;
    END IF;
    RETURN result;
END//
DELIMITER ;

# Primjer:
SELECT broj_racuna(10) FROM DUAL;

# Zadatak: Zbroj sati rada od određenog zaposlenika u određenom mjesecu.

DROP FUNCTION IF EXISTS sati_mjesec;
DELIMITER //
CREATE FUNCTION sati_mjesec (p_id_zaposlenik INTEGER, p_mjesec INTEGER, p_godina INTEGER) RETURNS FLOAT
DETERMINISTIC
BEGIN
	DECLARE REZ FLOAT;
	SELECT SUM(broj_sati) INTO REZ
		FROM prisutnost  
		WHERE YEAR(datum) = p_godina AND
			MONTH(datum) = p_mjesec AND
			id_zaposlenik = p_id_zaposlenik
		GROUP BY id_zaposlenik;
	IF REZ THEN
		RETURN REZ;
	ELSE RETURN 0;
END IF;
   
END//
DELIMITER ;

SELECT sati_mjesec(10, 1, 2020);

# Zadatak: Izračun plaće ordeđenog zaposlenika u oređenom mjesecu.

DROP FUNCTION IF EXISTS placa_mjesec;
DELIMITER //
CREATE FUNCTION placa_mjesec (p_id_zaposlenik INTEGER, p_mjesec INTEGER, p_godina INTEGER) RETURNS FLOAT
DETERMINISTIC
BEGIN
	DECLARE REZ FLOAT;
	SELECT SUM(broj_sati_sa_bonusima) INTO REZ
		FROM prisutnost
		WHERE YEAR(datum) = p_godina
			AND MONTH(datum) = p_mjesec
			AND id_zaposlenik = p_id_zaposlenik
		GROUP BY id_zaposlenik;
	IF NOT REZ THEN
		RETURN 0;
	END IF;   
	RETURN REZ * satnica_zaposlenika(p_id_zaposlenik);
END//
DELIMITER ;

SELECT placa_mjesec(17, 7, 2020);

# Zadatak: Procedura sprema auto u različite group ovisno o cijeni (grupe bitno_prodati i manje_bitno).

DROP PROCEDURE IF EXISTS sortiranje_auta;
DELIMITER //
CREATE PROCEDURE sortiranje_auta(IN limit_cij INTEGER, OUT bitno_prodati VARCHAR(4000), OUT manje_bitno VARCHAR(4000))
BEGIN
	DECLARE auto VARCHAR(50) DEFAULT "";
	DECLARE dod_cijena INTEGER DEFAULT 0;
	DECLARE finished INTEGER DEFAULT 0;
	DECLARE cur CURSOR FOR
		SELECT naziv, cijena
			FROM automobil;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000'
	BEGIN
		SET finished = 1;
	END;
	SET bitno_prodati = "";
	SET manje_bitno = "";
	OPEN CUR;
	iteriraj_automobile: LOOP
		FETCH cur INTO auto, dod_cijena;
		IF finished = 1 THEN
			LEAVE iteriraj_automobile;
		END IF;
		IF dod_cijena < limit_cij THEN
			SET manje_bitno = CONCAT(auto, ", ", manje_bitno);
		ELSE
			SET bitno_prodati = CONCAT(auto, ", ", bitno_prodati);
		END IF;
	END LOOP iteriraj_automobile;
	CLOSE cur;
END //
DELIMITER ;

CALL sortiranje_auta(150000, @bitno_prodati, @manje_bitno);
SELECT @bitno_prodati, @manje_bitno;

# Zadatak: Procedura koja sprema brojeve koliko je sveukupno novaca potrošio kupac na zasebno aute i servis.

DROP PROCEDURE IF EXISTS kupac_potrosio;
DELIMITER //
CREATE PROCEDURE kupac_potrosio(IN p_id_kupac INTEGER, OUT suma_auto INTEGER, OUT suma_servis INTEGER)
DETERMINISTIC
BEGIN
	SELECT SUM(automobil.cijena) INTO suma_auto
		FROM racun
			INNER JOIN automobil
			ON automobil.id = id_automobil
		WHERE id_kupac = p_id_kupac
		GROUP BY id_kupac;
	SELECT SUM(servis.cijena) INTO suma_servis
		FROM racun
			INNER JOIN servis
			ON servis.id = id_servis
		WHERE id_kupac = p_id_kupac
		GROUP BY id_kupac;
END//
DELIMITER ;

# Primjer

CALL kupac_potrosio(15, @suma_auto, @suma_servis);
SELECT @suma_auto, @suma_servis;

# Zadatak: Napraviti novog korisnika koji ima sva prava na tablici racun, dok na tablicama zaposlenik, automobil, servis, korisnik i placanje može samo čitati

DROP USER IF EXISTS novi_korisnik;
CREATE USER novi_korisnik IDENTIFIED BY "novi_korisnik";
GRANT ALL PRIVILEGES ON isplata_placa.racun TO novi_korisnik;
GRANT SELECT ON isplata_placa.zaposlenik TO novi_korisnik;
GRANT SELECT ON isplata_placa.kupac TO novi_korisnik;
GRANT SELECT ON isplata_placa.placanje TO novi_korisnik;
GRANT SELECT ON isplata_placa.automobil TO novi_korisnik;
GRANT SELECT ON isplata_placa.servis TO novi_korisnik;
SHOW GRANTS FOR novi_korisnik;

# Zadatak: Napraviti SQL upit i optimizirani plan izvođenja upita koji će prikazati popis imena i prezimena kupaca i zaposlenika čije je ime "Tomislav" i dodati novi
# atribut "uloga" u koji sprema riječ kupac ili zaposlenik ovisno koju ulogu ima ta osoba.

SELECT ime, prezime, "kupac" AS uloga
	FROM kupac
	WHERE ime = "Tomislav"
UNION ALL
SELECT ime, prezime, "zaposlenik" AS uloga
	FROM zaposlenik
	WHERE ime = "Tomislav";

# Optimizirani plan izvođenja upita

# π ime, prezime, 'kupac' → uloga (σ ime = 'Tomislav' (kupac))) ∪ ( π ime, prezime, 'zaposlenik' → uloga (σ ime = 'Tomislav' (zaposlenik)))



# Pogled koji pokazuje imena i prezimena kupaca koji su kupili aute skuplje od 500000 kuna.

CREATE VIEW vip_kupci AS
SELECT ime, prezime 
FROM racun INNER JOIN kupac ON kupac.id = id_kupac
INNER JOIN automobil ON automobil.id = id_automobil WHERE cijena > 500000;
SELECT * FROM vip_kupci;


# Pogled koji prikazuje imena i prezimena zaposlenika koji rade kao čistaći.

CREATE VIEW zaposlenik_čistać AS
SELECT zaposlenik.ime, prezime, pozicija.ime AS pozicija 
FROM zaposlenik INNER JOIN pozicija ON pozicija.id = id_pozicija 
WHERE id_pozicija = 12 OR id_pozicija=13;
SELECT * FROM zaposlenik_čistać;

# Pogled koji prikazuje sve zaposlenike koji su izdali račun te ih sortira po datumu zapošljenja toga korisnika.

CREATE VIEW zaposlenik_izdaje_računa AS
SELECT DISTINCT zaposlenik.id AS id, ime, prezime, datum_zaposlenja 
FROM zaposlenik RIGHT JOIN racun ON zaposlenik.id = id_zaposlenik 
ORDER BY datum_zaposlenja DESC;
SELECT * FROM zaposlenik_izdaje_računa;

# Pogled koji prikazuje zaposlenika koji je najviše zaradio u 7 mjesecu 2020.

CREATE VIEW najplaćeniji_zaposlenik AS
SELECT id, ime, prezime, placa_mjesec(id, 7, 2020) 
FROM zaposlenik ORDER BY placa_mjesec(id,7,2020) 
DESC LIMIT 1;
SELECT * FROM najplaćeniji_zaposlenik;

# Pogled koji prikazuje sve kupce i njihovu svotu novcu koju su potrošili na servise auta.

CREATE VIEW potrošnja_servisa AS
SELECT kupac.id AS id, ime, prezime, SUM(cijena) FROM kupac LEFT JOIN racun ON kupac.id = id_kupac 
RIGHT JOIN servis ON servis.id = id_servis 
GROUP BY kupac.id;
SELECT * FROM potrošnja_servisa;