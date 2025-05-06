import 'package:flutter/material.dart';
import 'booksummarizer.dart';
import 'storyteller.dart';
import 'objectidentfy.dart';
import 'Audio/viediomintues.dart';
import 'studycard.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<List<dynamic>> analyzers = [
    [
      'Book Summarizer',
      'Upload Books or Text to generate concise summary',
      Icons.bookmark_add,
      BookSummarizer(),
    ],
    [
      'Object Identifier',
      'Upload images to identify objects and get detailed information',
      Icons.remove_red_eye,
      ObjectIdentifier(),
    ],
    [
      'Study Card Generator',
      'Create flashcards and study questions from your pdf notes',
      Icons.card_membership,
      StudyCardGenerator(),
    ],
    [
      'Image StoryTeller',
      'Turn any image into a creative story with AI',
      Icons.video_camera_back,
      Storyteller(),
    ],
    [
      'Audio/Video Minutes',
      'Extract minutes and keypoints from recordings',
      Icons.audio_file,
      AudioVideoMinutes(),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Analyze AI',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: analyzers.length,
        padding: const EdgeInsets.all(10),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => analyzers[index][3]),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.blue),
              ),
              elevation: 1,
              shadowColor: Colors.grey,
              child: ListTile(
                contentPadding: const EdgeInsets.all(15),
                leading: Icon(analyzers[index][2], size: 30),
                title: Text(
                  analyzers[index][0],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  analyzers[index][1],
                  style: const TextStyle(color: Colors.blueGrey, fontSize: 15),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              ),
            ),
          );
        },
      ),
    );
  }
}
