import 'package:flutter/material.dart';

import '../models/leave_request.dart';
import '../widgets/leave_card.dart';
import 'leave_detail_screen.dart';

class LeaveListScreen extends StatefulWidget {
  const LeaveListScreen({super.key});

  @override
  State<LeaveListScreen> createState() => _LeaveListScreenState();
}

class _LeaveListScreenState extends State<LeaveListScreen> {
  final List<LeaveRequest> _requests = [...mockLeaveRequests];

  String? _selectedStatus;
  String? _selectedType;

  final List<String> _statuses = [
    'Menunggu',
    'Disetujui',
    'Ditolak',
  ];

  final List<String> _types = [
    'Cuti Tahunan',
    'Sakit',
    'Tanpa Gaji',
  ];

  List<LeaveRequest> get _filteredRequests {
    return _requests.where((request) {
      final matchesStatus = _selectedStatus == null ||
          request.status.label.toLowerCase() == _selectedStatus!.toLowerCase();

      final matchesType = _selectedType == null ||
          request.type.label.toLowerCase() == _selectedType!.toLowerCase();

      return matchesStatus && matchesType;
    }).toList();
  }

  Future<void> _openDetail(LeaveRequest request) async {
    final updatedRequest = await Navigator.push<LeaveRequest>(
      context,
      MaterialPageRoute(
        builder: (context) => LeaveDetailScreen(request: request),
      ),
    );

    if (!mounted || updatedRequest == null) return;

    setState(() {
      final index = _requests.indexWhere(
        (item) => item.id == updatedRequest.id,
      );

      if (index != -1) {
        _requests[index] = updatedRequest;
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedType = null;
    });
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onSelected(),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final requests = _filteredRequests;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HRIS Mini',
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: theme.colorScheme.primary),
            ),
            const Text('Pengajuan Cuti'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Reset filter',
            onPressed: _resetFilters,
            icon: const Icon(Icons.filter_alt_off_outlined),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildFilterChip(
                      label: 'Semua',
                      selected: _selectedStatus == null,
                      onSelected: () {
                        setState(() => _selectedStatus = null);
                      },
                    ),
                    ..._statuses.map((status) {
                      return _buildFilterChip(
                        label: status,
                        selected: _selectedStatus == status,
                        onSelected: () {
                          setState(() {
                            _selectedStatus =
                                _selectedStatus == status ? null : status;
                          });
                        },
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildFilterChip(
                      label: 'Semua jenis',
                      selected: _selectedType == null,
                      onSelected: () {
                        setState(() => _selectedType = null);
                      },
                    ),
                    ..._types.map((type) {
                      return _buildFilterChip(
                        label: type,
                        selected: _selectedType == type,
                        onSelected: () {
                          setState(() {
                            _selectedType = _selectedType == type ? null : type;
                          });
                        },
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${requests.length} pengajuan',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: requests.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        const Text('Tidak ada pengajuan cuti.'),
                        TextButton(
                          onPressed: _resetFilters,
                          child: const Text('Reset filter'),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: requests.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final request = requests[index];

                      return LeaveCard(
                        request: request,
                        onTap: () => _openDetail(request),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
