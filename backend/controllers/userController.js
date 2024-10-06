const userDao = require('../dao/userDao');
const db = require('../config/dbconfig'); // Ensure this path is correct
const bcrypt = require('bcrypt');

// Signup logic with password hashing
exports.signup = async (req, res) => {
    const { username, email, password } = req.body;

    // Check if all required fields are present
    if (!username || !email || !password) {
        return res.status(400).json({ message: 'All fields are required' });
    }

    try {
        // Hash the password before storing it
        const hashedPassword = await bcrypt.hash(password, 10);

        // Create a user object with the hashed password
        const user = { username, email, password: hashedPassword };

        // Store the user in the database
        userDao.createUser(user, (err, result) => {
            if (err) {
                return res.status(500).json({ message: 'Error creating user', error: err });
            }
            res.status(201).json({ message: 'User created successfully', result });
        });
    } catch (error) {
        return res.status(500).json({ message: 'Error processing request', error });
    }
};

// Retrieve user by email
exports.getUserByEmail = (email, callback) => {
    db.query('SELECT * FROM user WHERE email = ?', [email], (err, results) => {
        if (err) return callback(err, null);
        if (results.length === 0) return callback(null, null);
        callback(null, results[0]); // Return the user if found
    });
};

// Signin logic with password comparison
exports.signin = (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ message: 'Email and password are required' });
    }

    userDao.getUserByEmail(email, async (err, user) => {
        if (err) {
            console.error('Error retrieving user:', err); // Log the error for debugging
            return res.status(500).json({ message: 'Error retrieving user', error: err });
        }
        if (!user) {
            return res.status(401).json({ message: 'Invalid email or password' });
        }

        try {
            const isPasswordValid = await bcrypt.compare(password, user.password);
            if (isPasswordValid) {
                res.status(200).json({ message: 'Sign in successful' });
            } else {
                res.status(401).json({ message: 'Invalid email or password' });
            }
        } catch (error) {
            console.error('Error comparing passwords:', error); // Log any errors during password comparison
            return res.status(500).json({ message: 'Error signing in', error });
        }
    });
};
