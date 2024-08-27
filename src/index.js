const express = require('express');
const mongoose = require('mongoose');
const axios = require('axios');
const { ethers } = require('ethers');
require('dotenv').config();

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 3000;
const rollupServer = process.env.ROLLUP_HTTP_SERVER_URL;

// Connect to MongoDB
const connectDB = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI, {
            useNewUrlParser: true,
            useUnifiedTopology: true,
        });
        console.log('MongoDB connected');
    } catch (error) {
        console.error('MongoDB connection error:', error.message);
        process.exit(1);
    }
};

// Define User model
const UserSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
    },
    phoneNumber: {
        type: String,
        required: true,
        unique: true,
    },
    email: {
        type: String,
        required: true,
        unique: true,
    },
    walletAddress: {
        type: String,
        required: true,
        unique: true,
    },
    createdAt: {
        type: Date,
        default: Date.now,
    },
});

const User = mongoose.model('User', UserSchema);

// Middleware to parse JSON bodies
app.use(express.json());

// Function to send notice to Cartesi Rollup
const sendNotice = async (message) => {
    try {
        const response = await axios.post(`${rollupServer}/notice`, {
            payload: ethers.utils.hexlify(ethers.utils.toUtf8Bytes(message)),
        });
        console.log(`✅ Notice sent: ${response.status} - ${response.data}`);
    } catch (error) {
        console.error(`❌ Failed to send notice: ${error.message}`);
    }
};

// Function to send report to Cartesi Rollup
const sendReport = async (message) => {
    try {
        const response = await axios.post(`${rollupServer}/report`, {
            payload: ethers.utils.hexlify(ethers.utils.toUtf8Bytes(message)),
        });
        console.log(`✅ Report sent: ${response.status} - ${response.data}`);
    } catch (error) {
        console.error(`❌ Failed to send report: ${error.message}`);
    }
};

// Route to register a new user (Save user information)
app.post('/api/register', async (req, res) => {
    try {
        const { name, phoneNumber, email, walletAddress } = req.body;
        const newUser = new User({ name, phoneNumber, email, walletAddress });

        await newUser.save();

        const noticeMessage = `User ${name} registered with email ${email}`;
        await sendNotice(noticeMessage);

        res.status(201).json({ success: true, data: newUser });
    } catch (error) {
        const errorMessage = `Error registering user: ${error.message}`;
        await sendReport(errorMessage);

        res.status(400).json({ success: false, error: error.message });
    }
});

// Route to fetch all registered users (Fetch list of users)
app.get('/api/users', async (req, res) => {
    try {
        const users = await User.find();
        res.status(200).json({ success: true, data: users });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Route to fetch a user by phone number
app.get('/api/users/phone/:phoneNumber', async (req, res) => {
    try {
        const user = await User.findOne({ phoneNumber: req.params.phoneNumber });
        if (!user) {
            return res.status(404).json({ success: false, message: 'User not found' });
        }
        res.status(200).json({ success: true, data: user });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Route to fetch a user by email
app.get('/api/users/email/:email', async (req, res) => {
    try {
        const user = await User.findOne({ email: req.params.email });
        if (!user) {
            return res.status(404).json({ success: false, message: 'User not found' });
        }
        res.status(200).json({ success: true, data: user });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Route to fetch a user by wallet address
app.get('/api/users/wallet/:walletAddress', async (req, res) => {
    try {
        const user = await User.findOne({ walletAddress: req.params.walletAddress });
        if (!user) {
            return res.status(404).json({ success: false, message: 'User not found' });
        }
        res.status(200).json({ success: true, data: user });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Connect to the database and start the server
connectDB().then(() => {
    app.listen(PORT, () => {
        console.log(`Server running on http://localhost:${PORT}`);
    });
});
