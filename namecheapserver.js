var express = require('express');
var app = require('express')();
var http = require('http').createServer(app);
var io = require('socket.io')(http);
var fs = require('fs');

var util = require('util');
var log_file = fs.createWriteStream(__dirname + '/debug.log', {flags: 'w'});
var log_stdout = process.stdout;

// eta just define kortese je console.log diye kichu output korle oita debug.log file e save hobe
console.log = function (d) { //
    log_file.write(util.format(d) + '\n');
    log_stdout.write(util.format(d) + '\n');
};

app.use(express.json());

// this is to just check if the server is running
app.get('/server', (req, res) => {
    res.sendFile(__dirname + '/index.html');
});


// this is the main function. tradingview theke je data ashe oita req.body te thake. then ekhan theke 
// req.body er content ta JSON string hishebe socket er vitor diye vscode er node server e pathay
// io.emit is a function of socket that sends any data through socket
app.post('/alert-hook-buy', (req, res) => {
    console.log(req.body);
    res.send(req.body);
    io.emit("command", JSON.stringify(req.body));
});


// vscode er shathe socket connection establish hole eta run hoy
io.on('connection', (socket) => {
    socket.on('command', (msg) => {
        console.log(msg);
        io.emit('command', msg);
    });
});


// eta just 3000 port e listen korte thake for any request from tradingview
http.listen(3000, () => {
    console.log('listening on *:3000');
});