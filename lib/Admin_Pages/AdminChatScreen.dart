import 'package:cardealer/Assistance/ColorHelper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class AdminChatScreen extends StatefulWidget {
  final String userId;
  final String adminUid;

  const AdminChatScreen({
    Key? key,
    required this.userId,
    required this.adminUid,
  }) : super(key: key);

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  String? userName;

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  void fetchUserName() async {
    final snapshot = await _dbRef.child("users").child(widget.userId).once();

    final userData = snapshot.snapshot.value as Map<dynamic, dynamic>?;
    if (userData != null && userData['name'] != null) {
      setState(() {
        userName = userData['name'];
      });
    } else {
      setState(() {
        userName = "User";
      });
    }
  }

  String getChatId() {
    return widget.userId.hashCode <= widget.adminUid.hashCode
        ? '${widget.userId}_${widget.adminUid}'
        : '${widget.adminUid}_${widget.userId}';
  }

  void sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = {
      'senderId': widget.adminUid,
      'receiverId': widget.userId,
      'text': _messageController.text.trim(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'isRead': false,
    };

    _dbRef.child('messages').child(getChatId()).push().set(message);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chatId = getChatId();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [ColorSys.purple1, ColorSys.purple2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: AppBar(
            title: Text(userName ?? "Loading...",
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _dbRef.child('messages').child(chatId).orderByChild('timestamp').onValue,
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    (snapshot.data! as DatabaseEvent).snapshot.value != null) {
                  final data = Map<dynamic, dynamic>.from(
                    (snapshot.data! as DatabaseEvent).snapshot.value as Map,
                  );

                  final messages = data.entries.map((entry) {
                    final value = Map<dynamic, dynamic>.from(entry.value);
                    return {
                      'key': entry.key,
                      'text': value['text'],
                      'senderId': value['senderId'],
                      'timestamp': value['timestamp'],
                      'isRead': value['isRead'] ?? false,
                    };
                  }).toList()
                    ..sort((a, b) => a['timestamp'].compareTo(b['timestamp']));


                  for (var msg in messages) {
                    if (msg['senderId'] == widget.userId && msg['isRead'] == false) {
                      _dbRef.child('messages')
                          .child(chatId)
                          .child(msg['key'])
                          .update({'isRead': true});
                    }
                  }

                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final isMe = messages[index]['senderId'] == widget.adminUid;
                      final time = DateFormat('hh:mm a').format(
                        DateTime.fromMillisecondsSinceEpoch(messages[index]['timestamp']),
                      );

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? ColorSys.purple1 : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                messages[index]['text'],
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                time,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                return const Center(child: Text("No messages yet."));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type your reply...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
