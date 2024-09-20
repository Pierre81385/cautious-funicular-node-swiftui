const mongoose = require('mongoose');
const { Schema } = mongoose;

const messageSchema = require("./MessageModel")

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
        messages: {
            type: [messageSchema], // Embed array of message subdocuments
            required: false
        },
        isPrivate: {
            type: Boolean,
            required: true
        },
        accessCode: {
            type: Number,
            required: true,
        },
    },
    { timestamps: true } // Adds `createdAt` and `updatedAt` fields automatically
);
const Chat = mongoose.model('Chat', chatSchema);
module.exports = Chat;
