const express = require("express");
const mysql = require("mysql");
const app = express();
const port = "5050";
const bodyParser = require("body-parser");
const { query } = require("express");
const connection = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "root",
  database: "isplata_placa",
});
connection.connect((err) => {
  if (err) throw err;
  console.log("databaseconnected");
});
app.listen("5050", () => {
  console.log("server started");
});
app.use(express.static(__dirname));
app.use(bodyParser.urlencoded({ extended: true }));

app.get("/", (req, res) => {
  res.sendFile(__dirname + "/index.html");
  /* connection.query("SELECT * FROM isplata_placa.pozicija",(error, result)=>{
        if (error) throw error
        res.json({
            result
        })
    })*/
});

app.post("/", (req, res) => {
  var subName = req.body.yourname;
  var subEmail = req.body.youremail;
  res.send(
    "Hello " + subName + ", Thank you for subcribing. You email is " + subEmail
  );
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
