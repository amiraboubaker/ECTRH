class Employee {
    constructor(id, name, email, position, imagePath, phoneNumber) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.position = position;
        this.imagePath = imagePath || 'uploads/emp1.png';  // Optional default if not provided
        this.phoneNumber = phoneNumber;
    }
}

module.exports = Employee;
