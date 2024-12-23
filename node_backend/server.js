const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const uidRoutes = require('./routes/uidRoutes');
const dotenv = require('dotenv');
dotenv.config();

const app = express();
app.use(express.json());
app.use(bodyParser.json());
app.use('/api', uidRoutes);

mongoose.connect(process.env.MONGO_URI, { retryWrites: true, w: 'majority' })
.then(() => console.log('MongoDB connected'))
.catch((err) => console.error('MongoDB connection error:', err));

app.listen(5000, '0.0.0.0', () => { console.log(`Server running on http://0.0.0.0:5000`); });  