import 'package:cardealer/Assistance/ColorHelper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

import '../global/global.dart';
import 'login_screen.dart';

class MessagingPage extends StatefulWidget {
  const MessagingPage({Key? key}) : super(key: key);

  @override
  State<MessagingPage> createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage> {
  final TextEditingController _messageController = TextEditingController();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  final String adminUid = '6rdVjDX9uKexGfEHBB5JukoIL3N2';

  String getChatId() {
    return currentUser!.uid.hashCode <= adminUid.hashCode
        ? '${currentUser!.uid}_$adminUid'
        : '${adminUid}_${currentUser!.uid}';
  }

  void sendMessage() {
    if (isGuest || currentUser == null) return;

    if (_messageController.text.trim().isEmpty) return;

    final message = {
      'senderId': currentUser!.uid,
      'receiverId': adminUid,
      'text': _messageController.text.trim(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'isRead': false,
    };

    _dbRef.child('messages').child(getChatId()).push().set(message);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {

    if (isGuest || currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Contact Admin"),
          backgroundColor: ColorSys.purple2,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline,
                  size: 80, color: Colors.grey),
              const SizedBox(height: 15),
              const Text(
                "Login Required",
                style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Please login to chat with admin",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: ColorSys.purple1),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text(
                  "Go to Login",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      );
    }

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
            title: const Text(
              "Contact Admin",
              style:
              TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _dbRef
                  .child('messages')
                  .child(chatId)
                  .orderByChild('timestamp')
                  .onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (snapshot.hasData &&
                    (snapshot.data! as DatabaseEvent)
                        .snapshot
                        .value !=
                        null) {
                  final data = Map<dynamic, dynamic>.from(
                    (snapshot.data! as DatabaseEvent)
                        .snapshot
                        .value as Map,
                  );

                  final messages = data.entries.map((entry) {
                    final value =
                    Map<dynamic, dynamic>.from(entry.value);
                    return {
                      'text': value['text'],
                      'senderId': value['senderId'],
                      'timestamp': value['timestamp'],
                    };
                  }).toList()
                    ..sort(
                          (a, b) =>
                          a['timestamp'].compareTo(b['timestamp']),
                    );

                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final isMe =
                          messages[index]['senderId'] ==
                              currentUser!.uid;
                      final time = DateFormat('hh:mm a').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            messages[index]['timestamp']),
                      );

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe
                                ? ColorSys.purple1
                                : Colors.grey[300],
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                messages[index]['text'],
                                style:
                                const TextStyle(fontSize: 16),
                              ),
                              Text(
                                time,
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                return const Center(child: Text("No messages yet"));
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
                      hintText: "Type your message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon:
                  const Icon(Icons.send, color: Colors.deepPurple),
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
