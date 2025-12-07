import 'package:puzzle_8_game/models/puzzle_state.dart';
import 'package:puzzle_8_game/algorithms/search_base.dart';

class BFSSearch implements SearchAlgorithm {
  @override
  Future<SearchResult> solve(PuzzleState initialState) async {
    final stopwatch = Stopwatch()..start();
    final queue = <Node>[
      Node(state: initialState, parent: null, depth: 0),
    ];
    final visited = <PuzzleState>{initialState};
    int expandedNodes = 0;

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);

      if (current.state.isGoal()) {
        stopwatch.stop();
        return SearchResult(
          solution: current.state,
          path: current.reconstructPath(),
          expandedNodes: expandedNodes,
          exploredStates: visited.length,
          time: stopwatch.elapsed,
        );
      }

      expandedNodes++;

      for (final successor in current.state.getSuccessors()) {
        if (!visited.contains(successor)) {
          visited.add(successor);
          queue.add(Node(
            state: successor,
            parent: current,
            depth: current.depth + 1,
          ));
        }
      }

      // Dar oportunidade para UI atualizar
      if (expandedNodes % 100 == 0) {
        await Future.delayed(Duration.zero);
      }
    }

    stopwatch.stop();
    return SearchResult(
      solution: null,
      path: [],
      expandedNodes: expandedNodes,
      exploredStates: visited.length,
      time: stopwatch.elapsed,
    );
  }
}
