class Employee {
    constructor(id, name, email, position, imagePath, phoneNumber) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.position = position;
        this.phoneNumber = phoneNumber;
        this.imagePath = imagePath || 'uploads/default.png';
    }
}

module.exports = Employee;
