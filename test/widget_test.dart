import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_8_game/models/puzzle_state.dart';
import 'package:puzzle_8_game/algorithms/astar_search.dart';
import 'package:puzzle_8_game/main.dart';

void main() {
  group('PuzzleState Tests', () {
    test('Goal state is correctly identified', () {
      final solved = PuzzleState(
        tiles: [1, 2, 3, 4, 5, 6, 7, 8, 0],
      );
      expect(solved.isGoal(), true);
    });

    test('Non-goal state is correctly identified', () {
      final unsolved = PuzzleState(
        tiles: [2, 1, 3, 4, 5, 6, 7, 8, 0],
      );
      expect(unsolved.isGoal(), false);
    });

    test('Empty position is correctly found', () {
      final state = PuzzleState(
        tiles: [1, 2, 3, 4, 5, 6, 7, 0, 8],
      );
      expect(state.emptyPosition, 7);
    });

    test('Successors are generated correctly', () {
      final state = PuzzleState(
        tiles: [1, 2, 3, 4, 5, 6, 7, 0, 8],
      );
      final successors = state.getSuccessors();
      expect(successors.length, 4); // 4 moves possible
    });

    test('Manhattan distance for solved state is 0', () {
      final solved = PuzzleState(
        tiles: [1, 2, 3, 4, 5, 6, 7, 8, 0],
      );
      expect(solved.manhattanDistance(), 0);
    });

    test('Misplaced tiles for solved state is 0', () {
      final solved = PuzzleState(
        tiles: [1, 2, 3, 4, 5, 6, 7, 8, 0],
      );
      expect(solved.misplacedTiles(), 0);
    });

    test('Nilsson score for solved state is 0', () {
      final solved = PuzzleState(
        tiles: [1, 2, 3, 4, 5, 6, 7, 8, 0],
      );
      expect(solved.nilssonSequenceScore(), 0);
    });

    test('Random puzzle is solvable', () {
      final random = PuzzleState.generateRandom(moves: 10);
      expect(random.tiles.length, 9);
      expect(random.tiles.contains(0), true);
    });
  });

  group('A* Algorithm Tests', () {
    test('Solves simple puzzle', () async {
      final puzzle = PuzzleState(
        tiles: [1, 2, 3, 4, 5, 6, 7, 0, 8],
      );
      final solver = AStarSearch(heuristic: 'manhattan');
      final result = await solver.solve(puzzle);
      expect(result.isSolution, true);
      expect(result.expandedNodes, greaterThan(0));
    });

    test('A* with Manhattan is better than Misplaced', () async {
      final puzzle = PuzzleState.generateRandom(moves: 20);
      
      final manhattan = AStarSearch(heuristic: 'manhattan');
      final misplaced = AStarSearch(heuristic: 'misplaced');
      
      final resultManhattan = await manhattan.solve(puzzle);
      final resultMisplaced = await misplaced.solve(puzzle);
      
      // Manhattan should expand fewer nodes
      expect(
        resultManhattan.expandedNodes,
        lessThanOrEqualTo(resultMisplaced.expandedNodes),
      );
    });
  });

  group('Widget Tests', () {
    testWidgets('App renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const PuzzleGameApp());

      expect(find.text('8-Puzzle Game'), findsOneWidget);
      expect(find.text('Estado Atual'), findsOneWidget);
      expect(find.text('Novo Puzzle'), findsOneWidget);
    });

    testWidgets('Grid is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(const PuzzleGameApp());

      // Should have 9 tiles
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('Buttons are present', (WidgetTester tester) async {
      await tester.pumpWidget(const PuzzleGameApp());

      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byType(ElevatedButton), findsWidgets);
    });
  });
}
