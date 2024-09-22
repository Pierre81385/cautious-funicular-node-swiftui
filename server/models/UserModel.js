const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const userSchema = new Schema(
  {
    //this is a unique number generated by a hash function.  When a user initiates a chat their identifiers are 
    //combined to form the Chat identifier.  This way the chat between two users is identified the same no matter
    //which user initated it.
    identifier: {
      type: Number, 
      required: true,
      unique: true
    },
    online: {
      type: Boolean,
      required: [true, "Online status must be set."]
    },
    username: {
      type: String,
      required: [true, "Your username is required"],
      unique: true, // Ensure unique usernames
      trim: true,   // Trim whitespace
    },
    email: {
      type: String,
      required: [true, "Your email address is required"],
      unique: true, // Ensure unique emails
      match: [/.+@.+\..+/, "Must match an email address!"], // Simple regex for email validation
    },
    password: {
      type: String,
      required: [true, "Your password is required"],
      minlength: 5, // Minimum password length
    },
  },
  { timestamps: true } // Adds createdAt and updatedAt timestamps automatically
);

const User = mongoose.model("User", userSchema);

module.exports = User;