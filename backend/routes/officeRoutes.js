const express = require('express');
const router = express.Router();
const officeController = require('../controllers/officeController');
const multer = require('multer');
const upload = multer({ dest: 'uploads/' });

// Route to get all offices
router.get('/fetchOffices', officeController.fetchOffices);

// Route to add a new office
router.post('/addOffice', upload.single('image'), officeController.addOffice);

// Route to update an office
router.put('/updateOffice', officeController.updateOffice);

// Route to delete an office
router.delete('/deleteOffice', officeController.deleteOffice);

module.exports = router;
