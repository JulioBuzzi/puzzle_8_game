import 'package:flutter/material.dart';
import 'package:puzzle_8_game/algorithms/search_base.dart';

class ResultsComparison extends StatelessWidget {
  final Map<String, SearchResult> results;

  const ResultsComparison({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Algoritmo')),
          DataColumn(label: Text('Solução')),
          DataColumn(label: Text('Passos')),
          DataColumn(label: Text('Nós Expandidos')),
          DataColumn(label: Text('Tempo (ms)')),
        ],
        rows: results.entries.map((entry) {
          final result = entry.value;
          return DataRow(cells: [
            DataCell(Text(entry.key)),
            DataCell(Text(result.isSolution ? '✓' : '✗')),
            DataCell(Text('${result.path.length}')),
            DataCell(Text('${result.expandedNodes}')),
            DataCell(Text('${result.time.inMilliseconds}')),
          ]);
        }).toList(),
      ),
    );
  }
}
