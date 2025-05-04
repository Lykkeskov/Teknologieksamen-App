// lib/pages/exercise_page.dart

import 'package:flutter/material.dart';

class ExercisePage extends StatelessWidget {
  const ExercisePage({super.key});

  final List<Map<String, String>> exercises = const [
    {
      'title': 'Stræk armene over hovedet',
      'description': 'Hold i 10 sekunder og gentag 3 gange.'
    },
    {
      'title': 'Rul skuldrene',
      'description': '5 gange fremad og 5 gange bagud.'
    },
    {
      'title': 'Rejs dig og stræk benene',
      'description': 'Stå i 30 sekunder og stræk dig op.'
    },
    {
      'title': 'Drej hovedet fra side til side',
      'description': 'Gentag 5 gange hver vej.'
    },
    {
      'title': 'Lav 5 squats',
      'description': 'Brug din kontorstol som støtte hvis nødvendigt.'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tid til bevægelse!'), backgroundColor: Colors.blue),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(exercises[index]['title']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(exercises[index]['description']!),
              leading: const Icon(Icons.fitness_center),
            ),
          );
        },
      ),
    );
  }
}
