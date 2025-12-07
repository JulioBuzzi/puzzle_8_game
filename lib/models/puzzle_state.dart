import 'dart:math';

class PuzzleState {
  final List<int> tiles; // 0 representa o espaço vazio
  final int gridSize;

  PuzzleState({
    required this.tiles,
    this.gridSize = 3,
  }) : assert(tiles.length == gridSize * gridSize);

  // Getter para posição do espaço vazio
  int get emptyPosition => tiles.indexOf(0);

  // Verifica se o puzzle está resolvido
  bool isGoal() {
    for (int i = 0; i < tiles.length - 1; i++) {
      if (tiles[i] != i + 1) return false;
    }
    return tiles[tiles.length - 1] == 0;
  }

  // Gera todos os movimentos possíveis
  List<PuzzleState> getSuccessors() {
    final successors = <PuzzleState>[];
    final emptyPos = emptyPosition;
    final row = emptyPos ~/ gridSize;
    final col = emptyPos % gridSize;

    // Movimento para cima
    if (row > 0) {
      successors.add(_swap(emptyPos, emptyPos - gridSize));
    }
    // Movimento para baixo
    if (row < gridSize - 1) {
      successors.add(_swap(emptyPos, emptyPos + gridSize));
    }
    // Movimento para esquerda
    if (col > 0) {
      successors.add(_swap(emptyPos, emptyPos - 1));
    }
    // Movimento para direita
    if (col < gridSize - 1) {
      successors.add(_swap(emptyPos, emptyPos + 1));
    }

    return successors;
  }

  // Cria novo estado trocando dois tiles
  PuzzleState _swap(int pos1, int pos2) {
    final newTiles = List<int>.from(tiles);
    final temp = newTiles[pos1];
    newTiles[pos1] = newTiles[pos2];
    newTiles[pos2] = temp;
    return PuzzleState(tiles: newTiles, gridSize: gridSize);
  }

  // Gera um puzzle aleatório (garantidamente solucionável)
  static PuzzleState generateRandom({int gridSize = 3, int moves = 100}) {
    var state = PuzzleState(
      tiles: List<int>.generate(gridSize * gridSize, (i) => i),
      gridSize: gridSize,
    );

    final random = Random();
    for (int i = 0; i < moves; i++) {
      final successors = state.getSuccessors();
      state = successors[random.nextInt(successors.length)];
    }

    return state;
  }

  // Heurística 1: Manhattan Distance
  int manhattanDistance() {
    int distance = 0;
    for (int i = 0; i < tiles.length; i++) {
      if (tiles[i] == 0) continue;
      final value = tiles[i];
      final goalPos = value - 1;
      final currentRow = i ~/ gridSize;
      final currentCol = i % gridSize;
      final goalRow = goalPos ~/ gridSize;
      final goalCol = goalPos % gridSize;
      distance += (currentRow - goalRow).abs() + (currentCol - goalCol).abs();
    }
    return distance;
  }

  // Heurística 2: Misplaced Tiles
  int misplacedTiles() {
    int count = 0;
    for (int i = 0; i < tiles.length - 1; i++) {
      if (tiles[i] != i + 1) count++;
    }
    if (tiles[tiles.length - 1] != 0) count++;
    return count;
  }

  // Heurística 3: Nilsson Sequence Score
  int nilssonSequenceScore() {
    int score = misplacedTiles() * 2;

    // Penalidade pela sequência
    for (int i = 0; i < tiles.length - 1; i++) {
      final value = tiles[i];
      if (value == 0) continue;

      final nextValue = i + 1 < tiles.length ? tiles[i + 1] : 0;
      if (value != i + 1 && (value + 1) != nextValue) {
        score += 2;
      }
    }

    return score;
  }

  @override
  String toString() => tiles.toString();

  @override
  bool operator ==(Object other) {
    if (other is! PuzzleState) return false;
    return listEquals(tiles, other.tiles);
  }

  @override
  int get hashCode => Object.hashAll(tiles);

  static bool listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
