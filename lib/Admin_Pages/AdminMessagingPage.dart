import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lottie/lottie.dart';
import '../Assistance/ColorHelper.dart';
import 'AdminChatScreen.dart';

class AdminMessagingPage extends StatefulWidget {
  const AdminMessagingPage({Key? key}) : super(key: key);

  @override
  State<AdminMessagingPage> createState() => _AdminMessagingPageState();
}

class _AdminMessagingPageState extends State<AdminMessagingPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final String adminUid = '6rdVjDX9uKexGfEHBB5JukoIL3N2';
  Map<String, String> userNames = {};

  @override
  void initState() {
    super.initState();
    loadUserNames();
  }

  void loadUserNames() async {
    final snapshot = await _dbRef.child("users").once();
    final data = snapshot.snapshot.value as Map?;

    if (data != null) {
      Map<String, String> temp = {};
      data.forEach((key, value) {
        final user = value as Map<dynamic, dynamic>;
        if (user.containsKey('name')) {
          temp[key] = user['name'];
        }
      });
      setState(() {
        userNames = temp;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            title: const Text("User Messages",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: StreamBuilder(
        stream: _dbRef.child('messages').onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data != null &&
              (snapshot.data! as DatabaseEvent).snapshot.value != null) {
            final data = Map<dynamic, dynamic>.from(
              (snapshot.data! as DatabaseEvent).snapshot.value as Map,
            );

            final userChatIds = data.keys
                .where((chatId) => chatId.toString().contains(adminUid))
                .toList();


            if (userChatIds.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      "images/empty_box.json",
                      width: 200,
                      height: 200,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "No messages yet",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: userChatIds.length,
              itemBuilder: (context, index) {


                final chatId = userChatIds[index];
                final parts = chatId.split("_");
                final userId = parts.firstWhere((id) => id != adminUid);
                final userName = userNames[userId] ?? "User";

                return FutureBuilder<DatabaseEvent>(
                  future: _dbRef
                      .child('messages')
                      .child(chatId)
                      .orderByChild('timestamp')
                      .limitToLast(1)
                      .once(),
                  builder: (context, snapshot) {
                    bool showUnreadDot = false;
                    String lastMessage = "Tap to chat";

                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        snapshot.data!.snapshot.value != null) {
                      final messageMap = Map<dynamic, dynamic>.from(
                        snapshot.data!.snapshot.value as Map,
                      );
                      final latestEntry = messageMap.entries.first;
                      final latestMessage =
                      Map<dynamic, dynamic>.from(latestEntry.value);

                      final senderId = latestMessage['senderId'];
                      final isRead = latestMessage['isRead'] ?? true;

                      lastMessage = latestMessage['text'] ?? lastMessage;

                      if (senderId == userId && !isRead) {
                        showUnreadDot = true;
                      }
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminChatScreen(
                              userId: userId,
                              adminUid: adminUid,
                            ),
                          ),
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: showUnreadDot
                                ? [Colors.purple.shade300, Colors.purple]
                                : [Colors.grey.shade200, Colors.grey.shade300],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor:
                              showUnreadDot ? Colors.white : Colors.purple,
                              child: Text(
                                userName[0].toUpperCase(),
                                style: TextStyle(
                                  color: showUnreadDot
                                      ? Colors.purple
                                      : Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: TextStyle(
                                      color: showUnreadDot
                                          ? Colors.white
                                          : Colors.black87,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    lastMessage,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: showUnreadDot
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (showUnreadDot)
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }


          return Center(
            child: Lottie.asset(
              "images/Travel_app.json",
              width: 250,
              height: 250,
            ),
          );
        },
      ),
    );
  }
}
