import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/assessment_provider.dart';
import 'assessment_result.dart';

class TakeAssessment extends StatefulWidget {
  final Assessment assessment;

  const TakeAssessment({
    super.key,
    required this.assessment,
  });

  @override
  State<TakeAssessment> createState() => _TakeAssessmentState();
}

class _TakeAssessmentState extends State<TakeAssessment> {
  int currentQuestionIndex = 0;
  Map<int, String> answers = {};
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final questions = Provider.of<AssessmentProvider>(context)
        .getQuestionsForTopic('${widget.assessment.subject}-${widget.assessment.chapter}');

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Assessment?'),
            content: const Text('Your progress will be lost. Are you sure?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.assessment.subject),
          centerTitle: true,
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildTimer(),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Indicator
              LinearProgressIndicator(
                value: (currentQuestionIndex + 1) / questions!.length,
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(height: 16),
              
              // Question Counter
              Text(
                'Question ${currentQuestionIndex + 1} of ${questions.length}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),

              // Question
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    questions[currentQuestionIndex],
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Answer TextField
              TextField(
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Your Answer',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  answers[currentQuestionIndex] = value;
                },
                controller: TextEditingController(
                  text: answers[currentQuestionIndex],
                ),
              ),
              const Spacer(),

              // Navigation Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentQuestionIndex > 0)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentQuestionIndex--;
                        });
                      },
                      child: const Text('Previous'),
                    ),
                  if (currentQuestionIndex < questions.length - 1)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentQuestionIndex++;
                        });
                      },
                      child: const Text('Next'),
                    ),
                  if (currentQuestionIndex == questions.length - 1)
                    ElevatedButton(
                      onPressed: isSubmitting ? null : _submitAssessment,
                      child: isSubmitting
                          ? const CircularProgressIndicator()
                          : const Text('Submit'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimer() {
    final remaining = widget.assessment.endTime.difference(DateTime.now());
    final minutes = remaining.inMinutes;
    final color = minutes < 5 ? Colors.red : Colors.white;
    
    return Text(
      '${remaining.inHours}:${(remaining.inMinutes % 60).toString().padLeft(2, '0')}',
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Future<void> _submitAssessment() async {
    setState(() {
      isSubmitting = true;
    });

    try {
      // TODO: Implement AI-based evaluation
      await Future.delayed(const Duration(seconds: 2)); // Simulating API call

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AssessmentResult(
            assessment: widget.assessment,
            answers: answers,
          ),
        ),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }
} 