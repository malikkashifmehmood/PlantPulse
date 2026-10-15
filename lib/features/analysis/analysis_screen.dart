import 'dart:io';

import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../core/models/plant.dart';
import '../../core/network/plantpulse_api.dart';
import '../diagnosis/diagnosis_screen.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key, required this.imageFile, this.plant});

  final Plant? plant;
  final File imageFile;

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final PlantPulseApi _api = PlantPulseApi();

  bool _loading = true;
  String? _error;
  PlantPulsePrediction? _prediction;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _runPrediction();
  }

  Future<void> _runPrediction() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prediction = await _api.predict(widget.imageFile);

      if (!mounted) return;

      setState(() {
        _prediction = prediction;
        _loading = false;
      });

      if (!_navigated) {
        _navigated = true;

        await Future<void>.delayed(const Duration(milliseconds: 700));

        if (!mounted) return;

        await Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder:
                (_) => DiagnosisScreen(
                  plant: widget.plant,
                  prediction: prediction,
                  imageFile: widget.imageFile,
                ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final percent = _loading ? null : 1.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
        title: const Text('Analysis'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
        child: Column(
          children: [
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.file(
                widget.imageFile,
                width: 170,
                height: 170,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => const SizedBox(
                      width: 170,
                      height: 170,
                      child: Icon(Icons.broken_image_outlined, size: 64),
                    ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _error != null
                  ? 'Analysis could not finish'
                  : _loading
                  ? 'Analyzing your leaf'
                  : 'Analysis complete',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              _error != null
                  ? 'Check your connection to the local prediction server.'
                  : _loading
                  ? 'Sending the image to your trained CNN model.'
                  : 'Prediction received from the model.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: PlantPulseColors.muted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            if (_loading)
              const CircularProgressIndicator()
            else if (_error != null)
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 48,
              )
            else
              const Icon(
                Icons.check_circle_rounded,
                color: PlantPulseColors.green,
                size: 48,
              ),
            const SizedBox(height: 22),
            if (_loading)
              LinearProgressIndicator(
                value: percent,
                minHeight: 8,
                borderRadius: BorderRadius.circular(100),
              ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _runPrediction,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
            ] else if (_loading) ...[
              const Spacer(),
              const Text(
                'Keep the app open while the image is analyzed.',
                textAlign: TextAlign.center,
                style: TextStyle(color: PlantPulseColors.muted, fontSize: 12),
              ),
            ] else ...[
              Text(
                _prediction?.displayName ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
            ],
            if (_error != null || !_loading)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to scan'),
              ),
          ],
        ),
      ),
    );
  }
}
