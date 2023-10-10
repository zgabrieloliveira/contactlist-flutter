import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

class Contact {
  String name;
  String email;
  String phone;
  String img;
  int? id;

  Contact()
      : name = '',
        email = '',
        phone = '',
        img = '';

  Contact.fromMap(Map map)
      : id = map[idColumn] as int?,
        name = map[nameColumn] ?? '',
        email = map[emailColumn] ?? '',
        phone = map[phoneColumn] ?? '',
        img = map[imgColumn] ?? '';

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}

class ContactUtil {
  // singleton
  static final ContactUtil _instance = ContactUtil.internal();
  factory ContactUtil() => _instance;
  ContactUtil.internal();

  late Database _db;

  Future<Database> get db async {
    if (_db != null)
      return _db;
    else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "new_contacts.db"); // db file path

    // creating table, if it doesn't exist yet
    _db = await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY AUTOINCREMENT, $nameColumn TEXT, "
          "$emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)");
    });
    return _db;
  }

  Future<Contact> saveContact(Contact contact) async {
    // fetching data
    Database dbContact = await db;
    // insert new contact at the db table
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact?> getContact(int id) async {
    Database dbContact = await db;

    // searching contact by it's unique id
    List<Map> maps = await dbContact.query(contactTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);
    // checking if the contact were found
    if (maps.isNotEmpty)
      return Contact.fromMap(maps.first);
    else
      return null;
  }

  Future<int?> deleteContact(int? id) async {
    Database dbContact = await db;
    // deleting the contact by it's unique id
    return await dbContact
        .delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    // updating the contact by it's unique id
    return await dbContact.update(contactTable, contact.toMap(),
        where: "$idColumn = ?", whereArgs: [contact.id]);
  }

  Future<List<Contact>?> getAllContacts() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = [];
    // after getting all contacts in the db, add them in a list
    for (Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    // returns the result, that can be null if none contact were add
    return listContact;
  }

  Future<int> getNumber() async {
    Database dbContact = await db;
    final count =
        await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable");
    final int? result = Sqflite.firstIntValue(count);
    return result ?? 0;
  }

  Future<void> close() async {
    Database dbContact = await db;
    dbContact.close();
  }
}
