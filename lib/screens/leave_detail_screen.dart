import 'package:flutter/material.dart';

import '../models/leave_request.dart';
import '../utils/date_format.dart';
import '../widgets/employee_avatar.dart';
import '../widgets/leave_visuals.dart';
import '../widgets/status_chip.dart';

class LeaveDetailScreen extends StatelessWidget {
  const LeaveDetailScreen({
    super.key,
    required this.request,
  });

  final LeaveRequest request;

  Future<void> _updateStatus(
    BuildContext context,
    LeaveStatus status,
  ) async {
    final action = status == LeaveStatus.approved ? 'menyetujui' : 'menolak';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          status == LeaveStatus.approved
              ? 'Terima Pengajuan?'
              : 'Tolak Pengajuan?',
        ),
        content: Text(
          'Apakah kamu yakin ingin $action pengajuan cuti '
          'dari ${request.employee}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, lanjutkan'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    Navigator.pop(context, request.copyWith(status: status));
  }

  @override
  Widget build(BuildContext context) {
    final isPending = request.status == LeaveStatus.pending;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengajuan'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _ProfileHeader(request: request),
          const SizedBox(height: 16),
          _PeriodCard(request: request),
          const SizedBox(height: 16),
          _InfoCard(request: request),
          if (isPending) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => _updateStatus(
                context,
                LeaveStatus.approved,
              ),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Terima Pengajuan'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _updateStatus(
                context,
                LeaveStatus.rejected,
              ),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Tolak Pengajuan'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.request});

  final LeaveRequest request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = request.type.color;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            Color.lerp(color, Colors.black, 0.25)!,
          ],
        ),
      ),
      child: Column(
        children: [
          EmployeeAvatar(request: request, radius: 36),
          const SizedBox(height: 12),
          Text(
            request.employee,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(request.type.icon, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                request.type.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StatusChip(status: request.status),
        ],
      ),
    );
  }
}

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({required this.request});

  final LeaveRequest request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = leaveDurationInDays(
      request.startDate,
      request.endDate,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Periode Cuti', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DateTile(
                    label: 'Mulai',
                    date: request.startDate,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: theme.colorScheme.outline,
                  ),
                ),
                Expanded(
                  child: _DateTile(
                    label: 'Selesai',
                    date: request.endDate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Total $days hari',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.date,
  });

  final String label;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedColor = theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: mutedColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${date.day}',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            formatWeekdayMonth(date),
            style: theme.textTheme.bodySmall?.copyWith(
              color: mutedColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.request});

  final LeaveRequest request;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.tag_rounded,
            label: 'ID Pengajuan',
            value: request.id.toUpperCase(),
          ),
          const Divider(height: 1, indent: 56),
          _InfoRow(
            icon: request.type.icon,
            label: 'Tipe Cuti',
            value: request.type.label,
          ),
          const Divider(height: 1, indent: 56),
          _InfoRow(
            icon: request.status.icon,
            label: 'Status',
            value: request.status.label,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Text(
        value,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
