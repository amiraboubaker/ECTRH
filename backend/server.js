const express = require('express');
const bodyParser = require('body-parser');
const userRoutes = require('./routes/userRoutes');

const app = express();
app.use(bodyParser.json());

// MySQL connection setup
const mysql = require('mysql');
const db = mysql.createConnection({
  host: 'localhost',  // Ensure this is correct for your MySQL setup
  user: 'root',       // Replace with your MySQL username
  password: '',       // Replace with your MySQL password
  database: 'ectrh'
});

db.connect((err) => {
  if (err) {
    console.error('Database connection failed:', err.stack);
    return;
  }
  console.log('Connected to database');
});

// Routes setup
app.use('/api/user', userRoutes);

// Set PORT and start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on http://192.168.1.14:${PORT}`);
});
