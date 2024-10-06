const officeDao = require('../dao/officeDao');

// Controller to get all offices
const getAllOffices = (req, res) => {
    officeDao.getAllOffices((err, offices) => {
        if (err) {
            console.error('Error fetching offices:', err);
            return res.status(500).json({ error: 'Error fetching offices' });
        }
        res.status(200).json(offices);
    });
};

// Controller to add an office
const addOffice = (req, res) => {
    const { name } = req.body;
    if (!name) {
        return res.status(400).json({ error: 'Office name is required' });
    }

    officeDao.addOffice({ name }, (err, result) => {
        if (err) {
            console.error('Error adding office:', err);
            return res.status(500).json({ error: 'Internal Server Error' });
        }
        res.status(201).json(result);
    });
};

// Controller to delete an office
const deleteOffice = (req, res) => {
    const { id } = req.body;
    if (!id) {
        return res.status(400).json({ error: 'Office ID is required' });
    }

    officeDao.deleteOffice(id, (err, result) => {
        if (err) {
            console.error('Error deleting office:', err);
            return res.status(500).json({ error: 'Internal Server Error' });
        }
        res.status(204).send(); // No content for successful deletion
    });
};

// Controller to update an office
const updateOffice = (req, res) => {
    const { id, name, location } = req.body;
    
    if (!id) {
        return res.status(400).json({ error: 'Office ID is required' });
    }

    if (!name && !location) {
        return res.status(400).json({ error: 'At least one field (name or location) is required for update' });
    }

    const updatedOffice = { name, location };

    officeDao.updateOffice(id, updatedOffice, (err, result) => {
        if (err) {
            console.error('Error updating office:', err);
            return res.status(500).json({ error: 'Internal Server Error' });
        }

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Office not found' });
        }

        res.status(200).json({ message: 'Office updated successfully' });
    });
};

module.exports = {
    getAllOffices,
    addOffice,
    deleteOffice,
    updateOffice,
};
