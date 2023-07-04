import 'package:elushade_project/time_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'channel_button.dart';
import 'model.dart';

class ProjectPage extends ConsumerStatefulWidget {
  const ProjectPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProjectPageState();
}

class _ProjectPageState extends ConsumerState<ProjectPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final api = ref.watch(apiProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Project page"),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Energy Consumed:"),
              Text(
                  "${timeSlots[ref.watch(apiProvider).currentTimeSlot].accumulatedUsage.toStringAsFixed(6)} kwh"),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Current Reading"),
              Text("${api.currentReading.toStringAsFixed(4)} A"),
            ],
          ),
        ),
        for (final channel in api.channels)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChannelButton(
                enabled: ref.watch(apiProvider).userMode,
                channelModel: channel),
          ),
        const SizedBox(height: 20),
        const Text("All Channels control"),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                onPressed: () async {
                  ref.read(apiProvider.notifier).changeState(255, 0);
                },
                style: ElevatedButton.styleFrom(),
                child: const Text("Turn off")),
            ElevatedButton(
                onPressed: () async {
                  ref.read(apiProvider.notifier).changeState(255, 1);
                },
                style: ElevatedButton.styleFrom(),
                child: const Text("Turn on")),
            ElevatedButton(
                onPressed: () async {
                  ref.read(apiProvider.notifier).changeState(255, 2);
                },
                style: ElevatedButton.styleFrom(),
                child: const Text("Toggle state")),
          ],
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
          label:
              Text(ref.watch(apiProvider).userMode ? "User Mode" : "Auto Mode"),
          icon: Icon(Icons.change_circle),
          onPressed: () {
            ref
                .read(apiProvider.notifier)
                .changeMode(!(ref.read(apiProvider.notifier).state.userMode));
          }),
    );
  }
}
