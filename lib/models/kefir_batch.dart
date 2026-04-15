import 'package:hive/hive.dart';
import 'ferment_stage.dart';
import '../services/ferment_calculator.dart';

// ── Enums ─────────────────────────────────────────────────────────────────────

enum StorageLocation { ambient, fridge }

enum TempPreset {
  cold,   // < 18 °C — invierno / AC fuerte
  ideal,  // 18–22 °C — temperatura perfecta
  warm,   // 23–26 °C — verano / sin AC
  hot,    // 27–30 °C — muy cálido
  fridge, // 4–8 °C — refrigerador
}

extension TempPresetX on TempPreset {
  String get label => switch (this) {
        TempPreset.cold   => 'Frío  (<18°C)',
        TempPreset.ideal  => 'Ideal  (18–22°C)',
        TempPreset.warm   => 'Cálido  (23–26°C)',
        TempPreset.hot    => 'Caliente  (27–30°C)',
        TempPreset.fridge => 'Refrigerador',
      };

  String get emoji => switch (this) {
        TempPreset.cold   => '❄️',
        TempPreset.ideal  => '✅',
        TempPreset.warm   => '☀️',
        TempPreset.hot    => '🔥',
        TempPreset.fridge => '🧊',
      };

  double get multiplier => switch (this) {
        TempPreset.cold   => 1.6,
        TempPreset.ideal  => 1.0,
        TempPreset.warm   => 0.75,
        TempPreset.hot    => 0.60,
        TempPreset.fridge => 5.5,
      };
}

// ── Modelo ────────────────────────────────────────────────────────────────────

class KefirBatch {
  final String id;
  final DateTime startTime;
  final double grainsGrams;
  final double milkMl;
  final StorageLocation location;
  final TempPreset tempPreset;
  final double? customTempC;
  final String? notes;
  final bool isActive;
  final DateTime? endTime;

  const KefirBatch({
    required this.id,
    required this.startTime,
    required this.grainsGrams,
    required this.milkMl,
    required this.location,
    required this.tempPreset,
    this.customTempC,
    this.notes,
    this.isActive = true,
    this.endTime,
  });

  // ── Cálculos en tiempo real ──────────────────────────────────
  double get ratioPer100ml => grainsGrams / (milkMl / 100);

  int get estimatedHours => FermentCalculator.estimateHours(this);

  Duration get elapsed => (isActive ? DateTime.now() : (endTime ?? DateTime.now()))
      .difference(startTime);

  double get progress =>
      elapsed.inSeconds / (estimatedHours * 3600);

  FermentStage get stage => FermentStageX.fromProgress(progress);

  DateTime get estimatedReadyAt =>
      startTime.add(Duration(hours: estimatedHours));

  String get ratioQuality {
    final r = ratioPer100ml;
    if (r < 2.5) return 'Muy suave';
    if (r < 4.5) return 'Ideal';
    if (r < 7.5) return 'Intenso';
    return 'Muy intenso';
  }

  // ── Copy para actualizaciones ────────────────────────────────
  KefirBatch copyWith({
    StorageLocation? location,
    TempPreset? tempPreset,
    double? customTempC,
    bool? isActive,
    DateTime? endTime,
    String? notes,
  }) =>
      KefirBatch(
        id: id,
        startTime: startTime,
        grainsGrams: grainsGrams,
        milkMl: milkMl,
        location: location ?? this.location,
        tempPreset: tempPreset ?? this.tempPreset,
        customTempC: customTempC ?? this.customTempC,
        notes: notes ?? this.notes,
        isActive: isActive ?? this.isActive,
        endTime: endTime ?? this.endTime,
      );
}

// ── Hive TypeAdapter (sin código generado) ────────────────────────────────────

class KefirBatchAdapter extends TypeAdapter<KefirBatch> {
  @override
  final int typeId = 0;

  @override
  KefirBatch read(BinaryReader reader) {
    final n = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < n; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return KefirBatch(
      id:           fields[0] as String,
      startTime:    DateTime.fromMillisecondsSinceEpoch(fields[1] as int),
      grainsGrams:  (fields[2] as num).toDouble(),
      milkMl:       (fields[3] as num).toDouble(),
      location:     StorageLocation.values[fields[4] as int],
      tempPreset:   TempPreset.values[fields[5] as int],
      customTempC:  fields[6] != null ? (fields[6] as num).toDouble() : null,
      notes:        fields[7] as String?,
      isActive:     fields[8] as bool,
      endTime:      fields[9] != null
          ? DateTime.fromMillisecondsSinceEpoch(fields[9] as int)
          : null,
    );
  }

  @override
  void write(BinaryWriter writer, KefirBatch o) {
    writer.writeByte(10);
    writer
      ..writeByte(0)..write(o.id)
      ..writeByte(1)..write(o.startTime.millisecondsSinceEpoch)
      ..writeByte(2)..write(o.grainsGrams)
      ..writeByte(3)..write(o.milkMl)
      ..writeByte(4)..write(o.location.index)
      ..writeByte(5)..write(o.tempPreset.index)
      ..writeByte(6)..write(o.customTempC)
      ..writeByte(7)..write(o.notes)
      ..writeByte(8)..write(o.isActive)
      ..writeByte(9)..write(o.endTime?.millisecondsSinceEpoch);
  }
}
