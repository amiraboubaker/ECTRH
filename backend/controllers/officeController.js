const OfficeDao = require('./officeDao');

class OfficeController {
  static async fetchOffices(req, res) {
    try {
      const offices = await OfficeDao.getAllOffices();
      res.json(offices);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  static async fetchOfficeById(req, res) {
    try {
      const { id } = req.params;
      const office = await OfficeDao.getOfficeById(id);
      if (office) {
        res.json(office);
      } else {
        res.status(404).json({ error: 'Office not found' });
      }
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  static async addOffice(req, res) {
    try {
      const office = req.body;
      const newOffice = await OfficeDao.addOffice(office);
      res.status(201).json(newOffice);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  static async updateOffice(req, res) {
    try {
      const office = req.body;
      const updatedOffice = await OfficeDao.updateOffice(office);
      res.json(updatedOffice);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  static async deleteOffice(req, res) {
    try {
      const { id } = req.body;
      await OfficeDao.deleteOffice(id);
      res.status(204).end();
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
}

module.exports = OfficeController;
