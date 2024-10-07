const router = require("express").Router();
const User = require("../models/UserModel");

//http://localhost:3000/users/new
router.route('/new').post( async (req, res) => {
    try {
        const newUser = new User(req.body); // Create new User instance from request body
        const savedUser = await newUser.save(); // Save to MongoDB
        res.status(201).json(savedUser);
        req.io.emit('userCreated', savedUser);
      } catch (error) {
        res.status(400).json({ message: 'Error creating user', error: error.message });
      }
  });

//http://localhost:3000/users/
router.route("/").get( (req, res) => {
  User.find()
    .then((users) => res.status(200).json(users))
    .catch((err) => res.status(400).json("Error: " + err));
});

//http://localhost:3000/users/{user._id}
router.route("/:id").get( (req, res) => {
  User.findById(req.params.id)
    .then((user) => res.status(200).json(user))
    .catch((err) => res.status(400).json("Error: " + err));
});

//http://localhost:3000/users/user/{user.username}=
router.route("/user/:username").get(async (req, res) => {
  try {
    console.log(req.params.username); // Log the username to check the incoming request

    const user = await User.findOne({ username: req.params.username });

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.status(200).json(user);
  } catch (error) {
    res.status(500).json({ message: "Error retrieving user", error: error.message });
  }
});

//http://localhost:3000/users/{user._id}
router.route("/:id").put(async (req, res) => {
  try {
    const updatedUser = await User.findOneAndUpdate(
      { _id: req.params.id },
      {
        $set: {
          identifier: req.body.identifier,
          online: req.body.online,
          username: req.body.username,
          email: req.body.email,
          password: req.body.password,
          avatar: req.body.avatar,
          uploads: req.body.uploads
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

//http://localhost:3000/users/{user._id}
router.route("/:id").delete( (req, res) => {
  const { id } = req.params;
  User.findByIdAndDelete(id)
    .then(() => {
      res.status(200).json("User deleted!");
      req.io.emit('userDeleted', { id });
    })
    .catch((err) => {
      res.status(400).json("Error: " + err);
    });
});


  module.exports = router;