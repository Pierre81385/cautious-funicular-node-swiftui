const router = require("express").Router();
const User = require('../models/UserModel')

router.route('/user').post( async (req, res) => {
    try {
        const newUser = new User(req.body); // Create new User instance from request body
        const savedUser = await newUser.save(); // Save to MongoDB
        res.status(201).json(savedUser);
      } catch (error) {
        res.status(400).json({ message: 'Error creating user', error: error.message });
      }
  });

  module.exports = router;