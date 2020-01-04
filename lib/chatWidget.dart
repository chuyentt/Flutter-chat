
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/screens/zoomImage.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';

import 'chatData.dart';
import 'constants.dart';
import 'screens/chat.dart';

class ChatWidget{

  static Widget userListStack(String currentUserId, BuildContext context) {
    return Stack(
      children: <Widget>[
        // List
        Container(
          child: StreamBuilder(
            stream: Firestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                  ),
                );
              } else {
                return ListView.builder(
                  padding: EdgeInsets.all(10.0),
                  itemBuilder: (context, index) => userListbuildItem(
                      context, currentUserId, snapshot.data.documents[index]),
                  itemCount: snapshot.data.documents.length,
                );
              }
            },
          ),
        ),
      ],
    );
  }

  static Widget userListbuildItem(
      BuildContext context, String currentUserId, DocumentSnapshot document) {
    print('firebase ' + document['id']);
    print(currentUserId);
    if (document['id'] == currentUserId) {
      return Container();
    } else {
      return Container(
        child: FlatButton(
          child: Row(
            children: <Widget>[
              Material(
                child: document['photoUrl'] != null
                    ? (Image.network(
                  document['photoUrl'],
                  height: 50.0,
                  width: 50.0,
                ))
                    : Icon(
                  Icons.account_circle,
                  size: 50.0,
                  color: colorPrimaryDark,
                ),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                clipBehavior: Clip.hardEdge,
              ),
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          'Nickname: ${document['nickname']}',
                          style: TextStyle(color: primaryColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.only(left: 20.0),
                ),
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Chat(
                      currentUserId: currentUserId,
                      peerId: document.documentID,
                      peerName: document['nickname'],
                      peerAvatar: document['photoUrl'],
                    )));
          },
          color: viewBg,
          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
    }
  }

  static Widget widgetLoginScreen(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Icon(
                    Icons.message,
                    color: Colors.greenAccent,
                  ),
                  height: 25.0,
                ),
                Text(
                  ChatData.appName,
                  style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 48.0,
          ),
          Center(
            child: FlatButton(
                onPressed: () => ChatData.authUser(context),
                child: Text(
                  'SIGN IN WITH GOOGLE',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                color: Color(0xffdd4b39),
                highlightColor: Color(0xffff7f7f),
                splashColor: Colors.transparent,
                textColor: Colors.white,
                padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0)),
          ),
        ],
      ),
    );
  }

  static Widget getAppBar() {
    return AppBar(
      leading: null,
      title: Text(ChatData.appName),
      backgroundColor: themeColor,
    );
  }

  static Widget widgetWelcomeScreen(BuildContext context) {
    // return
    // FutureBuilder<Widget>(
    //         future: ChatData.widgetDynamic(context),
    //          builder: (BuildContext context, AsyncSnapshot snapshot) {

    //               if(snapshot.hasData){
    //                     if(snapshot.data!=null){
    //                       return snapshot.data;
    //                     }

    //                 }
    //                     else
    //                     {
    //                       return Container();
    //                     }

    //         },

    //   );
    return Center(
      child: Container(
          child: Text(
            ChatData.appName,
            style: TextStyle(fontSize: 28),
          )),
    );
  }

  static Widget widgetFullPhoto(BuildContext context, String url) {
    return Container(child: PhotoView(imageProvider: NetworkImage(url)));
  }


  static Widget buildItem(BuildContext context,var listMessage,String id, int index, DocumentSnapshot document,String peerAvatar) {
    if (document['idFrom'] == id) {
      return Row(
        children: <Widget>[
          document['type'] == 0
              ? chatText(document['content'],id,listMessage, index, true)
              : chatImage(context,id,listMessage,document['content'], index, true)
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                ChatData.isLastMessageLeft(listMessage,id,index)
                    ? Material(
                  child: Image.network(
                    peerAvatar,
                    height: 35.0,
                    width: 35.0,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(18.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                )
                    : Container(width: 35.0),
                document['type'] == 0
                    ? chatText(document['content'],id,listMessage, index, false)
                    : chatImage(context,id,listMessage,document['content'], index, false)
              ],
            ),

            // Time
            ChatData.isLastMessageLeft(listMessage,id,index)
                ? Container(
              child: Text(
                DateFormat('dd MMM kk:mm').format(
                    DateTime.fromMillisecondsSinceEpoch(
                        int.parse(document['timestamp']))),
                style: TextStyle(
                    color: greyColor,
                    fontSize: 12.0,
                    fontStyle: FontStyle.italic),
              ),
              margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
            )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  static Widget buildListMessage(groupChatId,listMessage,currentUserId,peerAvatar,listScrollController) {
    return Flexible(
      child: groupChatId == ''
          ? Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(themeColor)))
          : StreamBuilder(
        stream: Firestore.instance
            .collection('messages')
            .document(groupChatId)
            .collection(groupChatId)
            .orderBy('timestamp', descending: true)
            .limit(20)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor:
                    AlwaysStoppedAnimation<Color>(themeColor)));
          } else {
            listMessage = snapshot.data.documents;
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) =>
                  ChatWidget.buildItem(context,listMessage,currentUserId,index,
                      snapshot.data.documents[index],peerAvatar),
              itemCount: snapshot.data.documents.length,
              reverse: true,
              controller: listScrollController,
            );
          }
        },
      ),
    );
  }

  static Widget chatText(String chatContent,String id,var listMessage, int index, bool logUserMsg) {
    return Container(
      child: Text(
        chatContent,
        style: TextStyle(color: logUserMsg ? primaryColor : Colors.white),
      ),
      padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
      width: 200.0,
      decoration: BoxDecoration(
          color: logUserMsg ? greyColor2 : primaryColor,
          borderRadius: BorderRadius.circular(8.0)),
      margin: logUserMsg
          ? EdgeInsets.only(
          bottom: ChatData.isLastMessageRight(listMessage,id,index) ? 20.0 : 10.0, right: 10.0)
          : EdgeInsets.only(left: 10.0),
    );
  }

  static Widget chatImage(BuildContext context,String id,var listMessage,String chatContent, int index, bool logUserMsg) {
    return Container(
      child: FlatButton(
        child: Material(
          child: CachedNetworkImage(
            imageUrl: chatContent,
            height: 100,
            width: 100,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
          //Image.network(chatContent,height: 200.0,width: 200.0,),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          clipBehavior: Clip.hardEdge,
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ZoomImage(url: chatContent)));
        },
        padding: EdgeInsets.all(0),
      ),
      margin: logUserMsg
          ? EdgeInsets.only(
          bottom: ChatData.isLastMessageRight(listMessage,id,index) ? 20.0 : 10.0, right: 10.0)
          : EdgeInsets.only(left: 10.0),
    );
  }



}