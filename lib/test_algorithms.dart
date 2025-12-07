// Este arquivo contém exemplos de testes e análises dos algoritmos

import 'package:puzzle_8_game/models/puzzle_state.dart';
import 'package:puzzle_8_game/algorithms/astar_search.dart';
import 'package:puzzle_8_game/algorithms/bfs_search.dart';
import 'package:puzzle_8_game/algorithms/dfs_search.dart';

void main() async {
  // Exemplo 1: Criar um puzzle solucionável
  print('=== Criando Puzzle ===');
  final puzzle = PuzzleState.generateRandom(moves: 20);
  print('Estado inicial: ${puzzle.tiles}');
  print('É goal? ${puzzle.isGoal()}');
  print('Manhattan Distance: ${puzzle.manhattanDistance()}');
  print('Misplaced Tiles: ${puzzle.misplacedTiles()}');
  print('Nilsson Score: ${puzzle.nilssonSequenceScore()}');

  // Exemplo 2: Teste com A* (Manhattan)
  print('\n=== A* Search (Manhattan Distance) ===');
  final astarManhattan = AStarSearch(heuristic: 'manhattan');
  final resultManhattan = await astarManhattan.solve(puzzle);
  print('Solução encontrada: ${resultManhattan.isSolution}');
  print('Passos: ${resultManhattan.path.length - 1}');
  print('Nós expandidos: ${resultManhattan.expandedNodes}');
  print('Estados explorados: ${resultManhattan.exploredStates}');
  print('Tempo: ${resultManhattan.time.inMilliseconds} ms');

  // Exemplo 3: Teste com A* (Misplaced)
  print('\n=== A* Search (Misplaced Tiles) ===');
  final astarMisplaced = AStarSearch(heuristic: 'misplaced');
  final resultMisplaced = await astarMisplaced.solve(puzzle);
  print('Solução encontrada: ${resultMisplaced.isSolution}');
  print('Passos: ${resultMisplaced.path.length - 1}');
  print('Nós expandidos: ${resultMisplaced.expandedNodes}');
  print('Tempo: ${resultMisplaced.time.inMilliseconds} ms');

  // Exemplo 4: Teste com A* (Nilsson)
  print('\n=== A* Search (Nilsson Sequence) ===');
  final astarNilsson = AStarSearch(heuristic: 'nilsson');
  final resultNilsson = await astarNilsson.solve(puzzle);
  print('Solução encontrada: ${resultNilsson.isSolution}');
  print('Passos: ${resultNilsson.path.length - 1}');
  print('Nós expandidos: ${resultNilsson.expandedNodes}');
  print('Tempo: ${resultNilsson.time.inMilliseconds} ms');

  // Exemplo 5: Teste com BFS
  print('\n=== BFS Search ===');
  final bfs = BFSSearch();
  final resultBFS = await bfs.solve(puzzle);
  print('Solução encontrada: ${resultBFS.isSolution}');
  print('Passos: ${resultBFS.path.length - 1}');
  print('Nós expandidos: ${resultBFS.expandedNodes}');
  print('Tempo: ${resultBFS.time.inMilliseconds} ms');

  // Exemplo 6: Teste com DFS
  print('\n=== DFS Search ===');
  final dfs = DFSSearch();
  final resultDFS = await dfs.solve(puzzle);
  print('Solução encontrada: ${resultDFS.isSolution}');
  print('Passos: ${resultDFS.path.length - 1}');
  print('Nós expandidos: ${resultDFS.expandedNodes}');
  print('Tempo: ${resultDFS.time.inMilliseconds} ms');

  // Exemplo 7: Comparação Visual
  print('\n=== COMPARAÇÃO DE DESEMPENHO ===');
  print('Algoritmo\t\tSolução\tPassos\tNós Exp.\tTempo (ms)');
  print('A* (Manhattan)\t\t${resultManhattan.isSolution ? "✓" : "✗"}\t${resultManhattan.path.length - 1}\t${resultManhattan.expandedNodes}\t${resultManhattan.time.inMilliseconds}');
  print('A* (Misplaced)\t\t${resultMisplaced.isSolution ? "✓" : "✗"}\t${resultMisplaced.path.length - 1}\t${resultMisplaced.expandedNodes}\t${resultMisplaced.time.inMilliseconds}');
  print('A* (Nilsson)\t\t${resultNilsson.isSolution ? "✓" : "✗"}\t${resultNilsson.path.length - 1}\t${resultNilsson.expandedNodes}\t${resultNilsson.time.inMilliseconds}');
  print('BFS\t\t\t${resultBFS.isSolution ? "✓" : "✗"}\t${resultBFS.path.length - 1}\t${resultBFS.expandedNodes}\t${resultBFS.time.inMilliseconds}');
  print('DFS\t\t\t${resultDFS.isSolution ? "✓" : "✗"}\t${resultDFS.path.length - 1}\t${resultDFS.expandedNodes}\t${resultDFS.time.inMilliseconds}');

  // Análise de eficiência
  print('\n=== ANÁLISE DE EFICIÊNCIA ===');
  
  final algorithms = {
    'A* (Manhattan)': resultManhattan,
    'A* (Misplaced)': resultMisplaced,
    'A* (Nilsson)': resultNilsson,
    'BFS': resultBFS,
    'DFS': resultDFS,
  };

  // Encontrar o mais eficiente
  var most_efficient = algorithms.entries.first;
  for (var entry in algorithms.entries) {
    if (entry.value.isSolution && 
        entry.value.expandedNodes < most_efficient.value.expandedNodes) {
      most_efficient = entry;
    }
  }
  
  print('Algoritmo mais eficiente: ${most_efficient.key}');
  print('Nós expandidos: ${most_efficient.value.expandedNodes}');
  
  // Razão de eficiência comparada com BFS
  if (resultBFS.isSolution) {
    final ratio = resultBFS.expandedNodes / most_efficient.value.expandedNodes;
    print('BFS expandiu ${ratio.toStringAsFixed(1)}x mais nós que o mais eficiente');
  }
}

/*
ANÁLISE TEÓRICA:

1. A* Search:
   - Combina custo real (g) com heurística (h)
   - f(n) = g(n) + h(n)
   - Com boa heurística, é ótimo e completo
   
2. Heurísticas:
   - Manhattan Distance: Mais informativa, menos nós expandidos
   - Misplaced Tiles: Simples mas menos informativa
   - Nilsson: Combina multiple heurísticas
   
3. BFS:
   - Expande em nível, garante solução curta
   - Mas explora muitos estados desnecessários
   
4. DFS:
   - Com limite, pode não achar solução
   - Muito ineficiente para este problema

CONCLUSÃO:
A* com Manhattan Distance é o melhor para 8-puzzle,
expandindo consideravelmente menos nós que BFS.
*/
