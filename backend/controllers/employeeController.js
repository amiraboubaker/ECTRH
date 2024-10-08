const Employee = require('../models/employee');
const employeeDao = require('../dao/employeeDao');

// Controller to get all employees
const getAllEmployees = (_req, res) => {
    employeeDao.getAllEmployees((err, employees) => {
        if (err) {
            console.error('Error fetching employees:', err);
            res.status(500).json({ error: 'Error fetching employees' });
        } else {
            res.status(200).json(employees);
        }
    });
};

// Controller to add a new employee

const addEmployee = async (req, res) => {
    try {
        console.log('Received request to add employee:', req.body);
        const { name, email, position, phoneNumber } = req.body;  // Don't get imagePath here

        // File path (use uploaded image or fallback to default)
        const imagePath = req.file ? req.file.path : 'uploads/default.png';

        // Create new employee instance
        const newEmployee = new Employee(null, name, email, position, imagePath, phoneNumber);

        // Insert employee into the database
        const result = await employeeDao.addEmployee(newEmployee);  // Using employeeDao to add

        console.log('Employee added:', result);
        res.status(200).json(result);
    } catch (error) {
        console.error('Error adding employee:', error);
        res.status(500).json({ error: 'Internal Server Error' });
    }
};

// Controller to update an employee
const updateEmployee = (req, res) => {
    const { id, name, email, position, phoneNumber, imagePath } = req.body;
    const updatedEmployee = new Employee(id, name, email, position, imagePath, phoneNumber);

    employeeDao.updateEmployee(updatedEmployee, (err, _result) => {
        if (err) {
            console.error('Error updating employee:', err);
            res.status(500).json({ error: 'Error updating employee' });
        } else {
            res.status(200).json({ message: 'Employee updated successfully' });
        }
    });
};

// Controller to delete an employee
const deleteEmployee = (req, res) => {
    const { id } = req.body;

    employeeDao.deleteEmployee(id, (err, _result) => {
        if (err) {
            console.error('Error deleting employee:', err);
            res.status(500).json({ error: 'Error deleting employee' });
        } else {
            res.status(200).json({ message: 'Employee deleted successfully' });
        }
    });
};

module.exports = {
    getAllEmployees,
    addEmployee,
    updateEmployee,
    deleteEmployee
};
