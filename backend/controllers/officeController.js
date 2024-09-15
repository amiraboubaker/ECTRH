const officeDao = require('../dao/officeDao');
const Office = require('../models/office');

// Controller to get all offices
const fetchOffices = (req, res) => {
    officeDao.fetchOffices((err, offices) => {
        if (err) {
            console.error('Error fetching offices:', err);
            res.status(500).json({ error: 'Error fetching offices' });
        } else {
            res.status(200).json(offices);
        }
    });
};

// Controller to add a new office
const addOffice = async (req, res) => {
    try {
        console.log('Received request to add office:', req.body);
        const { name, manager, location, fixNumber } = req.body;

        // File path (use uploaded image or fallback to default)
        const imagePath = req.file ? req.file.path : 'uploads/office1.png';

        // Create new office instance
        const newOffice = new Office(null, name, manager, location, imagePath, fixNumber);

        // Insert office into the database
        const result = await officeDao.addOffice(newOffice);

        console.log('Office added:', result);
        res.status(201).json(result); // Use 201 status for creation
    } catch (error) {
        console.error('Error adding office:', error);
        res.status(500).json({ error: 'Internal Server Error' });
    }
};

// Controller to update an office
const updateOffice = (req, res) => {
    const { id, name, manager, location, imagePath, fixNumber } = req.body;
    const updatedOffice = new Office(id, name, manager, location, imagePath, fixNumber);

    officeDao.updateOffice(updatedOffice, (err, result) => {
        if (err) {
            console.error('Error updating office:', err);
            res.status(500).json({ error: 'Error updating office' });
        } else {
            res.status(200).json({ message: 'Office updated successfully' });
        }
    });
};

// Controller to delete an office
const deleteOffice = (req, res) => {
    const { id } = req.body;

    officeDao.deleteOffice(id, (err, result) => {
        if (err) {
            console.error('Error deleting office:', err);
            res.status(500).json({ error: 'Error deleting office' });
        } else {
            res.status(200).json({ message: 'Office deleted successfully' });
        }
    });
};

module.exports = {
    fetchOffices,
    addOffice,
    updateOffice,
    deleteOffice
};
