const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const ImageSchema = new Schema(
    {
      img: {
            data: Buffer,
            contentType: String
          }
    },
  );

  const Img = mongoose.model('Image', ImageSchema);
  module.exports = Img