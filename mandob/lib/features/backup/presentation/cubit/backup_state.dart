import 'package:equatable/equatable.dart';

abstract class BackupState extends Equatable {
  const BackupState();

  @override
  List<Object?> get props => [];
}

class BackupInitial extends BackupState {}

class BackupLoading extends BackupState {}

class BackupSuccess extends BackupState {
  final String message;

  const BackupSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class RestoreSuccess extends BackupState {
  const RestoreSuccess();
}

class BackupError extends BackupState {
  final String message;

  const BackupError(this.message);

  @override
  List<Object?> get props => [message];
}
