// profile_event.dart
part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}
class InitializeAllergens extends ProfileEvent {}
class LoadAllergens extends ProfileEvent {
  final String uid;

  LoadAllergens(this.uid);

  @override
  List<Object> get props => [uid];
}

class SetAllergens extends ProfileEvent {
  final String uid;
  final List<String> allergens;

  SetAllergens({required this.uid, required this.allergens});

  @override
  List<Object> get props => [uid, allergens];
}

class ClearAllergens extends ProfileEvent {
  final String uid;

  ClearAllergens(this.uid);

  @override
  List<Object> get props => [uid];
}