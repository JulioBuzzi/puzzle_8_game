import 'package:puzzle_8_game/models/puzzle_state.dart';
import 'package:puzzle_8_game/algorithms/search_base.dart';

class DFSSearch implements SearchAlgorithm {
  final int maxDepth = 50; // Limita profundidade para evitar recursão infinita

  @override
  Future<SearchResult> solve(PuzzleState initialState) async {
    final stopwatch = Stopwatch()..start();
    final visited = <PuzzleState>{};
    int expandedNodes = 0;

    Node? result;

    Future<Node?> dfs(Node node) async {
      if (node.depth > maxDepth) return null;

      visited.add(node.state);
      expandedNodes++;

      if (node.state.isGoal()) {
        return node;
      }

      for (final successor in node.state.getSuccessors()) {
        if (!visited.contains(successor)) {
          final childNode = Node(
            state: successor,
            parent: node,
            depth: node.depth + 1,
          );

          result = await dfs(childNode);
          if (result != null) return result;
        }
      }

      return null;
    }

    result = await dfs(Node(state: initialState, parent: null, depth: 0));

    stopwatch.stop();

    if (result != null) {
      return SearchResult(
        solution: result!.state,
        path: result!.reconstructPath(),
        expandedNodes: expandedNodes,
        exploredStates: visited.length,
        time: stopwatch.elapsed,
      );
    }

    return SearchResult(
      solution: null,
      path: [],
      expandedNodes: expandedNodes,
      exploredStates: visited.length,
      time: stopwatch.elapsed,
    );
  }
}
