const Team = require('../models/team');
const teamDao = require('../dao/teamDao');

// Controller to get all Teams

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

const addTeam = (req, res) => {
    const team = {
        name: req.body.name,
        imagePath: req.body.imagePath,
        head: req.body.head
    };

    teamDao.addTeam(team, (error, teamId) => {
        if (error) {
            return res.status(500).json({ message: 'Error adding team', error });
        }
        res.status(200).json({
            message: 'Team added successfully',
            id: teamId,
            name: team.name,
            imagePath: team.imagePath,
            head: team.head
        });
    });
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

// Controller to delete a team
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
