const db = require('../config/dbconfig');

// Function to get all teams
const getAllTeams = (callback) => {
    const query = 'SELECT * FROM team';
    db.query(query, (err, results) => {
        if (err) {
            console.error('Error fetching teams:', err);
            callback(err, null);
        } else {
            callback(null, results);
        }
    });
};

// Function to add a new team
const addTeam = (team, callback) => {
    const sql = "INSERT INTO team (name, imagePath, head) VALUES (?, ?, ?)";
    const values = [team.name, team.imagePath, team.head];

    db.query(sql, values, (err, result) => {
        if (err) {
            return callback(err);
        }
        callback(null, result);
    });
};


// Function to update an team
const updateTeam = (team, callback) => {
    const query = 'UPDATE team SET name = ?, imagePath = ?, head = ? WHERE id = ?';
    const values = [team.name, team.imagePath, team.head, team.id];
    db.query(query, values, (err, results) => {
        if (err) {
            console.error('Error updating team:', err);
            callback(err, null);
        } else {
            callback(null, results);
        }
    });
};

// Function to delete an team
const deleteTeam = (id, callback) => {
    const query = 'DELETE FROM team WHERE id = ?';
    db.query(query, [id], (err, results) => {
        if (err) {
            console.error('Error deleting team:', err);
            callback(err, null);
        } else {
            callback(null, results);
        }
    });
};

module.exports = {
    getAllTeams,
    addTeam,
    updateTeam,
    deleteTeam
};
