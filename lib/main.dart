import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';

void main() {
  runApp(QatrahApp());
}

class QatrahApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'قطة الديرة',
      theme: ThemeData(primarySwatch: Colors.teal, fontFamily: 'Cairo'),
      home: QatrahHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class QatrahHome extends StatefulWidget {
  @override
  _QatrahHomeState createState() => _QatrahHomeState();
}

class _QatrahHomeState extends State<QatrahHome> {
  List<Map<String, dynamic>> people = [];
  List<Map<String, dynamic>> expenses = [];
  final nameController = TextEditingController();
  final expenseNameController = TextEditingController();
  final expenseAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? peopleData = prefs.getString('people');
    String? expensesData = prefs.getString('expenses');
    if (peopleData!= null) people = List<Map<String, dynamic>>.from(json.decode(peopleData));
    if (expensesData!= null) expenses = List<Map<String, dynamic>>.from(json.decode(expensesData));
    setState(() {});
  }

  saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('people', json.encode(people));
    prefs.setString('expenses', json.encode(expenses));
  }

  addPerson() {
    if (nameController.text.isNotEmpty) {
      setState(() {
        people.add({'name': nameController.text, 'paid': 0.0});
        nameController.clear();
      });
      saveData();
    }
  }

  addExpense() {
    if (expenseNameController.text.isNotEmpty && expenseAmountController.text.isNotEmpty) {
      setState(() {
        expenses.add({
          'name': expenseNameController.text,
          'amount': double.parse(expenseAmountController.text),
          'by': people.isNotEmpty? people[0]['name'] : 'مجهول'
        });
        expenseNameController.clear();
        expenseAmountController.clear();
      });
      saveData();
    }
  }

  double getTotal() {
    return expenses.fold(0, (sum, item) => sum + item['amount']);
  }

  double getPerPerson() {
    return people.isEmpty? 0 : getTotal() / people.length;
  }

  String getSummary() {
    String summary = 'قطة الديرة - حسبة الويكند\n\n';
    summary += 'إجمالي المصاريف: ${getTotal().toStringAsFixed(2)} ريال\n';
    summary += 'على كل شخص: ${getPerPerson().toStringAsFixed(2)} ريال\n\n';
    summary += 'التفاصيل:\n';
    for (var e in expenses) {
      summary += '- ${e['name']}: ${e['amount']} ريال\n';
    }
    return summary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('قطة الديرة 🏖️'), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(child: ListTile(title: Text('الإجمالي: ${getTotal().toStringAsFixed(2)} ريال'), subtitle: Text('على كل شخص: ${getPerPerson().toStringAsFixed(2)} ريال'))),
            SizedBox(height: 10),
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'اسم الشخص', border: OutlineInputBorder())),
            ElevatedButton(onPressed: addPerson, child: Text('إضافة شخص')),
            SizedBox(height: 10),
           ...people.map((p) => ListTile(title: Text(p['name']))),
            Divider(),
            TextField(controller: expenseNameController, decoration: InputDecoration(labelText: 'اسم المصروف', border: OutlineInputBorder())),
            TextField(controller: expenseAmountController, decoration: InputDecoration(labelText: 'المبلغ', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            ElevatedButton(onPressed: addExpense, child: Text('إضافة مصروف')),
            SizedBox(height: 10),
           ...expenses.map((e) => ListTile(title: Text(e['name']), trailing: Text('${e['amount']} ريال'))),
            SizedBox(height: 20),
            ElevatedButton.icon(onPressed: () => Share.share(getSummary()), icon: Icon(Icons.share), label: Text('مشاركة الحسبة')),
          ],
        ),
      ),
    );
  }
}
