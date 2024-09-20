const team = require('../models/team');
const teamDao = require('../dao/teamDao');

// Controller to get all teams
const getAllTeams = (req, res) => {
    teamDao.getAllTeams((err, teams) => {
        if (err) {
            console.error('Error fetching teams:', err);
            res.status(500).json({ error: 'Error fetching teams' });
        } else {
            res.status(200).json(teams);
        }
    });
};

// Controller to add a new team

const addTeam = async (req, res) => {
    try {
        console.log('Received request to add team:', req.body);
        const { name, head } = req.body;  // Don't get imagePath here

        // File path (use uploaded image or fallback to default)
        const imagePath = req.file ? req.file.path : 'uploads/default.png';

        // Create new team instance
        const newteam = new team(null, name,head);

        // Insert team into the database
        const result = await teamDao.addTeam(newteam);  // Using teamDao to add

        console.log('team added:', result);
        res.status(200).json(result);
    } catch (error) {
        console.error('Error adding team:', error);
        res.status(500).json({ error: 'Internal Server Error' });
    }
};

// Controller to update an team
const updateTeam = (req, res) => {
    const { id, name, imagePath, head } = req.body;
    const updatedteam = new team(id, name, imagePath, head);

    teamDao.updateTeam(updatedteam, (err, result) => {
        if (err) {
            console.error('Error updating team:', err);
            res.status(500).json({ error: 'Error updating team' });
        } else {
            res.status(200).json({ message: 'team updated successfully' });
        }
    });
};

// Controller to delete an team
const deleteTeam = (req, res) => {
    const { id } = req.body;

    teamDao.deleteTeam(id, (err, result) => {
        if (err) {
            console.error('Error deleting team:', err);
            res.status(500).json({ error: 'Error deleting team' });
        } else {
            res.status(200).json({ message: 'team deleted successfully' });
        }
    });
};

module.exports = {
    getAllTeams,
    addTeam,
    updateTeam,
    deleteTeam
};
