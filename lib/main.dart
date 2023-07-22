import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/app_translation.dart';
import 'package:untitled/sql_helper.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? languageCode = prefs.getString('language');
  Locale locale  = languageCode != null ? Locale(languageCode) : const Locale('en', 'US');
  runApp(GetMaterialApp(
    theme: ThemeData(
        primarySwatch: Colors.indigo
    ),
    translations: AppTranslation(),
    locale: locale,
    navigatorKey: Get.key,
    debugShowCheckedModeBanner: false,
    home: const MyApp(),
  ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

final List locale = [
  {'name': 'O`zbekcha', 'locale': const Locale('uz', 'UZ')},
  {'name': 'Русский', 'locale': const Locale('ru', 'RU')},
  {'name': 'Тоҷикӣ', 'locale': const Locale('tg', 'TJ')},
  {'name': 'English', 'locale': const Locale('en', 'US')}
];

upDateLanguage(Locale locale) async {
  Get.back();
  Get.updateLocale(locale);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('language', locale.languageCode);
}

buildDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (builder) {
        return AlertDialog(
          title: Text('language'.tr),
          content: Container(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    locale[index]['name'];
                    upDateLanguage(locale[index]['locale']);
                  },
                  child: Center(
                    child: Text(
                      locale[index]['name'],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const Divider(
                  indent: 10,
                  endIndent: 10,
                  color: Colors.green,
                );
              },
              itemCount: locale.length,
            ),
          ),
        );
      });
}

class _MyAppState extends State<MyApp> {
  final formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _journals = [];

  @override
  void initState() {
    super.initState();
    _refreshJournals();
    print('......nomer  elementa ${_journals.length}');
  }

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _upperController = TextEditingController();
  final TextEditingController _lowerController = TextEditingController();
  final TextEditingController _pulseController = TextEditingController();

  Future<void> _addItem() async {
    await SQLHelper.createItem(_dateController.text.trim(), _upperController.text.trim(),
      _lowerController.text.trim(), _pulseController.text.trim(),);
    _refreshJournals();
    print('......nomer00000  elementa ${_journals.length}');
  }

  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(id, _dateController.text.trim(), _upperController.text.trim(),
      _lowerController.text.trim(), _pulseController.text.trim(),);
    _refreshJournals();
    print('......nomer00000  elementa ${_journals.length}');
  }

  @override
  void dispose() {
    _dateController.dispose();
    _upperController.dispose();
    _lowerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // bool _isLoading = true;

  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
    });
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('deleted'.tr,),),);
    _refreshJournals();
  }


  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal = _journals.firstWhere((element) => element['id'] == id);
     _dateController.text = existingJournal['date'];
      _upperController.text = existingJournal['title'];
      _lowerController.text = existingJournal['subtitle'];
      _pulseController.text = existingJournal['pulse'];
    }
    showModalBottomSheet(
        elevation: 5,
        isScrollControlled: true,
        context: context,
        builder: (_) => Container(
          padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: TextFormField(
                          maxLength: 3,
                          keyboardType: TextInputType.number,
                          controller: _upperController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            fillColor: Colors.black12,
                            filled: true,
                            label: Row(
                              children: [
                                Text(
                                  'upper'.tr,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text(
                                  '*',
                                  style: TextStyle(color: Colors.red),
                                )
                              ],
                            ),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(
                                  8,
                                ),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'required'.tr;
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: TextFormField(
                          maxLength: 3,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          controller: _lowerController,
                          decoration: InputDecoration(
                            fillColor: Colors.black12,
                            filled: true,
                            label: Row(
                              children: [
                                Text(
                                  'lower'.tr,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text(
                                  '*',
                                  style: TextStyle(color: Colors.red),
                                )
                              ],
                            ),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(
                                  8,
                                ),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'required'.tr;
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: TextFormField(
                          maxLength: 3,
                          keyboardType: TextInputType.number,
                          controller: _pulseController,
                          decoration: InputDecoration(
                            fillColor: Colors.black12,
                            filled: true,
                            label: Row(
                              children: [
                                Text(
                                  'pulse'.tr,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text(
                                  '*',
                                  style: TextStyle(color: Colors.red),
                                )
                              ],
                            ),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(
                                  8,
                                ),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'required'.tr;
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    maxLines: null,
                    readOnly: true,
                    keyboardType: TextInputType.number,
                    controller: _dateController,
                    decoration: InputDecoration(
                      fillColor: Colors.black12,
                      filled: true,
                      label: Row(
                        children: [
                          Text(
                            'date'.tr,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          const Text(
                            '*',
                            style: TextStyle(color: Colors.red),
                          )
                        ],
                      ),
                      prefixIcon: const Icon(Icons.calendar_today),
                      hintText: 'Kun_Oy_Yil',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            8,
                          ),
                        ),
                      ),
                    ),
                    onTap: () async {
                      String tdata =
                      DateFormat('HH:mm:ss').format(DateTime.now());
                      DateTime? pickeddate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2010),
                        lastDate: DateTime(2100),
                      );
                      if (pickeddate != null) {
                        setState(() {
                          _dateController.text =
                              DateFormat('dd-MM-yyyy\n  $tdata').format(pickeddate);
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'required'.tr;
                      }
                      return null;
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      if (id == null) {
                        await _addItem();
                      }
                      if (id != null) {
                        await _updateItem(id);
                      }
                      _upperController.text = '';
                      _lowerController.text = '';
                      _pulseController.text = '';
                      _dateController.text = '';
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Qo`shildi',
                          ),
                        ),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'theFieldsMustBeFilledIn'.tr,
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    id == null ? 'add'.tr : 'update'.tr,
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        leading: IconButton(
          onPressed: () {
            buildDialog(context);
          },
          icon: const Icon(
            Icons.language,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              backgroundColor: Colors.indigoAccent,
              onPressed: () {
                _showForm(null);
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
        centerTitle: true,
        title: Text('bloodPressureDiary'.tr),
      ),
      body: ListView.builder(
        itemCount: _journals.length,
          itemBuilder: (BuildContext context, int index) {
          return SizedBox(
            height: 70,
            child: Card(
              color: Colors.white70,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Column(
                        children: [
                          Text('date'.tr),
                          Text(_journals[index]['date'])
                        ],
                      ),
                      const SizedBox(width: 10,),
                      Column(
                        children: [
                          Text('upper'.tr),
                          const SizedBox(height: 10,),
                          Text(_journals[index]['title']),
                        ],
                      ),
                      const SizedBox(width: 10,),
                      Column(
                        children: [
                          Text('lower'.tr),
                          const SizedBox(height: 10,),
                          Text(_journals[index]['subtitle']),
                        ],
                      ),
                      const SizedBox(width: 10,),
                      Column(
                        children: [
                          Text('pulse'.tr),
                          const SizedBox(height: 10,),
                          Text(_journals[index]['pulse']),
                        ],
                      ),
                      const SizedBox(width: 5,),
                      IconButton(onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                  'wantChange'.tr),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('yes'.tr),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _showForm(_journals[index]['id']);
                                  },
                                ),
                                TextButton(
                                  child: Text('no'.tr),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                          icon: const Icon(Icons.edit)),
                      IconButton(onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                  'wantDelete'.tr),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('yes'.tr),
                                  onPressed: () {
                                    _deleteItem(
                                        _journals[index]['id']);
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text('no'.tr),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                          icon: const Icon(Icons.delete,),),
                    ],
                  ),
                ],
              ),
            ),
          );
          }
      )
    );
  }
}
