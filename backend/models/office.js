class Office {
    constructor(id, name, manager, location, imagePath, fixNumber) {
        this.id = id;
        this.name = name;
        this.manager = manager;
        this.location = location;
        this.imagePath = imagePath || 'uploads/office1.png';
        this.fixNumber = fixNumber;
    }
}

module.exports = Office;
