import 'package:baghdadcompany/screens/authControl.dart';

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final colors = [
      {'color': colorScheme.primary, 'name': 'primary'},
      {'color': colorScheme.primaryContainer, 'name': 'primaryContainer'},
      {'color': colorScheme.secondary, 'name': 'secondary'},
      {'color': colorScheme.secondaryContainer, 'name': 'secondaryContainer'},
      {'color': colorScheme.surface, 'name': 'surface'},
      {'color': colorScheme.error, 'name': 'error'},
      {'color': colorScheme.onPrimary, 'name': 'onPrimary'},
      {'color': colorScheme.onSecondary, 'name': 'onSecondary'},
      {'color': colorScheme.onSurface, 'name': 'onSurface'},
      {'color': colorScheme.onError, 'name': 'onError'},
      {'color': colorScheme.outline, 'name': 'outline'},
      {'color': colorScheme.shadow, 'name': 'shadow'},
      {'color': colorScheme.inverseSurface, 'name': 'inverseSurface'},
      {'color': colorScheme.onInverseSurface, 'name': 'onInverseSurface'},
      {'color': colorScheme.inversePrimary, 'name': 'inversePrimary'},
      {
        'color': colorScheme.surfaceContainerHighest,
        'name': 'surfaceContainerHighest'
      },
      {'color': colorScheme.onSurfaceVariant, 'name': 'onSurfaceVariant'},
    ];
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 3,
      ),
      drawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: colors.map((color) {
              return Row(
                children: [
                  Container(
                    height: 12,
                    width: 12,
                    color: color['color'] as Color?,
                    margin: EdgeInsets.symmetric(vertical: 4),
                  ),
                  SizedBox(width: 8),
                  Text(
                    color['name'] as String,
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
      body: Authcontrol(),
    );
  }
}
