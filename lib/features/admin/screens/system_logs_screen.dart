import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/admin_provider.dart';
import '../models/system_log_model.dart';

class SystemLogsScreen extends StatefulWidget {
  static const routeName = '/system-logs';
  
  const SystemLogsScreen({Key? key}) : super(key: key);

  @override
  State<SystemLogsScreen> createState() => _SystemLogsScreenState();
}

class _SystemLogsScreenState extends State<SystemLogsScreen> {
  bool _isLoading = true;
  String? _error;
  LogSeverity? _selectedSeverity;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Provider.of<AdminProvider>(context, listen: false).loadSystemLogs(
        severity: _selectedSeverity,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        startDate: _startDate,
        endDate: _endDate,
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _handleSearch() {
    _searchQuery = _searchController.text.trim();
    _loadLogs();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: _startDate ?? DateTime.now().subtract(const Duration(days: 7)),
      end: _endDate ?? DateTime.now(),
    );
    
    final pickedDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDateRange != null) {
      setState(() {
        _startDate = pickedDateRange.start;
        _endDate = pickedDateRange.end;
      });
      _loadLogs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _selectDateRange(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogs,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          _buildDateFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error loading logs',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(_error!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadLogs,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _buildLogsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search logs by message or user',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  if (_searchQuery.isNotEmpty) {
                    _searchQuery = '';
                    _loadLogs();
                  }
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onSubmitted: (_) => _handleSearch(),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('All Logs', null),
                const SizedBox(width: 8),
                _filterChip('Info', LogSeverity.info),
                const SizedBox(width: 8),
                _filterChip('Warning', LogSeverity.warning),
                const SizedBox(width: 8),
                _filterChip('Error', LogSeverity.error),
                const SizedBox(width: 8),
                _filterChip('Critical', LogSeverity.critical),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilterBar() {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    if (_startDate == null && _endDate == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            const Icon(Icons.date_range, size: 16),
            const SizedBox(width: 8),
            const Text('All dates'),
            TextButton(
              onPressed: () => _selectDateRange(context),
              child: const Text('Select Range'),
            ),
          ],
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const Icon(Icons.date_range, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  const TextSpan(text: 'Date range: '),
                  TextSpan(
                    text: _startDate != null
                        ? dateFormat.format(_startDate!)
                        : 'All time',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' to '),
                  TextSpan(
                    text: _endDate != null
                        ? dateFormat.format(_endDate!)
                        : 'Present',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () {
              setState(() {
                _startDate = null;
                _endDate = null;
              });
              _loadLogs();
            },
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, LogSeverity? severity) {
    final isSelected = _selectedSeverity == severity;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedSeverity = selected ? severity : null;
        });
        _loadLogs();
      },
      backgroundColor: Colors.grey[200],
      selectedColor: _getColorForSeverity(severity).withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? _getColorForSeverity(severity) : null,
      ),
    );
  }

  Color _getColorForSeverity(LogSeverity? severity) {
    switch (severity) {
      case LogSeverity.info:
        return Colors.blue;
      case LogSeverity.warning:
        return Colors.orange;
      case LogSeverity.error:
        return Colors.red;
      case LogSeverity.critical:
        return Colors.purple;
      default:
        return Theme.of(context).primaryColor;
    }
  }

  Widget _buildLogsList() {
    final adminProvider = Provider.of<AdminProvider>(context);
    final logs = adminProvider.systemLogs;
    
    if (logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No logs found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No logs match "$_searchQuery"'
                  : _selectedSeverity != null
                      ? 'No ${_selectedSeverity.toString().split('.').last} logs found'
                      : 'No logs available for the selected period',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLogs,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: logs.length,
        itemBuilder: (ctx, index) {
          final log = logs[index];
          return _buildLogListItem(log);
        },
      ),
    );
  }

  Widget _buildLogListItem(SystemLog log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: _getColorForSeverity(log.severity),
            shape: BoxShape.circle,
          ),
        ),
        title: Text(
          log.message,
          style: TextStyle(
            fontWeight: log.severity == LogSeverity.critical || log.severity == LogSeverity.error 
                ? FontWeight.bold 
                : FontWeight.normal,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${DateFormat('MMM d, yyyy, h:mm a').format(log.timestamp)} • ${log.source}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                if (log.details != null && log.details!.isNotEmpty) ...[
                  Text(
                    'Details:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      log.details!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'User: ${log.userId != null ? log.userId : 'System'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Chip(
                      label: Text(log.severityString),
                      backgroundColor: _getColorForSeverity(log.severity).withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: _getColorForSeverity(log.severity),
                        fontSize: 12,
                      ),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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