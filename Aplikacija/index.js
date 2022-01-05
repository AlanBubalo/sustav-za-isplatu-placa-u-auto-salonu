const express = require("express")
const mysql = require("mysql")
const app = express()
const port = "5050"
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
app.get("/data",(req, res)=>{
    connection.query("SELECT * FROM isplata_placa.pozicija",(error, result)=>{
        if (error) throw error
        res.json({
            result
        })
    })
})
app.listen(port, ()=>{
    console.log("server started")
})