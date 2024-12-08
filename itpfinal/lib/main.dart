import 'package:flutter/material.dart';
import 'mealadd.dart';

TextStyle ts = const TextStyle(fontSize: 30);

void main() {
  runApp(const MealApp());
}

class MealApp extends StatelessWidget {
  const MealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Journal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF2EBE2)),
        useMaterial3: true,
      ),
      home: const FirstHomePage(title: 'Meal Journal'),
    );
  }
}

class FirstHomePage extends StatefulWidget {
  const FirstHomePage({super.key, required this.title});
  final String title;

  @override
  State<FirstHomePage> createState() => FirstHomePageState();
}

class FirstHomePageState extends State<FirstHomePage> { //just a homepage page that redirects to the important stuff

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: 
      Center(
      child:
      Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        crossAxisAlignment: CrossAxisAlignment.center, 
        children: [
          Image.asset(
            'assets/toastlogo.jpg', 
              height: 175, 
              width: 175, 
              fit: BoxFit.cover
          ), 
          ElevatedButton
              ( onPressed: ()
                { Navigator.of(context).push
                  ( MaterialPageRoute
                    ( builder: (context) => const MealAddPage() //navigate button, calling the form to add meal, pushing it on the stack
                    ),
                  );
                },
                child: Text("start my journal", style:ts),
              ),
        ],
        ),
      ),
    );
  }
}