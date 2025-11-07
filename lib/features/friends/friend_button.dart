import 'package:flutter/material.dart';
import 'package:notekey_app/features/friends/friend_service.dart';
import 'package:notekey_app/features/friends/friendship_state.dart';
import 'package:notekey_app/features/friends/friend_service.dart';
import 'package:notekey_app/features/friends/friendship_state.dart';
import 'package:notekey_app/features/themes/colors.dart';

class FriendButton extends StatefulWidget {
  final String otherUserId;

  const FriendButton({super.key, required this.otherUserId});

  @override
  State<FriendButton> createState() => _FriendButtonState();
}

class _FriendButtonState extends State<FriendButton> {
  late Future<FriendshipState> _stateFuture;
  final FriendService _service = FriendService();
  bool _requestSent = false;

  @override
  void initState() {
    super.initState();
    _stateFuture = _service.getFriendshipState(widget.otherUserId);
  }

  void _sendRequest() async {
    await _service.sendFriendRequest(widget.otherUserId);
    setState(() {
      _requestSent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FriendshipState>(
      future: _stateFuture,
      builder: (context, snapshot) {
        if (_requestSent || snapshot.data == FriendshipState.pending) {
          return ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.hourglass_top),
            label: const Text("Anfrage gesendet"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown.shade200,
              foregroundColor: AppColors.hellbeige,
              shadowColor: Colors.transparent,
            ),
          );
        }

        if (snapshot.data == FriendshipState.accepted) {
          return ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.check),
            label: const Text("Bereits Freunde"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: AppColors.hellbeige,
              shadowColor: Colors.transparent,
            ),
          );
        }

        return ElevatedButton.icon(
          onPressed: _sendRequest,
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text("Freund hinzufügen"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown.shade400,
            foregroundColor: AppColors.hellbeige,
            shadowColor: Colors.transparent,
          ),
        );
      },
    );
  }
}
