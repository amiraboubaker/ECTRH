const express = require('express');
const router = express.Router();
const multer = require('multer'); // Assuming you're using multer for file uploads
const teamController = require('../controllers/teamController');

const upload = multer({ dest: 'uploads/' });

router.get('/getAllTeams', teamController.getAllTeams);
router.post('/addTeam', upload.single('image'), teamController.addTeam); // Assuming image upload
router.put('/updateTeam', upload.single('image'), teamController.updateTeam);
router.delete('/deleteTeam', teamController.deleteTeam);

module.exports = router;
