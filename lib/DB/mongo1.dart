import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';

import 'const1.dart';

class MongoDatabase1 {
  static Db? db;
  static DbCollection? userCollection;

  static Future<void> connect() async {
    db = await Db.create(MONG_CONN_URL);
    await db?.open();
    inspect(db);
    userCollection = db?.collection(USER_COLLECTION);
  }

  static Future<int> fetchLatestUserId() async {
    try {
      var result = await userCollection?.find(where.sortBy('id', descending: true)).toList();
      if (result != null) {
        var latestUser = result?.first;
        int latestUserId = latestUser?['id'] as int;
        return latestUserId;
      }
      return 0; // If no users exist, start from 0
    } catch (e) {
      print("Error fetching latest user: $e");
      return 0; // Handle errors by starting from 0
    }
  }


  static Future<void> insertUser(Map<String, dynamic> userData) async {
    await userCollection?.insert(userData);
  }
}
