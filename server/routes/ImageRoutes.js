const router = require("express").Router();
const Img = require("../models/ImageModel");
const multer = require('multer');

// Set up multer for file upload handling
const storage = multer.memoryStorage(); // Store image in memory as Buffer
const upload = multer({ storage: storage });

//http://localhost:3000/imgs/upload
router.post("/upload", upload.single('image'), async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).send('No file uploaded.');
        }
        
        // Create new Image document
        const newImage = new Img({
            img: {
                data: req.file.buffer,          // Store image as buffer
                contentType: req.file.mimetype  // Store content type
            }
        });

        // Save image to MongoDB
        const savedImage = await newImage.save();
        return res.status(200).send({ message: 'Image uploaded successfully!', imageId: savedImage._id });
    
    } catch (err) {
        return res.status(500).send('Error saving image.');
    }
});

//http://localhost:3000/imgs/id
router.route('/:id').get(async (req, res) => {
    try {
        const imageId = req.params.id;
        const image = await Img.findById(imageId);
    
        if (!image) {
          return res.status(404).send({ error: 'Image not found' });
        }
    
        // Ensure the image data is base64 encoded before sending it
        const base64Image = image.img.data.toString('base64');
        
        res.status(200).json({
          _id: image._id,
          img: {
            data: base64Image, // Sending the image data as a base64 string
            contentType: image.img.contentType
          }
        });
      } catch (error) {
        res.status(500).send({ error: 'Error fetching image' });
      }
});


module.exports = router;
