// routes/teamRoutes.js

const express = require('express');
const router = express.Router();
const teamController = require('../controllers/teamController');

router.get('/getAllTeams', teamController.getAllTeams);
router.post('/addTeam', teamController.addTeam);
router.put('/updateTeam', teamController.updateTeam);
router.delete('/deleteTeam', teamController.deleteTeam);

module.exports = router;
