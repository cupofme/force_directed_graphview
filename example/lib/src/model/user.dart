import 'package:faker/faker.dart';

final _faker = Faker(seed: 0);

class User {
  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  factory User.generate() {
    return User(
      id: _faker.randomGenerator.integer(100000),
      firstName: faker.person.firstName(),
      lastName: faker.person.lastName(),
    );
  }

  final int id;
  final String firstName;
  final String lastName;
}
