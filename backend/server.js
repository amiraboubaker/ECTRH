const express = require('express');
const bodyParser = require('body-parser');
const multer = require('multer');
const path = require('path');
const userRoutes = require('./routes/userRoutes');
const employeeRoutes = require('./routes/employeeRoutes');
const officeRoutes = require('./routes/officeRoutes');

const app = express();
app.use(bodyParser.json());

// MySQL connection setup
const mysql = require('mysql');
const db = mysql.createConnection({
  host: 'localhost',  // Ensure this is correct for your MySQL setup
  user: 'root',       // Replace with your MySQL username
  password: '',       // Replace with your MySQL password
  database: 'ectrh'   // Replace with your database name
});

// Connect to MySQL
db.connect((err) => {
  if (err) {
    console.error('Error connecting to the database:', err);
    return;
  }
  console.log('Connected to MySQL database.');
});

// Middleware to use the database connection in the request
app.use((req, res, next) => {
  req.db = db;
  next();
});

// Multer setup for file uploads from local drive
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');  // The directory where the files will be stored
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ storage: storage });

// Ensure the "uploads" directory exists
const fs = require('fs');
const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir);
}

// Route to upload an employee image and save employee info
app.post('/api/addEmployee', upload.single('image'), (req, res) => {
  const { name, email, position, phoneNumber } = req.body;
  
  // File path (or default if no file is uploaded)
  const imagePath = req.file ? req.file.path : 'uploads/default.png';

  // SQL query to insert employee details into the database
  const sql = 'INSERT INTO employee (name, email, position, phoneNumber, imagePath) VALUES (?, ?, ?, ?, ?)';
  db.query(sql, [name, email, position, phoneNumber, imagePath], (err, result) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    res.status(200).json({
      id: result.insertId,
      name,
      email,
      position,
      phoneNumber,
      imagePath: req.file ? req.file.path : 'uploads/default.png'
    });
  });
});

// Route to upload an office image and save office info
app.post('/api/addOffice', upload.single('image'), (req, res) => {
  const { name, location, headMaster, fixNumber } = req.body;
  const imagePath = req.file ? req.file.path : 'uploads/default.png';

  const sql = 'INSERT INTO office (name, location, headMaster, fixNumber, imagePath) VALUES (?, ?, ?, ?, ?)';
  db.query(sql, [name, location, headMaster, fixNumber, imagePath], (err, result) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    res.status(200).json({
      id: result.insertId,
      name,
      location,
      headMaster,
      fixNumber,
      imagePath
    });
  });
});

// Routes setup
app.use('/api/user', userRoutes);
app.use('/api', employeeRoutes);
app.use('/api', officeRoutes);

// Set PORT and start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on http://192.168.1.14:${PORT}`);
});
