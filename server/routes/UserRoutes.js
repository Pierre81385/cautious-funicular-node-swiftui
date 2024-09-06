const router = require("express").Router();
const { MongoClient, ServerApiVersion } = require('mongodb');
const client = new MongoClient(process.env.MONGODB_URI, {
    serverApi: {
      version: ServerApiVersion.v1,
      strict: true,
      deprecationErrors: true,
    }
  });

router.route('/user').post( async (req, res) => {
    try {
      const newUser = {
        name: req.body.name,
        email: req.body.email,
        password: req.body.password,
        registeredAt: new Date()
      };
  
      // Insert the new user document into the 'user' collection
      const database = client.db('cautious_funicular_db');
      const collection = database.collection('users');
      const result = await collection.insertOne(newUser);
  
      // Respond with the newly created user's ID
      res.status(201).json({ message: 'User created', userId: result.insertedId });
    } catch (error) {
      console.error('Error inserting user:', error);
      res.status(500).json({ message: 'Error inserting user', error: error.message });
    }
  });

  module.exports = router;