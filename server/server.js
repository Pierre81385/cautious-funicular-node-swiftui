const express = require('express');
const http = require('http'); // Import HTTP module to work with Socket.IO
const { Server } = require('socket.io');
const app = express();
const port = 3000;
const server = http.createServer(app);
const io = new Server(server);

app.get('/', (req, res) => {
  res.send('Hello, World!');
});

// Listen for Socket.IO connections
io.on('connection', (socket) => {
  console.log('A user connected');

  // Example: Listen for a custom event
  socket.on('chat message', (msg) => {
    console.log('Message: ' + msg);

    // Emit the message to all connected clients
    io.emit('chat message', msg);
  });

  // Handle disconnection
  socket.on('disconnect', () => {
    console.log('User disconnected');
  });
});

// Start the server
server.listen(port, () => {
  console.log(`Server running at http://localhost:${port}/`);
});

