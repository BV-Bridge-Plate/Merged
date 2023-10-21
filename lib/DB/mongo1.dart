import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';

import 'const1.dart';

class MongoDatabase1 {
  static var db, userCollection;

  static Future<void> connect() async {
    db = await Db.create(MONG_CONN_URL);
    await db.open();
    inspect(db);
    userCollection = db.collection(USER_COLLECTION);
  }

  static Future<int> fetchLatestUserId() async {
    int count = await userCollection.count();

    if (count == 0) {
      return 0; // No users exist
    } else {
      return count; // This assumes userid starts from 1 and increments by 1 for each user
    }
  }





  static Future<void> insertUser(Map<String, dynamic> userData) async {
    await userCollection.insert(userData);
  }
}
