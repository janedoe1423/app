import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_textfield.dart';
import '../../../core/theme/app_theme.dart';
import '../provider/classroom_provider.dart';
import '../../auth/provider/auth_provider.dart';
import '../../../core/models/attendance_model.dart';

class ClassroomScreen extends StatefulWidget {
  const ClassroomScreen({Key? key}) : super(key: key);

  @override
  State<ClassroomScreen> createState() => _ClassroomScreenState();
}

class _ClassroomScreenState extends State<ClassroomScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isCreatingClassroom = false;
  
  // Form controllers for classroom creation
  final _classNameController = TextEditingController();
  final _gradeController = TextEditingController();
  final _sectionController = TextEditingController();
  final _subjectController = TextEditingController();
  final _roomNumberController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Selected week day for schedule
  List<bool> _selectedWeekDays = List.generate(7, (index) => false);
  Map<int, ClassroomSchedule> _schedules = {};
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize provider with user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        Provider.of<ClassroomProvider>(context, listen: false).init(user.id, user.role);
      }
    });
  }
  
  @override
  void dispose() {
    _classNameController.dispose();
    _gradeController.dispose();
    _sectionController.dispose();
    _subjectController.dispose();
    _roomNumberController.dispose();
    _notesController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ClassroomProvider>(
      builder: (context, authProvider, classroomProvider, _) {
        final user = authProvider.user;
        
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: Text('User data not available'),
            ),
          );
        }
        
        return Scaffold(
          appBar: _isCreatingClassroom 
              ? AppBar(
                  title: const Text('Create Classroom'),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        _isCreatingClassroom = false;
                      });
                    },
                  ),
                )
              : classroomProvider.selectedClassroom != null
                  ? AppBar(
                      title: Text(classroomProvider.selectedClassroom!.name),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            // Edit classroom
                            _showEditClassroomDialog(context, classroomProvider.selectedClassroom!);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            // Delete classroom
                            _showDeleteClassroomDialog(context, classroomProvider.selectedClassroom!.id);
                          },
                        ),
                      ],
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          classroomProvider.clearSelectedClassroom();
                        },
                      ),
                      bottom: TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: 'Attendance'),
                          Tab(text: 'Students'),
                        ],
                      ),
                    )
                  : AppBar(
                      title: const Text('Classrooms'),
                      actions: [
                        if (user.isTeacher)
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                _isCreatingClassroom = true;
                                _resetClassroomForm();
                              });
                            },
                          ),
                      ],
                    ),
          body: Column(
            children: [
              // Offline banner
              if (classroomProvider.isOffline)
                OfflineBanner(
                  isOffline: true,
                  onRetry: () => classroomProvider.checkConnectivity(),
                ),
              
              // Main content
              Expanded(
                child: _buildContent(classroomProvider, user),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildContent(ClassroomProvider provider, UserModel user) {
    if (provider.status == ClassroomStatus.loading) {
      return const LoadingIndicator(
        message: 'Loading classroom data...',
      );
    }
    
    if (provider.status == ClassroomStatus.error) {
      return AppErrorWidget(
        message: provider.errorMessage,
        onRetry: () => provider.init(user.id, user.role),
      );
    }
    
    if (_isCreatingClassroom) {
      return _buildCreateClassroomForm(provider, user);
    }
    
    if (provider.selectedClassroom != null) {
      return TabBarView(
        controller: _tabController,
        children: [
          // Attendance Tab
          _buildAttendanceTab(provider, user),
          
          // Students Tab
          _buildStudentsTab(provider, user),
        ],
      );
    }
    
    return _buildClassroomsList(provider, user);
  }
  
  Widget _buildClassroomsList(ClassroomProvider provider, UserModel user) {
    final classrooms = provider.classrooms;
    
    if (classrooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.class_,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              user.isTeacher 
                  ? 'No classrooms found. Create your first classroom!'
                  : 'No classrooms found.',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            if (user.isTeacher) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isCreatingClassroom = true;
                    _resetClassroomForm();
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Classroom'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: classrooms.length,
      itemBuilder: (context, index) {
        final classroom = classrooms[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              provider.setSelectedClassroom(classroom);
              provider.loadAttendanceRecords(classroom.id);
              _tabController.animateTo(0);
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          classroom.name.substring(0, 1),
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
                              classroom.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${classroom.grade} - Section ${classroom.section}',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              'Subject: ${classroom.subject ?? 'Multiple Subjects'}',
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
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildClassroomInfoChip(
                        Icons.people,
                        '${classroom.studentCount} Students',
                        Colors.blue,
                      ),
                      if (user.isStudent)
                        _buildClassroomInfoChip(
                          Icons.person,
                          classroom.teacherName,
                          Colors.green,
                        )
                      else
                        _buildClassroomInfoChip(
                          Icons.room,
                          'Room ${classroom.roomNumber ?? 'Not Set'}',
                          Colors.orange,
                        ),
                      _buildClassroomScheduleChip(classroom),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildAttendanceTab(ClassroomProvider provider, UserModel user) {
    if (provider.status == ClassroomStatus.loading) {
      return const LoadingIndicator(
        message: 'Loading attendance data...',
      );
    }
    
    return Column(
      children: [
        // Date selector
        Material(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: user.isTeacher ? () => _selectDate(context, provider) : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy').format(provider.selectedDate),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.calendar_today,
                          color: user.isTeacher ? AppTheme.primaryColor : Colors.grey,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Attendance list
        Expanded(
          child: provider.currentAttendance == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_note,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No attendance record for this date',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      if (user.isTeacher) ...[
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            provider.getAttendanceForDate(
                              provider.selectedClassroom!.id,
                              provider.selectedDate,
                            );
                          },
                          child: const Text('Take Attendance'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.currentAttendance!.studentAttendances.length,
                        itemBuilder: (context, index) {
                          final studentAttendance = provider.currentAttendance!.studentAttendances[index];
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: _getStatusColor(studentAttendance.status).withOpacity(0.2),
                                    child: Text(
                                      studentAttendance.studentName.substring(0, 1),
                                      style: TextStyle(
                                        color: _getStatusColor(studentAttendance.status),
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
                                          studentAttendance.studentName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (studentAttendance.remarks != null && studentAttendance.remarks!.isNotEmpty)
                                          Text(
                                            'Note: ${studentAttendance.remarks}',
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (user.isTeacher)
                                    DropdownButton<AttendanceStatus>(
                                      value: studentAttendance.status,
                                      onChanged: (newStatus) {
                                        if (newStatus != null) {
                                          provider.updateStudentAttendance(
                                            studentAttendance.studentId,
                                            newStatus,
                                            studentAttendance.remarks,
                                          );
                                        }
                                      },
                                      items: AttendanceStatus.values.map((status) {
                                        return DropdownMenuItem<AttendanceStatus>(
                                          value: status,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(status),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(_getStatusText(status)),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    )
                                  else
                                    Chip(
                                      label: Text(_getStatusText(studentAttendance.status)),
                                      backgroundColor: _getStatusColor(studentAttendance.status).withOpacity(0.2),
                                      labelStyle: TextStyle(
                                        color: _getStatusColor(studentAttendance.status),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Attendance summary and save button
                    if (user.isTeacher && provider.currentAttendance != null)
                      Material(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildAttendanceStat(
                                    'Present',
                                    provider.currentAttendance!.getStats()['present'].toString(),
                                    Colors.green,
                                  ),
                                  _buildAttendanceStat(
                                    'Absent',
                                    provider.currentAttendance!.getStats()['absent'].toString(),
                                    Colors.red,
                                  ),
                                  _buildAttendanceStat(
                                    'Late',
                                    provider.currentAttendance!.getStats()['late'].toString(),
                                    Colors.orange,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppTextField(
                                      label: 'Notes',
                                      hintText: 'Add notes for this attendance',
                                      controller: _notesController,
                                      onChanged: (value) {
                                        provider.updateAttendanceNotes(value);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  AppButton(
                                    text: 'Save',
                                    onPressed: () async {
                                      final success = await provider.saveAttendance(provider.currentAttendance!);
                                      
                                      if (success && mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Attendance saved successfully'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } else if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Failed to save attendance: ${provider.errorMessage}'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                    isLoading: provider.status == ClassroomStatus.saving,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
  
  Widget _buildStudentsTab(ClassroomProvider provider, UserModel user) {
    final classroom = provider.selectedClassroom;
    
    if (classroom == null) {
      return const Center(
        child: Text('No classroom selected'),
      );
    }
    
    return Column(
      children: [
        Material(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Students (${classroom.students.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user.isTeacher)
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddStudentDialog(context, classroom.id, provider);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Student'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        Expanded(
          child: classroom.students.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No students in this classroom',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: classroom.students.length,
                  itemBuilder: (context, index) {
                    final student = classroom.students[index];
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                          child: Text(
                            student.name.substring(0, 1),
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          student.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: student.rollNumber != null
                            ? Text('Roll Number: ${student.rollNumber}')
                            : null,
                        trailing: user.isTeacher
                            ? IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _showRemoveStudentDialog(context, classroom.id, student, provider);
                                },
                              )
                            : null,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildCreateClassroomForm(ClassroomProvider provider, UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create a New Classroom',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Class Name
          AppTextField(
            label: 'Class Name',
            hintText: 'Enter class name',
            controller: _classNameController,
            prefixIcon: const Icon(Icons.class_),
          ),
          const SizedBox(height: 16),
          
          // Grade and Section
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Grade',
                  hintText: 'e.g., Grade 8',
                  controller: _gradeController,
                  prefixIcon: const Icon(Icons.grade),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  label: 'Section',
                  hintText: 'e.g., A',
                  controller: _sectionController,
                  prefixIcon: const Icon(Icons.segment),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Subject and Room Number
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Subject',
                  hintText: 'e.g., Mathematics',
                  controller: _subjectController,
                  prefixIcon: const Icon(Icons.subject),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  label: 'Room Number',
                  hintText: 'e.g., 101',
                  controller: _roomNumberController,
                  prefixIcon: const Icon(Icons.room),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Class Schedule
          Text(
            'Class Schedule',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Weekday selector
          Wrap(
            spacing: 8,
            children: List.generate(7, (index) {
              final weekday = index + 1; // 1 = Monday, 7 = Sunday
              final weekdayName = _getWeekdayName(weekday);
              
              return FilterChip(
                label: Text(weekdayName.substring(0, 3)),
                selected: _selectedWeekDays[index],
                onSelected: (selected) {
                  setState(() {
                    _selectedWeekDays[index] = selected;
                    
                    // Handle schedule for this weekday
                    if (selected) {
                      if (!_schedules.containsKey(weekday)) {
                        _schedules[weekday] = ClassroomSchedule(
                          id: 'temp-$weekday',
                          weekday: weekday,
                          startTime: '09:00',
                          endTime: '10:00',
                        );
                      }
                      // Show time picker
                      _showTimePickerDialog(context, weekday);
                    } else {
                      _schedules.remove(weekday);
                    }
                  });
                },
                selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                checkmarkColor: AppTheme.primaryColor,
              );
            }),
          ),
          const SizedBox(height: 16),
          
          // Selected schedules
          if (_schedules.isNotEmpty) ...[
            Column(
              children: _schedules.entries.map((entry) {
                final weekday = entry.key;
                final schedule = entry.value;
                
                return ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(_getWeekdayName(weekday)),
                  subtitle: Text('${schedule.startTime} - ${schedule.endTime}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _showTimePickerDialog(context, weekday);
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          
          // Create Button
          AppButton(
            text: 'Create Classroom',
            onPressed: () => _createClassroom(provider, user),
            isLoading: provider.status == ClassroomStatus.saving,
            isFullWidth: true,
          ),
          const SizedBox(height: 16),
          
          // Cancel Button
          AppButton(
            text: 'Cancel',
            onPressed: () {
              setState(() {
                _isCreatingClassroom = false;
              });
            },
            type: AppButtonType.outline,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
  
  // Helper Widgets
  Widget _buildClassroomInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }
  
  Widget _buildClassroomScheduleChip(ClassroomModel classroom) {
    // Get today's schedule if available
    final todaySchedule = classroom.getTodaySchedule();
    
    if (todaySchedule!.id == 'none') {
      return _buildClassroomInfoChip(
        Icons.event_busy,
        'No class today',
        Colors.grey,
      );
    }
    
    return _buildClassroomInfoChip(
      Icons.schedule,
      todaySchedule.timeRange,
      Colors.purple,
    );
  }
  
  Widget _buildAttendanceStat(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  // Helper Methods
  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }
  
  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.late:
        return Colors.orange;
    }
  }
  
  String _getStatusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
    }
  }
  
  Future<void> _selectDate(BuildContext context, ClassroomProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != provider.selectedDate) {
      provider.selectDate(picked);
      provider.getAttendanceForDate(provider.selectedClassroom!.id, picked);
    }
  }
  
  void _resetClassroomForm() {
    _classNameController.clear();
    _gradeController.clear();
    _sectionController.clear();
    _subjectController.clear();
    _roomNumberController.clear();
    _selectedWeekDays = List.generate(7, (index) => false);
    _schedules.clear();
  }
  
  Future<void> _createClassroom(ClassroomProvider provider, UserModel user) async {
    // Validate inputs
    if (_classNameController.text.isEmpty ||
        _gradeController.text.isEmpty ||
        _sectionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Create classroom model
    final classroom = ClassroomModel(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      name: _classNameController.text,
      grade: _gradeController.text,
      section: _sectionController.text,
      subject: _subjectController.text.isEmpty ? null : _subjectController.text,
      teacherId: user.id,
      teacherName: user.name,
      students: [],
      schedules: _schedules.values.toList(),
      roomNumber: _roomNumberController.text.isEmpty ? null : _roomNumberController.text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Save classroom
    final success = await provider.createClassroom(classroom);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Classroom created successfully'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _isCreatingClassroom = false;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create classroom: ${provider.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Dialogs
  void _showTimePickerDialog(BuildContext context, int weekday) {
    final schedule = _schedules[weekday]!;
    
    // Parse current times
    final startTimeParts = schedule.startTime.split(':');
    final endTimeParts = schedule.endTime.split(':');
    
    final startTime = TimeOfDay(
      hour: int.parse(startTimeParts[0]),
      minute: int.parse(startTimeParts[1]),
    );
    
    final endTime = TimeOfDay(
      hour: int.parse(endTimeParts[0]),
      minute: int.parse(endTimeParts[1]),
    );
    
    // Temporary values for dialog
    TimeOfDay newStartTime = startTime;
    TimeOfDay newEndTime = endTime;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${_getWeekdayName(weekday)} Schedule'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Start Time'),
                subtitle: Text(newStartTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: newStartTime,
                  );
                  if (picked != null) {
                    newStartTime = picked;
                    // Force a rebuild of the dialog
                    Navigator.of(context).pop();
                    _showTimePickerDialog(context, weekday);
                  }
                },
              ),
              ListTile(
                title: const Text('End Time'),
                subtitle: Text(newEndTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: newEndTime,
                  );
                  if (picked != null) {
                    newEndTime = picked;
                    // Force a rebuild of the dialog
                    Navigator.of(context).pop();
                    _showTimePickerDialog(context, weekday);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Format times as HH:MM
                final formattedStartTime = '${newStartTime.hour.toString().padLeft(2, '0')}:${newStartTime.minute.toString().padLeft(2, '0')}';
                final formattedEndTime = '${newEndTime.hour.toString().padLeft(2, '0')}:${newEndTime.minute.toString().padLeft(2, '0')}';
                
                // Update schedule
                setState(() {
                  _schedules[weekday] = ClassroomSchedule(
                    id: schedule.id,
                    weekday: weekday,
                    startTime: formattedStartTime,
                    endTime: formattedEndTime,
                  );
                });
                
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
  
  void _showAddStudentDialog(BuildContext context, String classroomId, ClassroomProvider provider) {
    final nameController = TextEditingController();
    final rollNumberController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Student'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Student Name',
                hintText: 'Enter student name',
                controller: nameController,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Roll Number (Optional)',
                hintText: 'Enter roll number',
                controller: rollNumberController,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter student name'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                final student = ClassroomStudent(
                  id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
                  name: nameController.text,
                  rollNumber: rollNumberController.text.isEmpty ? null : rollNumberController.text,
                );
                
                Navigator.of(context).pop();
                
                final success = await provider.addStudentToClassroom(classroomId, student);
                
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Student added successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add student: ${provider.errorMessage}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
  
  void _showRemoveStudentDialog(
    BuildContext context,
    String classroomId,
    ClassroomStudent student,
    ClassroomProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Student'),
          content: Text('Are you sure you want to remove ${student.name} from this classroom?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                final success = await provider.removeStudentFromClassroom(
                  classroomId,
                  student.id,
                );
                
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Student removed successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to remove student: ${provider.errorMessage}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Remove'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }
  
  void _showEditClassroomDialog(BuildContext context, ClassroomModel classroom) {
    final nameController = TextEditingController(text: classroom.name);
    final gradeController = TextEditingController(text: classroom.grade);
    final sectionController = TextEditingController(text: classroom.section);
    final subjectController = TextEditingController(text: classroom.subject ?? '');
    final roomNumberController = TextEditingController(text: classroom.roomNumber ?? '');
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Classroom'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Class Name',
                controller: nameController,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Grade',
                      controller: gradeController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      label: 'Section',
                      controller: sectionController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Subject',
                      controller: subjectController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      label: 'Room Number',
                      controller: roomNumberController,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    gradeController.text.isEmpty ||
                    sectionController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all required fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                final updatedClassroom = classroom.copyWith(
                  name: nameController.text,
                  grade: gradeController.text,
                  section: sectionController.text,
                  subject: subjectController.text.isEmpty ? null : subjectController.text,
                  roomNumber: roomNumberController.text.isEmpty ? null : roomNumberController.text,
                );
                
                Navigator.of(context).pop();
                
                final provider = Provider.of<ClassroomProvider>(context, listen: false);
                final success = await provider.updateClassroom(updatedClassroom);
                
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Classroom updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update classroom: ${provider.errorMessage}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
  
  void _showDeleteClassroomDialog(BuildContext context, String classroomId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Classroom'),
          content: const Text('Are you sure you want to delete this classroom? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                final provider = Provider.of<ClassroomProvider>(context, listen: false);
                final success = await provider.deleteClassroom(classroomId);
                
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Classroom deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete classroom: ${provider.errorMessage}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Delete'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }
}
