import 'dart:io';
import 'package:agenda_contatos/ui/contactpage.dart';
import 'package:agenda_contatos/utils/contactUtil.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions { az, za }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactUtil contactUtil = ContactUtil();
  List<Contact>? _contacts = [];

  @override
  void initState() {
    // start db, then show the saved contacts
    contactUtil.initDb().then((_) {
      contactUtil.getAllContacts().then((list) {
        setState(() {
          _contacts = list;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _showContactPage,
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Contatos"),
          backgroundColor: Colors.teal,
          centerTitle: true,
          actions: [
            PopupMenuButton<OrderOptions>(
              itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
                const PopupMenuItem<OrderOptions>(
                  value: OrderOptions.az,
                  child: Text("Ordenar de A a Z"),
                ),
                const PopupMenuItem<OrderOptions>(
                  value: OrderOptions.za,
                  child: Text("Ordenar de Z a A"),
                )
              ],
              onSelected: _orderList,
            )
          ],
        ),
        body: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: _contacts?.length,
            itemBuilder: (context, index) {
              return _buildContact(context, index);
            }));
  }

  void _showContactPage({Contact? contact}) async {
    // go to the page of the contact chosen
    final recContact = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ContactPage(contact: contact)));

    if (recContact != null) {
      // if the contact already exists, update
      if (contact != null) {
        await contactUtil.updateContact(recContact);
      }
      // if it doesn't, insert on the db
      else {
        await contactUtil.saveContact(recContact);
      }
      // updates the contact list shown
      contactUtil.getAllContacts().then((list) {
        setState(() {
          _contacts = list;
        });
      });
    }
  }

  // call, edit and delete
  void _showOptions(context, index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
              onClosing: () {},
              builder: (context) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                          onPressed: () {
                            // goes to the calling app
                            launch('tel:${_contacts![index].phone}');
                            Navigator.pop(context); // previous screen
                          },
                          style: const ButtonStyle(),
                          child: const Text("Ligar",
                              style:
                                  TextStyle(color: Colors.teal, fontSize: 20))),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context); // exiting options widget
                            _showContactPage(contact: _contacts![index]);
                          },
                          child: const Text("Editar",
                              style:
                                  TextStyle(color: Colors.teal, fontSize: 20))),
                      TextButton(
                          onPressed: () {
                            contactUtil.deleteContact(_contacts![index].id);
                            // updating the screen current state
                            setState(() {
                              _contacts!.removeAt(index); // remove the chosen contact
                              Navigator.pop(context); // previous screen
                            });
                          },
                          child: const Text("Excluir",
                              style:
                                  TextStyle(color: Colors.teal, fontSize: 20))),
                    ],
                  ),
                );
              });
        });
  }

  Widget _buildContact(context, index) {
    if (_contacts != null && index >= 0 && index < _contacts!.length) {
      return GestureDetector(
        // contact card
        child: Card(
            child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: _contacts![index].img != ''
                      ? DecorationImage(
                          image: FileImage(File(_contacts![index].img)),
                          fit: BoxFit.cover,
                        )
                      : const DecorationImage(
                          image: AssetImage("assets/images/person.png"),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 10),
                  // text fields
                  child: Column(
                    children: [
                      Text(_contacts?[index].name ?? "",
                          style: const TextStyle(
                              fontSize: 21, fontWeight: FontWeight.bold)),
                      Text(_contacts?[index].email ?? "",
                          style: const TextStyle(fontSize: 16)),
                      Text(_contacts?[index].phone ?? "",
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ))
            ],
          ),
        )),
        onTap: () => _showOptions(context, index), // call, edit, delete
      );
    } else {
      return Container();
    }
  }

  // order the contact list by alphabetic order
  void _orderList(OrderOptions result) {
     switch(result) {
       case OrderOptions.az:
         _contacts?.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
         break;
       case OrderOptions.za:
         _contacts?.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
         break;
     }
     // updating the current state of the screen
     setState(() {
     });

  }

}
