import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/fade_in_wrapper.dart';
import '../../../../core/widgets/skeleton_list.dart';
import '../blocs/reportes_bloc.dart';
import '../blocs/reportes_event.dart';
import '../blocs/reportes_state.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  String? _idMedicoSeleccionado;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  @override
  void initState() {
    super.initState();
    context.read<ReportesBloc>().add(CargarMedicosReporteEvent());
    _cargarEstadisticas();
  }

  void _cargarEstadisticas() {
    context.read<ReportesBloc>().add(CargarEstadisticasEvent(
          idMedico: _idMedicoSeleccionado,
          fechaInicio: _fechaInicio,
          fechaFin: _fechaFin,
        ));
  }

  Future<void> _seleccionarFechaInicio() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaInicio ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha != null) {
      setState(() => _fechaInicio = fecha);
      _cargarEstadisticas();
    }
  }

  Future<void> _seleccionarFechaFin() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaFin ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha != null) {
      setState(() => _fechaFin = fecha);
      _cargarEstadisticas();
    }
  }

  void _limpiarFiltros() {
    setState(() {
      _idMedicoSeleccionado = null;
      _fechaInicio = null;
      _fechaFin = null;
    });
    _cargarEstadisticas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes y Estadísticas')),
      body: BlocConsumer<ReportesBloc, ReportesState>(
        listener: (context, state) {
          if (state is ReportesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensaje)),
            );
          }
        },
        builder: (context, state) {
          List<Map<String, dynamic>> medicos = [];
          Map<String, int>? estadisticas;

          if (state is MedicosReporteCargados) {
            medicos = state.medicos;
          } else if (state is EstadisticasCargadas) {
            estadisticas = state.estadisticas;
          } else if (state is ReportesLoading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonCard(),
                  SizedBox(height: 24),
                  SkeletonCard(),
                  SizedBox(height: 24),
                  SkeletonCard(),
                ],
              ),
            );
          }

          return FadeInWrapper(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFiltros(medicos),
                  const SizedBox(height: 24),
                  if (estadisticas != null) ...[
                    _buildResumen(estadisticas),
                    const SizedBox(height: 24),
                    _buildGrafico(estadisticas),
                    const SizedBox(height: 24),
                    _buildTabla(estadisticas),
                  ] else
                    const SkeletonCard(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFiltros(List<Map<String, dynamic>> medicos) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtros',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _idMedicoSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Médico',
                prefixIcon: Icon(Icons.person_search),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Todos los médicos'),
                ),
                ...medicos.map((med) {
                  final nombre = med['usuario']['nombre_completo'] as String;
                  final especialidad = med['especialidad']['nombre'] as String;
                  return DropdownMenuItem<String?>(
                    value: med['id_medico'] as String,
                    child: Text('Dr. $nombre - $especialidad'),
                  );
                }),
              ],
              onChanged: (val) {
                setState(() => _idMedicoSeleccionado = val);
                _cargarEstadisticas();
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(_fechaInicio == null
                        ? 'Desde'
                        : '${_fechaInicio!.day}/${_fechaInicio!.month}/${_fechaInicio!.year}'),
                    onPressed: _seleccionarFechaInicio,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(_fechaFin == null
                        ? 'Hasta'
                        : '${_fechaFin!.day}/${_fechaFin!.month}/${_fechaFin!.year}'),
                    onPressed: _seleccionarFechaFin,
                  ),
                ),
              ],
            ),
            if (_idMedicoSeleccionado != null ||
                _fechaInicio != null ||
                _fechaFin != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.clear),
                  label: const Text('Limpiar filtros'),
                  onPressed: _limpiarFiltros,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResumen(Map<String, int> estadisticas) {
    final total = estadisticas.values.fold(0, (sum, val) => sum + val);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.analytics, size: 40, color: Colors.deepPurple),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total de citas',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  '$total',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrafico(Map<String, int> estadisticas) {
    final orden = ['solicitado', 'aceptado', 'realizado', 'cancelado'];
    final colores = <String, Color>{
      'solicitado': Colors.orange,
      'aceptado': Colors.green,
      'realizado': Colors.blue,
      'cancelado': Colors.red,
    };

    final datos = orden
        .asMap()
        .entries
        .map((e) => BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: estadisticas[e.value]?.toDouble() ?? 0,
                  color: colores[e.value],
                  width: 32,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estado de Citas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  barGroups: datos,
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= orden.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              orden[index].substring(0, 3).toUpperCase(),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabla(Map<String, int> estadisticas) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalle',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...estadisticas.entries.map((entry) {
              final icono = switch (entry.key) {
                'solicitado' => Icons.schedule,
                'aceptado' => Icons.check_circle,
                'realizado' => Icons.done_all,
                'cancelado' => Icons.cancel,
                _ => Icons.help,
              };

              return ListTile(
                leading: Icon(icono),
                title: Text(entry.key.toUpperCase()),
                trailing: Text(
                  '${entry.value}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
