const db = require('../config/dbconfig');

// Function to get all offices
const fetchOffices = (callback) => {
    const query = 'SELECT * FROM office';
    db.query(query, (err, results) => {
        if (err) {
            console.error('Error fetching offices:', err);
            callback(err, null);
        } else {
            callback(null, results);
        }
    });
};

// Function to add a new office
const addOffice = (office, callback) => {
    const query = 'INSERT INTO office (name, manager, location, imagePath, fixNumber) VALUES (?, ?, ?, ?, ?)';
    const values = [office.name, office.manager, office.location, office.imagePath, office.fixNumber];

    db.query(query, values, (err, results) => {
        if (err) {
            console.error('Error adding office:', err);
            callback(err, null);
        } else {
            callback(null, results);
        }
    });
};

// Function to update an office
const updateOffice = (office, callback) => {
    const query = 'UPDATE office SET name = ?, manager = ?, location = ?, imagePath = ?, fixNumber = ? WHERE id = ?';
    const values = [office.name, office.manager, office.location, office.imagePath, office.fixNumber, office.id];

    db.query(query, values, (err, results) => {
        if (err) {
            console.error('Error updating office:', err);
            callback(err, null);
        } else {
            callback(null, results);
        }
    });
};

// Function to delete an office
const deleteOffice = (id, callback) => {
    const query = 'DELETE FROM office WHERE id = ?';
    db.query(query, [id], (err, results) => {
        if (err) {
            console.error('Error deleting office:', err);
            callback(err, null);
        } else {
            callback(null, results);
        }
    });
};

module.exports = {
    fetchOffices,
    addOffice,
    updateOffice,
    deleteOffice
};
