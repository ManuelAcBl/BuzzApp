import 'dart:io';

class CastServer {
  late final ServerSocket _socket;

  final List<Socket> _clients = [];

  CastServer() {
    _start();
  }

  Future<void> _start() async {
    _socket = await ServerSocket.bind('127.0.0.1', 4040);

    await for (final client in _socket) {
      _clients.add(client);

      client.listen(null).onDone(() => _clients.remove(client));
    }
  }

  void stop() => _socket.close();

  void listen(String key) {

  }
}
