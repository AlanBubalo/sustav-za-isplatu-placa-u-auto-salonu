const express = require("express");
const mysql = require("mysql");
const cors = require("cors");
const app = express();
const port = "5050";
const bodyParser = require("body-parser");
const { query } = require("express");

app.listen("5050", () => {
  console.log("server started");
});
const connection = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "root",
  database: "isplata_placa",
  multipleStatements: true,
});
connection.connect((err) => {
  if (err) throw err;
  console.log("databaseconnected");
});

app.use(cors());
app.use(express.static(__dirname));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

//----------------------------------------------------

app.get("/", (req, res) => {
  res.sendFile(__dirname + "/index.html");
});

app.post("/satnicazaposlenika.html", (req, res) => {
  var idZaposlenik = req.body.idZaposlenik;
  const sql_query =
    "SELECT satnica_zaposlenika(" + idZaposlenik + ") FROM DUAL;";
  connection.query(sql_query, (error, result) => {
    if (error) throw error;
    res.json({
      result,
    });
  });
});

app.post("/brojracuna.html", (req, res) => {
  var idZaposlenik = req.body.idZaposlenik;
  const sql_query = "SELECT broj_racuna(" + idZaposlenik + ") FROM DUAL;";
  connection.query(sql_query, (error, result) => {
    if (error) throw error;
    res.json({
      result,
    });
  });
});

app.post("/brojsatiumjesecu.html", (req, res) => {
  var idZaposlenik = req.body.idZaposlenik;
  var Mjesec = req.body.Mjesec;
  var Godina = req.body.Godina;
  const sql_query =
    "SELECT sati_mjesec(" +
    idZaposlenik +
    ", " +
    Mjesec +
    ", " +
    Godina +
    ") FROM DUAL;";
  connection.query(sql_query, (error, result) => {
    if (error) throw error;
    res.json({
      result,
    });
  });
});

app.post("/izracunplace.html", (req, res) => {
  var idZaposlenik = req.body.idZaposlenik;
  var Mjesec = req.body.Mjesec;
  var Godina = req.body.Godina;
  const sql_query =
    "SELECT placa_mjesec(" +
    idZaposlenik +
    ", " +
    Mjesec +
    ", " +
    Godina +
    ") FROM DUAL;";
  connection.query(sql_query, (error, result) => {
    if (error) throw error;
    res.json({
      result,
    });
  });
});

app.post("/sortiranjeauta.html", (req, res) => {
  var Cijena = req.body.Cijena;
  const sql_query =
    "CALL sortiranje_auta(" +
    Cijena +
    ", @bitno_prodati, @manje_bitno); SELECT @bitno_prodati, @manje_bitno;";
  connection.query(sql_query, (error, result) => {
    if (error) throw error;
    res.json({ result });
  });
});

app.post("/troskovikupca.html", (req, res) => {
  var idKupac = req.body.idKupac;
  const sql_query =
    "CALL kupac_potrosio(" +
    idKupac +
    ", @suma_auto, @suma_servis);SELECT @suma_auto, @suma_servis;";
  connection.query(sql_query, (error, result) => {
    if (error) throw error;
    res.json({ result });
  });
});
