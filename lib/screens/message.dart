import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mychat/pages/allpage.dart';
import 'package:mychat/widgets/animated_rail_widget.dart';
import 'package:mychat/pages/callpage.dart';
import 'package:mychat/pages/contacts.dart';
import 'package:mychat/pages/favouritepage.dart';
import 'package:mychat/pages/msg_settings.dart';
import 'package:mychat/screens/searchscreen.dart';
import 'package:mychat/provider/user_data.dart';
import 'package:provider/provider.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  int index = 0;
  final selectedColor = Colors.blue;
  final unSelectedColor = Colors.grey;
  final labelstyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
  bool isExtended = false;
  String? currentUserId;
  String? myusername;
  String? myfirstname;
  String? mysecondname;
  String? myprofImg;
  bool isRail = true;
  String pageOrientation = "a";

  @override
  void initState() {
    super.initState();
    currentUserId = Provider.of<UserData>(context, listen: false).currentUserId;
    getUserInfo();
  }

  getUserInfo() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

    setState(() {
      myusername = docSnapshot.data()!['userName'];
      myfirstname = docSnapshot.data()!['firstName'];
      mysecondname = docSnapshot.data()!['secondName'];
      myprofImg = docSnapshot.data()!['profileImageUrl'];
    });
  }

  Widget buildPages() {
    switch (index) {
      case 0:
        return const AllPage();
      case 1:
        return const FavouritePage();
      case 2:
        return const CallPage();
      case 3:
        return const ContactScreen();
      default:
        return const AllPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isProfImg = myprofImg == null;
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              isRail ? Container() : circleAvatarAppBar(isProfImg),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('$myfirstname $mysecondname',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.verified,
                        color: Colors.blue,
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@$myusername',
                    style: const TextStyle(fontSize: 14, color: Colors.blue),
                  )
                ],
              ),
            ],
          ),
          actions: [
            isRail
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        isRail = false;
                      });
                    },
                    icon: const Icon(Icons.accessibility_new_rounded))
                : IconButton(
                    onPressed: () {
                      setState(() {
                        isRail = true;
                      });
                    },
                    icon: const Icon(Icons.architecture_rounded)),
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const SearchScreenS()));
                },
                icon: const Icon(Icons.search))
          ],
        ),
        body: isRail ? railScreen(isProfImg) : screen());
  }

  Widget railScreen(bool isProfImg) {
    return Row(
      children: [
        NavigationRail(
          extended: isExtended,
          leading: circleAvatar(isProfImg),
          trailing: AnimatedRailWidget(
            child: isExtended
                ? InkWell(
                    onTap: openSettingPage,
                    child: Row(
                      children: const [
                        Icon(Icons.settings, color: Colors.white, size: 35),
                        SizedBox(width: 10),
                        Text(
                          'Settings',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  )
                : IconButton(
                    onPressed: openSettingPage,
                    icon: const Icon(Icons.settings,
                        color: Colors.white, size: 35)),
          ),
          destinations: const [
            NavigationRailDestination(
                icon: Icon(Icons.home), label: Text('All')),
            NavigationRailDestination(
                icon: Icon(Icons.favorite_border),
                selectedIcon: Icon(Icons.favorite),
                label: Text('Favourite')),
            NavigationRailDestination(
                icon: Icon(Icons.phone), label: Text('Calls')),
            NavigationRailDestination(
                icon: Icon(Icons.contacts), label: Text('Contacts'))
          ],
          selectedIndex: index,
          selectedLabelTextStyle: labelstyle.copyWith(color: selectedColor),
          unselectedLabelTextStyle: labelstyle.copyWith(color: unSelectedColor),
          onDestinationSelected: (index) => setState(() => this.index = index),
          selectedIconTheme: IconThemeData(color: selectedColor, size: 44),
          unselectedIconTheme: IconThemeData(color: unSelectedColor, size: 40),
        ),
        Expanded(child: buildPages())
      ],
    );
  }

  openSettingPage() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const MessageSettings()));
  }

  circleAvatar(isProfImg) {
    return SizedBox(
      width: 55,
      height: 55,
      child: Material(
        clipBehavior: Clip.hardEdge,
        shape: const CircleBorder(),
        child: Ink.image(
          width: 55,
          height: 55,
          fit: BoxFit.fitHeight,
          image: isProfImg
              ? const CachedNetworkImageProvider('')
              : CachedNetworkImageProvider(myprofImg!),
          child: InkWell(
            child: isProfImg
                ? Center(
                    child: Text(
                      '${myfirstname![0].toUpperCase()} ${mysecondname![0].toUpperCase()}',
                      style: const TextStyle(fontSize: 20),
                    ),
                  )
                : Container(),
            onTap: () => setState(() => isExtended = !isExtended),
          ),
        ),
      ),
    );
  }

  circleAvatarAppBar(isProfImg) {
    return CircleAvatar(
        radius: 21,
        backgroundColor: Colors.blueGrey,
        child: isProfImg
            ? Center(
                child: Text(
                '${myfirstname![0].toUpperCase()} ${mysecondname![0].toUpperCase()}',
                style: const TextStyle(color: Colors.amberAccent),
              ))
            : CircleAvatar(
                radius: 21,
                backgroundImage: CachedNetworkImageProvider(myprofImg!),
              ));
  }

  Widget screen() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 7),
          toggleButton(),
          const SizedBox(height: 10),
          mainBody(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  setPageOrientation(String pageOrientation) {
    setState(() {
      this.pageOrientation = pageOrientation;
    });
  }

  toggleButton() {
    return Container(
      height: 40,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: Colors.transparent),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              setPageOrientation("a");
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.2,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: pageOrientation == 'a'
                      ? Colors.pink
                      : Colors.transparent),
              child: Center(
                  child: Icon(
                Icons.home,
                color: Colors.white,
                size: pageOrientation == 'a' ? 30 : 25,
              )),
            ),
          ),
          InkWell(
            onTap: () {
              setPageOrientation("b");
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.2,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: pageOrientation == 'b'
                      ? Colors.pink
                      : Colors.transparent),
              child: Center(
                  child: Icon(
                pageOrientation == 'b'
                    ? Icons.favorite_outline_rounded
                    : Icons.favorite_border_rounded,
                color: Colors.white,
                size: pageOrientation == 'b' ? 30 : 25,
              )),
            ),
          ),
          InkWell(
            onTap: () {
              setPageOrientation("c");
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.2,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: pageOrientation == 'c'
                      ? Colors.pink
                      : Colors.transparent),
              child: Center(
                  child: Icon(
                Icons.call,
                color: Colors.white,
                size: pageOrientation == 'c' ? 30 : 25,
              )),
            ),
          ),
          InkWell(
            onTap: () {
              setPageOrientation("d");
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.2,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: pageOrientation == 'd'
                      ? Colors.pink
                      : Colors.transparent),
              child: Center(
                  child: Icon(
                Icons.contacts,
                color: Colors.white,
                size: pageOrientation == 'd' ? 30 : 25,
              )),
            ),
          ),
          InkWell(
            onTap: () {
              setPageOrientation("e");
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.2,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: pageOrientation == 'e'
                      ? Colors.pink
                      : Colors.transparent),
              child: Center(
                  child: Icon(
                Icons.settings,
                color: Colors.white,
                size: pageOrientation == 'e' ? 30 : 25,
              )),
            ),
          ),
        ],
      ),
    );
  }

  mainBody() {
    if (pageOrientation == 'a') {
      return SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: ChatListContainer(
          currentUserId: currentUserId!,
        ),
      );
    } else if (pageOrientation == 'b') {
      return const FavouritePage();
    } else if (pageOrientation == 'c') {
      return const CallPage();
    } else if (pageOrientation == 'd') {
      return const ContactScreen();
    } else if (pageOrientation == 'e') {
      return const MessageSettings();
    }
  }
}
