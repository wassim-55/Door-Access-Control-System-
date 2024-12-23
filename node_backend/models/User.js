const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  uid: { type: String, required: true, unique: true},
  name: { type: String, required: true},
  createdAt: { type: Date, default: Date.now }, 
});

module.exports = mongoose.model('User', UserSchema);
