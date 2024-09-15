const Team = require('../models/team');
const teamDao = require('../dao/teamDao');

// Controller to get all employees
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

// Controller to add a new employee

const addTeam = async (req, res) => {
    try {
        console.log('Received request to add team:', req.body);
        const { name, head } = req.body;  // Don't get imagePath here

        // File path (use uploaded image or fallback to default)
        const imagePath = req.file ? req.file.path : 'uploads/';

        // Create new employee instance
        const newTeam = new Team (null, name, imagePath, head);

        // Insert employee into the database
        const result = await teamDao.addTeam(newTeam);  // Using employeeDao to add

        console.log('Team added:', result);
        res.status(200).json(result);
    } catch (error) {
        console.error('Error adding team:', error);
        res.status(500).json({ error: 'Internal Server Error' });
    }
};

  
  
// Controller to update an team
const updateTeam = (req, res) => {
    const { id, name, imagePath, head } = req.body;
    const updatedteam = new Team(id, name, imagePath, head);

    teamDao.updateTeam(updatedteam, (err, result) => {
        if (err) {
            console.error('Error updating team:', err);
            res.status(500).json({ error: 'Error updating team' });
        } else {
            res.status(200).json({ message: 'Team updated successfully' });
        }
    });
};

// Controller to delete an employee
const deleteTeam = (req, res) => {
    const { id } = req.body;

    teamDao.deleteTeam(id, (err, result) => {
        if (err) {
            console.error('Error deleting team:', err);
            res.status(500).json({ error: 'Error deleting team' });
        } else {
            res.status(200).json({ message: 'Team deleted successfully' });
        }
    });
};

module.exports = {
    getAllTeams,
    addTeam,
    updateTeam,
    deleteTeam
};
