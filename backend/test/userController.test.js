const request = require('supertest');
const app = require('../server'); // Adjust this to the correct path of your app
const dbConfig = require('../config/dbconfig'); // Adjust the path as needed
const mysql = require('mysql'); // Ensure you're importing MySQL

let connection;

// Connect to the database once before all tests
beforeAll(done => {
    connection = mysql.createConnection(dbConfig);
    connection.connect(err => {
        if (err) return done(err);
        console.log('Connected to MySQL database.');
        done();
    });
});

// Close the connection after all tests are done
afterAll(done => {
    if (connection) {
        connection.end(err => {
            if (err) return done(err);
            console.log('Disconnected from MySQL database.');
            done();
        });
    }
});

describe('User Controller Tests', () => {
    describe('POST /signup', () => {
        it('should create a new user successfully', async () => {
            const userData = { username: 'testuser', email: 'test@example.com', password: 'password' };
            const response = await request(app).post('/api/users/signup').send(userData);
            expect(response.statusCode).toBe(201);
        });
    });

    describe('POST /signin', () => {
        it('should sign in successfully', async () => {
            const userData = { email: 'test@example.com', password: 'password' };
            const response = await request(app).post('/api/users/signin').send(userData);
            expect(response.statusCode).toBe(200);
        });

        it('should return an error when credentials are incorrect', async () => {
            const userData = { email: 'wrong@example.com', password: 'wrongpassword' };
            const response = await request(app).post('/api/users/signin').send(userData);
            expect(response.statusCode).toBe(401);
        });
    });
});
