const express = require("express")
const mysql = require("mysql")
const app = express()
const port = "5050"
const bodyParser = require("body-parser");
const connection = mysql.createConnection({
 host: 'localhost',
 user: 'root',
 password: 'root',
 database: 'isplata_placa',
})
connection.connect((err)=>{
    if (err) throw err
    console.log ("databaseconnected")

})
app.listen("5050", ()=>{
    console.log("server started")
}) 
app.use(express.static(__dirname))
app.use(bodyParser.urlencoded({ extended: true }))

 app.get("/",(req, res)=>{
     res.sendFile(__dirname+"/index.html")
   /* connection.query("SELECT * FROM isplata_placa.pozicija",(error, result)=>{
        if (error) throw error
        res.json({
            result
        })
    })*/
}) 

app.post("/", (req, res) => {
    var subName = req.body.yourname
  var subEmail = req.body.youremail;
 res.send("Hello " + subName + ", Thank you for subcribing. You email is " + subEmail);
  });
  
