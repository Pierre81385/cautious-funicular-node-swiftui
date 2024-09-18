const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const messageSchema = new Schema(
    {
        id: {
            type: Number,
            unique: true,
            required: true
        },
        sender: {
            type: String,
            required: true,
        },
        textContent: {
            type: String,
            required: false,
        },
        mediaContent: {
            type: [String],
            required: false
        },
        dateCreated: {
            type: Date,
            default: Date.now
        }
    }
);

// Export the schema, not the model
module.exports = messageSchema;