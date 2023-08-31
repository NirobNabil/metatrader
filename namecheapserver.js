var express = require('express');
var app = require('express')();
var http = require('http').createServer(app);
var io = require('socket.io')(http);
var fs = require('fs');

var util = require('util');
var log_file = fs.createWriteStream(__dirname + '/debug.log', {flags: 'w'});
var log_stdout = process.stdout;

console.log = function (d) { //
    log_file.write(util.format(d) + '\n');
    log_stdout.write(util.format(d) + '\n');
};

app.use(express.json());

app.get('/server', (req, res) => {
    res.sendFile(__dirname + '/index.html');
});
app.post('/alert-hook-sell', (req, res) => {
    console.log(req.body);
    res.send("Got it sell");
    io.emit("chat message", "sell it")
});
app.post('/alert-hook-buy', (req, res) => {
    console.log(req.body);
    res.send("Got it buy");
    io.emit("chat message", "buy it")
});


io.on('connection', (socket) => {
    socket.on('chat message', (msg) => {
        console.log(msg);
        io.emit('chat message', msg);
    });
});


http.listen(3000, () => {
    console.log('listening on *:3000');
});
