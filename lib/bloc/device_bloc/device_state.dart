part of 'device_bloc.dart';

sealed class DeviceState extends Equatable {
  const DeviceState();
  @override
  List<Object?> get props => [];
}

final class DeviceInitial extends DeviceState {}

final class DeviceLoading extends DeviceState {}

class DeviceLoaded extends DeviceState {
  final List<DeviceWithStatus> data;
  final DateTime updatedAt;

  DeviceLoaded(this.data, {DateTime? updatedAt})
      : updatedAt = updatedAt ?? DateTime.now();

  @override
  List<Object> get props => [data, updatedAt];
}

final class DeviceError extends DeviceState {
  final String message;
  const DeviceError(this.message);
}
