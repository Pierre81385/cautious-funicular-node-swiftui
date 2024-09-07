const express = require('express');
const mongoose = require('mongoose');
const http = require('http'); // Import HTTP module to work with Socket.IO
const { Server } = require('socket.io');
const bodyParser = require('body-parser');
const app = express();
const port = 3000;
const server = http.createServer(app);
const io = new Server(server);
const dotenv = require("dotenv");

dotenv.config();

app.use(bodyParser.json());

app.get('/', (req, res) => {
  res.send('Hello, World!');
});

const UserRouter = require("./routes/UserRoutes");
app.use("/users", (req, res, next) => {
  req.io = io; // Attach io to the request object
  next();
}, UserRouter);

mongoose.connect(process.env.MONGODB_URI);
const connection = mongoose.connection;
connection.once("open", () => {
  console.log("MongoDB database connection established successfully");
});

// Listen for Socket.IO connections
io.on('connection', (socket) => {
  console.log('A user connected');

  //need to implement socket event

  socket.on('authenticated', (data) => {
    console.log(`User Login: ${data.username}`);
    io.emit("logged in")
  });

  // // Listen for when a user is updated
  // socket.on('userUpdated', (updatedUser) => {
  //   console.log('User updated:', updatedUser);
  // });

  // // Listen for when a user is deleted
  // socket.on('userDeleted', (deletedUser) => {
  //   console.log('User deleted:', deletedUser);
  // });

  // Handle disconnection
  socket.on('disconnect', () => {
    console.log('User disconnected');
  });
});

// Start the server
server.listen(port, () => {
  console.log(`Server running at http://localhost:${port}/`);
});

