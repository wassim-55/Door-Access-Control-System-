const Log = require('../models/Log');
const User = require('../models/User');
const admin = require('firebase admin sdk');

// Initialize Firebase Admin SDK
const serviceAccount = require('firebase admin sdk'); // Path to your Firebase service account JSON
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

exports.validateUID = async (req, res) => {
  const { uid } = req.body;
  try {
      // Find the user by UID
      const user = await User.findOne({ uid });

      if (!user) {
          // If UID is not found, respond with 404
          res.status(404).json({ success: false, message: 'UID not found' });
          return;
      }

      const status = 'Granted';

      // Log access attempt
      const log = new Log({
          uid,
          name: user.name,
          status
      });
      await log.save();

      // Send notification about the access attempt
      const message = {
          notification: {
              title: 'Access Attempt',
              body: `UID: ${uid} - ${status}`
          },
          topic: 'access-updates'
      };
      const response = await admin.messaging().send(message);
      console.log('Notification sent successfully:', response);

      // Respond with 200 for access granted
      res.status(200).json({ success: true, message: 'Access granted' });
  } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Server error' });
  }
};


exports.getLogsForUser = async (req, res) => {
  const { uid } = req.params;

  try {
    const logs = await Log.find({ uid }).sort({ timestamp: -1 });
    res.status(200).json(logs);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
};

  exports.addUser = async (req, res) => {
    const { uid, name } = req.body;
  
    try {
      // Check if the user already exists
      const existingUser = await User.findOne({ uid });
      if (existingUser) {
        return res.status(400).json({ message: 'User already exists' });
      }
  
      const newUser = new User({ uid, name});
  
      await newUser.save();
  
      res.status(201).json({
        message: 'User added successfully',
        user: newUser
      });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Server error' });
    }
  };

  exports.removeUser = async (req, res) => {
    const { uid } = req.params;
  
    try {
      const deletedUser = await User.findOneAndDelete({ uid });
  
      if (!deletedUser) {
        return res.status(404).json({ message: 'User not found' });
      }
  
      res.status(200).json({
        message: 'User removed successfully',
        user: deletedUser
      });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Server error' });
    }
  };

  // Fetch all users
exports.getUsers = async (req, res) => {
  try {
    const users = await User.find(); // Fetch all users from the database
    res.status(200).json(users);  // Send the users list as the response
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });  // Handle server errors
  }
};

// Controller to update a user
exports.updateUser = async (req, res) => {
  const { uid } = req.params;              // Extract UID from URL parameters
  const { name } = req.body;               // Extract new user details from the request body

  try {
    const user = await User.findOneAndUpdate(
      { uid },                             // Find user by UID
      { name },                            // Update user's name (extend this for other fields)
      { new: true }                        // Return the updated user
    );

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json({
      message: 'User updated successfully',
      user,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error while updating user' });
  }
};

exports.openDoor = async (req, res) => {
  const { uid } = req.body;

  try {
    // Check if the user exists
    const user = await User.findOne({ uid });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Log the "Open Door" event
    const log = new Log({
      uid: user.uid,
      name: user.name,
      status: 'Granted',
      timestamp: new Date(),
    });

    await log.save();

    return res.status(200).json({ message: 'Door opened and log recorded successfully.' });
  } catch (error) {
    console.error('Error opening door:', error);
    return res.status(500).json({ message: 'Server error' });
  }
};

// Fetch all logs
exports.getAllLogs = async (req, res) => {
  try {
    const logs = await Log.find();
    res.status(200).json(logs);
  } catch (error) {
    res.status(500).json({ message: "Failed to fetch logs", error: error.message });
  }
};