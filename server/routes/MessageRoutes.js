const router = require("express").Router();
const Message = require("../models/MessageModel");

router.route('/send').post( async (req, res) => {
    console.log("preparing to send message!")
    try {
        const newMessage = new Message(req.body); // Create new User instance from request body
        const sentMessage = await newMessage.save(); // Save to MongoDB
        res.status(200).json(sentMessage);
        req.io.emit('messageSent', sentMessage);
      } catch (error) {
        res.status(400).json({ message: 'Error sending message', error: error.message });
      }
  });

router.route("/:id").get( (req, res) => {
    const { id } = req.params.id;
    Message.findById(req.params.id)
    .then((message) => res.status(200).json(message))
    .catch((err) => res.status(400).json("Error: " + err));
  });

  router.route("/:id").delete( (req, res) => {
    const { id } = req.params;
    Message.findByIdAndDelete(id)
      .then(() => {
        res.status(200).json("Message deleted!");
        req.io.emit('messageDeleted', { id });
      })
      .catch((err) => {
        res.status(400).json("Error: " + err);
      });
  });
  
    module.exports = router;