import 'package:cached_network_image/cached_network_image.dart';
import 'package:example/src/model/user.dart';
import 'package:flutter/material.dart';
import 'package:force_directed_graphview/force_directed_graphview.dart';

class UserNode extends StatelessWidget {
  const UserNode({
    required this.node,
    super.key,
  });

  final Node<User> node;

  @override
  Widget build(BuildContext context) {
    final user = node.data;
    return SizedBox(
      width: node.size,
      height: node.size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey,
          border: Border.all(
            color: node.pinned ? Colors.red : Colors.black,
            width: 2,
          ),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: CachedNetworkImageProvider(
              'https://picsum.photos/seed/${user.id}/${node.size.toInt()}',
            ),
          ),
        ),
        child: node.pinned
            ? const Icon(
                Icons.push_pin,
                color: Colors.red,
              )
            : null,
      ),
    );
  }
}
