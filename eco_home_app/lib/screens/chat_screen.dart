import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:eco_home_app/services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final String username;
  final String token;
  const ChatScreen({super.key, required this.username, required this.token});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late IO.Socket socket;
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController textCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    connectSocket();
  }

  void connectSocket() {
    socket = IO.io(
      ApiService.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'username': widget.username})
          .build(),
    );

    socket.onConnect((_) {
      debugPrint('Conectado al chat');
    });

    socket.on('messages', (data) {
      setState(() {
        messages.clear();
        messages.addAll(List<Map<String, dynamic>>.from(data));
      });
    });

    socket.on('new-message', (msg) {
      setState(() {
        messages.add(Map<String, dynamic>.from(msg));
      });
    });

    socket.onDisconnect((_) {
      debugPrint('Desconectado del chat');
    });
  }

  void sendMessage() {
    final text = textCtrl.text.trim();
    if (text.isEmpty) return;
    socket.emit('new-message', {
      'user': widget.username,
      'text': text,
    });
    textCtrl.clear();
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat - ${widget.username}'),
        backgroundColor: Colors.blue[100],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[messages.length - 1 - index];
                final user = msg['user'] ?? 'Anónimo';
                final text = msg['text'] ?? '';
                final isMe = user == widget.username;
                return ListTile(
                  title: Text(
                    text,
                    style: TextStyle(
                      fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(user),
                  leading: isMe ? Icon(Icons.person) : null,
                  trailing: isMe ? null : Icon(Icons.person_outline),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textCtrl,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: sendMessage,
                  child: Text('Enviar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}