const express = require('express');
const router = express.Router();
const employeeController = require('../controllers/employeeController');

// Route to get all employees

router.get('/getAllEmployees', employeeController.getAllEmployees);

// Route to add a new employee

router.post('/addEmployee', employeeController.addEmployee);

// Route to update an employee

router.put('/updateEmployee', employeeController.updateEmployee);

// Route to delete an employee

router.delete('/deleteEmployee', employeeController.deleteEmployee);

module.exports = router;
