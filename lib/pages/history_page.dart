import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medical History"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHistoryCard(
            testName: "Complete Blood Count (CBC)",
            date: DateTime(2023, 11, 15),
            status: "Completed",
            result: "Normal",
            color: Colors.green,
          ),
          _buildHistoryCard(
            testName: "COVID-19 RT-PCR Test",
            date: DateTime(2023, 10, 28),
            status: "Completed",
            result: "Negative",
            color: Colors.green,
          ),
          _buildHistoryCard(
            testName: "Lipid Profile",
            date: DateTime(2023, 9, 5),
            status: "Completed",
            result: "High Cholesterol",
            color: Colors.orange,
          ),
          _buildHistoryCard(
            testName: "Diabetes Screening",
            date: DateTime(2023, 8, 12),
            status: "Completed",
            result: "Borderline",
            color: Colors.orange,
          ),
          _buildHistoryCard(
            testName: "X-Ray Chest",
            date: DateTime(2023, 7, 20),
            status: "Completed",
            result: "Normal",
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard({
    required String testName,
    required DateTime date,
    required String status,
    required String result,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    testName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Chip(
                    label: Text(status),
                    backgroundColor: Colors.blue[50],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Date: ${DateFormat('dd MMM yyyy').format(date)}",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("Result: "),
                Text(
                  result,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // View details action
                },
                child: const Text("View Details"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}