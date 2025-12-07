import 'package:flutter/material.dart';
import 'package:puzzle_8_game/algorithms/search_base.dart';

class ResultsComparison extends StatelessWidget {
  final Map<String, SearchResult> results;
  final String? activeAlgorithm;
  final String? playingAlgorithm;
  final void Function(String algorithm)? onPlay;
  final VoidCallback? onStop;

  const ResultsComparison({
    super.key,
    required this.results,
    this.activeAlgorithm,
    this.playingAlgorithm,
    this.onPlay,
    this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: DataTable(
        columns: [
          const DataColumn(label: Text('Algoritmo')),
          const DataColumn(label: Text('Solução')),
          const DataColumn(label: Text('Passos')),
          const DataColumn(label: Text('Nós Expandidos')),
          DataColumn(
            label: Row(
              children: [
                const Text('Tempo (ms)'),
                const SizedBox(width: 12),
                // Button placed on the header line
                if (activeAlgorithm != null && results[activeAlgorithm] != null && results[activeAlgorithm]!.isSolution)
                  Builder(builder: (ctx) {
                    final isPlaying = playingAlgorithm == activeAlgorithm;
                    return ElevatedButton.icon(
                      onPressed: isPlaying
                          ? onStop
                          : () {
                              if (onPlay != null) onPlay!(activeAlgorithm!);
                            },
                      icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                      label: Text(isPlaying ? 'Parar' : 'Iniciar'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    );
                  }),
              ],
            ),
          ),
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
