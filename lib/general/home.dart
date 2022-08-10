// ignore_for_file: avoid_print, unnecessary_this
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mychat/screens/message.dart';
import 'package:mychat/provider/user_data.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  static const String id = 'home';

  const Home({
    Key? key,
  }) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  final PageController homePageController = PageController();
  String? currentUserId;
  bool cameFromRegistration = false;
  int pageIndex = 0;
  String? changes;
  Timestamp lastTimeOnline = Timestamp.fromDate(DateTime.now());
  final _formKey1 = GlobalKey<FormState>();
  final TextEditingController userNameController = TextEditingController();
  Stream<QuerySnapshot>? searchResultsFuture;
  String query = '';
  bool unAvail = false;
  bool superunavail = false;
  String notavailable = 'kkcbdghjndhbnpmnmjjbs';

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final isBg = state == AppLifecycleState.paused;
    final isClosed = state == AppLifecycleState.detached;
    final isScreen = state == AppLifecycleState.resumed;
    final DateTime dateNow = DateTime.now();
    final Timestamp timeNow = Timestamp.fromDate(dateNow);

    isBg || isScreen == true || isClosed == false
        ? setState(() {
            // SET ONLINE
            changes = 'User is Online';
            //    online = 'yes';
            lastTimeOnline = timeNow;
          })
        : setState(() {
            //SET  OFFLINE
            changes = ' User is Offline';
            //    online = 'no';
            lastTimeOnline = timeNow;
          });
    print('CHANGES IS : $changes ');
    FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
      //'online': online,
      'lastTimeOnline': lastTimeOnline
    });
  }

  @override
  void initState() {
    super.initState();
    cameFromRegistration =
        Provider.of<UserData>(context, listen: false).cameFromRegisterScreen;
    currentUserId = Provider.of<UserData>(context, listen: false).currentUserId;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return cameFromRegistration
        ? Scaffold(
            body: SizedBox(
              height: MediaQuery.of(context).size.height * 1.5,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.height * 0.15,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey1,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: userNameController,
                          //  autofocus: false,
                          style: const TextStyle(
                              fontSize: 20, color: Colors.white),
                          decoration: const InputDecoration(
                              labelText: 'Username',
                              prefixIcon: Icon(CupertinoIcons.profile_circled,
                                  color: Colors.white),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              labelStyle:
                                  TextStyle(fontSize: 15, color: Colors.white)),

                          onChanged: (val) {
                            setState(() {
                              query = val;
                            });
                            handleSearch(query);
                          },
                          onSaved: (value) {
                            userNameController.text = value!;
                          },
                        ),
                        searchResultsFuture == null ? Container() : result(),
                        const SizedBox(height: 20.0),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 8,
                              primary: Colors.red,
                              fixedSize: const Size(200, 40),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          onPressed: () async {
                            await adduserName();
                          },
                          child: const Text(
                            'Confirm',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  superunavail
                      ? const Text(
                          'Sorry, username should be minimum of 3 characters',
                          style: TextStyle(color: Colors.red, fontSize: 20),
                        )
                      : unAvail
                          ? Text(
                              'Sorry, @$notavailable is not available',
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 20),
                            )
                          : Container()
                ],
              ),
            ),
          )
        : const Scaffold(
            body: MessageScreen(),
          );
  }

  handleSearch(String query) {
    if (query == '') {
      setState(() {
        searchResultsFuture = null;
      });
    } else {
      Stream<QuerySnapshot> users = FirebaseFirestore.instance
          .collection('users')
          .where('userName', isEqualTo: query)
          //  .limit(1)
          .snapshots();
      setState(() {
        searchResultsFuture = users;
      });
    }
  }

  result() {
    if (query.length < 3) {
      return const Text('Username should be minimum of 3 characters!',
          style: TextStyle(color: Colors.orange, fontSize: 17));
    } else {
      return StreamBuilder(
          stream: searchResultsFuture,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              int a = snapshot.data!.docs.length;
              if (a == 0) {
                return available();
              } else {
                return unAvailable();
              }
            } else {
              return available();
            }
          });
    }
  }

  Widget available() {
    return Row(
      children: [
        Text('@$query',
            style: const TextStyle(
                color: Colors.lightGreen,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        const Text(' is available',
            style: TextStyle(color: Colors.lightGreen, fontSize: 17)),
      ],
    );
  }

  Widget unAvailable() {
    return Row(
      children: [
        Text('@$query',
            style: const TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18)),
        const Text(' is taken by someone',
            style: TextStyle(color: Colors.blue, fontSize: 17)),
      ],
    );
  }

  adduserName() async {
    if (userNameController.text.length > 2) {
      setState(() {
        this.superunavail = false;
      });
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userName', isEqualTo: userNameController.text)
          .get();
      int length = snapshot.docs.length;

      if (length == 0) {
        setState(() {
          this.unAvail = false;
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .update({
          'userName': userNameController.text
          //  query
        });
        changeState();
      } else {
        setState(() {
          this.unAvail = true;
          this.notavailable = userNameController.text;
        });
      }

      /*   for (final doc in snapshot.docs) {
        final snapshot1 = await FirebaseFirestore.instance
            .collection('users')
            .doc(doc.id)
            .get();
        if (snapshot1.exists) {
          setState(() {
            this.unAvail = true;
          });
        }
      } */

      /*  await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({
        'userName': userNameController.text
        //  query
      }); */
    } else {
      setState(() {
        this.superunavail = true;
      });
    }
  }

  changeState() {
    Provider.of<UserData>(context, listen: false).cameFromRegisterScreen =
        false;
    setState(() {
      this.cameFromRegistration = false;
    });
  }
}
