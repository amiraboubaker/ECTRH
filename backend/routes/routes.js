// const express = require('express');
// const router = express.Router();
// const multer = require('multer');
// const path = require('path');
// const teamDao = require('../dao/teamDao');
// const userDao = require('../dao/userDao');
// const officeDao = require('../dao/officeDao');
// const employeeController = require('../controllers/employeeController');
// const User = require('../models/user');
// const Office = require('../models/office');

// // Set up multer for file uploads
// const storage = multer.diskStorage({
//   destination: (req, file, cb) => {
//     cb(null, 'uploads/'); // Folder to store uploaded files
//   },
//   filename: (req, file, cb) => {
//     cb(null, Date.now() + path.extname(file.originalname)); // File naming convention
//   }
// });
// const upload = multer({ storage: storage });

// // POST /api/user/signup
// router.post('/signup', userController.signup);

// // // Employee Routes
// // router.get('/getAllEmployees', employeeController.getAllEmployees);
// // router.post('/addEmployee', upload.single('image'), employeeController.addEmployee);
// // router.put('/updateEmployee', upload.single('image'), employeeController.updateEmployee);
// // router.delete('/deleteEmployee', employeeController.deleteEmployee);

// // // Office Routes
// // router.get('/getAllOffices', (req, res) => {
// //     officeDao.getAllOffices((err, offices) => {
// //         if (err) {
// //             console.error('Error fetching offices:', err);
// //             res.status(500).json({ error: 'Error fetching offices' });
// //         } else {
// //             res.status(200).json(offices);
// //         }
// //     });
// // });

// // router.post('/addOffice', upload.single('image'), (req, res) => {
// //     const { name, location, fixNumber } = req.body;
// //     const imagePath = req.file ? req.file.path : ''; // Handle image path
// //     const newOffice = new Office(null, name, location, imagePath, fixNumber);

// //     officeDao.addOffice(newOffice, (err, result) => {
// //         if (err) {
// //             console.error('Error adding office:', err);
// //             res.status(500).json({ error: 'Error adding office' });
// //         } else {
// //             console.log('Office added successfully');
// //             res.status(200).json({ message: 'Office added successfully', id: result.insertId });
// //         }
// //     });
// // });

// // router.put('/updateOffice', upload.single('image'), (req, res) => {
// //     const { id, name, location, fixNumber } = req.body;
// //     const imagePath = req.file ? req.file.path : req.body.imagePath; // Handle image path
// //     const updatedOffice = new Office(id, name, location, imagePath, fixNumber);

// //     officeDao.updateOffice(updatedOffice, (err, result) => {
// //         if (err) {
// //             console.error('Error updating office:', err);
// //             res.status(500).json({ error: 'Error updating office' });
// //         } else {
// //             console.log('Office updated successfully');
// //             res.status(200).json({ message: 'Office updated successfully' });
// //         }
// //     });
// // });

// // router.delete('/deleteOffice', (req, res) => {
// //     const { id } = req.body;

// //     officeDao.deleteOffice(id, (err, result) => {
// //         if (err) {
// //             console.error('Error deleting office:', err);
// //             res.status(500).json({ error: 'Error deleting office' });
// //         } else {
// //             console.log('Office deleted successfully');
// //             res.status(200).json({ message: 'Office deleted successfully' });
// //         }
// //     });
// // });

// // // Team Routes
// // router.post('/addTeam', async (req, res) => {
// //   try {
// //     const team = await teamDao.createTeam(req.body);
// //     res.status(201).json(team);
// //   } catch (error) {
// //     console.error('Error creating team:', error);
// //     res.status(500).json({ error: 'Error creating team' });
// //   }
// // });

// // router.get('/getAllTeams', async (req, res) => {
// //   try {
// //     const teams = await teamDao.getAllTeams();
// //     res.status(200).json(teams);
// //   } catch (error) {
// //     console.error('Error fetching teams:', error);
// //     res.status(500).json({ error: 'Error fetching teams' });
// //   }
// // });

// // router.put('/updateTeam', async (req, res) => {
// //   try {
// //     const { id, name, imagePath, head } = req.body;
// //     const result = await teamDao.updateTeam(id, { name, imagePath, head });
// //     res.status(200).json({ message: 'Team updated successfully' });
// //   } catch (error) {
// //     console.error('Error updating team:', error);
// //     res.status(500).json({ error: 'Error updating team' });
// //   }
// // });

// // router.delete('/deleteTeam', async (req, res) => {
// //   try {
// //     const { id } = req.body;
// //     await teamDao.deleteTeam(id);
// //     res.status(200).json({ message: 'Team deleted successfully' });
// //   } catch (error) {
// //     console.error('Error deleting team:', error);
// //     res.status(500).json({ error: 'Error deleting team' });
// //   }
// // });

// module.exports = router;
