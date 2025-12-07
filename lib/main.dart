import 'dart:async';
import 'package:flutter/material.dart';
import 'package:puzzle_8_game/models/puzzle_state.dart';
import 'package:puzzle_8_game/algorithms/astar_search.dart';
import 'package:puzzle_8_game/algorithms/bfs_search.dart';
import 'package:puzzle_8_game/algorithms/dfs_search.dart';
import 'package:puzzle_8_game/algorithms/search_base.dart';
import 'package:puzzle_8_game/widgets/puzzle_grid.dart';
import 'package:puzzle_8_game/widgets/results_comparison.dart';

void main() {
  runApp(const PuzzleGameApp());
}

class PuzzleGameApp extends StatelessWidget {
  const PuzzleGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '8-Puzzle Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PuzzleGameScreen(),
    );
  }
}

class PuzzleGameScreen extends StatefulWidget {
  const PuzzleGameScreen({super.key});

  @override
  State<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen> {
  late PuzzleState currentState;
  Map<String, SearchResult> searchResults = {};
  bool isSearching = false;
  // Playback controls for automatic step-by-step solution
  Timer? _playTimer;
  int _playIndex = 0;
  bool _isPlayingSolution = false;
  String? _playingAlgorithm;
  List<PuzzleState>? _currentSolutionPath;
  String? activeTab;

  @override
  void initState() {
    super.initState();
    _generateNewPuzzle();
  }

  void _generateNewPuzzle() {
    setState(() {
      currentState = PuzzleState.generateRandom(moves: 50);
      searchResults.clear();
      activeTab = null;
    });
  }

  void _updateTile(PuzzleState newState) {
    setState(() {
      currentState = newState;
    });

    if (newState.isGoal()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Parabéns! Você resolveu o puzzle!'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _solveWithAlgorithm(String algorithm) async {
    setState(() {
      isSearching = true;
    });

    try {
      SearchResult result;

      switch (algorithm) {
        case 'A* (Manhattan)':
          result = await AStarSearch(heuristic: 'manhattan').solve(currentState);
          break;
        case 'A* (Misplaced)':
          result = await AStarSearch(heuristic: 'misplaced').solve(currentState);
          break;
        case 'A* (Nilsson)':
          result = await AStarSearch(heuristic: 'nilsson').solve(currentState);
          break;
        case 'BFS':
          result = await BFSSearch().solve(currentState);
          break;
        case 'DFS':
          result = await DFSSearch().solve(currentState);
          break;
        default:
          return;
      }

      setState(() {
        searchResults[algorithm] = result;
        activeTab = algorithm;
        isSearching = false;
      });

      if (!mounted) return;

      if (result.isSolution) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✓ Solução encontrada! Passos: ${result.path.length - 1}',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✗ Nenhuma solução encontrada'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  void _startPlayingSolution(SearchResult result, String algorithm) {
    if (!result.isSolution || result.path.isEmpty) return;

    _playTimer?.cancel();
    _currentSolutionPath = result.path;
    _playIndex = 0;
    _playingAlgorithm = algorithm;

    setState(() {
      _isPlayingSolution = true;
    });

    _playTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (!mounted) return;

      if (_playIndex >= _currentSolutionPath!.length) {
        _stopPlayingSolution();
        return;
      }

      _updateTile(_currentSolutionPath![_playIndex]);
      _playIndex++;
    });
  }

  void _stopPlayingSolution() {
    _playTimer?.cancel();
    _playTimer = null;
    _playingAlgorithm = null;
    setState(() {
      _isPlayingSolution = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('8-Puzzle Game'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Título da seção
              const Text(
                'Estado Atual',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Grid do puzzle
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: PuzzleGrid(
                    state: currentState,
                    onTilePressed: _updateTile,
                    interactive: true,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Status
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  currentState.isGoal()
                      ? '✓ Puzzle Resolvido!'
                      : '○ Puzzle Não Resolvido',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: currentState.isGoal() ? Colors.green : Colors.orange,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Botões de ação
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: isSearching ? null : _generateNewPuzzle,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Novo Puzzle'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Resolver com Algoritmos:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildAlgorithmButtons(),
                ],
              ),
              const SizedBox(height: 24),

              // Resultados
              if (searchResults.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Resultados da Busca',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ResultsComparison(
                      results: searchResults,
                      activeAlgorithm: activeTab,
                      playingAlgorithm: _playingAlgorithm,
                      onPlay: (alg) {
                        final res = searchResults[alg];
                        if (res != null) _startPlayingSolution(res, alg);
                      },
                      onStop: _stopPlayingSolution,
                    ),
                    const SizedBox(height: 16),
                    if (activeTab != null && searchResults[activeTab] != null)
                      _buildSolutionPath(searchResults[activeTab]!),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlgorithmButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildAlgoButton('A* (Manhattan)', Colors.blue[600]!),
          const SizedBox(width: 8),
          _buildAlgoButton('A* (Misplaced)', Colors.blue[600]!),
          const SizedBox(width: 8),
          _buildAlgoButton('A* (Nilsson)', Colors.blue[600]!),
          const SizedBox(width: 8),
          _buildAlgoButton('BFS', Colors.green[600]!),
          const SizedBox(width: 8),
          _buildAlgoButton('DFS', Colors.orange[600]!),
        ],
      ),
    );
  }

  Widget _buildAlgoButton(String label, Color color) {
    return ElevatedButton(
      onPressed: (isSearching || _isPlayingSolution) ? null : () => _solveWithAlgorithm(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: Colors.grey,
      ),
      child: Text(label),
    );
  }

  Widget _buildSolutionPath(SearchResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Text(
          'Solução (${result.path.length - 1} passos):',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (result.isSolution)
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: result.path.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Passo $index: ${result.path[index]}',
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          )
        else
          const Text('Nenhuma solução encontrada'),
        const SizedBox(height: 12),
        // Play / Stop button for step-by-step automatic moves
        if (result.isSolution)
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: (_isPlayingSolution && _playingAlgorithm == activeTab)
                    ? _stopPlayingSolution
                    : () => _startPlayingSolution(result, activeTab ?? ''),
                icon: Icon((_isPlayingSolution && _playingAlgorithm == activeTab)
                    ? Icons.stop
                    : Icons.play_arrow),
                label: Text((_isPlayingSolution && _playingAlgorithm == activeTab)
                    ? 'Parar'
                    : 'Iniciar reprodução'),
              ),
              const SizedBox(width: 8),
              if (_isPlayingSolution && _playingAlgorithm == activeTab)
                Text('Reproduzindo passo ${_playIndex}/${result.path.length - 1}'),
            ],
          ),
      ],
    );
  }

  @override
  void dispose() {
    _playTimer?.cancel();
    super.dispose();
  }
}
