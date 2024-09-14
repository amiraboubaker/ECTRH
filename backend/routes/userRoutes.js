const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

// Route for user registration
router.post('/signup', userController.signup);

// Route for user sign-in
router.post('/signin', userController.signin);

module.exports = router;
