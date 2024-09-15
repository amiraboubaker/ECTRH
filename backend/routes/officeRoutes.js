const express = require('express');
const router = express.Router();
const officeController = require('../controllers/officeController');

// Route to get all offices
router.get('/fetchOffices', officeController.getAllOffices);

// Route to add a new office
router.post('/addOffice', officeController.addOffice);

// Route to update an office
router.put('/updateOffice', officeController.updateOffice);

// Route to delete an office
router.delete('/deleteOffice', officeController.deleteOffice);

module.exports = router;
