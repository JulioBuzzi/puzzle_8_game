import 'package:puzzle_8_game/models/puzzle_state.dart';
import 'package:puzzle_8_game/algorithms/search_base.dart';

class AStarSearch implements SearchAlgorithm {
  final String heuristic; // 'manhattan', 'misplaced', 'nilsson'

  AStarSearch({this.heuristic = 'manhattan'});

  @override
  Future<SearchResult> solve(PuzzleState initialState) async {
    final stopwatch = Stopwatch()..start();
    final openSet = <Node>[];
    final closedSet = <PuzzleState>{};
    int expandedNodes = 0;

    final startNode = Node(
      state: initialState,
      parent: null,
      depth: 0,
      gCost: 0,
      hCost: _calculateHeuristic(initialState),
    );

    openSet.add(startNode);

    while (openSet.isNotEmpty) {
      // Encontra nó com menor f-cost
      int bestIndex = 0;
      for (int i = 1; i < openSet.length; i++) {
        if (openSet[i].fCost < openSet[bestIndex].fCost) {
          bestIndex = i;
        }
      }

      final current = openSet.removeAt(bestIndex);

      if (current.state.isGoal()) {
        stopwatch.stop();
        return SearchResult(
          solution: current.state,
          path: current.reconstructPath(),
          expandedNodes: expandedNodes,
          exploredStates: closedSet.length,
          time: stopwatch.elapsed,
        );
      }

      closedSet.add(current.state);
      expandedNodes++;

      for (final successor in current.state.getSuccessors()) {
        if (closedSet.contains(successor)) continue;

        final tentativeGCost = current.gCost + 1;
        Node? openNode;

        for (final node in openSet) {
          if (node.state == successor) {
            openNode = node;
            break;
          }
        }

        if (openNode != null && tentativeGCost >= openNode.gCost) {
          continue;
        }

        final newNode = Node(
          state: successor,
          parent: current,
          depth: current.depth + 1,
          gCost: tentativeGCost,
          hCost: _calculateHeuristic(successor),
        );

        if (openNode != null) {
          openSet.remove(openNode);
        }
        openSet.add(newNode);
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
      exploredStates: closedSet.length,
      time: stopwatch.elapsed,
    );
  }

  int _calculateHeuristic(PuzzleState state) {
    switch (heuristic) {
      case 'misplaced':
        return state.misplacedTiles();
      case 'nilsson':
        return state.nilssonSequenceScore();
      case 'manhattan':
      default:
        return state.manhattanDistance();
    }
  }
}
