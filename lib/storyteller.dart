import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mime/mime.dart';
import 'package:image_picker/image_picker.dart';

class Storyteller extends StatefulWidget {
  const Storyteller({super.key});

  @override
  State<Storyteller> createState() => _StorytellerState();
}

class _StorytellerState extends State<Storyteller> {
  bool isLoading = false;
  String API_KEY = "API_KEY";
  dynamic response;
  File? image;
  var type = [
    "Adventure",
    "Romance",
    "Mystery",
    "Fantasy",
    "Horror",
    "Science Fiction",
  ];
  var tone = ["emotional", "funny", "serious"];
  var length = ["short paragraph", "3-minute read", "500 words"];
  var typeVal = "Adventure";
  var toneVal = "emotional";
  var lengthVal = "short paragraph";

  void picImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? img = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
    );
    if (img == null) return;
    setState(() {
      image = File(img.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          "Image Story Teller",
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Upload an image and let AI create a captivating story based on what it sees',
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
                  dashPattern: [6, 3],
                  color: Colors.grey,
                  borderType: BorderType.RRect,
                  radius: Radius.circular(12),
                  padding: EdgeInsets.all(6),
                  strokeWidth: 2,
                  child: SizedBox(
                    width: screenWidth - 40,
                    height: MediaQuery.of(context).size.height / 3.5,
                    child: GestureDetector(
                      onTap: () => picImage(),
                      child:
                          image == null
                              ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.upload,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                  Text(
                                    'Upload image',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    'Drag and drop your file here, or\nclick to browse',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: Colors.blueGrey,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              )
                              : Image.file(
                                image!,
                                width: screenWidth - 40,
                                height:
                                    MediaQuery.of(context).size.height / 3.5,
                                fit: BoxFit.cover,
                              ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  DropdownButton(
                    dropdownColor: Colors.blue[100],
                    value: typeVal,
                    onChanged: (newValue) {
                      setState(() {
                        typeVal = newValue!;
                      });
                    },
                    items:
                        type.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                  ),
                  DropdownButton(
                    dropdownColor: Colors.blue[100],
                    value: lengthVal,
                    onChanged: (newValue) {
                      setState(() {
                        lengthVal = newValue!;
                      });
                    },
                    items:
                        length.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                  ),
                  DropdownButton(
                    dropdownColor: Colors.blue[100],
                    value: toneVal,
                    onChanged: (newValue) {
                      setState(() {
                        toneVal = newValue!;
                      });
                    },
                    items:
                        tone.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 300,
                  height: 40,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    label: Text(
                      'Generate Story',
                      style: TextStyle(fontSize: 19),
                    ),
                    icon: Icon(Icons.book, color: Colors.white, size: 21),
                    onPressed: () async {
                      if (image == null) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Pick Image')));
                        return;
                      }

                      setState(() => isLoading = true);

                      final model = GenerativeModel(
                        model: 'gemini-1.5-flash',
                        apiKey: API_KEY,
                        systemInstruction: Content.system(
                          '''You are a master storyteller. Look at the image and create a compelling story inspired by what you see. Include characters, setting, emotions, and a narrative arc. You can be imaginative — it's okay to create a fantasy or fictional story based on visual clues. Tailor the tone depending on the audience (e.g., kids, adults, dark, motivational, humorous).
 - Story Type: $typeVal
 - Length: $lengthVal
 - Tone: $toneVal

Output format:
1. Title:
2. Genre:
3. Story:
4. Moral / Message (optional):
5. Characters Introduced:
6. Possible Continuation (optional):
''',
                        ),
                      );

                      response = await model.generateContent([
                        Content.multi([
                          DataPart(
                            lookupMimeType(image!.path) ??
                                'application/octet-stream',
                            await image!.readAsBytes(),
                          ),
                        ]),
                      ]);

                      setState(() => isLoading = false);
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 250,
                child:
                    isLoading
                        ? Center(
                          child: CircularProgressIndicator(color: Colors.blue),
                        )
                        : response == null
                        ? Container()
                        : Card(
                          color: const Color.fromARGB(255, 238, 224, 218),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15.0,
                              vertical: 10,
                            ),
                            child: Text(
                              response.text,
                              style: TextStyle(
                                fontSize: 14,
                                height: 2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
