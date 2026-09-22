class Student {
  final String name;
  final String group;

  const Student(this.name, this.group);

  const Student.guest() : name = 'Guest', group = '—';

  @override
  String toString() => 'Student($name, $group)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Student && other.name == name && other.group == group;
  }

  @override
  int get hashCode => Object.hash(name, group);
}

void main() {
  print(Student('Ana Rusu', 'TI-231'));
  print(Student.guest());
  print(Student('Ana Rusu', 'TI-231') == Student('Ana Rusu', 'TI-231'));
  print({Student('Ana Rusu', 'TI-231'), Student('Ana Rusu', 'TI-231')}.length);
}
