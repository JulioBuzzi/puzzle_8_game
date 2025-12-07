import 'package:puzzle_8_game/models/puzzle_state.dart';

class SearchResult {
  final PuzzleState? solution;
  final List<PuzzleState> path;
  final int expandedNodes;
  final int exploredStates;
  final Duration time;

  SearchResult({
    required this.solution,
    required this.path,
    required this.expandedNodes,
    required this.exploredStates,
    required this.time,
  });

  bool get isSolution => solution != null;
}

abstract class SearchAlgorithm {
  Future<SearchResult> solve(PuzzleState initialState);
}

// Nó para busca
class Node {
  final PuzzleState state;
  final Node? parent;
  final int depth;
  int gCost; // Custo do inicio até aqui
  int hCost; // Custo heurístico até o goal

  Node({
    required this.state,
    this.parent,
    required this.depth,
    this.gCost = 0,
    this.hCost = 0,
  });

  int get fCost => gCost + hCost; // Para A*

  List<PuzzleState> reconstructPath() {
    final path = <PuzzleState>[];
    Node? current = this;
    while (current != null) {
      path.insert(0, current.state);
      current = current.parent;
    }
    return path;
  }
}
