// features/order/order_tracking_screen.dart
import 'package:flutter/material.dart';
import 'package:ipot/app_routes.dart';
import 'package:ipot/shared/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../order/order_provider.dart';
import '../../core/models/order_status.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Order Status'),
        centerTitle: true,
      ),
      body: order.currentOrder == null
          ? _buildError(context)
          : _buildContent(context, order),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.black26),
          const SizedBox(height: 16),
          const Text(
            'Order not found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.scanner,
              (route) => false,
            ),
            child: const Text('Back to Scanner'),
          ),
        ],
      ),
    );
  }

  // ── Content ───────────────────────────────────────────────────────────────

  Widget _buildContent(BuildContext context, OrderProvider order) {
    final currentOrder = order.currentOrder!;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        children: [
          _buildOrderIdCard(currentOrder.id),
          const SizedBox(height: 24),
          _buildStatusIndicator(currentOrder.status),
          const SizedBox(height: 24),
          if (currentOrder.estimatedMinutes != null &&
              currentOrder.status.isActive)
            _buildEstimatedTime(currentOrder.estimatedMinutes!),
          const SizedBox(height: 24),
          _buildStatusSteps(currentOrder.status),
          const SizedBox(height: 32),
          if (!currentOrder.status.isActive) _buildServedState(context),
          if (currentOrder.status.isActive) _buildPollingIndicator(),
        ],
      ),
    );
  }

  // ── Order ID Card ─────────────────────────────────────────────────────────

  Widget _buildOrderIdCard(String orderId) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Order Placed!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your order ID',
            style: TextStyle(color: Colors.black38, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            orderId,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // ── Status Indicator ──────────────────────────────────────────────────────

  Widget _buildStatusIndicator(OrderStatusType status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: _statusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _statusColor(status).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(_statusIcon(status), size: 48, color: _statusColor(status)),
          const SizedBox(height: 12),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _statusColor(status),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _statusDescription(status),
            style: const TextStyle(color: Colors.black45, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Estimated Time ────────────────────────────────────────────────────────

  Widget _buildEstimatedTime(int minutes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.access_time_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Estimated time: ',
            style: const TextStyle(color: Colors.black45),
          ),
          Text(
            '$minutes min',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ── Status Steps ──────────────────────────────────────────────────────────

  Widget _buildStatusSteps(OrderStatusType currentStatus) {
    final steps = OrderStatusType.values
        .where((s) => s != OrderStatusType.served)
        .toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isCompleted = step.index < currentStatus.index;
          final isCurrent = step == currentStatus;
          final isLast = index == steps.length - 1;

          return _StatusStep(
            status: step,
            isCompleted: isCompleted,
            isCurrent: isCurrent,
            isLast: isLast,
          );
        }).toList(),
      ),
    );
  }

  // ── Served State ──────────────────────────────────────────────────────────

  Widget _buildServedState(BuildContext context) {
    return Column(
      children: [
        const Text(
          '🎉 Enjoy your meal!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              context.read<OrderProvider>().reset();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.scanner,
                (route) => false,
              );
            },
            child: const Text('Scan New Table'),
          ),
        ),
      ],
    );
  }

  // ── Polling Indicator ─────────────────────────────────────────────────────

  Widget _buildPollingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.black26,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Updating automatically...',
          style: TextStyle(color: Colors.black38, fontSize: 12),
        ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Color _statusColor(OrderStatusType status) => switch (status) {
    OrderStatusType.pending => Colors.orange,
    OrderStatusType.confirmed => Colors.blue,
    OrderStatusType.preparing => AppColors.primary,
    OrderStatusType.ready => Colors.green,
    OrderStatusType.served => Colors.purple,
  };

  IconData _statusIcon(OrderStatusType status) => switch (status) {
    OrderStatusType.pending => Icons.hourglass_empty_rounded,
    OrderStatusType.confirmed => Icons.check_circle_outline_rounded,
    OrderStatusType.preparing => Icons.restaurant_rounded,
    OrderStatusType.ready => Icons.notifications_active_rounded,
    OrderStatusType.served => Icons.done_all_rounded,
  };

  String _statusDescription(OrderStatusType status) => switch (status) {
    OrderStatusType.pending => 'Waiting for kitchen to confirm',
    OrderStatusType.confirmed => 'Kitchen has received your order',
    OrderStatusType.preparing => 'Your food is being prepared',
    OrderStatusType.ready => 'Your order is ready to be served!',
    OrderStatusType.served => 'Your order has been served',
  };
}

// ── Status Step Widget ─────────────────────────────────────────────────────

class _StatusStep extends StatelessWidget {
  final OrderStatusType status;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;

  const _StatusStep({
    required this.status,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          _buildTimeline(),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _buildStepContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted || isCurrent
                ? AppColors.primary
                : Colors.black12,
          ),
          child: Icon(
            isCompleted
                ? Icons.check
                : isCurrent
                ? Icons.circle
                : Icons.circle_outlined,
            size: 14,
            color: isCompleted || isCurrent ? Colors.white : Colors.black26,
          ),
        ),
        if (!isLast)
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 2,
              color: isCompleted ? AppColors.primary : Colors.black12,
            ),
          ),
      ],
    );
  }

  Widget _buildStepContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          status.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            color: isCurrent ? Colors.black87 : Colors.black45,
          ),
        ),
        if (isCurrent)
          Text(
            _currentStepHint(status),
            style: const TextStyle(fontSize: 12, color: AppColors.primary),
          ),
      ],
    );
  }

  String _currentStepHint(OrderStatusType status) => switch (status) {
    OrderStatusType.pending => 'Hang tight...',
    OrderStatusType.confirmed => 'Getting started!',
    OrderStatusType.preparing => 'Almost there...',
    OrderStatusType.ready => 'Look out for your server!',
    OrderStatusType.served => 'Bon appétit!',
  };
}
