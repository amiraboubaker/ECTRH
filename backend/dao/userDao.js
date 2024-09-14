const connection = require('../config/dbconfig');

const userDao = {
    createUser: (user, callback) => {
        const query = 'INSERT INTO user (username, email, password) VALUES (?, ?, ?)';
        connection.query(query, [user.username, user.email, user.password], (err, result) => {
            if (err) {
                return callback(err, null);
            }
            return callback(null, result);
        });
    },

    getUserByEmail: (email, callback) => {
        const query = 'SELECT * FROM user WHERE email = ?';
        connection.query(query, [email], (err, results) => {
            if (err) {
                return callback(err, null);
            }
            if (results.length === 0) {
                return callback(null, null);
            }
            return callback(null, results[0]);
        });
    }
};

module.exports = userDao;
