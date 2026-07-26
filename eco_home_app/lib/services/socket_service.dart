import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'api_service.dart';

class SocketService {
  static IO.Socket? _socket;
  static bool _isConnected = false;

  static void connect(String username, Function(Map<String, dynamic>) onMessage, Function(List<dynamic>) onHistory) {
    if (_socket != null && _socket!.connected) {
      return;
    }
    _socket = IO.io(
      ApiService.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'username': username})
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      print('Socket conectado');
    });

    _socket!.on('messages', (data) {
      // data is the full history
      onHistory(data);
    });

    _socket!.on('new-message', (msg) {
      // msg is the new message object
      onMessage(msg);
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      print('Socket desconectado');
    });
  }

  static void sendMessage(String user, String text) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('new-message', {'user': user, 'text': text});
    } else {
      print('Socket no conectado');
    }
  }

  static void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
  }

  static bool get isConnected => _isConnected;
}