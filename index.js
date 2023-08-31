// import { io } from 'socket.io-client';
const {io} = require("socket.io-client")

const namecheap_socket = io("wss://mrptyltd.com");



namecheap_socket.on("command", message => {
    console.log("Got message from namecheap: " + message);
    if( send(message) == -1 ) console.log("Couldn't forward command to metatrader");
    else console.log("forwarded command to metatrader");
})

console.log("emitting");
namecheap_socket.emit("command", "health-check")



var net = require('net');
let metatrader_socket = null;
let EOF = "--EOF"; 
var PORT = 6000;


const send = (messsage) => {
    if( metatrader_socket == null ) return -1;
    messsage += EOF;
    console.log("sending to metatrader: ", messsage);
    metatrader_socket.write(messsage);
}


net.createServer(function (sock) {
    console.log('Connected to Metatrader: ' + sock.remoteAddress + ':' + sock.remotePort);
    sock.on('data', function (data) {
        console.log('Health check message: ' + sock.remoteAddress + ': ' + data);
        try {
            send('Health check response: ' + data);
        } catch (e) {
            console.log("Health check Error ", e);
        }
    });

    // const timerId = setInterval( () => send("timer message"), 3000 );

    metatrader_socket = sock;

    sock.on('close', function (data) {
        console.log('Connection to metatraer closed: ' + sock.remoteAddress + ' ' + sock.remotePort);
        // clearInterval(timerId);
    });

}).listen(PORT);