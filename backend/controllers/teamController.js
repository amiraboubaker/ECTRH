const Team = require('../models/team');
const teamDao = require('../dao/teamDao');

// Controller to get all teams
const getAllTeams = (req, res) => {
    teamDao.getAllTeams((err, teams) => {
        if (err) {
            console.error('Error fetching teams:', err);
            return res.status(500).json({ error: 'Error fetching teams' });
        }
        res.status(200).json(teams);
    });
};

// Controller to add a new team
const addTeam = async (req, res) => {
    try {
        console.log('Received request to add team:', req.body);
        const { name, head } = req.body;

        // Use the uploaded file path if multer has processed the file
        const imagePath = req.file ? req.file.path : 'uploads/default.png';

        // Create new team instance
        const newTeam = new Team(null, name, imagePath, head);

        // Insert team into the database
        const result = await teamDao.addTeam(newTeam);

        console.log('Team added:', result);
        res.status(201).json({ message: 'Team added successfully', teamId: result.insertId });
    } catch (error) {
        console.error('Error adding team:', error);
        res.status(500).json({ error: 'Internal Server Error' });
    }
};

// Controller to update a team
const updateTeam = async (req, res) => {
    try {
        const { id, name, head } = req.body;

        // Use the uploaded file path if multer has processed the file
        const imagePath = req.file ? req.file.path : undefined; // Optional for image update
        const updatedTeam = new Team(id, name, imagePath, head);

        const result = await teamDao.updateTeam(updatedTeam);
        res.status(200).json({ message: 'Team updated successfully', result });
    } catch (error) {
        console.error('Error updating team:', error);
        res.status(500).json({ error: 'Error updating team' });
    }
};

// Controller to delete a team
const deleteTeam = async (req, res) => {
    try {
        const { id } = req.body;

        const result = await teamDao.deleteTeam(id);
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Team not found' });
        }
        res.status(200).json({ message: 'Team deleted successfully' });
    } catch (error) {
        console.error('Error deleting team:', error);
        res.status(500).json({ error: 'Error deleting team' });
    }
};

module.exports = {
    getAllTeams,
    addTeam,
    updateTeam,
    deleteTeam,
};
