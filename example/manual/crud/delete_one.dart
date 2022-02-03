import 'package:mongo_dart/mongo_dart.dart';

const dbName = 'mongo-dart-example';
const dbAddress = '127.0.0.1';

const DefaultUri = 'mongodb://$dbAddress:27017/$dbName';

void main() async {
  var db = Db(DefaultUri);
  await db.open();

  Future cleanupDatabase() async {
    await db.close();
  }

  if (!db.masterConnection.serverCapabilities.supportsOpMsg) {
    return;
  }

  var collectionName = 'delete-one';
  await db.dropCollection(collectionName);
  var collection = db.collection(collectionName);

  var ret = await collection.insertMany([
    {'_id': 3, 'name': 'John', 'age': 32},
    {'_id': 4, 'name': 'Mira', 'age': 27},
    {'_id': 7, 'name': 'Luis', 'age': 42},
  ]);
  if (!ret.isSuccess) {
    print('Error detected in record insertion');
  }

  var res = await collection.deleteOne(<String, Object>{});

  print('Removed documents: ${res.nRemoved}');

  var findResult = await collection.find().toList();

  print('First record name: ${findResult.first['name']}'); // 'Mira';

  await cleanupDatabase();
}
