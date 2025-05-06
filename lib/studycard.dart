import 'dart:convert';
import 'dart:io';

import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flip_card/controllers/flip_card_controllers.dart';
import 'package:flutter_flip_card/flipcard/flip_card.dart';
import 'package:flutter_flip_card/modal/flip_side.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mime/mime.dart';

class StudyCardGenerator extends StatefulWidget {
  const StudyCardGenerator({super.key});

  @override
  State<StudyCardGenerator> createState() => _StudyCardGeneratorState();
}

class _StudyCardGeneratorState extends State<StudyCardGenerator> {
  bool isLoading = false;
  String API_KEY = "AIzaSyBgjxAfBK6GT2Mnsv_gvvkeaLdZMbjw_gk";
  List<List<Color>> answers = List.generate(
    5,
    (index) => List.generate(4, (_) => Color.fromARGB(255, 244, 217, 204)),
  );

  dynamic response;
  File? image;
  PlatformFile? file;
  bool isFlashCard = true;
  final controller = FlipCardController();
  List<dynamic> questions = [];
  List<dynamic> flashcards = [];

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        file = result.files.single;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          "Study Material Generator",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Upload your notes or textbook PDFs to create flashcards and study questions',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blueGrey,
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DottedBorder(
                dashPattern: [6, 3, 6, 3],
                color: Colors.grey,
                borderType: BorderType.RRect,
                radius: Radius.circular(12),
                padding: EdgeInsets.all(6),
                strokeWidth: 2,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  height: MediaQuery.of(context).size.height / 4.5,
                  child: GestureDetector(
                    onTap: () => pickFile(),
                    child:
                        file == null
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.upload,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                                Text(
                                  'Upload Notes file',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  textAlign: TextAlign.center,
                                  'Drag and drop your file here, or\n click to browse',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.blueGrey,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            )
                            : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.file_upload_outlined,
                                  color: Colors.green,
                                  size: 60,
                                ),
                                Text(
                                  textAlign: TextAlign.center,
                                  'File Uploaded Successfully \n ${file!.name}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10),
              child: CustomSlidingSegmentedControl<int>(
                innerPadding: EdgeInsets.all(5),
                initialValue: 1,
                children: {
                  1: Text(
                    'Flash Cards',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  2: Text(
                    'Study Questions',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                },
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
                thumbDecoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInToLinear,
                onValueChanged: (v) {
                  setState(() {
                    isFlashCard = (v == 1);
                    questions.clear();
                    flashcards.clear();
                  });
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 15.0),
              child: SizedBox(
                width: 320,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  label: Text(
                    'Generate Study Materials',
                    style: TextStyle(fontSize: 20),
                  ),
                  icon: Icon(Icons.book, color: Colors.white, size: 20),
                  onPressed: () async {
                    if (file == null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Select files')));
                      return;
                    }

                    setState(() {
                      isLoading = true;
                    });

                    final model = GenerativeModel(
                      model: 'gemini-1.5-flash',
                      apiKey: API_KEY,
                      systemInstruction:
                          isFlashCard
                              ? Content.system(
                                '''You are a brilliant teacher and memory coach. Based on the uploaded notes or documents, generate exactly 3 flashcards. Each flashcard must have a **question** and its corresponding **short answer** (3 lines max). 

Format your output as a JSON array like this:
[
  ["What is Newton's First Law?", "Newton's First Law states that an object at rest stays at rest, and an object in motion stays in motion unless acted upon by an external force."],
  ["Define kinetic energy.", "Kinetic energy is the energy of motion, calculated as KE = ½mv²."],
  ["What is Ohm’s Law?", "Ohm’s Law relates voltage, current, and resistance: V = IR."]
]''',
                              )
                              : Content.system(
                                '''You are a brilliant teacher and memory coach. Based on the uploaded notes or documents, generate 5 MCQ quiz questions.
Output Format:
[
  {
    "question": "Sample question?",
    "answers": ["Option 1", "Option 2", "Option 3", "Option 4"],
    "correctAnswer": 1
  }
]''',
                              ),
                    );

                    try {
                      final content = await File(file!.path!).readAsBytes();
                      final mimeType =
                          lookupMimeType(file!.path!) ?? 'application/pdf';

                      final responseContent = await model.generateContent([
                        Content.multi([DataPart(mimeType, content)]),
                      ]);

                      final text = responseContent.text ?? '';
                      final jsonStart = text.indexOf('[');
                      final jsonEnd = text.lastIndexOf(']') + 1;
                      final jsonString =
                          (jsonStart != -1 &&
                                  jsonEnd != -1 &&
                                  jsonEnd > jsonStart)
                              ? text.substring(jsonStart, jsonEnd)
                              : '[]';

                      final decoded = json.decode(jsonString);

                      setState(() {
                        if (isFlashCard) {
                          flashcards = decoded;
                          print("Parsed Flashcards: $flashcards");
                        } else {
                          questions = decoded;
                          // Reinitialize answer color list
                          answers = List.generate(
                            questions.length,
                            (_) => List.generate(
                              4,
                              (_) => Color.fromARGB(255, 244, 217, 204),
                            ),
                          );
                        }
                        isLoading = false;
                      });
                    } catch (e) {
                      setState(() {
                        isLoading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error parsing response')),
                      );
                    }
                  },
                ),
              ),
            ),
            Expanded(
              child:
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : isFlashCard && flashcards.isNotEmpty
                      ? ListView.builder(
                        itemCount: flashcards.length,
                        itemBuilder: (context, index) {
                          return FlipCard(
                            controller: controller,
                            rotateSide: RotateSide.right,

                            axis: FlipAxis.horizontal,

                            animationDuration: Duration(milliseconds: 800),
                            frontWidget: Card(
                              color: Color(0xFFEEE0DA),
                              child: Container(
                                height: 220,
                                width: 320,
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(10),
                                child: SizedBox(
                                  height: 150,
                                  child: Column(
                                    children: [
                                      Text(
                                        flashcards[index][0], // Question
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        flashcards[index][1],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            backWidget: Card(
                              color: Colors.white,
                              child: Container(
                                height: 220,
                                width: 320,
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  flashcards[index].length > 1 &&
                                          flashcards[index][1].isNotEmpty
                                      ? flashcards[index][1] // Answer
                                      : "Answer not available",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                      : !isFlashCard && questions.isNotEmpty
                      ? ListView.builder(
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 5,
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                children: [
                                  Text(
                                    questions[index]['question'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  ...List.generate(4, (i) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            answers[index][i] =
                                                questions[index]['correctAnswer'] ==
                                                        i
                                                    ? Color(0xffabff94)
                                                    : Color(0xffff6061);
                                          });
                                        },
                                        child: Container(
                                          color: answers[index][i],
                                          padding: EdgeInsets.all(10),
                                          child: Center(
                                            child: Text(
                                              questions[index]['answers'][i],
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                      : Center(child: Text('No content to show')),
            ),
          ],
        ),
      ),
    );
  }
}
