import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentSubmitScreen extends StatefulWidget {
  const DocumentSubmitScreen({super.key});

  @override
  State<DocumentSubmitScreen> createState() => _DocumentSubmitScreenState();
}

class _DocumentSubmitScreenState extends State<DocumentSubmitScreen> {
  final itemController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();
  final notesController = TextEditingController();

  Future<void> sendToWhatsApp() async {
    String item = itemController.text;
    String quantity = quantityController.text;
    String price = priceController.text;
    String notes = notesController.text;

    String phoneNumber = "8801682832598";

    String message = '''
*Accessories Costing Details*

📦 Item: $item
🔢 Quantity: $quantity
💰 Price: $price
📝 Notes: $notes
''';

    final Uri whatsappUrl = Uri.parse(
      "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}",
    );

    await launchUrl(
      whatsappUrl,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accessories Costing"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: itemController,
              decoration: const InputDecoration(
                labelText: "Accessories Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Quantity",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Cost Price",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Notes",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: sendToWhatsApp,
                child: const Text(
                  "Submit To WhatsApp",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}