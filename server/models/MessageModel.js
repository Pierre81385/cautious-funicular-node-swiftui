const mongoose = require('mongoose');
const { Schema } = mongoose;

const messageSchema = new Schema(
    {
        _id: {
            type: String,
            required: true
        },
        sender: {
            type: String, // Can be user ID or email
            required: true,
        },
        textContent: {
            type: String,
            required: false,
        },
        mediaContent: {
            type: [String], // Array of media file URLs (optional)
            required: false
        },
    },
    { timestamps: true } // Adds `createdAt` and `updatedAt` for each message
);

// Export only the schema, not the model
module.exports = messageSchema;