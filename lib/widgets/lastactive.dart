import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LastActive extends StatelessWidget {
  final String? uid;
  const LastActive({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Object?>>(
        stream:
            FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!;
            //    String online = data['online'];
            Timestamp lastSeen = data['lastTimeOnline'];
            DateTime timeA = lastSeen.toDate();
            String timeAgo = timeAg(timeA);
            //     bool isOnline = online == 'yes';
            //   bool isOnline = timeAgo == 'now';
            return Text(
              'Active $timeAgo',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            );
          }
          return const Text('');
        });
  }

  String timeAg(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365) {
      return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
    }
    if (diff.inDays > 30) {
      return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"} ago";
    }
    if (diff.inDays > 7) {
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
    }
    if (diff.inDays > 0) {
      return "${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago";
    }
    if (diff.inHours > 0) {
      return "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
    }
    if (diff.inMinutes > 0) {
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
    }
    return 'now'
        //  "just now"
        ;
  }
}
