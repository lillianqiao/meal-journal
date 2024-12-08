import 'package:flutter/material.dart';
import 'mealadd.dart';

class NutritionResultPage extends StatelessWidget {

  //list of meals where each meal is a map that has key string to value type dynamic
  final List<Map<String, dynamic>> meals; //dynamic allows for any type of value to be mapped to each key, which we need here because we have numbers, letters, symbols

  const NutritionResultPage({super.key, required this.meals}); //must pass in the list of added user meals to nutrition page in order for timeline to display

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Food Journal!")),
      body: ListView.builder( //creates a widget for each entry/meal in the list that was passed from meal add page
        itemCount: meals.length, //number of meals in list/number of items in the timeline
        itemBuilder: (context, index) {
        final meal = meals[index]; //last
        return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // left side with time and date
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text(
                  '${meal['time']}', //passed from meal add as key value pair format, so get with key
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${meal['date']}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            //middle bar in between each log
            const SizedBox(
                  height: 350,
                  child: VerticalDivider(
                    thickness: 1,
                    color: Colors.black,
                    width: 20,
                  ),
                ), 
            //right side with description, photo, and calories
            Expanded ( child:
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meal['description'],  
                  maxLines : 3, //let the description go onto next line for three lines so it doesn't go off the page
                  overflow: TextOverflow.ellipsis, //if description is longer than 3 rows, then add ...
                  style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  if (meal['image'] != null)
                    ClipRRect( //image format with rounded corners
                      borderRadius: BorderRadius.circular(12.0), 
                      child: Image.file(
                        meal['image']!,
                        height: 175, 
                        width: 175, 
                        fit: BoxFit.cover, 
                      ),
                    ),
                  Text(
                    'Calories',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(meal['calories']),
                ],
              ),
            ),
          ],
        ),
      ); 
    },
  ),
      //when user clicks add button from the timeline, the current nutrition page gets popped so the next time the user adds their meal
      //it populates the timeline with all their entries, not just their last entry
      floatingActionButton: FloatingActionButton( 
        onPressed: () 
                { Navigator.of(context).pop
                  ( MaterialPageRoute
                    ( builder: (context) => const MealAddPage()
                    ),
                  );
                },
                child: const Icon(Icons.add),
      ), 
    );
  }
}
