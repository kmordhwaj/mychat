import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mychat/chat/chatscreen.dart';
import 'package:mychat/widgets/progress.dart';

class SearchScreenS extends StatefulWidget {
  const SearchScreenS({Key? key}) : super(key: key);

  @override
  State<SearchScreenS> createState() => _SearchScreenSState();
}

class _SearchScreenSState extends State<SearchScreenS> {
  Stream<QuerySnapshot>? searchResultsFuture;
  String query = '';
  TextEditingController searchController = TextEditingController();

  handleSearch(String query) {
    Stream<QuerySnapshot> users = FirebaseFirestore.instance
        .collection('users')
        .where('userName', isGreaterThanOrEqualTo: query)
        .snapshots();

    setState(() {
      searchResultsFuture = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 20),
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: TextField(
                controller: searchController,
                onChanged: (String val) {
                  setState(() {
                    query = val;
                  });
                  handleSearch(query);
                },
                cursorColor: Colors.grey,
                autofocus: true,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 35),
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                        onPressed: () {
                          searchController.clear();
                        },
                        icon: const Icon(Icons.close, color: Colors.white)),
                    border: InputBorder.none,
                    hintText: 'Search',
                    hintStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 35,
                        color: Color(0x88ffffff))),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
            child: searchResultsFuture == null
                ? Container()
                : buildSearchResults()));
  }

  buildSearchResults() {
    return StreamBuilder(
        stream: searchResultsFuture,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<Column> searchResults = [];

          for (var doc in snapshot.data!.docs) {
            searchResults.add(Column(
              children: [
                ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ChatScreen(profileId: doc['id'])));
                  },
                  leading: circleavatar(doc),
                  title: Text(
                    '${doc['firstName']} ${doc['secondName']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(doc['userName'],
                      style: const TextStyle(color: Colors.lightBlue)),
                  trailing: ElevatedButton(
                      onPressed: () {}, child: const Text('Follow')),
                ),
                const Divider(height: 4, color: Colors.transparent)
              ],
            ));
          }
          return Column(children: searchResults);
        });
  }

  circleavatar(doc) {
    String firstname = doc['firstName'];
    String secondname = doc['secondName'];
    String? profImg = doc['profileImageUrl'];
    bool isProfImg = profImg == null;
    return CircleAvatar(
      backgroundColor: Colors.purple.shade800,
      child: isProfImg
          ? Center(
              child: Text(
                  '${firstname[0].toUpperCase()} ${secondname[0].toUpperCase()}'),
            )
          : CircleAvatar(backgroundImage: CachedNetworkImageProvider(profImg)),
    );
  }
}
