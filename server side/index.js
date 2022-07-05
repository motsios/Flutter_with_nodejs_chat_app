const WebSocket = require("ws");

const wss = new WebSocket.Server({ port: 5556 });

wss.on("connection", ws => {
    console.log("New client connected")
    ws.on("message", message => {
        wss.clients.forEach(function each(client) {
            if (client !== ws && client.readyState === WebSocket.OPEN) {
                client.send("My friend: " + message);
            }
            if (client == ws) {
                client.send("Me: " + message);
            }
        });
    });
});