const express = require('express');
const http = require('http'); // Import HTTP module to work with Socket.IO
const { Server } = require('socket.io');
const app = express();
const port = 3000;
const server = http.createServer(app);
const io = new Server(server);
const { MongoClient, ServerApiVersion } = require('mongodb');
const dotenv = require("dotenv");

dotenv.config();

// Create a MongoClient with a MongoClientOptions object to set the Stable API version
const client = new MongoClient(process.env.MONGODB_URI, {
  serverApi: {
    version: ServerApiVersion.v1,
    strict: true,
    deprecationErrors: true,
  }
});
async function run() {
  try {
    // Connect the client to the server	(optional starting in v4.7)
    await client.connect();
    // Send a ping to confirm a successful connection
    await client.db("cautious_funicular_db").command({ ping: 1 });
    console.log("Pinged your deployment. You successfully connected to MongoDB!");
  } finally {
    // Ensures that the client will close when you finish/error
    await client.close();
  }
}

run().catch(console.dir);

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

