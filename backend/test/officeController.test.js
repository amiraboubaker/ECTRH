const officeController = require('../controllers/officeController');
const officeDao = require('../dao/officeDao');

jest.mock('../dao/officeDao');

describe('Office Controller Tests', () => {
    let req, res;

    beforeEach(() => {
        req = { body: {} };
        res = {
            status: jest.fn().mockReturnThis(),
            json: jest.fn(),
            send: jest.fn(),
        };
    });

    test('should fetch all offices', () => {
        const mockOffices = [{ id: 1, name: 'Office A' }, { id: 2, name: 'Office B' }];
        officeDao.getAllOffices.mockImplementation((callback) => callback(null, mockOffices));

        officeController.getAllOffices(req, res);

        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith(mockOffices);
    });

    test('should handle error while fetching offices', () => {
        officeDao.getAllOffices.mockImplementation((callback) => callback(new Error('Database Error')));

        officeController.getAllOffices(req, res);

        expect(res.status).toHaveBeenCalledWith(500);
        expect(res.json).toHaveBeenCalledWith({ error: 'Error fetching offices' });
    });

    test('should add an office', () => {
        req.body = { name: 'Office C' };
        const mockResult = { id: 3, name: 'Office C' };
        officeDao.addOffice.mockImplementation((office, callback) => callback(null, mockResult));

        officeController.addOffice(req, res);

        expect(res.status).toHaveBeenCalledWith(201);
        expect(res.json).toHaveBeenCalledWith(mockResult);
    });

    test('should handle error while adding office', () => {
        req.body = { name: 'Office C' };
        officeDao.addOffice.mockImplementation((office, callback) => callback(new Error('Database Error')));

        officeController.addOffice(req, res);

        expect(res.status).toHaveBeenCalledWith(500);
        expect(res.json).toHaveBeenCalledWith({ error: 'Internal Server Error' });
    });

    test('should delete an office', () => {
        req.body = { id: 1 };
        officeDao.deleteOffice.mockImplementation((id, callback) => callback(null, {}));

        officeController.deleteOffice(req, res);

        expect(res.status).toHaveBeenCalledWith(204);
        expect(res.send).toHaveBeenCalled();
    });

    test('should handle error while deleting office', () => {
        req.body = { id: 1 };
        officeDao.deleteOffice.mockImplementation((id, callback) => callback(new Error('Database Error')));

        officeController.deleteOffice(req, res);

        expect(res.status).toHaveBeenCalledWith(500);
        expect(res.json).toHaveBeenCalledWith({ error: 'Internal Server Error' });
    });

    test('should validate input while adding an office', () => {
        officeController.addOffice(req, res);

        expect(res.status).toHaveBeenCalledWith(400);
        expect(res.json).toHaveBeenCalledWith({ error: 'Office name is required' });
    });

    test('should validate input while deleting an office', () => {
        officeController.deleteOffice(req, res);

        expect(res.status).toHaveBeenCalledWith(400);
        expect(res.json).toHaveBeenCalledWith({ error: 'Office ID is required' });
    });
});
