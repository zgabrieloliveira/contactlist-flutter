import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/contactUtil.dart';

class ContactPage extends StatefulWidget {
  final Contact? contact;
  const ContactPage({this.contact});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  late bool _userEdited = false;
  late Contact _editedContact;
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {

    // add new contact case
    if (widget.contact == null) {
      _editedContact = Contact();
    }
    // edit contact case
    else {
      _editedContact = Contact.fromMap(widget.contact!.toMap());
    }

    _nameController.text = _editedContact.name;
    _emailController.text = _editedContact.email;
    _phoneController.text = _editedContact.phone;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    // the user can return to the previous screen any time
    return WillPopScope(
      // if the screen pops, alert dialog
      onWillPop: _requestPop,
      child: Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.teal,
              onPressed: () {
                if (_editedContact.name != '')
                  Navigator.pop(context, _editedContact);
                // the contact name must be filled
                else
                  FocusScope.of(context).requestFocus(_nameFocus);
              },
              child: const Icon(Icons.save)),
          appBar: AppBar(
              backgroundColor: Colors.teal,
              centerTitle: true,
              // the app bar contains the contact name
              title: Text(
                  _editedContact.name == ''
                      ? "Novo Contato"
                      : _editedContact.name,
                  style: const TextStyle(color: Colors.white)
              )
          ),
          // the list can be scrolled
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                GestureDetector(
                  // choose a profile pic for the contact, by the gallery
                  onTap: () {
                    _imagePicker
                        .pickImage(source: ImageSource.gallery)
                        .then((file) {
                      if (file == null)
                        return; // in case there's no chosen photo, return
                      else {
                        setState(() {
                          _editedContact.img = file.path;
                        });
                      }
                    });
                  },
                  // contact profile pic
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: _editedContact.img != ''
                          ? DecorationImage(
                              image: FileImage(File(_editedContact.img)),
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image: AssetImage("assets/images/person.png"),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
                TextField(
                  focusNode: _nameFocus,
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Nome"),
                  onChanged: (text) {
                    _userEdited = true;
                    setState(() {
                      _editedContact.name = text;
                    });
                  },
                ),
                TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: "Email"),
                    onChanged: (text) {
                      _userEdited = true;
                      _editedContact.email = text;
                    }),
                TextField(
                    controller: _phoneController,
                    focusNode: _phoneFocus,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: "Phone"),
                    onChanged: (text) {
                      _userEdited = true;
                      _editedContact.phone = text;
                    }),
              ],
            ),
          )),
    );
  }

  Future<bool> _requestPop() async {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Descartar Alterações?"),
              content: const Text("Se sair, as alterações serão perdidas"),
              actions: [
                ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed)) {
                          return Colors.teal.shade200;
                        }
                        return Colors.teal;
                      }),
                    ),
                    child: const Text("Cancelar")),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed)) {
                          return Colors.teal.shade200;
                        }
                        return Colors.teal;
                      }),
                    ),
                    child: const Text("Sim")),
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
