const mysql = require('mysql');
const db = require('../config/dbconfig'); // Ensure the path to your dbconfig is correct

const getAllTeams = () => {
  return new Promise((resolve, reject) => {
    db.query('SELECT * FROM team', (err, results) => {
      if (err) reject(err);
      resolve(results);
    });
  });
};

const addTeam = (team, callback) => {
  const query = 'INSERT INTO team (name, imagePath, head) VALUES (?, ?, ?)';
  db.query(query, [team.name, team.imagePath, team.head], (error, results) => {
      if (error) {
          console.error('Error inserting team:', error);
          return callback(error); // Ensure callback is passed the error
      }
      return callback(null, results.insertId); // Correctly pass the insert ID
  });
};


const updateTeam = (id, name, imagePath, head) => {
  return new Promise((resolve, reject) => {
    const query = 'UPDATE team SET name = ?, imagePath = ?, head = ? WHERE id = ?';
    db.query(query, [name, imagePath, head, id], (err, results) => {
      if (err) reject(err);
      if (results.affectedRows > 0) {
        resolve({ id, name, imagePath, head });
      } else {
        resolve(null);
      }
    });
  });
};

const deleteTeam = (id) => {
  return new Promise((resolve, reject) => {
    const query = 'DELETE FROM team WHERE id = ?';
    db.query(query, [id], (err, results) => {
      if (err) reject(err);
      if (results.affectedRows > 0) {
        resolve(true);
      } else {
        resolve(false);
      }
    });
  });
};

module.exports = {
  getAllTeams,
  addTeam,
  updateTeam,
  deleteTeam,
};
