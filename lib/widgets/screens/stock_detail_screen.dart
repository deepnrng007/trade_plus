// stock_detail_screen.dart
import 'package:flutter/material.dart';

class StockDetailScreen extends StatefulWidget {
  final String symbol;

  const StockDetailScreen({super.key, required this.symbol});

  @override
  _StockDetailScreenState createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  // You can add any state variables here
  String stockDetails = "Loading...";

  @override
  void initState() {
    super.initState();
    // Simulate fetching stock details
    _fetchStockDetails();
  }

  Future<void> _fetchStockDetails() async {
    // Simulate a network call or data fetching
    await Future.delayed(const Duration(seconds: 2)); // Simulating a delay
    setState(() {
      // Update the state with fetched stock details
      stockDetails = "Details for stock: ${widget.symbol}"; // Replace with actual data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details for ${widget.symbol}'),
      ),
      body: Center(
        child: Text(stockDetails),
      ),
    );
  }
}