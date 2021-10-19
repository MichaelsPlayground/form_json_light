import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

// based on https://flutter.de/artikel/flutter-formulare.html
// https://github.com/coodoo-io/flutter-samples
// edited to null safety
// access to form data

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyFormPage(title: 'RSA Kryptographie'),
    );
  }
}

class MyFormPage extends StatefulWidget {
  MyFormPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyFormPageState createState() => _MyFormPageState();
}

class _MyFormPageState extends State<MyFormPage> {
  @override
  void initState() {
    super.initState();
    descriptionController.text = txtDescription;
  }

  final _formKey = GlobalKey<FormState>();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController plaintextController = TextEditingController();
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController numberEditingController = TextEditingController();
  TextEditingController keyController = TextEditingController();
  TextEditingController outputController = TextEditingController();

  String dropdownValue = 'AES-256 CBC PBKDF2 encryption';
  String txtDescription = 'Verschlüsselung mit AES-256 im Modus CBC.'
      '\nDer Schlüssel wird mit PBKDF2 und 10.000 Iterationen abgeleitet.';

  static Future<ClipboardData?> getData(String format) async {
    final Map<String, dynamic>? result =
        await SystemChannels.platform.invokeMethod(
      'Clipboard.getData',
      format,
    );
    if (result == null) return null;
    return ClipboardData(text: result['text'] as String?);
  }

  String _loadKey() {
    String _key = '-----BEGIN PRIVATE KEY-----\n'
        'MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDwSZYlRn86zPi9\n'
        'e1RTZL7QzgE/36zjbeCMyOhf6o/WIKeVxFwVbG2FAY3YJZIxnBH+9j1XS6f+ewjG\n'
        'FlJY4f2IrOpS1kPiO3fmOo5N4nc8JKvjwmKtUM0t63uFFPfs69+7mKJ4w3tk2mSN\n'
        '4gb8J9P9BCXtH6Q78SdOYvdCMspA1X8eERsdLb/jjHs8+gepKqQ6+XwZbSq0vf2B\n'
        'MtaAB7zTX/Dk+ZxDfwIobShPaB0mYmojE2YAQeRq1gYdwwO1dEGk6E5J2toWPpKY\n'
        '/IcSYsGKyFqrsmbw0880r1BwRDer4RFrkzp4zvY+kX3eDanlyMqDLPN+ghXT1lv8\n'
        'snZpbaBDAgMBAAECggEBAIVxmHzjBc11/73bPB2EGaSEg5UhdzZm0wncmZCLB453\n'
        'XBqEjk8nhDsVfdzIIMSEVEowHijYz1c4pMq9osXR26eHwCp47AI73H5zjowadPVl\n'
        'uEAot/xgn1IdMN/boURmSj44qiI/DcwYrTdOi2qGA+jD4PwrUl4nsxiJRZ/x7PjL\n'
        'hMzRbvDxQ4/Q4ThYXwoEGiIBBK/iB3Z5eR7lFa8E5yAaxM2QP9PENBr/OqkGXLWV\n'
        'qA/YTxs3gAvkUjMhlScOi7PMwRX9HsrAeLKbLuC1KJv1p2THUtZbOHqrAF/uwHaj\n'
        'ygUblFaa/BTckTN7PKSVIhp7OihbD04bSRrh+nOilcECgYEA/8atV5DmNxFrxF1P\n'
        'ODDjdJPNb9pzNrDF03TiFBZWS4Q+2JazyLGjZzhg5Vv9RJ7VcIjPAbMy2Cy5BUff\n'
        'EFE+8ryKVWfdpPxpPYOwHCJSw4Bqqdj0Pmp/xw928ebrnUoCzdkUqYYpRWx0T7YV\n'
        'RoA9RiBfQiVHhuJBSDPYJPoP34kCgYEA8H9wLE5L8raUn4NYYRuUVMa+1k4Q1N3X\n'
        'Bixm5cccc/Ja4LVvrnWqmFOmfFgpVd8BcTGaPSsqfA4j/oEQp7tmjZqggVFqiM2m\n'
        'J2YEv18cY/5kiDUVYR7VWSkpqVOkgiX3lK3UkIngnVMGGFnoIBlfBFF9uo02rZpC\n'
        '5o5zebaDImsCgYAE9d5wv0+nq7/STBj4NwKCRUeLrsnjOqRriG3GA/TifAsX+jw8\n'
        'XS2VF+PRLuqHhSkQiKazGr2Wsa9Y6d7qmxjEbmGkbGJBC+AioEYvFX9TaU8oQhvi\n'
        'hgA6ZRNid58EKuZJBbe/3ek4/nR3A0oAVwZZMNGIH972P7cSZmb/uJXMOQKBgQCs\n'
        'FaQAL+4sN/TUxrkAkylqF+QJmEZ26l2nrzHZjMWROYNJcsn8/XkaEhD4vGSnazCu\n'
        '/B0vU6nMppmezF9Mhc112YSrw8QFK5GOc3NGNBoueqMYy1MG8Xcbm1aSMKVv8xba\n'
        'rh+BZQbxy6x61CpCfaT9hAoA6HaNdeoU6y05lBz1DQKBgAbYiIk56QZHeoZKiZxy\n'
        '4eicQS0sVKKRb24ZUd+04cNSTfeIuuXZrYJ48Jbr0fzjIM3EfHvLgh9rAZ+aHe/L\n'
        '84Ig17KiExe+qyYHjut/SC0wODDtzM/jtrpqyYa5JoEpPIaUSgPuTH/WhO3cDsx6\n'
        '3PIW4/CddNs8mCSBOqTnoaxh\n'
        '-----END PRIVATE KEY-----'; // important last crlf
    return _key;
  }

  String _returnJson(String data) {
    var parts = data.split(':');
    var algorithm = parts[0];
    var iterations = parts[1];
    var plaintext = parts[2];
    var salt = parts[3];
    var nonce = parts[4];
    var ciphertext = parts[5];
    var gcmTag = parts[6];

    String exportData = '{"algorithm":"' +
        algorithm +
        '","iterations":"' +
        iterations +
        '","plaintext":"' +
        plaintext +
        '","salt":"' +
        salt +
        '","nonce":"' +
        nonce +
        '","ciphertext":"' +
        ciphertext +
        '","gcmTag":"' +
        gcmTag +
        '"}';

    /*
    var exportData = JSON.encode({
    'framework': "Flutter",
    'tags': ['flutter', 'snippets'],
    'versions': '0.0.20',
    'task': 13511,
    });
 */
    //String exportData = '{"framework":"Flutter","tags":["flutter","snippets"],"versions":"0.0.20","task":13511}';
    //outputController.text = exportData;
    return exportData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      //SizedBox(height: 20),
                      TextFormField(
                        controller: descriptionController,
                        keyboardType: TextInputType.text,
                        autocorrect: false,
                        enabled: false,
                        // false = disabled, true = enabled
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Beschreibung',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: plaintextController,
                        keyboardType: TextInputType.text,
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText: 'Klartext oder verschlüsselter Text',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bitte Daten eingeben';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.grey,
                                textStyle: TextStyle(color: Colors.white)),
                            onPressed: () {
                              plaintextController.text = '';
                            },
                            child: Text('Feld löschen'),
                          ),
                          SizedBox(width: 15),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.blue,
                                textStyle: TextStyle(color: Colors.white)),
                            onPressed: () async {
                              final data = await Clipboard.getData(Clipboard.kTextPlain);
                              plaintextController.text = data!.text!;
                            },
                            child: Text('aus Zwischenablage einfügen'),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: keyController,
                        enabled: true,
                        // false = disabled, true = enabled
                        maxLines: 5,
                        maxLength: 2000,
                        style: TextStyle(
                          fontSize: 15,
                        ),
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          labelText:
                              'Privater Schlüssel für RSA in PKCS#8 encoded PEM',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bitte Daten eingeben';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.grey,
                                textStyle: TextStyle(color: Colors.white)),
                            onPressed: () {
                              keyController.text = '';
                            },
                            child: Text('Feld löschen'),
                          ),
                          SizedBox(width: 15),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.blue,
                                textStyle: TextStyle(color: Colors.white)),
                            onPressed: () {
                              keyController.text = _loadKey();

                              //readData2();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Daten wurden gelesen')),
                              );
                              // Wenn alle Validatoren der Felder des Formulars g¸ltig sind.
                            },
                            child: Text('Datei laden'),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        obscureText: false, // true zeigt Sternchen
                        decoration: InputDecoration(
                          labelText: 'Passwort',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bitte Daten eingeben';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.grey,
                                textStyle: TextStyle(color: Colors.white)),
                            onPressed: () {
                              // reset() setzt alle Felder wieder auf den Initalwert zurück.
                              _formKey.currentState!.reset();
                            },
                            child: Text('Formulardaten löschen'),
                          ),
                          SizedBox(width: 25),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.blue,
                                textStyle: TextStyle(color: Colors.white)),
                            onPressed: () {
                              // Wenn alle Validatoren der Felder des Formulars g¸ltig sind.
                              if (_formKey.currentState!.validate()) {
                                print(
                                    "Formular ist gültig und kann verarbeitet werden");
                                String plaintext = plaintextController.text;

                                // If the form is valid, display a snackbar. In the real world,
                                // you'd often call a server or save the information in a database.
                                String _formdata = 'AES-256 GCM PBKDF2' +
                                    ':' +
                                    '10000' +
                                    ':' +
                                    plaintext +
                                    ':' +
                                    '0IVpqIziJ4OtrhVKehdgLHpukOuOSPrlX202Wc4voRQ=:0HKptx5YN0+zIjLw:zBZLulzazLa5NfmNX74LUDb8WHQnnW4qdh2hiCOaqauSVzNc9rTnMFct7g==:Wi9iyNJ+Wl08Gaid1l5EjQ==';
                                //'output is (Base64) salt : (Base64) nonce : (Base64) ciphertext : (Base64) gcmTag';
                                outputController.text = _returnJson(_formdata);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(_formdata)),
                                );
                              } else {
                                print("Formular ist nicht gültig");
                              }
                            },
                            child: Text('verschlüsseln'),
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: outputController,
                        maxLines: 5,
                        maxLength: 500,
                        decoration: InputDecoration(
                          labelText: 'Ausgabe',
                          hintText: 'Ausgabe',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.grey,
                                textStyle: TextStyle(color: Colors.white)),
                            onPressed: () {
                              outputController.text = '';
                            },
                            child: Text('Feld löschen'),
                          ),
                          SizedBox(width: 15),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.blue,
                                textStyle: TextStyle(color: Colors.white)),
                            onPressed: () async {

                              final data = ClipboardData(text: outputController.text);
                              await Clipboard.setData(data);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                  content: const Text('Copied to clipboard!'),
                                ),
                              );
                            },
                            child: Text('in Zwischenablage kopieren'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ))));
  }
}
