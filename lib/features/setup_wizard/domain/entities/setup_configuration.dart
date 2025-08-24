import 'package:freezed_annotation/freezed_annotation.dart';

part 'setup_configuration.freezed.dart';
part 'setup_configuration.g.dart';

@freezed
class SetupConfiguration with _$SetupConfiguration {
  const factory SetupConfiguration({
    required BusinessConfiguration businessConfig,
    required FeatureConfiguration featureConfig,
    required PermissionConfiguration permissionConfig,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? createdBy,
    String? notes,
  }) = _SetupConfiguration;

  factory SetupConfiguration.fromJson(Map<String, dynamic> json) =>
      _$SetupConfigurationFromJson(json);
}

@freezed
class BusinessConfiguration with _$BusinessConfiguration {
  const factory BusinessConfiguration({
    required String businessName,
    required String businessType,
    required String address,
    required String phone,
    required String email,
    String? website,
    String? currency,
    String? timezone,
    String? language,
    required List<String> services,
  }) = _BusinessConfiguration;

  factory BusinessConfiguration.fromJson(Map<String, dynamic> json) =>
      _$BusinessConfigurationFromJson(json);
}

@freezed
class FeatureConfiguration with _$FeatureConfiguration {
  const factory FeatureConfiguration({
    required List<ModuleFeature> modules,
    required List<String> disabledFeatures,
    required Map<String, bool> featureFlags,
  }) = _FeatureConfiguration;

  factory FeatureConfiguration.fromJson(Map<String, dynamic> json) =>
      _$FeatureConfigurationFromJson(json);
}

@freezed
class ModuleFeature with _$ModuleFeature {
  const factory ModuleFeature({
    required String id,
    required String name,
    required String description,
    required bool isEnabled,
    required bool isRequired,
    required List<String> roles,
    String? icon,
    String? category,
  }) = _ModuleFeature;

  factory ModuleFeature.fromJson(Map<String, dynamic> json) =>
      _$ModuleFeatureFromJson(json);
}

@freezed
class PermissionConfiguration with _$PermissionConfiguration {
  const factory PermissionConfiguration({
    required List<RolePermission> roles,
    required Map<String, List<String>> rolePermissions,
  }) = _PermissionConfiguration;

  factory PermissionConfiguration.fromJson(Map<String, dynamic> json) =>
      _$PermissionConfigurationFromJson(json);
}

@freezed
class RolePermission with _$RolePermission {
  const factory RolePermission({
    required String id,
    required String name,
    required String description,
    required List<String> permissions,
    required bool isActive,
    required int priority,
  }) = _RolePermission;

  factory RolePermission.fromJson(Map<String, dynamic> json) =>
      _$RolePermissionFromJson(json);
}
