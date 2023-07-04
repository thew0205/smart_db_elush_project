import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'model.dart';

class ChannelButton extends ConsumerWidget {
  const ChannelButton({required this.enabled, super.key, required this.channelModel});
  final ChannelModel channelModel;
  final bool enabled;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Channel ${channelModel.channel}",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Text(stateToString(channelModel.state)),
                      const SizedBox(width: 5),
                      Icon(
                        Icons.lightbulb_circle,
                        color: channelModel.state == 1
                            ? Colors.yellow
                            : Colors.black,
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ElevatedButton(
                //     onPressed: () async {
                //       ref
                //           .read(apiProvider.notifier)
                //           .changeState(channelModel.channel, 0);
                //     },
                //     style: ElevatedButton.styleFrom(),
                //     child: const Text("Turn off")),
                // ElevatedButton(
                //     onPressed: () async {
                //       ref
                //           .read(apiProvider.notifier)
                //           .changeState(channelModel.channel, 1);
                //     },
                //     style: ElevatedButton.styleFrom(),
                //     child: const Text("Turn on")),
                ElevatedButton(
                    onPressed: enabled
                        ? () async {
                            ref
                                .read(apiProvider.notifier)
                                .changeState(channelModel.channel, 2);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(),
                    child: const Text("Toggle state")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
