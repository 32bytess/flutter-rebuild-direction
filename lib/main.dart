import 'package:benchmark_container/generated_widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const BenchmarkApp());
}

class BenchmarkApp extends StatelessWidget {
  const BenchmarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Benchmark Container"),
        ),
        body: GeneratedWidget(),
      ),
    );
  }
}
