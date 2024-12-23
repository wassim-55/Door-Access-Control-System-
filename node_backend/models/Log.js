const mongoose = require('mongoose');

const LogSchema = new mongoose.Schema({
  uid: { type: String, required: true },
  name: { type: String },
  status: { type: String, required: true },
  timestamp: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Log', LogSchema);