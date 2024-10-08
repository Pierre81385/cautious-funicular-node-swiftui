const router = require("express").Router();
const Chat = require("../models/ChatModel");
const Message = require("../models/MessageModel");

//http://localhost:3000/chats/new
router.route('/new').post( async (req, res) => {
    try {
        const newChat = new Chat(req.body); // Create new User instance from request body
        const chatRoom = await newChat.save(); // Save to MongoDB
        res.status(201).json(chatRoom);
      } catch (error) {
        res.status(400).json({ message: 'Error creating chatroom', error: error.message });
      }
  });

//http://localhost:3000/chats/{chat.identifier}
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

//http://localhost:3000/chats/{chat.identifier}/update
router.route('/:identifier/update').put(async (req, res) => {
  try {
      const updatedChat = await Chat.findOneAndUpdate(
          { identifier: req.params.identifier },
          {
              $set: {
                  identifier: req.body.identifier,
                  participants: req.body.participants,
                  messages: req.body.messages, 
                  isPrivate: req.body.isPrivate,
                  accessCode: req.body.accessCode
              }
          },
          { new: true } // Return the updated document
      );

      // Send the response
      res.status(200).json({ message: "Successfully updated chat!" });
  } catch (err) {
      res.status(400).json("Error: " + err);
  }
});

module.exports = router;
