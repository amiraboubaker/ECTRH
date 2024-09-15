const db = require('../config/dbconfig');

// Function to get all employees
const getAllEmployees = (callback) => {
    const query = 'SELECT * FROM employee';
    db.query(query, (err, results) => {
        if (err) {
            console.error('Error fetching employees:', err);
            callback(err, null);
        } else {
            callback(null, results);
        }
    });
};

// Function to add a new employee
const addEmployee = (employee, callback) => {
    const query = 'INSERT INTO employee (name, email, position, imagePath, phoneNumber) VALUES (?, ?, ?, ?, ?)';
    const values = [employee.name, employee.email, employee.position, employee.imagePath, employee.phoneNumber];

    db.query(query, values, (err, results) => {
        if (err) {
            console.error('Error adding employee:', err);
            callback(err, null);
        } else {
            callback(null, results);
        }
    });
};

// Function to update an employee
const updateEmployee = (employee, callback) => {
    const query = 'UPDATE employee SET name = ?, email = ?, position = ?, imagePath = ?, phoneNumber = ? WHERE id = ?';
    const values = [employee.name, employee.email, employee.position, employee.imagePath, employee.phoneNumber, employee.id];
    db.query(query, values, (err, results) => {
        if (err) {
            console.error('Error updating employee:', err);
            callback(err, null);
        } else {
            callback(null, results);
        }
    });
};

// Function to delete an employee
const deleteEmployee = (id, callback) => {
    const query = 'DELETE FROM employee WHERE id = ?';
    db.query(query, [id], (err, results) => {
        if (err) {
            console.error('Error deleting employee:', err);
            callback(err, null);
        } else {
            callback(null, results);
        }
    });
};

module.exports = {
    getAllEmployees,
    addEmployee,
    updateEmployee,
    deleteEmployee
};
