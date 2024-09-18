const mongoose = require('mongoose');
const { Schema } = mongoose;

const messageSchema = require("./MessageModel");
// Chat schema that contains an array of messages
const chatSchema = new Schema(
    {
        identifier: {
            type: Number,
            required: true,
            unique: true
        },
        participants: {
            type: [String], // Array of user IDs (or names/emails)
            required: true
        },
        messages: [messageSchema], // Array of messages
        isPrivate: {
            type: Boolean,
            required: true
        },
        accessCode: {
            type: Number,
            required: true,
        },
        createdAt: {
            type: Date,
            default: Date.now
        },
        updatedAt: {
            type: Date,
            default: Date.now
        }
    },
    { timestamps: true } // Adds `createdAt` and `updatedAt` fields automatically
);

const Chat = mongoose.model('Chat', chatSchema);

module.exports = Chat;
