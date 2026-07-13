import 'package:blackout/data/content_repository.dart';
import 'package:blackout/models/game_enums.dart';

/// A deterministic in-memory stand-in for [ContentRepository] so game logic
/// tests don't depend on the real JSON assets or asset-bundle loading.
class FakeContentRepository implements ContentRepository {
  final Map<Difficulty, List<String>> actionsByDifficulty;
  final Map<Difficulty, List<String>> veritesByDifficulty;
  final Map<EventType, List<String>> eventsByType;
  final List<String> transitionsMale;
  final List<String> transitionsFemale;

  FakeContentRepository({
    Map<Difficulty, List<String>>? actionsByDifficulty,
    Map<Difficulty, List<String>>? veritesByDifficulty,
    Map<EventType, List<String>>? eventsByType,
    List<String>? transitionsMale,
    List<String>? transitionsFemale,
  })  : actionsByDifficulty = actionsByDifficulty ??
            {
              for (final d in Difficulty.values)
                d: ['action-${d.name}-1', 'action-${d.name}-2'],
            },
        veritesByDifficulty = veritesByDifficulty ??
            {
              for (final d in Difficulty.values)
                d: ['verite-${d.name}-1', 'verite-${d.name}-2'],
            },
        eventsByType = eventsByType ??
            {
              for (final t in EventType.values)
                t: List.generate(3, (i) => '${t.name}-card-$i'),
            },
        transitionsMale = transitionsMale ?? ['transition-h-1', 'transition-h-2'],
        transitionsFemale =
            transitionsFemale ?? ['transition-f-1', 'transition-f-2'];

  @override
  Future<List<String>> loadActions(Set<Difficulty> difficulties) async {
    return [
      for (final d in difficulties) ...actionsByDifficulty[d]!,
    ];
  }

  @override
  Future<List<String>> loadVerites(Set<Difficulty> difficulties) async {
    return [
      for (final d in difficulties) ...veritesByDifficulty[d]!,
    ];
  }

  @override
  Future<List<String>> loadEvent(EventType type) async {
    return eventsByType[type]!;
  }

  @override
  Future<List<String>> loadTransitionsMale() async => transitionsMale;

  @override
  Future<List<String>> loadTransitionsFemale() async => transitionsFemale;
}
