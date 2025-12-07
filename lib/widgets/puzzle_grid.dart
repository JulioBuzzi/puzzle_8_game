import 'package:flutter/material.dart';
import 'package:puzzle_8_game/models/puzzle_state.dart';

class PuzzleGrid extends StatefulWidget {
  final PuzzleState state;
  final Function(PuzzleState)? onTilePressed;
  final bool interactive;

  const PuzzleGrid({
    super.key,
    required this.state,
    this.onTilePressed,
    this.interactive = true,
  }) : super();

  @override
  State<PuzzleGrid> createState() => _PuzzleGridState();
}

class _PuzzleGridState extends State<PuzzleGrid> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.state.gridSize,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: widget.state.tiles.length,
      itemBuilder: (context, index) {
        final value = widget.state.tiles[index];
        final isEmpty = value == 0;

        return GestureDetector(
          onTap: widget.interactive && !isEmpty
              ? () {
                  final emptyPos = widget.state.emptyPosition;
                  final row = index ~/ widget.state.gridSize;
                  final col = index % widget.state.gridSize;
                  final emptyRow = emptyPos ~/ widget.state.gridSize;
                  final emptyCol = emptyPos % widget.state.gridSize;

                  // Verifica se o tile está adjacente ao espaço vazio
                  if ((row - emptyRow).abs() + (col - emptyCol).abs() == 1) {
                    widget.onTilePressed?.call(
                      widget.state._swapPublic(index, emptyPos),
                    );
                  }
                }
              : null,
          child: Container(
            decoration: BoxDecoration(
              color: isEmpty ? Colors.grey[300] : Colors.blue[600],
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              isEmpty ? '' : '$value',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        );
      },
    );
  }
}

extension PuzzleStateExt on PuzzleState {
  PuzzleState _swapPublic(int pos1, int pos2) {
    final newTiles = List<int>.from(tiles);
    final temp = newTiles[pos1];
    newTiles[pos1] = newTiles[pos2];
    newTiles[pos2] = temp;
    return PuzzleState(tiles: newTiles, gridSize: gridSize);
  }
}
