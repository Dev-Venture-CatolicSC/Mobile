import 'package:flutter/foundation.dart';

import '../models/activity_model.dart';
import '../models/user_model.dart';
import '../repositories/activity_repository.dart';
import '../repositories/user_repository.dart';
import '../utils/firestore_operation_exception.dart';
import '../utils/sample_data.dart';

class AtomicOperationsProvider extends ChangeNotifier {
  AtomicOperationsProvider({
    UserRepository? userRepository,
    ActivityRepository? activityRepository,
  }) : _userRepository = userRepository ?? UserRepository(),
       _activityRepository = activityRepository ?? ActivityRepository();

  final UserRepository _userRepository;
  final ActivityRepository _activityRepository;

  UserModel? _user;
  bool _loading = false;
  String? _message;
  String? _error;

  UserModel? get user => _user;
  bool get loading => _loading;
  String? get message => _message;
  String? get error => _error;

  List<ActivityModel> get demoActivities => SampleData.demoActivities();

  Future<void> refreshUser() async {
    _user = await _userRepository.getUser(SampleData.demoUserId);
    notifyListeners();
  }

  Future<void> createUserProfile() async {
    await _runOperation(() async {
      await _userRepository.createUserProfile(SampleData.demoUser());
      _user = SampleData.demoUser();
      _message =
          'Perfil criado com Batched Write (usuário + progresso inicial).';
    });
  }

  Future<void> saveDemoActivities() async {
    await _runOperation(() async {
      await _activityRepository.saveActivities(demoActivities);
      _message =
          '${demoActivities.length} atividades salvas com Batched Write.';
    });
  }

  Future<void> completeNextActivity() async {
    await _runOperation(() async {
      final currentUser =
          _user ?? await _userRepository.getUser(SampleData.demoUserId);
      if (currentUser == null) {
        throw Exception('Crie o perfil antes de concluir uma atividade.');
      }

      final completedIds = await _userRepository.getCompletedActivityIds(
        SampleData.demoUserId,
      );
      final nextActivity = demoActivities.firstWhere(
        (activity) => !completedIds.contains(activity.id),
        orElse: () => throw Exception('Todas as atividades demo já foram concluídas.'),
      );

      _user = await _userRepository.completeActivity(
        userId: SampleData.demoUserId,
        activity: nextActivity,
      );
      _message =
          'Atividade "${nextActivity.id}" concluída com Transaction '
          '(pontos, nível e histórico atualizados atomicamente).';
    });
  }

  Future<void> deleteDemoActivities() async {
    await _runOperation(() async {
      await _activityRepository.deleteActivitiesWithUserCompletions(
        userId: SampleData.demoUserId,
        activityIds: demoActivities.map((activity) => activity.id).toList(),
      );
      _message =
          'Atividades e conclusões removidas com Batched Write.';
    });
  }

  void clearFeedback() {
    _message = null;
    _error = null;
    notifyListeners();
  }

  Future<void> _runOperation(Future<void> Function() action) async {
    _loading = true;
    _message = null;
    _error = null;
    notifyListeners();

    try {
      await action();
    } on FirestoreOperationException catch (error) {
      _error = error.message;
    } catch (error) {
      _error = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
