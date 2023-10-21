import 'dart:convert';
import 'package:flutter/material.dart';

class DonationScreen extends StatefulWidget {
  @override
  _DonationScreenState createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  List<Map<String, dynamic>> doneeList = [];
  int? _selectedOtwIndex; // To track which "On my way" button was clicked.

  @override
  void initState() {
    super.initState();
    String jsonString = '''
    {
      "_id": {"\$oid": "6533438bc270f70b8bb373cf"},
      "donationid": "1",
      "doneelist": [
        {
          "doneename": "Renju",
          "qty": "10",
          "time": "15 mins",
          "otw": true
        },
        {
          "doneename": "Karthik",
          "qty": "15",
          "time": "20 mins",
          "otw": false
        }
      ]
    }
    ''';

    Map<String, dynamic> data = jsonDecode(jsonString);
    doneeList = List<Map<String, dynamic>>.from(data['doneelist']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donation Details'),
        elevation: 0,
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Table
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Quantity')),
                  DataColumn(label: Text('Time to donor')),
                ],
                rows: doneeList.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> donee = entry.value;
                  return DataRow(cells: [
                    DataCell(Text(donee['doneename'])),
                    DataCell(Text(donee['qty'])),
                    DataCell(
                      Row(
                        children: [
                          Text(donee['time']),
                          if (_selectedOtwIndex == index)
                            Icon(Icons.directions_run, color: Colors.green) // Running man icon
                        ],
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
            ...doneeList.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> donee = entry.value;
              return Visibility(
                visible: donee['otw'],
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedOtwIndex = index;
                      });
                    },
                    child: Text('On my way'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
