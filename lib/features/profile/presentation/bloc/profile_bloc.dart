import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import '../../../auth/data/datasources/auth_service.dart';
import '../../domain/usecases/clear_user_allergens.dart';
import '../../domain/usecases/get_user_allergens.dart';
import '../../domain/usecases/set_user_allergens.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserAllergens getUserAllergens;
  final SetUserAllergens setUserAllergens;
  final ClearUserAllergens clearUserAllergens;
  final AuthService _authService;
  List<String> _currentAllergens = [];

  ProfileBloc({
    required this.getUserAllergens,
    required this.setUserAllergens,
    required this.clearUserAllergens,
    required AuthService authService,
  })
      : _authService = authService,
        super(ProfileInitial()) {
    on<LoadAllergens>(_onLoadAllergens);
    on<SetAllergens>(_onSetAllergens);
    on<ClearAllergens>(_onClearAllergens);

    // Chargement initial des allergènes si l'utilisateur est connecté
    on<InitializeAllergens>((event, emit) async {
      if (await _authService.isUserLoggedIn()) {
        final uid = await _authService.getCurrentUserId();
        print('🔍 UID récupéré: $uid');
        if (uid != null) {
          add(LoadAllergens(uid));
        } else {
          print('❌ UID non disponible');
        }
      } else {
        print('❌ Utilisateur non connecté');
      }
    });
  }

  Future<void> _onLoadAllergens(LoadAllergens event,
      Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    print('🔄 Chargement des allergènes pour l\'utilisateur ${event.uid}...');
    try {
      final allergens = await getUserAllergens(event.uid);
      print('✅ Allergenes récupérés : $allergens');
      _currentAllergens = allergens;
      emit(AllergensLoaded(allergens));
    } catch (e) {
      print('❌ Erreur lors du chargement des allergènes : ${e.toString()}');
      emit(ProfileError('Failed to load allergens: ${e.toString()}'));
    }
  }

  Future<void> _onSetAllergens(SetAllergens event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      // Sauvegarde les nouveaux allergènes
      await setUserAllergens(event.uid, event.allergens);

      // Optionnel : Charger les données fraîches si tu veux les garder localement
      final freshAllergens = await getUserAllergens(event.uid);
      _currentAllergens = freshAllergens;

      // Émet l'état pour signaler que les allergènes ont été mis à jour
      emit(AllergensUpdated(freshAllergens));


      debugPrint('✅ Allergènes sauvegardés et rechargés: $freshAllergens');
    } catch (e) {
      emit(ProfileError('Failed to save allergens: ${e.toString()}'));
    }
  }


  Future<void> _onClearAllergens(ClearAllergens event,
      Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    print('🧹 Suppression des allergènes pour l\'utilisateur ${event.uid}...');
    try {
      await clearUserAllergens(event.uid);
      print('✅ Allergenes supprimés avec succès');
      _currentAllergens = [];
      emit(AllergensCleared());
    } catch (e) {
      print('❌ Erreur lors de la suppression des allergènes : ${e.toString()}');
      emit(ProfileError('Failed to clear allergens'));
    }
  }
}