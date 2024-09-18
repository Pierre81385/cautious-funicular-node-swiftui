const router = require("express").Router();
const Chat = require("../models/ChatModel");
const Message = require("../models/MessageModel");

router.route('/new').post( async (req, res) => {
    try {
        const newChat = new Chat(req.body); // Create new User instance from request body
        const chatRoom = await newChat.save(); // Save to MongoDB
        res.status(201).json(chatRoom);
      } catch (error) {
        res.status(400).json({ message: 'Error creating chatroom', error: error.message });
      }
  });

router.route('/:identifier').get(async (req, res) => {
    try {
        const chat = await Chat.findOne({ identifier: req.params.identifier }); // Find chat by identifier
        if (!chat) {
            return res.status(404).json({ message: "Chat not found" });
        }
        res.status(200).json(chat);
    } catch (err) {
        res.status(400).json("Error: " + err.message);
    }
});

router.route('/:id/new').put( async (req, res) => {
    try {
        const updateMessage = await Chat.findOneAndUpdate(
          { _id: req.params.id },
          {
            $push: {
                message: req.body.message
                //need to test if I need to send the message or the entire chat object
            },
          },
          {
            new: true,
          }
        );
    
        // Send the response
        res.status(200).json({ message: "Successfully updated user!" });
    
        // Emit the WebSocket event after the response is sent
        req.io.emit('userUpdated', updatedUser);
      } catch (err) {
        res.status(400).json("Error: " + err);
      }
});

module.exports = router;
