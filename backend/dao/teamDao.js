// dao/teamDao.js

const db = require('../config/dbconfig'); // Adjust the path as needed

const getAllTeams = () => {
  return new Promise((resolve, reject) => {
    db.query('SELECT * FROM team', (err, results) => {
      if (err) reject(err);
      resolve(results);
    });
  });
};

const addTeam = (name, imagePath, head) => {
  return new Promise((resolve, reject) => {
    const query = 'INSERT INTO team (name, imagePath, head) VALUES (?, ?, ?)';
    db.query(query, [name, imagePath, head], (err, results) => {
      if (err) reject(err);
      resolve({ id: results.insertId, name, imagePath, head });
    });
  });
};

const updateTeam = (id, name, imagePath, head) => {
  return new Promise((resolve, reject) => {
    const query = 'UPDATE team SET name = ?,imagePath = ?, head = ? WHERE id = ?';
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
