import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';

class AiService {
  final http.Client _client;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Constructor with dependency injection for testing
  AiService({http.Client? client}) : _client = client ?? http.Client();
  
  // Generate Multiple Choice Questions
  Future<List<Map<String, dynamic>>> generateMCQs({
    required String subject,
    required String topic,
    required String grade,
    required String language,
    required int numberOfQuestions,
  }) async {
    try {
      final apiKey = await _getOpenAiApiKey();
      
      if (apiKey.isEmpty) {
        throw Exception('OpenAI API key not found');
      }
      
      final response = await _client.post(
        Uri.parse('${AppConstants.openAiBaseUrl}${AppConstants.openAiChatEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': '''You are an expert educator specializing in creating 
              multiple-choice questions with a focus on student comprehension. 
              For each question, provide real-life examples and explanations 
              that make the concept relatable for students. Generate questions 
              with varying difficulty levels.'''
            },
            {
              'role': 'user',
              'content': '''Generate $numberOfQuestions multiple-choice questions for 
              $grade students about $topic in $subject. 
              The language of the questions should be in $language.
              
              The response should be a valid JSON array where each question has:
              1. A "question" text field
              2. An "options" object with keys A, B, C, D and their values
              3. A "correctAnswer" field containing the letter of the correct option
              4. An "explanation" field explaining why the answer is correct
              5. A "difficulty" field with value "easy", "medium", or "hard"
              
              Ensure the questions are age-appropriate and incorporate real-world examples.'''
            }
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
          'top_p': 1,
          'frequency_penalty': 0,
          'presence_penalty': 0,
        }),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = responseData['choices'] as List;
        final content = choices[0]['message']['content'] as String;
        
        // Extract the valid JSON from the content
        String jsonStr = content.trim();
        
        // Handle case where content might include markdown backticks
        if (jsonStr.startsWith('```json')) {
          jsonStr = jsonStr.substring(7);
        }
        if (jsonStr.startsWith('```')) {
          jsonStr = jsonStr.substring(3);
        }
        if (jsonStr.endsWith('```')) {
          jsonStr = jsonStr.substring(0, jsonStr.length - 3);
        }
        
        jsonStr = jsonStr.trim();
        
        final questions = jsonDecode(jsonStr) as List;
        return questions.map((q) => q as Map<String, dynamic>).toList();
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception('API error: ${errorData['error']['message']}');
      }
    } catch (e) {
      Logger.error('Error generating MCQs: $e');
      throw Exception('Failed to generate questions: $e');
    }
  }
  
  // Get AI-powered recommendations for student learning
  Future<Map<String, dynamic>> getPersonalizedRecommendations({
    required String userId,
    required List<String> recentTopics,
    required Map<String, double> performanceData,
  }) async {
    try {
      final apiKey = await _getOpenAiApiKey();
      
      if (apiKey.isEmpty) {
        throw Exception('OpenAI API key not found');
      }
      
      final response = await _client.post(
        Uri.parse('${AppConstants.openAiBaseUrl}${AppConstants.openAiChatEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': '''You are an AI education assistant specializing in
              personalized learning recommendations. Based on student performance
              data, you provide tailored suggestions for topics to focus on,
              learning strategies, and appropriate resources.'''
            },
            {
              'role': 'user',
              'content': '''Generate personalized learning recommendations based on the following student data:
              
              Recent topics studied: ${recentTopics.join(', ')}
              Performance data (topic: score percentage):
              ${performanceData.entries.map((e) => "${e.key}: ${e.value}%").join('\n')}
              
              Provide recommendations in JSON format with the following structure:
              1. "focusAreas": Array of topics the student should focus on
              2. "strengths": Array of topics the student is doing well in
              3. "learningStrategies": Array of recommended study methods
              4. "resourceTypes": Array of suggested resource types (videos, practice problems, etc.)
              5. "nextTopics": Array of recommended next topics to explore'''
            }
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
          'top_p': 1,
          'frequency_penalty': 0,
          'presence_penalty': 0,
        }),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = responseData['choices'] as List;
        final content = choices[0]['message']['content'] as String;
        
        // Extract the valid JSON from the content
        String jsonStr = content.trim();
        
        // Handle case where content might include markdown backticks
        if (jsonStr.startsWith('```json')) {
          jsonStr = jsonStr.substring(7);
        }
        if (jsonStr.startsWith('```')) {
          jsonStr = jsonStr.substring(3);
        }
        if (jsonStr.endsWith('```')) {
          jsonStr = jsonStr.substring(0, jsonStr.length - 3);
        }
        
        jsonStr = jsonStr.trim();
        
        return jsonDecode(jsonStr) as Map<String, dynamic>;
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception('API error: ${errorData['error']['message']}');
      }
    } catch (e) {
      Logger.error('Error getting personalized recommendations: $e');
      throw Exception('Failed to get recommendations: $e');
    }
  }
  
  // Generate detailed explanations for incorrect answers
  Future<String> generateConceptExplanation({
    required String subject,
    required String topic,
    required String question,
    required String studentAnswer,
    required String correctAnswer,
    required String grade,
    required String language,
  }) async {
    try {
      final apiKey = await _getOpenAiApiKey();
      
      if (apiKey.isEmpty) {
        throw Exception('OpenAI API key not found');
      }
      
      final response = await _client.post(
        Uri.parse('${AppConstants.openAiBaseUrl}${AppConstants.openAiChatEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': '''You are an expert teacher who provides detailed and
              encouraging explanations to help students understand concepts they
              are struggling with. Your explanations are clear, concise, and include
              real-world examples to make the concepts relatable.'''
            },
            {
              'role': 'user',
              'content': '''A $grade student answered a question incorrectly in $subject
              about $topic. Please provide a detailed explanation of the concept in $language
              that's appropriate for their grade level.
              
              Question: $question
              Student's Answer: $studentAnswer
              Correct Answer: $correctAnswer
              
              The explanation should:
              1. Start with an encouraging statement
              2. Explain the core concept clearly
              3. Provide a real-world example
              4. Explain why the correct answer is right
              5. Explain the misconception in the student's answer
              6. End with a positive reinforcement'''
            }
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
          'top_p': 1,
          'frequency_penalty': 0,
          'presence_penalty': 0,
        }),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = responseData['choices'] as List;
        final content = choices[0]['message']['content'] as String;
        
        return content.trim();
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception('API error: ${errorData['error']['message']}');
      }
    } catch (e) {
      Logger.error('Error generating explanation: $e');
      throw Exception('Failed to generate explanation: $e');
    }
  }
  
  // Retrieve OpenAI API key from secure storage
  Future<String> _getOpenAiApiKey() async {
    try {
      final apiKey = await _secureStorage.read(key: 'openai_api_key');
      return apiKey ?? '';
    } catch (e) {
      Logger.error('Error retrieving OpenAI API key: $e');
      return '';
    }
  }
  
  // Save OpenAI API key to secure storage
  Future<void> saveOpenAiApiKey(String apiKey) async {
    try {
      await _secureStorage.write(key: 'openai_api_key', value: apiKey);
    } catch (e) {
      Logger.error('Error saving OpenAI API key: $e');
      throw Exception('Failed to save API key: $e');
    }
  }
  
  // Delete OpenAI API key from secure storage
  Future<void> deleteOpenAiApiKey() async {
    try {
      await _secureStorage.delete(key: 'openai_api_key');
    } catch (e) {
      Logger.error('Error deleting OpenAI API key: $e');
      throw Exception('Failed to delete API key: $e');
    }
  }
}