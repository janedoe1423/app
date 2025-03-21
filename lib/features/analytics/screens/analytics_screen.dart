import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/performance_model.dart';
import '../provider/analytics_provider.dart';
import '../../auth/provider/auth_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedSubject;
  String? _selectedClass;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isFilterExpanded = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize provider with user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        Provider.of<AnalyticsProvider>(context, listen: false).init(user.id, user.role);
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, AnalyticsProvider>(
      builder: (context, authProvider, analyticsProvider, _) {
        final user = authProvider.user;
        
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: Text('User data not available'),
            ),
          );
        }
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Performance Analytics'),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  setState(() {
                    _isFilterExpanded = !_isFilterExpanded;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  analyticsProvider.refreshData(user.id, user.role);
                },
              ),
            ],
            bottom: user.isTeacher ? TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Class Performance'),
                Tab(text: 'Student Details'),
              ],
            ) : null,
          ),
          body: Column(
            children: [
              // Offline banner
              if (analyticsProvider.isOffline)
                OfflineBanner(
                  isOffline: true,
                  onRetry: () => analyticsProvider.checkConnectivity(),
                ),
              
              // Filters section
              if (_isFilterExpanded)
                _buildFiltersSection(context, analyticsProvider, user),
              
              // Main content
              Expanded(
                child: user.isTeacher
                    ? _buildTeacherAnalytics(analyticsProvider, user)
                    : _buildStudentAnalytics(analyticsProvider, user),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildFiltersSection(
    BuildContext context, 
    AnalyticsProvider provider, 
    UserModel user
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Different filters based on user role
          if (user.isTeacher) ...[
            // Class filter for teachers
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Class',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    value: _selectedClass,
                    items: [
                      const DropdownMenuItem(value: 'class-1', child: Text('Class 8A')),
                      const DropdownMenuItem(value: 'class-2', child: Text('Class 8B')),
                      const DropdownMenuItem(value: 'class-3', child: Text('Class 9A')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedClass = value;
                      });
                      if (value != null) {
                        provider.setFilters(classId: value);
                        provider.loadClassPerformance(user.id, value);
                      }
                    },
                    hint: const Text('Select Class'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    value: _selectedSubject,
                    items: const [
                      DropdownMenuItem(value: 'Mathematics', child: Text('Mathematics')),
                      DropdownMenuItem(value: 'Science', child: Text('Science')),
                      DropdownMenuItem(value: 'English', child: Text('English')),
                      DropdownMenuItem(value: 'History', child: Text('History')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedSubject = value;
                      });
                      provider.setFilters(subject: value);
                    },
                    hint: const Text('Select Subject'),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Subject filter for students
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              value: _selectedSubject,
              items: const [
                DropdownMenuItem(value: 'Mathematics', child: Text('Mathematics')),
                DropdownMenuItem(value: 'Science', child: Text('Science')),
                DropdownMenuItem(value: 'English', child: Text('English')),
                DropdownMenuItem(value: 'History', child: Text('History')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedSubject = value;
                });
                provider.setFilters(subject: value);
                if (value != null) {
                  provider.loadStudentPerformance(user.id, subject: value);
                }
              },
              hint: const Text('Select Subject'),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Date range filters
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _startDate = date;
                      });
                      provider.setFilters(startDate: date);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      _startDate == null 
                          ? 'Select Date' 
                          : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _endDate = date;
                      });
                      provider.setFilters(endDate: date);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'End Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      _endDate == null 
                          ? 'Select Date' 
                          : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Apply and Clear buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Apply filters
                    provider.refreshData(user.id, user.role);
                    setState(() {
                      _isFilterExpanded = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Clear filters
                    setState(() {
                      _selectedSubject = null;
                      _selectedClass = null;
                      _startDate = null;
                      _endDate = null;
                    });
                    provider.clearFilters();
                  },
                  child: const Text('Clear Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildTeacherAnalytics(AnalyticsProvider provider, UserModel user) {
    if (provider.status == AnalyticsStatus.loading) {
      return const LoadingIndicator(
        message: 'Loading analytics data...',
      );
    }
    
    if (provider.status == AnalyticsStatus.error) {
      return AppErrorWidget(
        message: provider.errorMessage,
        onRetry: () => provider.refreshData(user.id, user.role),
      );
    }
    
    // Tab view for teacher
    return TabBarView(
      controller: _tabController,
      children: [
        // Class Performance Tab
        _buildClassPerformanceTab(provider),
        
        // Student Details Tab
        _buildStudentDetailsTab(provider),
      ],
    );
  }
  
  Widget _buildClassPerformanceTab(AnalyticsProvider provider) {
    final classPerformance = provider.classPerformance;
    
    if (classPerformance == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.class_,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Select a class to view performance',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isFilterExpanded = true;
                });
              },
              child: const Text('Select Class'),
            ),
          ],
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class info card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classPerformance.className,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Subject: ${classPerformance.subject}'),
                  Text('Grade: ${classPerformance.grade}'),
                  Text('Students: ${classPerformance.studentCount}'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        'Class Average: ${classPerformance.classAverageScore.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Class average chart
          Text(
            'Class Performance Trend',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _buildClassPerformanceChart(classPerformance),
          ),
          const SizedBox(height: 24),
          
          // Topics performance
          Text(
            'Topic Performance',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: classPerformance.topicPerformances.length,
            itemBuilder: (context, index) {
              final entry = classPerformance.topicPerformances.entries.elementAt(index);
              final topic = entry.key;
              final performance = entry.value;
              
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Average: ${performance.classAverageScore.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: _getColorForScore(performance.classAverageScore),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: performance.classAverageScore / 100,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getColorForScore(performance.classAverageScore),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mastered: ${performance.masteryPercentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Struggling: ${performance.strugglingPercentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          
          // Student performance table
          Text(
            'Student Performance',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Student')),
                  DataColumn(label: Text('Avg. Score')),
                  DataColumn(label: Text('Assessments')),
                  DataColumn(label: Text('Accuracy')),
                  DataColumn(label: Text('Last Active')),
                ],
                rows: classPerformance.studentPerformances.map((student) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          student.studentName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          // Load student details
                          provider.loadStudentDetailsForTeacher(
                            student.studentId, 
                            classPerformance.classId,
                          );
                          _tabController.animateTo(1); // Switch to student details tab
                        },
                      ),
                      DataCell(
                        Text(
                          '${student.averageScore.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: _getColorForScore(student.averageScore),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataCell(Text('${student.assessmentsCompleted}')),
                      DataCell(Text('${student.accuracy.toStringAsFixed(1)}%')),
                      DataCell(Text(_formatDate(student.lastAssessmentDate))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Top performers
          Text(
            'Top Performers',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTopPerformersChart(classPerformance),
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Generate report feature
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Generating detailed report...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.assessment),
                  label: const Text('Generate Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Share analytics feature
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sharing analytics...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share Analytics'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStudentDetailsTab(AnalyticsProvider provider) {
    final studentPerformance = provider.studentPerformance;
    
    if (studentPerformance == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Select a student to view details',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Click on a student name in the Class Performance tab',
              style: TextStyle(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student info card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          studentPerformance.studentName.substring(0, 1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              studentPerformance.studentName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Grade: ${studentPerformance.grade}',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(
                        'Overall Score',
                        '${studentPerformance.overallPerformance.toStringAsFixed(1)}%',
                        _getColorForScore(studentPerformance.overallPerformance),
                      ),
                      _buildStatColumn(
                        'Grade',
                        studentPerformance.performanceGrade,
                        _getColorForGrade(studentPerformance.performanceGrade),
                      ),
                      _buildStatColumn(
                        'Subject',
                        studentPerformance.subject,
                        AppTheme.primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Performance trend
          Text(
            'Performance Trend',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _buildStudentPerformanceChart(studentPerformance),
          ),
          const SizedBox(height: 24),
          
          // Strengths and weaknesses
          Row(
            children: [
              Expanded(
                child: _buildStrengthsWeaknessesCard(
                  context,
                  'Strengths',
                  studentPerformance.getStrengths(),
                  Colors.green,
                  Icons.thumb_up,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStrengthsWeaknessesCard(
                  context,
                  'Areas for Improvement',
                  studentPerformance.getWeaknesses(),
                  Colors.orange,
                  Icons.trending_up,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Topic performance
          Text(
            'Topic Performance',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: studentPerformance.topicPerformances.length,
            itemBuilder: (context, index) {
              final entry = studentPerformance.topicPerformances.entries.elementAt(index);
              final topic = entry.key;
              final performance = entry.value;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            topic,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getColorForScore(performance.averageScore).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              performance.performanceLevel,
                              style: TextStyle(
                                color: _getColorForScore(performance.averageScore),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Average Score: ${performance.averageScore.toStringAsFixed(1)}%'),
                      Text('Accuracy: ${performance.accuracy.toStringAsFixed(1)}%'),
                      Text('Questions Attempted: ${performance.questionsAttempted}'),
                      Text('Last Practiced: ${_formatDate(performance.lastAttempted)}'),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: performance.averageScore / 100,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getColorForScore(performance.averageScore),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          
          // Recent assessments
          Text(
            'Recent Assessments',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: studentPerformance.assessmentPerformances.length,
            itemBuilder: (context, index) {
              final assessment = studentPerformance.assessmentPerformances[index];
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    assessment.assessmentTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Date: ${_formatDate(assessment.date)} • Time: ${assessment.formattedTimeSpent}',
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getColorForScore(assessment.score).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${assessment.score.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: _getColorForScore(assessment.score),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    // Show assessment details
                    _showAssessmentDetailsDialog(context, assessment);
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Generate personalized plan
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Generating personalized learning plan...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate Learning Plan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Share report with parents
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sharing report with parents...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share Report'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStudentAnalytics(AnalyticsProvider provider, UserModel user) {
    if (provider.status == AnalyticsStatus.loading) {
      return const LoadingIndicator(
        message: 'Loading your performance data...',
      );
    }
    
    if (provider.status == AnalyticsStatus.error) {
      return AppErrorWidget(
        message: provider.errorMessage,
        onRetry: () => provider.refreshData(user.id, user.role),
      );
    }
    
    final studentPerformance = provider.studentPerformance;
    
    if (studentPerformance == null) {
      return const Center(
        child: Text('No performance data available'),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall performance card
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Your Performance',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPerformanceIndicator(
                        context,
                        studentPerformance.overallPerformance,
                        'Overall Score',
                        _getColorForScore(studentPerformance.overallPerformance),
                      ),
                      Column(
                        children: [
                          Text(
                            studentPerformance.performanceGrade,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: _getColorForGrade(studentPerformance.performanceGrade),
                            ),
                          ),
                          Text(
                            'Grade',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Subject: ${studentPerformance.subject}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Performance trend
          Text(
            'Performance Trend',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _buildStudentPerformanceChart(studentPerformance),
          ),
          const SizedBox(height: 24),
          
          // Strengths and weaknesses
          Row(
            children: [
              Expanded(
                child: _buildStrengthsWeaknessesCard(
                  context,
                  'Your Strengths',
                  studentPerformance.getStrengths(),
                  Colors.green,
                  Icons.thumb_up,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStrengthsWeaknessesCard(
                  context,
                  'Areas to Improve',
                  studentPerformance.getWeaknesses(),
                  Colors.orange,
                  Icons.trending_up,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Topic performance
          Text(
            'Topic Performance',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: studentPerformance.topicPerformances.length,
            itemBuilder: (context, index) {
              final entry = studentPerformance.topicPerformances.entries.elementAt(index);
              final topic = entry.key;
              final performance = entry.value;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            topic,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getColorForScore(performance.averageScore).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              performance.performanceLevel,
                              style: TextStyle(
                                color: _getColorForScore(performance.averageScore),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Score: ${performance.averageScore.toStringAsFixed(1)}%'),
                                Text('Accuracy: ${performance.accuracy.toStringAsFixed(1)}%'),
                                Text('Questions: ${performance.questionsCorrect}/${performance.questionsAttempted}'),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                LinearProgressIndicator(
                                  value: performance.averageScore / 100,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getColorForScore(performance.averageScore),
                                  ),
                                  minHeight: 8,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Last Practice:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      _formatDate(performance.lastAttempted),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Practice button
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to practice questions
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Navigating to practice questions...'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_arrow, size: 18),
                          label: const Text('Practice'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            minimumSize: const Size(100, 36),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          
          // Recent assessments
          Text(
            'Recent Assessments',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: studentPerformance.assessmentPerformances.length,
            itemBuilder: (context, index) {
              final assessment = studentPerformance.assessmentPerformances[index];
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: _getColorForScore(assessment.score).withOpacity(0.2),
                    child: Text(
                      '${assessment.score.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: _getColorForScore(assessment.score),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    assessment.assessmentTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${_formatDate(assessment.date)}'),
                      Text('Time spent: ${assessment.formattedTimeSpent}'),
                      Text('Correct: ${assessment.correctAnswers}/${assessment.totalQuestions}'),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Show assessment details
                    _showAssessmentDetailsDialog(context, assessment);
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Get personalized recommendations
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Getting personalized recommendations...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Get Recommendations'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // View detailed report
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Viewing detailed report...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.assessment),
                  label: const Text('Detailed Report'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Helper widgets
  Widget _buildPerformanceIndicator(
    BuildContext context,
    double score,
    String label,
    Color color,
  ) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: score / 100,
                backgroundColor: Colors.grey.shade300,
                strokeWidth: 8,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${score.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStrengthsWeaknessesCard(
    BuildContext context,
    String title,
    List<String> items,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty) ...[
              const Text(
                'Not enough data',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ] else ...[
              ...items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(item),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildStudentPerformanceChart(PerformanceModel performance) {
    final performanceTrend = performance.getPerformanceTrend();
    
    if (performanceTrend.isEmpty) {
      return const Center(
        child: Text('No performance data available'),
      );
    }
    
    final spots = <FlSpot>[];
    final titles = <String>[];
    
    for (int i = 0; i < performanceTrend.length; i++) {
      spots.add(FlSpot(i.toDouble(), performanceTrend[i]['score']));
      titles.add(performanceTrend[i]['date'].toString().substring(5, 10));
    }
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= titles.length) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    titles[value.toInt()],
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    '${value.toInt()}%',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade400),
            left: BorderSide(color: Colors.grey.shade400),
          ),
        ),
        minX: 0,
        maxX: (performanceTrend.length - 1).toDouble(),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.primaryColor,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryColor.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildClassPerformanceChart(ClassPerformanceModel performance) {
    final assessments = performance.assessmentPerformances;
    
    if (assessments.isEmpty) {
      return const Center(
        child: Text('No assessment data available'),
      );
    }
    
    final spots = <FlSpot>[];
    final titles = <String>[];
    
    for (int i = 0; i < assessments.length; i++) {
      spots.add(FlSpot(i.toDouble(), assessments[i].classAverageScore));
      titles.add(assessments[i].formattedDate);
    }
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= titles.length) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    titles[value.toInt()],
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    '${value.toInt()}%',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade400),
            left: BorderSide(color: Colors.grey.shade400),
          ),
        ),
        minX: 0,
        maxX: (assessments.length - 1).toDouble(),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.primaryColor,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryColor.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTopPerformersChart(ClassPerformanceModel performance) {
    final topPerformers = performance.getTopPerformers(limit: 5);
    
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.grey.shade100,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${topPerformers[groupIndex].studentName}\n',
                  const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: '${rod.toY.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: _getColorForScore(rod.toY),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value < 0 || value >= topPerformers.length) {
                    return const SizedBox.shrink();
                  }
                  final name = topPerformers[value.toInt()].studentName.split(' ')[0];
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      name,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      '${value.toInt()}%',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
                reservedSize: 28,
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            checkToShowHorizontalLine: (value) => value % 20 == 0,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade300,
                strokeWidth: 1,
              );
            },
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade400),
              left: BorderSide(color: Colors.grey.shade400),
            ),
          ),
          barGroups: topPerformers.asMap().entries.map((entry) {
            final index = entry.key;
            final student = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: student.averageScore,
                  color: _getColorForScore(student.averageScore),
                  width: 16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
  
  // Helpers
  Color _getColorForScore(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 75) return Colors.lightGreen;
    if (score >= 60) return Colors.amber;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
  
  Color _getColorForGrade(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.lightGreen;
      case 'C':
        return Colors.amber;
      case 'D':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  void _showAssessmentDetailsDialog(BuildContext context, AssessmentPerformance assessment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            assessment.assessmentTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Date and time info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Date:'),
                              Text(
                                _formatDate(assessment.date),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Time Spent:'),
                              Text(
                                assessment.formattedTimeSpent,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Avg. Time per Question:'),
                              Text(
                                '${assessment.averageTimePerQuestion.toStringAsFixed(1)} seconds',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Performance info
                    Row(
                      children: [
                        Expanded(
                          child: _buildPerformanceCard(
                            'Score',
                            '${assessment.score.toStringAsFixed(1)}%',
                            _getColorForScore(assessment.score),
                            Icons.score,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildPerformanceCard(
                            'Accuracy',
                            '${assessment.accuracy.toStringAsFixed(1)}%',
                            assessment.accuracy >= 75 ? Colors.green : Colors.orange,
                            Icons.check_circle,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildPerformanceCard(
                            'Questions',
                            '${assessment.correctAnswers}/${assessment.totalQuestions}',
                            Colors.blue,
                            Icons.question_answer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Performance visualization
                    const Text(
                      'Performance Breakdown',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: assessment.score / 100,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(_getColorForScore(assessment.score)),
                      minHeight: 10,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '0%',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '50%',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '100%',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // View detailed questions and answers
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Viewing detailed questions...'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.list),
                            label: const Text('View Questions'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Retry similar questions
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Generating similar practice questions...'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Practice Similar'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildPerformanceCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
