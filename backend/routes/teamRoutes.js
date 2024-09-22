const express = require('express');
const router = express.Router();
const multer = require('multer'); // Assuming you're using multer for file uploads
const teamController = require('../controllers/teamController');

const upload = multer({ dest: 'uploads/' });

// Route to get all teams

router.get('/getAllTeams', teamController.getAllTeams);

// Route to add a new team

router.post('/addTeam', upload.single('image'), teamController.addTeam); 

// Route to add a new team

router.put('/updateTeam', upload.single('image'), teamController.updateTeam);

// Route to add a new team

router.delete('/deleteTeam', teamController.deleteTeam);

module.exports = router;
