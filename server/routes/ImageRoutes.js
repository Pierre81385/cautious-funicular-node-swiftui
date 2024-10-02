const router = require("express").Router();
const Img = require("../models/ImageModel");
const multer = require('multer');

// Set up multer for file upload handling
const storage = multer.memoryStorage(); // Store image in memory as Buffer
const upload = multer({ storage: storage });

// Route for uploading image
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

module.exports = router;
