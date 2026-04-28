import 'package:flutter/material.dart';

class BusinessUpgradeFlowPage extends StatefulWidget {
  const BusinessUpgradeFlowPage({super.key});

  @override
  State<BusinessUpgradeFlowPage> createState() => _BusinessUpgradeFlowPageState();
}

class _BusinessUpgradeFlowPageState extends State<BusinessUpgradeFlowPage> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Business Upgrade", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () => setState(() => _currentStep < 4 ? _currentStep++ : Navigator.pop(context)),
        onStepCancel: () => setState(() => _currentStep > 0 ? _currentStep-- : Navigator.pop(context)),
        steps: [
          Step(
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            title: const Text("Intro"),
            content: _buildStepContent(0),
          ),
          Step(
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            title: const Text("Details"),
            content: _buildStepContent(1),
          ),
          Step(
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
            title: const Text("Verification"),
            content: _buildStepContent(2),
          ),
          Step(
            isActive: _currentStep >= 3,
            state: _currentStep > 3 ? StepState.complete : StepState.indexed,
            title: const Text("Review"),
            content: _buildStepContent(3),
          ),
          Step(
            isActive: _currentStep >= 4,
            state: _currentStep > 4 ? StepState.complete : StepState.indexed,
            title: const Text("Final"),
            content: _buildStepContent(4),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0: return _buildIntro();
      case 1: return _buildDetails();
      case 2: return const _PlaceholderStep(title: "Identity Verification");
      case 3: return const _PlaceholderStep(title: "Address Information");
      case 4: return const _PlaceholderStep(title: "Ready to Submit");
      default: return const SizedBox();
    }
  }

  Widget _buildIntro() {
    return const Column(
      children: [
        Icon(Icons.rocket_launch, size: 64, color: Color(0xFF8B5CF6)),
        SizedBox(height: 16),
        Text("Upgrade your business profile to unlock premium features and higher limits.", textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildDetails() {
    return const Column(
      children: [
        TextField(decoration: InputDecoration(labelText: "Official Business Name")),
        TextField(decoration: InputDecoration(labelText: "Tax Identification Number")),
      ],
    );
  }
}

class _PlaceholderStep extends StatelessWidget {
  final String title;
  const _PlaceholderStep({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        const Text("This step's detailed form is integrated here from the previous multi-page implementation."),
      ],
    );
  }
}
