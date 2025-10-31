import 'package:flutter/material.dart';

class DietScreen extends StatelessWidget {
    final String hospitalId; 

   DietScreen({super.key, required this.hospitalId});

  @override
  Widget build(BuildContext context) {
    final dietPlans = [
      {"meal": "Breakfast", "menu": "Oats, Milk, Banana"},
      {"meal": "Lunch", "menu": "Rice, Dal, Salad"},
      {"meal": "Dinner", "menu": "Soup, Roti, Vegetables"},
    ];

    return Scaffold(
      appBar: AppBar(title:  Text("Diet Plan")),
      body: ListView.builder(
        itemCount: dietPlans.length,
        itemBuilder: (context, index) {
          final meal = dietPlans[index];
          return Card(
            margin:  EdgeInsets.all(8),
            child: ListTile(
              title: Text(meal["meal"]!),
              subtitle: Text(meal["menu"]!),
              leading:  Icon(Icons.restaurant_menu, color: Colors.green),
            ),
          );
        },
      ),
    );
  }
}
