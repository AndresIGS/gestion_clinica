import 'package:mocktail/mocktail.dart';
import 'package:sistemav2/features/auth/domain/repositories/auth_repository.dart';
import 'package:sistemav2/features/citas/domain/repositories/citas_repository.dart';
import 'package:sistemav2/features/reportes/domain/repositories/reportes_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockCitasRepository extends Mock implements CitasRepository {}

class MockReportesRepository extends Mock implements ReportesRepository {}
