import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'nutritionpage.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';

class MealAddPage extends StatefulWidget { 
  const MealAddPage({super.key});

  @override
  _AddMealFormState createState() => _AddMealFormState();
}

class _AddMealFormState extends State<MealAddPage> { //the form style page to allow users to add meal entries
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now(); //initializes selectedDate to current day to user's don't have to modify if they're adding a meal they ate today
  TimeOfDay _selectedTime = TimeOfDay.now(); //initializes selectedTime to the current time so user's don't have to modify if they're adding a meal they just had
  File? _selectedImage;

  // list to store added meals in one session, but doesn't work if app is closed then restarted
  //dynamic allows for any type of value to be mapped to each key, which we need here because we have numbers, letters, symbols
  List<Map<String, dynamic>> addedMeals = [];

  Future<void> _fetchCalories(String description) async {

    setState(() {
      _isLoading = true;
    });

    try { //fetching from nutrition api that returns the calories from the user's input (this specific api requires commas in between each entry to be able to parse)
      const appId = 'd1e74d02'; 
      const appKey = '2ebe205700295d325e3514a49cac2056'; 

      final encodedDescription = Uri.encodeComponent(description);
      final String apiUrl =
          'https://api.edamam.com/api/nutrition-data?app_id=$appId&app_key=$appKey&ingr=$encodedDescription';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {

        final data = json.decode(response.body);
        final calories = data['calories'] ?? 'Unknown'; // fetch only calories from the api
        
        //add the meal to the list of added meals with each category of data
        setState(() {
          addedMeals.add({
            'description': description,
            'calories': calories.toString(),
            'date': DateFormat.yMMMd().format(_selectedDate),
            'time': _selectedTime.format(context),
            'image': _selectedImage, 
          });
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NutritionResultPage(
              meals: addedMeals,  // pass the list of added meals to the nutrition page
            ),
          ),
        );
      } else {
        _showError('Failed to fetch calories. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showError('An error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async { //date selection from package intl
    final DateTime? picked = await showDatePicker( //built in function that displays the calendar interface
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000), //first year allowed to choose from
      lastDate: DateTime(2101), //last year allowed to choose from
    );
    if (picked != null && picked != _selectedDate) { //change the state
      setState(() {
        _selectedDate = picked;
      });
    }
  }
 
  Future<void> _selectTime(BuildContext context) async { //time selection from package intl
    final TimeOfDay? picked = await showTimePicker( //built in function in the intl package that shows a clock interface
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async { //passes in the source of the picker the user chose, either that they just took or got from their album
    final picker = ImagePicker(); //built in function from image_picker package
    final XFile? pickedFile = await picker.pickImage(source: source); //pickImage takes in the user's selected image and turns it into File type
    //XFile contains metadata and path to the user's selected image

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add A Meal")),
      body: _isLoading //turnery bc can't have if statement here
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          children: [
                            ClipRRect( // image corner rounding and ensuring full image is displayed
                            borderRadius: BorderRadius.circular(12.0), 
                            child:
                             _selectedImage != null
                              ? Image.file(
                                _selectedImage!,
                                height: 200,
                                width: 200, 
                                fit: BoxFit.cover, 
                            )
                            : const SizedBox() //if an image hasn't been selected, empty sizedbox as a placeholder
                          ),
                            const SizedBox(height: 25),
                            Row( //
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _pickImage(ImageSource.camera), //imagesource.camera is a built in 
                                  icon: const Icon(Icons.camera),
                                  label: const Text('Camera'),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _pickImage(ImageSource.gallery),
                                  icon: const Icon(Icons.photo_library),
                                  label: const Text('Gallery'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Enter details of your meal!',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            AlertDialog(
                              title: const Text(''),
                            content: const Text('add a meal!'),
                            actions: [TextButton(onPressed: ()=>
                            Navigator.pop(context, 'ok'), child: const Text('ok'))],);
                          }
                          return null;
                        },
                      ),
                      ListTile(
                        title: Text('Date: ${DateFormat.yMMMd().format(_selectedDate)}'),
                        trailing: const Icon(Icons.calendar_today), 
                        onTap: () => _selectDate(context),
                      ),
                      ListTile(
                        title: Text('Time: ${_selectedTime.format(context)}'),
                        trailing: const Icon(Icons.access_time),
                        onTap: () => _selectTime(context),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {
                              final description = _descriptionController.text; //get the user inputted food description text
                              if (description.isNotEmpty) { //make sure user entered something
                                _fetchCalories(description); //try to get the amount of calories from user input
                              } 
                            },
                            child: const Text('Add'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
