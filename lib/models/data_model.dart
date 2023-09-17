/// A Dart class called `PersonDB` that manages a SQLite database for storing and retrieving information about people.
/// 
/// The class includes methods for creating a person, closing the database, opening the database, and retrieving all people from the database.
/// 
/// Example Usage:
/// ```dart
/// final personDB = PersonDB(dbName: 'myDatabase.db');
/// await personDB.open();
/// await personDB.create('John', 'Doe');
/// await personDB.create('Jane', 'Smith');
/// await personDB.close();
/// ```
/// 
/// Inputs:
/// - `dbName` (String): The name of the database file.
/// 
/// Flow:
/// 1. The `PersonDB` class is instantiated with the `dbName` provided.
/// 2. The `open` method is called to open the database. If the database is already open, it returns `true`.
/// 3. Inside the `open` method, the database file path is obtained using the `getApplicationDocumentsDirectory` function from the `path_provider` package.
/// 4. The database is opened using the `openDatabase` function from the `sqflite` package.
/// 5. If the database is successfully opened, a table called "PEOPLE" is created if it doesn't already exist.
/// 6. The `_fetchPeople` method is called to retrieve all existing people from the database.
/// 7. The retrieved people are stored in the `_persons` list and added to the `_streamController` to be broadcasted.
/// 8. The `create` method is called to insert a new person into the database. It takes the first name and last name as parameters.
/// 9. Inside the `create` method, the person is inserted into the "PEOPLE" table using the `insert` method of the database.
/// 10. The inserted person is created as a `Person` object and added to the `_persons` list.
/// 11. The `close` method is called to close the database. If the database is already closed, it returns `false`.
/// 12. Inside the `close` method, the `close` method of the database is called to close the database connection.
/// 
/// Outputs:
/// - `open` method: Returns `true` if the database is successfully opened, `false` otherwise.
/// - `create` method: Returns `true` if the person is successfully created and inserted into the database, `false` otherwise.
/// - `close` method: Returns `true` if the database is successfully closed, `false` otherwise.
import 'dart:async';


import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class Person implements Comparable{
  const Person({
  required this.id,
  required this.FirstName,
  required this.LastName
  });
  String get fullName =>'$FirstName $LastName';

  Person.fromRow(Map<String, Object?> row) : id = row['ID'] as int , FirstName = row['First_Name'] as String, LastName = row['LAST_NAME'] as String;
    final int id;
   final String FirstName;
   final String LastName;
   
     @override
     int compareTo(covariant Person other) => other.id.compareTo(other.id);
     @override
     //checcks if there are two persons with the same name
     bool operator ==(covariant Person other) => id == other.id;
     
       @override
     
       int get hashCode => id.hashCode;
     @override
  String toString() =>
  'Person, id = $id, firstname: $FirstName, lastname: $LastName';

}
class PersonDB{
  final  String dbName;
  Database? _db;
  //create an array
  List<Person> _persons = [];
   PersonDB( {required this.dbName});
   final _streamController = StreamController<List<Person>>.broadcast();
   Future <List<Person>> _fetchPeople () async {
       final db = _db;
       if(db == null){
        return [];
       } try {
        final read = await db.query('PEOPLE',
        distinct:  true,
        columns: [
          'ID',
          'FIRST_NAME',
          'LAST_NAME',
        ],
        orderBy: 'ID'
        );
        final people = read.map((row) => Person.fromRow(row)).toList();
        return people;
       } catch (e) {
        print('Error fetching people =$e');
        return [];
       }

   }
   Future <bool>  create(String FirstName, String LastName) async{
    final db = _db;
    if(db == null){
      return false;
    }
    try{
    final id = await db.insert('PEOPLE', {
     'FIRST_NAME': FirstName,
     'LAST_NAME': LastName,
    }); 
    final person = Person(
      id: id, 
    FirstName: FirstName,
     LastName: LastName);
     _persons.add(person); 
     _streamController.add(_persons);
     return true;
    }catch(e){
      print('Error in creating person = $e');
      return false;
   

    }
   }
   Future <bool> delete(Person person) async {
    final db = _db;
    if (db == null){
      return false;
    }
    try{
      final deleteCount = await db.delete(
        'PEOPLE',
        where: 'ID = ?',
        whereArgs: [person.id],

        );
        if(deleteCount == 1 ){
          _persons.remove(person);
          _streamController.add(_persons);
          return true;
        } else{
          return false;
        }
        

    }catch(e){
      print('Deletion with error $e');
      return false;  
      
    }
   }
   Future <bool> close() async {
    final db = _db;
    if(db == null){
      return false;
    } 
    await db.close();
    return true;

   }


  Future<bool> open() async{
    if(_db != null){
      return true;
      
    }
     
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/dbName';
    try{
     final db =await openDatabase(path);
     _db = db;
  


     //create table
     const create =
      """CREATE TABLE IF NOT EXISTS PEOPLE(
     ID INTEGER PRIMARY KEY AUTOINCREMENT,
     FIRST_NAME STRING NOT NULL,
     LAST_NAME STRING NOT NULL
     )""";

     await db.execute(create);
     //read all exciting Persons objectsdfrom the db
    // final persons = await _fetchPeople();
     _persons = await _fetchPeople();
     _streamController.add(_persons);
     return true;

    }catch(e){
      print('Error = $e');
     return false;
    }
 
  }

  Future <bool> update(Person person) async{
    final db = _db;
    if(db == null){
      return false;
    }
    try{
      final updateCount = await db.update('PEOPLE', {
        'FIRST_NAME': person.FirstName,
        'LAST_NAME': person.LastName,
      },
      where: 'ID = ?',
      whereArgs: [person.id], 
      );
      if(updateCount == 1){
        _persons.removeWhere((other) => other.id == person.id);
        _persons.add(person);
        _streamController.add(_persons);
        return true;
      }
    } catch(e){
      print('Failed to Update person, error = $e'); 
    }
      return false;

  }

  


 Stream<List<Person>> all() =>
 _streamController.stream.map((persons) => persons..sort());
}