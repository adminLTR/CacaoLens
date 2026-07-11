import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/flow_stepper.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowOnboarding());
  }

  Future<void> _maybeShowOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarding_camera_seen') ?? false;
    if (seen || !mounted) return;

    await showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _OnboardingSheet(
        onDone: () async {
          await prefs.setBool('onboarding_camera_seen', true);
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _initCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        _controller = CameraController(
          cameras![0], 
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _controller!.initialize();
        if (!mounted) return;
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Error inicializando cámara: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null && context.mounted) {
      Navigator.of(context).pushNamed(AppRoutes.preview, arguments: image.path);
    }
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final XFile image = await _controller!.takePicture();
      if (mounted) {
        Navigator.of(context).pushNamed(AppRoutes.preview, arguments: image.path);
      }
    } catch (e) {
      debugPrint("Error al tomar foto: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showMenu: true,
      title: const Text('CacaoLens'),
      body: Column(
        children: [
          const FlowStepper(currentStep: 1),
          Expanded(
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.grayLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _isCameraInitialized
                        ? SizedBox.expand(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _controller!.value.previewSize?.height ?? 1,
                                height: _controller!.value.previewSize?.width ?? 1,
                                child: CameraPreview(_controller!),
                              ),
                            ),
                          )
                        : const Center(
                            child: CircularProgressIndicator(color: AppColors.green),
                          ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.white, width: 3),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: AppColors.brown,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.beige,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search, color: AppColors.green),
                      const SizedBox(width: 8),
                      Text('Enfoca la vaina de cacao', style: AppTextStyles.body),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CircleIcon(
                      icon: Icons.image,
                      onTap: () => _pickImage(context, ImageSource.gallery),
                    ),
                    _CircleCapture(
                      onTap: _capturePhoto,
                    ),
                    _CircleIcon(
                      icon: Icons.sync,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSheet extends StatelessWidget {
  const _OnboardingSheet({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Antes de tomar la foto', style: AppTextStyles.titleMedium),
            const SizedBox(height: 16),
            const _OnboardingTip(
              icon: Icons.wb_sunny,
              text: 'Busca buena iluminación, de preferencia luz natural.',
            ),
            const SizedBox(height: 12),
            const _OnboardingTip(
              icon: Icons.center_focus_strong,
              text: 'Enfoca bien la vaina de cacao antes de capturar.',
            ),
            const SizedBox(height: 12),
            const _OnboardingTip(
              icon: Icons.zoom_in,
              text: 'Acércate lo suficiente para que la vaina llene el encuadre.',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: AppColors.white,
                  shape: const StadiumBorder(),
                ),
                onPressed: onDone,
                child: const Text('Entendido'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingTip extends StatelessWidget {
  const _OnboardingTip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.green),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: AppTextStyles.body)),
      ],
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.brownDark,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Icon(icon, color: AppColors.white),
      ),
    );
  }
}

class _CircleCapture extends StatelessWidget {
  const _CircleCapture({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.green,
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: AppColors.white, width: 4),
        ),
        child: const Icon(Icons.camera_alt, color: AppColors.white, size: 32),
      ),
    );
  }
}
