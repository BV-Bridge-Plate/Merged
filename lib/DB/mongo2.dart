import 'dart:developer';
import 'package:ipfs/DB/constant2.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDatabase2 {
  static var db, userCollection;

  static Future<void> connect() async {
    db = await Db.create(MONG_CONN_URL);
    await db.open();
    inspect(db);
    userCollection = db.collection(USER_COLLECTION);
  }

  static Future<List<Map<String, dynamic>>> fetchRecordsByDonor(String donorId) async {
    print("Fetching data from database..."); // Added for debugging
    List<Map<String, dynamic>> records = await userCollection.find(where.eq('donerid', donorId)).toList();
    print("Fetched ${records.length} records."); // Added for debugging
    return records;
  }

  static Future<void> insertDonation(Map<String, dynamic> donationData) async {
    await userCollection.insert(donationData);
  }
}
