// ignore_for_file: unnecessary_string_escapes, unnecessary_this, use_build_context_synchronously

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:image/image.dart' as im;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:mychat/widgets/lastactive.dart';
import 'package:mychat/provider/user_data.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:random_string/random_string.dart';
import 'package:mychat/services/database.dart';
import 'package:mychat/chat/views/chatmsgTile.dart';
import 'package:mychat/chat/views/pdfmsgTile.dart';
import 'package:mychat/chat/views/photo_preview.dart';
import 'package:mychat/chat/views/photomsgTile.dart';
import 'package:mychat/chat/views/video_preview.dart';
import 'package:mychat/chat/views/video_widget.dart';
import 'package:mychat/chat/views/videomsgtile.dart';
import 'package:mychat/chat/views/viewpdf.dart';

class ChatScreen extends StatefulWidget {
  final String? profileId;
  final Function? abc;
  final String? caption;

  const ChatScreen({
    Key? key,
    required this.profileId,
    this.abc,
    this.caption,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String chatRoomId = '';
  String messageId = '';
  bool isUploading = false;
  String? currentUserId;
  TextEditingController msgController = TextEditingController();
  Stream<QuerySnapshot>? messageStream;
  final ImagePicker? imgPicker = ImagePicker();
  File? mFile;
  String username = '';
  String firstname = '';
  String secondname = '';
  String? profImg;
  String myusername = '';
  String myfirstname = '';
  String mysecondname = '';
  String? myprofImg;
  final _formKey = GlobalKey<FormState>();
  String fileType = 'photo';
  bool chatScr = true;
  int mLength = 0;
  File? videoPreviewImage;
  TextEditingController captionController = TextEditingController();
  bool longPressed = false;
  bool longPressedAgain = false;
  String? replyPreviousText;
  String? replyPreviousMedia;
  int? replyPreviousMediaLength;
  bool isReplyingMusic = false;
  bool isReplyingPdf = false;
  bool replyButtonPressed = false;
  bool isReplying = false;
  String appbarLongPressed = 'chat';
  String appbarLongPressedAgain = 'chat';
  bool longPressedC = false;
  bool longPressedP = false;
  bool longPressedM = false;
  bool longPressedVd = false;
  bool longPressedVo = false;
  bool longPressedPd = false;
  bool longPressedG = false;
  String msgId = '';
  List<String> list = <String>[];

  final storageRef = FirebaseStorage.instance.ref();
  Reference imagesRef = FirebaseStorage.instance.ref().child("images");

  getMyInfo() {
    chatRoomId = getChatRoomId(widget.profileId!, currentUserId!);
  }

  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return '$b\_$a';
    } else {
      return '$a\_$b';
    }
  }

  addMessage(bool sendClicked) async {
    if (msgController.text != '') {
      String message = msgController.text;

      DateTime dateNow = DateTime.now();

      var lastMsgTs = Timestamp.fromDate(dateNow);

      //messageId
      if (messageId == '') {
        messageId = randomAlphaNumeric(12);
      }

      Map<String, dynamic> messageInfo = {
        'messageId': messageId,
        'message': message,
        'voiceMsgUrl': null,
        'musicMsgUrl': null,
        'photoMsgUrl': null,
        'videoMsgUrl': null,
        'videoPreviewImage': null,
        'pdfMsgUrl': null,
        'mediaLength': null,
        'sendBy': '$myfirstname $mysecondname',
        'ts': lastMsgTs,
        'imageUrl': myprofImg,
        'isDeleted': false
      };

      DatabaseMethods()
          .addMessage(chatRoomId, messageId, messageInfo)
          .then((value) {
        Map<String, dynamic> lastMessageInfo = {
          'messageId': messageId,
          'lastMessage': message,
          'lastVoiceMsgUrl': null,
          'lastMusicMsgUrl': null,
          'lastPhotoMsgUrl': null,
          'lastVideoMsgUrl': null,
          'lastPdfMsgUrl': null,
          'lastMediaLength': mLength,
          'lastMessageSendTs': lastMsgTs,
          'lastMessageSendByFN': myfirstname,
          'lastMessageSendBySN': mysecondname,
          'lastMessageSendToFN': firstname,
          'lastMessageSendToSN': secondname,
          'lastMessageSenderDp': myprofImg,
          'lastMessageSendDp': profImg,
          'lastMessageSenderId': currentUserId,
          'lastMessageSendId': widget.profileId,
          'users': <String>[currentUserId!, widget.profileId!],
          'isDeleted': false
        };

        DatabaseMethods().updateLastMessageSend(chatRoomId, lastMessageInfo);

        if (sendClicked) {
          //remove the text in the message field
          msgController.text = '';
          //make msg id blank to get regenerated on next msg send
          messageId = '';
        }
      });
    }
  }

  addMessage1(bool sendClicked) async {
    if (msgController.text != '') {
      String message = msgController.text;

      DateTime dateNow = DateTime.now();

      var lastMsgTs = Timestamp.fromDate(dateNow);

      //messageId
      if (messageId == '') {
        messageId = randomAlphaNumeric(12);
      }

      Map<String, dynamic> messageInfo = {
        'messageId': messageId,
        'message': message,
        'voiceMsgUrl': null,
        'musicMsgUrl': null,
        'photoMsgUrl': null,
        'videoMsgUrl': null,
        'videoPreviewImage': null,
        'pdfMsgUrl': null,
        'mediaLength': null,
        'sendBy':
            //  myusername,
            '$myfirstname $mysecondname',
        'ts': lastMsgTs,
        'imageUrl': myprofImg,
        'isDeleted': false,
        'isReplied': true
      };

      DatabaseMethods()
          .addMessage(chatRoomId, messageId, messageInfo)
          .then((value) {
        Map<String, dynamic> lastMessageInfo = {
          'messageId': messageId,
          'lastMessage': message,
          'lastVoiceMsgUrl': null,
          'lastMusicMsgUrl': null,
          'lastPhotoMsgUrl': null,
          'lastVideoMsgUrl': null,
          'lastPdfMsgUrl': null,
          'lastMediaLength': mLength,
          'lastMessageSendTs': lastMsgTs,
          'lastMessageSendByFN': myfirstname,
          'lastMessageSendBySN': mysecondname,
          //  'lastMessage'
          'lastMessageSendToFN': firstname,
          'lastMessageSendToSN': secondname,
          'lastMessageSenderDp': myprofImg,
          'lastMessageSendDp': profImg,
          'lastMessageSenderId': currentUserId,
          'lastMessageSendId': widget.profileId,
          'users': <String>[currentUserId!, widget.profileId!],
          'isDeleted': false
        };

        DatabaseMethods().updateLastMessageSend(chatRoomId, lastMessageInfo);

        if (sendClicked) {
          //remove the text in the message field
          msgController.text = '';
          //make msg id blank to get regenerated on next msg send
          messageId = '';
        }
      });
    }
  }

  replyWidget() {
    bool isReplyPreviousMedia = replyPreviousMedia == null;
    return Container(
      height: replyButtonPressed ? 70 : 40,
      color: replyButtonPressed
          ? Colors.green.withOpacity(0.4)
          : Colors.grey.shade800,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: replyButtonPressed
            ? Column(
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.reply,
                        color: Colors.lightBlue,
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Replying to',
                        style: TextStyle(color: Colors.lightBlue, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      isReplyPreviousMedia
                          ? isReplyingMusic
                              ? Container(
                                  height: 34,
                                  width: 34,
                                  decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      gradient: LinearGradient(colors: [
                                        Colors.deepPurple,
                                        Colors.purple
                                      ])),
                                  child: const Center(
                                      child: Icon(CupertinoIcons.music_note)),
                                )
                              : isReplyingPdf
                                  ? Container(
                                      height: 34,
                                      width: 34,
                                      decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                          gradient: LinearGradient(colors: [
                                            Colors.orange,
                                            Colors.pink
                                          ])),
                                      child: Center(
                                          child: Text('.Pdf',
                                              style: TextStyle(
                                                  color:
                                                      Colors.blue.shade900))),
                                    )
                                  : Container()
                          : Container(
                              height: 34,
                              width: 34,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: CachedNetworkImageProvider(
                                          replyPreviousMedia!),
                                      fit: BoxFit.cover))),
                      const SizedBox(width: 7),
                      Text(replyPreviousText!,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15))
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  isReplyPreviousMedia
                      ? isReplyingMusic
                          ? Container(
                              height: 34,
                              width: 34,
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  gradient: LinearGradient(colors: [
                                    Colors.deepPurple,
                                    Colors.purple
                                  ])),
                              child: const Center(
                                  child: Icon(CupertinoIcons.music_note)),
                            )
                          : isReplyingPdf
                              ? Container(
                                  height: 34,
                                  width: 34,
                                  decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      gradient: LinearGradient(colors: [
                                        Colors.orange,
                                        Colors.pink
                                      ])),
                                  child: Center(
                                      child: Text('.Pdf',
                                          style: TextStyle(
                                              color: Colors.blue.shade900))),
                                )
                              : Container()
                      : Container(
                          height: 34,
                          width: 34,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                      replyPreviousMedia!),
                                  fit: BoxFit.cover))),
                  const SizedBox(width: 7),
                  Text(replyPreviousText!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 15))
                ],
              ),
      ),
    );
  }

  Widget replyMessageTile(
      {required String message,
      required bool sendByMe,
      required Timestamp time}) {
    return GestureDetector(
      onLongPress: () {
        setState(() {
          longPressed = true;
        });
      },
      child: Container(
        color: longPressed ? Colors.blue.withOpacity(0.3) : Colors.transparent,
        child: Row(
          mainAxisAlignment:
              sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                    color: sendByMe ? Colors.green : Colors.blue,
                    borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(24),
                        bottomRight: sendByMe
                            ? const Radius.circular(0)
                            : const Radius.circular(24),
                        topRight: const Radius.circular(24),
                        bottomLeft: sendByMe
                            ? const Radius.circular(24)
                            : const Radius.circular(0))),
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    replyWidget(),
                    Text(
                      message,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      time.toDate().toString(),
                      //   '${DateFormat.yMMMd().format(time)}  ${DateFormat.Hm().format(time)}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 8),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget chatMessages() {
    return StreamBuilder<QuerySnapshot>(
        stream: messageStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80, top: 16),
                reverse: true,
                itemCount: snapshot.data!.docs.length,
                /*      GroupedListView<Element, DateTime>(
                  elements: snapshot.data!.docs,
                  order: GroupedListOrder.DESC,
                  reverse: true,
                  floatingHeader: true,
                  useStickyGroupSeparators: true,
                  groupBy: (Element element) => DateTime(
                      element.date.year, element.date.month, element.date.day),
                  groupHeaderBuilder: (Element element) => Container(
                        height: 40,
                        child: Align(
                          child: Container(
                            width: 120,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10.0)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${DateFormat.yMMMd().format(element.date)}',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),  */
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data!.docs[index];
                  bool isDeleted = ds['isDeleted'];
                  //   bool isReplying = ds['isReplying'];
                  String mesgId = ds['messageId'];
                  String? msg = ds['message'];
                  final photomsgurl = ds['photoMsgUrl'];
                  final vdomsgurl = ds['videoMsgUrl'];
                  final vdoprevw = ds['videoPreviewImage'];
                  final pdfmsgurl = ds['pdfMsgUrl'];
                  final medialength = ds['mediaLength'];
                  bool isPhoto = photomsgurl == null;
                  bool isVideo = vdomsgurl == null;
                  bool isPdf = pdfmsgurl == null;
                  return isPhoto
                      ? isVideo
                          ? isPdf
                              ? ChatMessageTile(
                                  onLongPress: () {
                                    setState(() {
                                      this.appbarLongPressed = mesgId;
                                      this.msgId = mesgId;
                                    });
                                    pressFn1(mesgId);
                                    setState(() {
                                      this.replyPreviousText = msg;
                                      this.replyPreviousMedia = photomsgurl;
                                    });
                                  },
                                  /*     onPress: () {
                                            /*   setState(() {
                                              longPressedC = true;
                                              longPressed = true;
                                              this.replyPreviousText = msg;
                                              this.msgId = mesgId;
                                              //  list.add(msgId);
                                            }); */
                                            setState(() {
                                              this.appbarLongPressedAgain =
                                                  mesgId;
                                              //       this.msgId = mesgId;
                                              list.add(mesgId);
                                            });
                                            list.every((element) {
                                              return pressFn2(element);
                                            });
                                            // pressFn2();
                                            setState(() {
                                              longPressedAgain = true;
                                              //  longPressedP = true;
                                              //      longPressedP = true;
                                              //   this.appbarLongPressed = 'photo';
                                              //    this.replyPreviousText = msg;
                                              //   this.replyPreviousMedia =
                                              //      photomsgurl;
                                            });
                                          }, */
                                  longPressed: pressFn3(mesgId),
                                  //   longPressedAgain: longPressedAgain,
                                  // longPressedC,
                                  //      longPressedG: longPressed,
                                  isDeleted: isDeleted,
                                  message: msg,
                                  sendByMe: '$myfirstname $mysecondname' ==
                                      ds['sendBy'],
                                  time: ds['ts'])
                              : PdfMessageTile(
                                  onLongPress: () {
                                    setState(() {
                                      this.appbarLongPressed = mesgId;
                                      this.msgId = mesgId;
                                    });
                                    pressFn1(mesgId);
                                    setState(() {
                                      this.replyPreviousText = msg;
                                      isReplyingPdf = true;
                                    });
                                  },
                                  isDeleted: isDeleted,
                                  longPressed: pressFn3(mesgId),
                                  pdfMessage: pdfmsgurl,
                                  message: msg,
                                  sendByMe: '$myfirstname $mysecondname' ==
                                      ds['sendBy'],
                                  time: ds['ts'])
                          : VideoMessageTile(
                              onLongPress: () {
                                setState(() {
                                  this.appbarLongPressed = mesgId;
                                  this.msgId = mesgId;
                                });
                                pressFn1(mesgId);
                                setState(() {
                                  this.replyPreviousText = msg;
                                  this.replyPreviousMedia = vdoprevw;
                                  this.replyPreviousMediaLength = medialength;
                                });
                              },
                              isDeleted: isDeleted,
                              longPressed: pressFn3(mesgId),
                              message: msg,
                              videoMessage: vdomsgurl,
                              videoPreview: vdoprevw,
                              sendByMe:
                                  '$myfirstname $mysecondname' == ds['sendBy'],
                              time: ds['ts'],
                              medialength: medialength)
                      : PhotoMessageTile(
                          onLongPress: () {
                            setState(() {
                              this.appbarLongPressed = mesgId;
                              this.msgId = mesgId;
                            });
                            pressFn1(mesgId);
                            setState(() {
                              this.replyPreviousText = msg;
                              this.replyPreviousMedia = photomsgurl;
                            });
                          },
                          isDeleted: isDeleted,
                          longPressed: pressFn3(mesgId),
                          message: msg,
                          photoMessage: photomsgurl,
                          sendByMe:
                              '$myfirstname $mysecondname' == ds['sendBy'],
                          time: ds['ts']);
                });
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            final error = snapshot.error;
            Logger().w(error.toString());
          }
          return Container();
        });
  }

  getAndSetMessages() async {
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomId);
    //   photoMessageStream =
    //     await DatabaseMethods().getChatRoomPhotoMessages(chatRoomId);
    setState(() {});
  }

  doThisOnLaunch() async {
    await getMyInfo();
    getAndSetMessages();
  }

  profileInfo() async {
    final userDocSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.profileId)
        .get();
    setState(() {
      username = userDocSnapshot.data()!['userName'];
      firstname = userDocSnapshot.data()!['firstName'];
      secondname = userDocSnapshot.data()!['secondName'];
      profImg = userDocSnapshot.data()!['profileImageUrl'];
    });
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

  @override
  void initState() {
    super.initState();
    currentUserId = Provider.of<UserData>(context, listen: false).currentUserId;
    doThisOnLaunch();
    profileInfo();
  }

  @override
  Widget build(BuildContext context) {
    bool isProfImg = profImg == null;
    return chatScr ? chatScreen(isProfImg) : buildUploadForm();
  }

  Scaffold chatScreen(isProfImg) {
    return Scaffold(
      appBar: longPressed
          ? AppBar(
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                      onPressed: () {
                        pressFn();
                        setState(() {
                          appbarLongPressed = '';
                        });
                        /*  setState(() {
                          longPressed = false;
                        }); */
                      },
                      icon: const Icon(Icons.clear)),
                  IconButton(
                      onPressed: () {
                        pressFn();
                        setState(() {
                          replyButtonPressed = true;
                          appbarLongPressed = '';
                        });
                      },
                      icon: const Icon(Icons.reply_rounded)),
                  IconButton(
                      onPressed: deleteFn, icon: const Icon(Icons.delete)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.copy)),
                  IconButton(
                      onPressed: deleteAll,
                      icon: const Icon(Icons.delete_sweep_rounded)),
                ],
              ),
            )
          : AppBar(
              automaticallyImplyLeading: false,
              centerTitle: false,
              title: Row(
                children: [
                  const SizedBox(width: 2),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back)),
                  const SizedBox(width: 3),
                  /*     isProfImg
                      ? CircleAvatar(child: Icon(Icons.person))
                      : CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(profImg!),
                        ), */
                  CircleAvatar(
                    child: isProfImg
                        ? Center(
                            child: Text(
                              '${firstname[0].toUpperCase()} ${secondname[0].toUpperCase()}',
                              style: TextStyle(color: Colors.purple.shade300),
                            ),
                          )
                        : CircleAvatar(
                            backgroundImage:
                                CachedNetworkImageProvider(profImg!)),
                  ),
                  const SizedBox(width: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$firstname $secondname',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 17),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@$username',
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.blue),
                      ),
                      const SizedBox(height: 2),
                      LastActive(uid: widget.profileId)
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.call)),
                IconButton(
                    onPressed: () {
                      //       CallUtils.dial(from: currentUserId, to: widget.profileId);
                    },
                    icon: const Icon(Icons.video_call))
              ],
            ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            chatMessages(),
            isUploading
                ? Positioned(
                    bottom: 15,
                    left: 3,
                    right: 3,
                    child: Container(
                      height: 100,
                      color: Colors.black,
                      child: Column(
                        children: [
                          const LinearProgressIndicator(
                            color: Colors.blue,
                            backgroundColor: Colors.green,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              bottomFileView(),
                              const Text(
                                'Uploading....',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          )
                        ],
                      ),
                    ))
                : Positioned(
                    left: 8,
                    right: 8,
                    bottom: 20,
                    child: replyButtonPressed
                        ? Column(
                            children: [
                              Stack(
                                children: [
                                  replyWidget(),
                                  Positioned(
                                      right: 3,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            replyButtonPressed = false;
                                          });
                                        },
                                        child: const CircleAvatar(
                                          radius: 15,
                                          child: Icon(
                                            Icons.close,
                                            size: 15,
                                          ),
                                        ),
                                      ))
                                ],
                              ),
                              const SizedBox(height: 7),
                              Container(
                                height: 60,
                                decoration: const BoxDecoration(
                                    color: Colors.black,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: noAbc1(context),
                              ),
                            ],
                          )
                        : Container(
                            height: 60,
                            decoration: const BoxDecoration(
                                color: Colors.black,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: noAbc(context),
                          ),
                  )
          ],
        ),
      ),
    );
  }

  pressFn1(mesgId) {
    if (appbarLongPressed == mesgId) {
      setState(() {
        longPressed = true;
        //    longPressedFired = false;
      });
    } else {
      setState(() {
        longPressed = false;
        //   longPressedFired = false;
      });
    }
  }

  bool pressFn3(mesgId) {
    if (appbarLongPressed == mesgId) {
      return true;
    } else {
      return false;
    }
  }

  pressFn2(String element) {
    if (appbarLongPressedAgain == element) {
      setState(() {
        longPressedAgain = true;
        //    longPressedFired = false;
      });
    } else {
      setState(() {
        longPressedAgain = false;
        //   longPressedFired = false;
      });
    }
  }

  pressFn() {
    if (appbarLongPressed == msgId) {
      setState(() {
        longPressed = false;
        //    longPressedFired = false;
      });
    } else {
      setState(() {
        longPressed = true;
        //   longPressedFired = false;
      });
    }
  }

  deleteFn() async {
    await pressFn();

    final a = await FirebaseFirestore.instance
        .collection('chatRooms')
        .where('messageId', isEqualTo: msgId)
        .get();
    for (final doc in a.docs) {
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(doc.id)
          .update({'isDeleted': true});
      //  .delete();
    }

    FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('chats')
        .doc(msgId)
        .update({'isDeleted': true});
  }

  deleteAll() async {
    await pressFn();

    final a = await FirebaseFirestore.instance
        .collection('chatRooms')
        .where('users', arrayContains: currentUserId)
        .orderBy('lastMessageSendTs', descending: true)
        .get();
    for (final doc in a.docs) {
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(doc.id)
          .delete();
    }

    final b = await FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('chats')
        .get();
    for (final doc1 in b.docs) {
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('chats')
          .doc(doc1.id)
          .delete();
    }
  }

  bottomFileView() {
    if (fileType == 'photo') {
      return imageWidget();
    } else if (fileType == 'video') {
      return videoWidget();
    }
  }

  Widget imageWidget() {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PhotoPreview(photofile: mFile)));
      },
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
            image:
                DecorationImage(image: FileImage(mFile!), fit: BoxFit.cover)),
      ),
    );
  }

  Widget videoWidget() {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => VideoPreview(videofile: mFile)));
      },
      child: Stack(
        children: [
          SizedBox(
            width: 140,
            height: 90,
            child: VideoPreview(videofile: mFile),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 40, left: 65),
            child: CircleAvatar(
                backgroundColor: Colors.black,
                radius: 15,
                child: Center(
                    child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                ))),
          )
        ],
      ),
    );
  }

  Row noAbc1(context) {
    return Row(children: [
      IconButton(
          onPressed: () {}, icon: const Icon(Icons.emoji_emotions_rounded)),
      Expanded(
          child: Form(
        key: _formKey,
        child: TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return "Please type something first.....";
            }
            return null;
          },
          controller: msgController,
          onSaved: (value) {
            addMessage(false);
            // msgController.text = value!;
          },
          style: const TextStyle(color: Colors.white, fontSize: 17),
          decoration: const InputDecoration(
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.orange),
              hintText: 'Type a message'),
        ),
      )),
      IconButton(
          onPressed: () {
            showAttachmentBottomSheet(context);
          },
          icon: const Icon(
            Icons.attachment_rounded,
            color: Colors.lightBlue,
          )),
      const SizedBox(width: 8),
      InkWell(
          onTap: () {
            addMessage1(true);
          },
          child: const Icon(Icons.send, color: Colors.pink)),
      const SizedBox(width: 8),
    ]);
  }

  Row noAbc(context) {
    return Row(children: [
      IconButton(
          onPressed: () {}, icon: const Icon(Icons.emoji_emotions_rounded)),
      Expanded(
          child: Form(
        key: _formKey,
        child: TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return "Please type something first.....";
            }
            return null;
          },
          controller: msgController,
          onSaved: (value) {
            addMessage(false);
            // msgController.text = value!;
          },
          style: const TextStyle(color: Colors.white, fontSize: 17),
          decoration: const InputDecoration(
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.orange),
              hintText: 'Type a message'),
        ),
      )),
      IconButton(
          onPressed: () {
            showAttachmentBottomSheet(context);
          },
          icon: const Icon(
            Icons.attachment_rounded,
            color: Colors.lightBlue,
          )),
      const SizedBox(width: 8),
      InkWell(
          onTap: () {
            addMessage(true);
          },
          child: const Icon(Icons.send, color: Colors.pink)),
      const SizedBox(width: 8),
    ]);
  }

  showAttachmentBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 135,
              child: Wrap(spacing: 20, children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () => selectImage(context),
                      child: Container(
                        height: 50,
                        width: 100,
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                colors: [Colors.green, Colors.purple]),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: const Center(
                          child: Icon(Icons.photo, color: Colors.white),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => showOptionsDialog(context),
                      child: Container(
                        height: 50,
                        width: 100,
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                colors: [Colors.red, Colors.purple]),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: const Center(
                          child: Icon(Icons.video_camera_back_rounded,
                              color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () async {
                        await pickAudio();
                      },
                      child: Container(
                        height: 50,
                        width: 100,
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                colors: [Colors.blue, Colors.purple]),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: const Center(
                          child: Icon(Icons.music_note_rounded,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        await pickPdf();
                      },
                      child: Container(
                        height: 50,
                        width: 100,
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                colors: [Colors.yellow, Colors.purple]),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: const Center(
                          child: Icon(Icons.file_copy_rounded,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 100,
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Colors.orange, Colors.purple]),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: const Center(
                        child: Icon(Icons.celebration_rounded,
                            color: Colors.white),
                      ),
                    )
                  ],
                )
              ]));
        });
  }

  pickAudio() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['mp3']);
    if (result == null) {
      return;
    }
    final file = result.files.first;
    final newFile = await saveFilePermanently(file);
    setState(() {
      this.mFile = newFile;
      this.fileType = 'audio';
      chatScr = false;
    });
  }

  pickPdf() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result == null) {
      return;
    }
    final file = result.files.first;
    final newFile = await saveFilePermanently(file);
    setState(() {
      this.mFile = newFile;
      this.fileType = 'pdf';
      chatScr = false;
    });
    openPdf();
  }

  Future<File> saveFilePermanently(PlatformFile file) async {
    final appStorage = await getApplicationDocumentsDirectory();
    final newFile = File('${appStorage.path}/${file.name}');
    return File(file.path!).copy(newFile.path);
  }

  void openFile(newFile) {
    OpenFile.open(newFile.path!);
  }

  handleTakePhoto() async {
    final XFile? file = await imgPicker!
        .pickImage(source: ImageSource.camera, maxHeight: 675, maxWidth: 960);

    final File imageFile = File(file!.path);

    setState(() {
      this.mFile = imageFile;
      chatScr = false;
    });
    Navigator.of(context).pop();
  }

  handleChooseFromGallery() async {
    final XFile? file = await imgPicker!.pickImage(source: ImageSource.gallery);
    final File imageFile = File(file!.path);
    setState(() {
      this.mFile = imageFile;
      chatScr = false;
    });
    Navigator.of(context).pop();
  }

  selectImage(BuildContext context) {
    Navigator.of(context).pop();
    return showDialog(
        useRootNavigator: false,
        context: context,
        builder: (BuildContext context) => SimpleDialog(
              title: const Center(
                  child: Text(
                'Create Post',
                style: TextStyle(
                    color: Colors.purpleAccent,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontSize: 25),
              )),
              backgroundColor: Colors.black87,
              children: [
                SimpleDialogOption(
                  onPressed: handleTakePhoto,
                  child: const Center(
                    child: Text(
                      'Photo with camera',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                SimpleDialogOption(
                  onPressed: handleChooseFromGallery,
                  child: const Center(
                      child: Text(
                    'Image from Gallery',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent),
                  )),
                ),
                const SizedBox(height: 5),
                SimpleDialogOption(
                  child: const Center(
                      child: Text(
                    'Cancel',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent),
                  )),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  InkWell micSend() {
    /*  bool isMic = qvery == null;
    return isMic
        ? InkWell(
            onTap: () {
              setState(() {
                isMicy = false;
              });
            },
            child: Icon(Icons.mic, color: Colors.lightGreen.withBlue(30)))
        : InkWell(
            onTap: () {
              addMessage(true);
            },
            child: Icon(Icons.send, color: Colors.pink)); */
    if (msgController.text != '') {
      return InkWell(
          onTap: () {
            addMessage(true);
          },
          child: const Icon(Icons.send, color: Colors.pink));
    }
    return InkWell(
        onTap: () {
          setState(() {
            //    isMicy = false;
          });
        },
        child: Icon(Icons.mic, color: Colors.lightGreen.withBlue(30)));
  }

  clearFile() {
    setState(() {
      mFile = null;
      chatScr = true;
    });
  }

  buildUploadForm() {
    if (fileType == 'photo') {
      return imageUploadForm();
    } else if (fileType == 'video') {
      return videoUploadForm();
    } else if (fileType == 'audio') {
      return audioUploadForm();
    } else if (fileType == 'pdf') {
      return pdfUploadForm();
    }
  }

  Scaffold imageUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
            onPressed: clearFile,
            icon: const Icon(Icons.arrow_back, color: Colors.black)),
        title: const Center(
            child: Text('Send Image', style: TextStyle(color: Colors.black))),
        actions: [
          IconButton(
              onPressed: () => handleSubmit(),
              icon: const Icon(Icons.done, color: Colors.blue))
        ],
      ),
      body: ListView(
        children: [
          Center(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.65,
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: FileImage(mFile!), fit: BoxFit.cover)),
            ),
          ),
          caption()
        ],
      ),
    );
  }

  Scaffold videoUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
            onPressed: clearFile,
            icon: const Icon(Icons.arrow_back, color: Colors.black)),
        title: const Center(
            child: Text('Send Video', style: TextStyle(color: Colors.black))),
        actions: [
          IconButton(
              onPressed: () => uploadVideo(),
              icon: const Icon(Icons.done, color: Colors.blue))
        ],
      ),
      body: ListView(
        children: [
          Center(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              width: MediaQuery.of(context).size.width * 0.9,
              child: VideoWidget(
                videoFile: mFile,
              ),
            ),
          ),
          caption()
        ],
      ),
    );
  }

  Scaffold audioUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
            onPressed: clearFile,
            icon: const Icon(Icons.arrow_back, color: Colors.black)),
        title: const Center(
            child: Text('Send Audio', style: TextStyle(color: Colors.black))),
        actions: [
          IconButton(
              onPressed: () => uploadAudio(),
              icon: const Icon(Icons.done, color: Colors.blue))
        ],
      ),
      body: Container(
        color: Colors.black,
        child: ListView(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                height: MediaQuery.of(context).size.width * 0.8,
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    gradient: LinearGradient(
                        colors: [Colors.deepPurple, Colors.purple])),
                child: const Center(
                  child: Icon(Icons.music_note),
                ),
              ),
            ),
            const SizedBox(height: 20),
            caption()
          ],
        ),
      ),
    );
  }

  Scaffold pdfUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
            onPressed: clearFile,
            icon: const Icon(Icons.arrow_back, color: Colors.black)),
        title: const Center(
            child:
                Text('Send Pdf File', style: TextStyle(color: Colors.black))),
        actions: [
          IconButton(
              onPressed: () => uploadPdf(),
              icon: const Icon(Icons.done, color: Colors.blue))
        ],
      ),
      body: Container(
        color: Colors.black,
        child: ListView(
          children: [
            const SizedBox(height: 20),
            Center(
              child: InkWell(
                onTap: openPdf,
                child: Container(
                  height: MediaQuery.of(context).size.width * 0.8,
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      gradient:
                          LinearGradient(colors: [Colors.orange, Colors.pink])),
                  child: Center(
                    child: Text(
                      '.pdf',
                      style: TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 40),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            caption()
          ],
        ),
      ),
    );
  }

  openPdf() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => ViewPdf(file: mFile)));
  }

  Padding caption() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: ListTile(
        leading: const CircleAvatar(child: Center(child: Icon(Icons.edit))),
        title: SizedBox(
            width: 200,
            child: TextField(
              controller: captionController,
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Write about this photo....'),
            )),
      ),
    );
  }

  uploadPdfToStorage(String id) async {
    UploadTask storageUploadTask =
        storageRef.child('message/Pdf/$messageId.pdf').putFile(mFile!);
    TaskSnapshot storageTaskSnapshot =
        await storageUploadTask.whenComplete(() {});
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  uploadPdf() async {
    setState(() {
      chatScr = true;
      messageId = const Uuid().v4();
      isUploading = true;
    });

    String pdf = await uploadPdfToStorage(messageId);
    String? msg = captionController.text;
    DateTime dateNow = DateTime.now();
    String mid = messageId;
    var lastMsgTs = Timestamp.fromDate(dateNow);

    Map<String, dynamic> messageInfo = {
      'messageId': messageId,
      'message': msg,
      'voiceMsgUrl': null,
      'musicMsgUrl': null,
      'photoMsgUrl': null,
      'videoMsgUrl': null,
      'videoPreviewImage': null,
      'pdfMsgUrl': pdf,
      'mediaLength': mLength,
      'sendBy': '$myfirstname $mysecondname',
      'ts': lastMsgTs,
      'imageUrl': myprofImg,
      'isDeleted': false
    };

    DatabaseMethods()
        .addMessage(chatRoomId, messageId, messageInfo)
        .then((value) {
      Map<String, dynamic> lastMessageInfo = {
        'messageId': mid,
        'lastMessage': msg,
        'lastVoiceMsgUrl': null,
        'lastMusicMsgUrl': null,
        'lastPhotoMsgUrl': null,
        'lastVideoMsgUrl': null,
        'lastPdfMsgUrl': pdf,
        'lastMediaLength': null,
        'lastMessageSendTs': lastMsgTs,
        'lastMessageSendByFN': myfirstname,
        'lastMessageSendBySN': mysecondname,
        'lastMessageSendToFN': firstname,
        'lastMessageSendToSN': secondname,
        'lastMessageSenderDp': myprofImg,
        'lastMessageSendDp': profImg,
        'lastMessageSenderId': currentUserId,
        'lastMessageSendId': widget.profileId,
        'users': <String>[currentUserId!, widget.profileId!],
        'isDeleted': false
      };

      DatabaseMethods().updateLastMessageSend(chatRoomId, lastMessageInfo);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pdf Sent Successfully!')),
    );
    setState(() {
      mFile = null;
      isUploading = false;
      captionController.clear();
      messageId = const Uuid().v4();
      fileType = 'photo';
    });
    getAndSetMessages();
  }

  uploadAudioToStorage(String id) async {
    UploadTask storageUploadTask =
        storageRef.child('message/Audio/$messageId.mp3').putFile(mFile!);
    TaskSnapshot storageTaskSnapshot =
        await storageUploadTask.whenComplete(() {});
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  uploadAudio() async {
    setState(() {
      chatScr = true;
      messageId = const Uuid().v4();
      isUploading = true;
    });

    String audio = await uploadAudioToStorage(messageId);
    String? msg = captionController.text;
    DateTime dateNow = DateTime.now();
    String mid = messageId;
    var lastMsgTs = Timestamp.fromDate(dateNow);

    Map<String, dynamic> messageInfo = {
      'messageId': messageId,
      'message': msg,
      'voiceMsgUrl': null,
      'musicMsgUrl': audio,
      'photoMsgUrl': null,
      'videoMsgUrl': null,
      'videoPreviewImage': null,
      'pdfMsgUrl': null,
      'mediaLength': mLength,
      'sendBy': '$myfirstname $mysecondname',
      'ts': lastMsgTs,
      'imageUrl': myprofImg,
      'isDeleted': false
    };

    DatabaseMethods()
        .addMessage(chatRoomId, messageId, messageInfo)
        .then((value) {
      Map<String, dynamic> lastMessageInfo = {
        'messageId': mid,
        'lastMessage': msg,
        'lastVoiceMsgUrl': null,
        'lastMusicMsgUrl': audio,
        'lastPhotoMsgUrl': null,
        'lastVideoMsgUrl': null,
        'lastPdfMsgUrl': null,
        'lastMediaLength': mLength,
        'lastMessageSendTs': lastMsgTs,
        'lastMessageSendByFN': myfirstname,
        'lastMessageSendBySN': mysecondname,
        'lastMessageSendToFN': firstname,
        'lastMessageSendToSN': secondname,
        'lastMessageSenderDp': myprofImg,
        'lastMessageSendDp': profImg,
        'lastMessageSenderId': currentUserId,
        'lastMessageSendId': widget.profileId,
        'users': <String>[currentUserId!, widget.profileId!],
        'isDeleted': false
      };

      DatabaseMethods().updateLastMessageSend(chatRoomId, lastMessageInfo);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Audio Sent Successfully!')),
    );
    setState(() {
      mFile = null;
      isUploading = false;
      captionController.clear();
      messageId = const Uuid().v4();
      fileType = 'photo';
    });
    getAndSetMessages();
  }

  pickVideoCamera() async {
    final XFile? video =
        await ImagePicker().pickVideo(source: ImageSource.camera);
    final File videoFile = File(video!.path);
    //  Navigator.of(context).pop();
    setState(() {
      this.mFile = videoFile;
      this.mLength = videoFile.length() as int;
      chatScr = false;
      this.fileType = 'video';
    });
    Navigator.of(context).pop();
  }

  pickVideoGallery() async {
    final XFile? video =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    final File videoFile = File(video!.path);
    //  Navigator.of(context).pop();
    setState(() {
      this.mFile = videoFile;
      this.mLength = videoFile.length() as int;
      chatScr = false;
      this.fileType = 'video';
    });
    Navigator.of(context).pop();
  }

  showOptionsDialog(BuildContext context) {
    Navigator.of(context).pop();
    return showDialog(
        useRootNavigator: false,
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: [
              SimpleDialogOption(
                onPressed: () => pickVideoGallery(),
                child: Row(
                  children: const [
                    Icon(Icons.image),
                    Padding(
                      padding: EdgeInsets.all(7),
                      child: Text("Gallery",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () => pickVideoCamera(),
                child: Row(
                  children: const [
                    Icon(Icons.camera_alt),
                    Padding(
                      padding: EdgeInsets.all(7),
                      child:
                          Text("Camera", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.of(context).pop(),
                child: Row(
                  children: const [
                    Icon(Icons.cancel),
                    Padding(
                        padding: EdgeInsets.all(7),
                        child: Text("Cancel",
                            style: TextStyle(color: Colors.white))),
                  ],
                ),
              ),
            ],
          );
        });
  }

  compressVideo() async {
    final compressedVideo = await VideoCompress.compressVideo(
      mFile!.path,
      quality: VideoQuality.MediumQuality,
    );
    return File(compressedVideo!.path!);
  }

  getPreviewImage() async {
    final previewImage = await VideoCompress.getFileThumbnail(mFile!.path);
    setState(() {
      this.videoPreviewImage = previewImage;
    });
    return previewImage;
  }

  uploadVideoToStorage(String id) async {
    UploadTask storageUploadTask = storageRef
        .child('message/Video/$messageId.mp4')
        .putFile(await compressVideo());
    TaskSnapshot storageTaskSnapshot =
        await storageUploadTask.whenComplete(() {});
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  uploadImageToStorage(String id) async {
    UploadTask storageUploadTask =
        imagesRef.child(id).putFile(await getPreviewImage());
    TaskSnapshot storageTaskSnapshot =
        await storageUploadTask.whenComplete(() {});
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  uploadVideo() async {
    setState(() {
      chatScr = true;
      messageId = const Uuid().v4();
      isUploading = true;
    });

    String video = await uploadVideoToStorage(messageId);
    String previewImage = await uploadImageToStorage(messageId);

    DateTime dateNow = DateTime.now();
    String? msg = captionController.text;
    var lastMsgTs = Timestamp.fromDate(dateNow);
    String mid = messageId;
    Map<String, dynamic> messageInfo = {
      'messageId': messageId,
      'message': msg,
      'voiceMsgUrl': null,
      'musicMsgUrl': null,
      'photoMsgUrl': null,
      'videoMsgUrl': video,
      'videoPreviewImage': previewImage,
      'pdfMsgUrl': null,
      'mediaLength': mLength,
      'sendBy': '$myfirstname $mysecondname',
      'ts': lastMsgTs,
      'imageUrl': myprofImg,
      'isDeleted': false
    };

    DatabaseMethods()
        .addMessage(chatRoomId, messageId, messageInfo)
        .then((value) {
      Map<String, dynamic> lastMessageInfo = {
        'messageId': mid,
        'lastMessage': msg,
        'lastVoiceMsgUrl': null,
        'lastMusicMsgUrl': null,
        'lastPhotoMsgUrl': null,
        'lastVideoMsgUrl': video,
        'lastPdfMsgUrl': null,
        'lastMediaLength': mLength,
        'lastMessageSendTs': lastMsgTs,
        'lastMessageSendByFN': myfirstname,
        'lastMessageSendBySN': mysecondname,
        'lastMessageSendToFN': firstname,
        'lastMessageSendToSN': secondname,
        'lastMessageSenderDp': myprofImg,
        'lastMessageSendDp': profImg,
        'lastMessageSenderId': currentUserId,
        'lastMessageSendId': widget.profileId,
        'users': <String>[currentUserId!, widget.profileId!],
        'isDeleted': false
      };

      DatabaseMethods().updateLastMessageSend(chatRoomId, lastMessageInfo);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video Sent Successfully!')),
    );
    setState(() {
      mFile = null;
      isUploading = false;
      captionController.clear();
      messageId = const Uuid().v4();
      fileType = 'photo';
    });
    getAndSetMessages();
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    im.Image? imgFile = im.decodeImage(mFile!.readAsBytesSync());
    final compressedImageFile = File('$path/img_$messageId.jpg')
      ..writeAsBytesSync(im.encodeJpg(imgFile!, quality: 25));
    setState(() {
      mFile = compressedImageFile;
    });
  }

  Future<String> uploadImage(imgFile) async {
    UploadTask uploadTask =
        storageRef.child('message/Image/$messageId.jpg').putFile(imgFile);
    TaskSnapshot storageSnap = await uploadTask.whenComplete(() {});
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  handleSubmit() async {
    setState(() {
      chatScr = true;
      isUploading = true;
      messageId = const Uuid().v4();
    });
    await compressImage();
    String mediaUrl = await uploadImage(mFile);

    String mid = messageId;
    DateTime dateNow = DateTime.now();
    String? msg = captionController.text;
    var lastMsgTs = Timestamp.fromDate(dateNow);

    Map<String, dynamic> messageInfo = {
      'messageId': messageId,
      'message': msg,
      'voiceMsgUrl': null,
      'musicMsgUrl': null,
      'photoMsgUrl': mediaUrl,
      'videoMsgUrl': null,
      'videoPreviewImage': null,
      'pdfMsgUrl': null,
      'mediaLength': null,
      'sendBy': '$myfirstname $mysecondname',
      'ts': lastMsgTs,
      'imageUrl': myprofImg,
      'isDeleted': false
    };

    DatabaseMethods()
        .addMessage(chatRoomId, messageId, messageInfo)
        .then((value) {
      Map<String, dynamic> lastMessageInfo = {
        'messageId': mid,
        'lastMessage': msg,
        'lastVoiceMsgUrl': null,
        'lastMusicMsgUrl': null,
        'lastPhotoMsgUrl': mediaUrl,
        'lastVideoMsgUrl': null,
        'lastPdfMsgUrl': null,
        'lastMediaLength': null,
        'lastMessageSendTs': lastMsgTs,
        'lastMessageSendByFN': myfirstname,
        'lastMessageSendBySN': mysecondname,
        'lastMessageSendToFN': firstname,
        'lastMessageSendToSN': secondname,
        'lastMessageSenderDp': myprofImg,
        'lastMessageSendDp': profImg,
        'lastMessageSenderId': currentUserId,
        'lastMessageSendId': widget.profileId,
        'users': <String>[currentUserId!, widget.profileId!],
        'isDeleted': false
      };

      DatabaseMethods().updateLastMessageSend(chatRoomId, lastMessageInfo);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image Sent Successfully!')),
    );
    setState(() {
      captionController.clear();
      mFile = null;
      isUploading = false;
      messageId = const Uuid()
          .v4(); // that id gets change so that nxt tym a unique id come
    });
    getAndSetMessages();
  }
}
