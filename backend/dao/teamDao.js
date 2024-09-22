const db = require('../config/dbconfig');

// Function to get all teams
const getAllTeams = () => {
    return new Promise((resolve, reject) => {
        const query = 'SELECT * FROM team';
        db.query(query, (err, results) => {
            if (err) {
                console.error('Error fetching teams:', err);
                reject(err);
            } else {
                resolve(results);
            }
        });
    });
};

// Function to add a new team
const addTeam = (team) => {
    return new Promise((resolve, reject) => {
        const sql = "INSERT INTO team (name, imagePath, head) VALUES (?, ?, ?)";
        const values = [team.name, team.imagePath, team.head];

        db.query(sql, values, (err, result) => {
            if (err) {
                reject(err);
            } else {
                resolve(result);
            }
        });
    });
};

// Function to update a team
const updateTeam = (team) => {
    return new Promise((resolve, reject) => {
        const query = 'UPDATE team SET name = ?, imagePath = ?, head = ? WHERE id = ?';
        const values = [team.name, team.imagePath, team.head, team.id];

        db.query(query, values, (err, results) => {
            if (err) {
                console.error('Error updating team:', err);
                reject(err);
            } else {
                resolve(results);
            }
        });
    });
};

// Function to delete a team
const deleteTeam = (id) => {
    return new Promise((resolve, reject) => {
        const query = 'DELETE FROM team WHERE id = ?';
        db.query(query, [id], (err, results) => {
            if (err) {
                console.error('Error deleting team:', err);
                reject(err);
            } else {
                resolve(results);
            }
        });
    });
};

module.exports = {
    getAllTeams,
    addTeam,
    updateTeam,
    deleteTeam
};
