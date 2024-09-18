const router = require("express").Router();
const Message = require("../models/MessageModel");

router.route('/new').post( async (req, res) => {
    try {
        const newMessage = new Message(req.body); // Create new User instance from request body
        const sentMessage = await newMessage.save(); // Save to MongoDB
        res.status(201).json(sentMessage);
        req.io.emit('messageSent', sentMessage);
      } catch (error) {
        res.status(400).json({ message: 'Error sending message', error: error.message });
      }
  });

router.route("/").get( (req, res) => {
    Message.find()
      .then((messages) => res.status(200).json(messages))
      .catch((err) => res.status(400).json("Error: " + err));
  });

router.route("/:chat/:id").delete( (req, res) => {
    const { chat } = req.params.chat
    const { id } = req.params.id;
    Message.findByIdAndDelete(id)
      .then(() => {
        res.status(200).json("Message deleted!");
        req.io.emit('messageDeleted', { chat });
      })
      .catch((err) => {
        res.status(400).json("Error: " + err);
      });
  });