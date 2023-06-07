import 'package:cached_network_image/cached_network_image.dart';
import 'package:example/src/model/user.dart';
import 'package:flutter/material.dart';
import 'package:force_directed_graphview/force_directed_graphview.dart';

class UserNode extends StatefulWidget {
  const UserNode({
    required this.node,
    this.onPressed,
    this.onLongPressed,
    super.key,
  });

  final Node node;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPressed;

  @override
  State<UserNode> createState() => _UserNodeState();
}

class _UserNodeState extends State<UserNode> {
  var _isActive = false;

  @override
  Widget build(BuildContext context) {
    final user = widget.node.data as User;
    return GestureDetector(
      onTap: () {
        setState(() => _isActive = !_isActive);
        widget.onPressed?.call();
      },
      onLongPress: widget.onLongPressed,
      child: SizedBox(
        width: widget.node.size,
        height: widget.node.size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey,
            border: Border.all(
              color: _isActive ? Colors.red : Colors.black,
              width: 2,
            ),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: CachedNetworkImageProvider(
                'https://picsum.photos/seed/${user.id}/${widget.node.size.toInt()}',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
