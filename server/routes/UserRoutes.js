const router = require("express").Router();
const User = require("../models/UserModel");
const { io } = require("../server");

//create
router.route('/create').post( async (req, res) => {
    try {
        const newUser = new User(req.body); // Create new User instance from request body
        const savedUser = await newUser.save(); // Save to MongoDB
        res.status(201).json(savedUser);
        io.emit('userCreated', savedUser);
      } catch (error) {
        res.status(400).json({ message: 'Error creating user', error: error.message });
      }
  });

//read all
router.route("/").get( (req, res) => {
  User.find()
    .then((users) => res.status(200).json(users))
    .catch((err) => res.status(400).json("Error: " + err));
});

//read one
router.route("/:id").get( (req, res) => {
  User.findById(req.params.id)
    .then((user) => res.status(200).json(user))
    .catch((err) => res.status(400).json("Error: " + err));
});

//update
router.route("/:id").put( async (req, res) => {
  console.log(req);
  await User.findOneAndUpdate(
    { name: req.params.id },
    {
      $set: {
        username: req.body.username,
        email: req.body.email,
        password: req.body.password,
      },
    },
    {
      new: true,
    }
  )
    .then((data) => {
      res.status(200).json({ message: "Successfully updated user!" });
      io.emit('userUpdated', updatedUser);
    })
    .catch((err) => {
      res.status(400).json("Error: " + err);
    });
});

//delete
router.route("/:id").delete( (req, res) => {
  const { id } = req.params;
  User.findByIdAndDelete(id)
    .then(() => {
      res.status(200).json("User deleted!");
      io.emit('userDeleted', { id });
    })
    .catch((err) => {
      res.status(400).json("Error: " + err);
    });
});


  module.exports = router;