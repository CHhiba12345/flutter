// profile_state.dart
part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class AllergensLoaded extends ProfileState {
  final List<String> allergens;

  const AllergensLoaded(this.allergens);

  @override
  List<Object> get props => [allergens];
}

class AllergensUpdated extends ProfileState {
  final List<String> allergens;

  const AllergensUpdated(this.allergens);

  @override
  List<Object> get props => [allergens];
}

class AllergensCleared extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object> get props => [message];
}