class Team {
  constructor(id, name, imagePath, head) {
    this.id = id;
    this.name = name;
    this.imagePath = imagePath || 'uploads/default.png';
    this.head = head;
  }
}

module.exports = Team;
