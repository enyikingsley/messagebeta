import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'dart:typed_data';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Strategy strategy = Strategy.P2P_STAR;
  List<String> messages = [];
  final TextEditingController msgController = TextEditingController();

  @override
  void dispose() {
    msgController.dispose();
    super.dispose();
  }

  Future<void> startAdvertising() async {
    try {
      await Nearby().startAdvertising(
        "MessageBetaUser",
        strategy,
        onConnectionInitiated: onConnInit,
        onConnectionResult: (id, status) {},
        onDisconnected: (id) {},
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> startDiscovery() async {
    try {
      await Nearby().startDiscovery(
        "MessageBetaUser",
        strategy,
        onEndpointFound: (id, name, serviceId) {
          Nearby().requestConnection(
            "MessageBetaUser",
            id,
            onConnectionInitiated: onConnInit,
            onConnectionResult: (id, status) {},
            onDisconnected: (id) {},
          );
        },
        onEndpointLost: (id) {},
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void onConnInit(String id, ConnectionInfo info) {
    Nearby().acceptConnection(
      id,
      onPayLoadRecieved: (endid, payload) {
        if (payload.type == PayloadType.BYTES) {
          String msg = String.fromCharCodes(payload.bytes!);
          setState(() => messages.add("Friend: $msg"));
        }
      },
    );
  }

  void sendMessage(String text) {
    Nearby().getConnectedEndpoints().then((endpoints) {
      for (String ep in endpoints) {
        Nearby().sendBytesPayload(ep, Uint8List.fromList(text.codeUnits));
      }
    });
    setState(() {
      messages.add("Me: $text");
      msgController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MessageBeta"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.pushNamed(context, '/about'),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Align(
                  alignment: messages[index].startsWith("Me")
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: messages[index].startsWith("Me")
                          ? Colors.indigo.shade300
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      messages[index],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey.shade200,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: msgController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.indigo,
                  onPressed: () {
                    if (msgController.text.isNotEmpty) {
                      sendMessage(msgController.text);
                    }
                  },
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: startAdvertising,
                icon: const Icon(Icons.wifi_tethering),
                label: const Text("Advertise"),
              ),
              ElevatedButton.icon(
                onPressed: startDiscovery,
                icon: const Icon(Icons.search),
                label: const Text("Discover"),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
