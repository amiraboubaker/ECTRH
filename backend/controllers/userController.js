const userDao = require('../dao/userDao');
const db = require('../config/dbconfig'); // Ensure this path is correct

// Signup logic without password hashing
exports.signup = (req, res) => {
    const { username, email, password } = req.body;

    // Check if all required fields are present
    if (!username || !email || !password) {
        return res.status(400).json({ message: 'All fields are required' });
    }

    // Create a user object with the real password (no hashing)
    const user = { username, email, password };

    // Store the user in the database
    userDao.createUser(user, (err, result) => {
        if (err) {
            return res.status(500).json({ message: 'Error creating user', error: err });
        }
        res.status(200).json({ message: 'User created successfully', result });
    });
};

// Retrieve user by email
exports.getUserByEmail = (email, callback) => {
    db.query('SELECT * FROM user WHERE email = ?', [email], (err, results) => {
        if (err) return callback(err, null);
        if (results.length === 0) return callback(null, null);
        callback(null, results[0]); // Return the user if found
    });
};

// Signin logic without password hashing
exports.signin = (req, res) => {
    const { email, password } = req.body;

    // Check if both email and password are provided
    if (!email || !password) {
        return res.status(400).json({ message: 'Email and password are required' });
    }

    // Retrieve the user by email
    userDao.getUserByEmail(email, (err, user) => {
        if (err) {
            return res.status(500).json({ message: 'Error retrieving user', error: err });
        }
        if (!user) {
            return res.status(401).json({ message: 'Invalid email or password' });
        }

        // Check if the entered password matches the stored password
        if (password === user.password) {
            // Passwords match
            res.status(200).json({ message: 'Sign in successful' });
        } else {
            // Passwords don't match
            res.status(401).json({ message: 'Invalid email or password' });
        }
    });
};
