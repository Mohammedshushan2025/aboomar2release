// lib/utils/api_logger_overlay.dart
// Overlay يظهر فوق كل الشاشات ويعرض الـ API calls

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api_logger.dart';
import 'dart:math' as math;

/// ضع هذا الـ Widget في أعلى شجرة الـ MaterialApp
/// مثال: home: ApiLoggerOverlay(child: LoginScreen(...))
class ApiLoggerOverlay extends StatefulWidget {
  final Widget child;
  const ApiLoggerOverlay({super.key, required this.child});

  @override
  State<ApiLoggerOverlay> createState() => _ApiLoggerOverlayState();
}

class _ApiLoggerOverlayState extends State<ApiLoggerOverlay>
    with SingleTickerProviderStateMixin {
  bool _panelOpen = false;
  ApiLogEntry? _selectedLog;
  late AnimationController _animCtrl;
  late Animation<double> _slideAnim;
  Offset _buttonPos = const Offset(20, 200);
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _slideAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    ApiLogger.instance.addListener(_onLogsChanged);
  }

  @override
  void dispose() {
    ApiLogger.instance.removeListener(_onLogsChanged);
    _animCtrl.dispose();
    super.dispose();
  }

  void _onLogsChanged() {
    if (mounted) setState(() {});
  }

  void _togglePanel() {
    setState(() {
      _panelOpen = !_panelOpen;
      _selectedLog = null;
      if (_panelOpen) {
        _animCtrl.forward();
      } else {
        _animCtrl.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          // ========== PANEL ==========
          if (_panelOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() {
                  _selectedLog = null;
                }),
                child: Container(color: Colors.transparent),
              ),
            ),
          if (_panelOpen)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FadeTransition(
                opacity: _slideAnim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(_slideAnim),
                  child: _selectedLog == null
                      ? _buildLogsList()
                      : _buildLogDetail(_selectedLog!),
                ),
              ),
            ),

          // ========== FLOATING BUTTON ==========
          Positioned(
            left: _buttonPos.dx,
            top: _buttonPos.dy,
            child: GestureDetector(
              onPanStart: (_) => setState(() => _dragging = true),
              onPanUpdate: (d) {
                setState(() {
                  _buttonPos += d.delta;
                  // منع الخروج من الشاشة
                  final size = MediaQuery.of(context).size;
                  _buttonPos = Offset(
                    _buttonPos.dx.clamp(0, size.width - 60),
                    _buttonPos.dy.clamp(0, size.height - 60),
                  );
                });
              },
              onPanEnd: (_) => setState(() => _dragging = false),
              onTap: _dragging ? null : _togglePanel,
              child: _FloatingApiButton(
                logsCount: ApiLogger.instance.logs.length,
                isOpen: _panelOpen,
                hasPending: ApiLogger.instance.logs.any((l) => l.isPending),
                hasError: ApiLogger.instance.logs.any((l) => l.isError),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== LIST PANEL =====================
  Widget _buildLogsList() {
    final logs = ApiLogger.instance.logs;
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Color(0xFF0D1117),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 2)
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF161B22),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const _PulsingDot(),
                const SizedBox(width: 8),
                const Text(
                  'API Monitor',
                  style: TextStyle(
                    color: Color(0xFF58A6FF),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF21262D),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${logs.length}',
                    style: const TextStyle(
                      color: Color(0xFF8B949E),
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    ApiLogger.instance.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFF8B949E)),
                  label: const Text('Clear', style: TextStyle(color: Color(0xFF8B949E), fontSize: 12)),
                ),
                IconButton(
                  onPressed: _togglePanel,
                  icon: const Icon(Icons.close, color: Color(0xFF8B949E), size: 20),
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: logs.isEmpty
                ? const Center(
                    child: Text(
                      'No API calls yet...',
                      style: TextStyle(color: Color(0xFF8B949E), fontFamily: 'monospace'),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: logs.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: Color(0xFF21262D), height: 1),
                    itemBuilder: (context, i) => _LogTile(
                      entry: logs[i],
                      onTap: () => setState(() => _selectedLog = logs[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ===================== DETAIL PANEL =====================
  Widget _buildLogDetail(ApiLogEntry entry) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF0D1117),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 2)
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF161B22),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _selectedLog = null),
                  icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF58A6FF), size: 18),
                ),
                _MethodBadge(method: entry.method),
                const SizedBox(width: 8),
                _StatusBadge(entry: entry),
                const Spacer(),
                if (entry.duration != null)
                  Text(
                    '${entry.duration!.inMilliseconds}ms',
                    style: const TextStyle(color: Color(0xFF8B949E), fontSize: 12, fontFamily: 'monospace'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // URL
                  _DetailSection(
                    title: '🔗 URL',
                    content: entry.url,
                    copyable: true,
                  ),
                  if (entry.requestBody != null)
                    _DetailSection(
                      title: '📤 Request Body',
                      content: _prettyJson(entry.requestBody!),
                      copyable: true,
                    ),
                  if (entry.requestHeaders != null)
                    _DetailSection(
                      title: '📋 Request Headers',
                      content: entry.requestHeaders!.entries
                          .map((e) => '${e.key}: ${e.value}')
                          .join('\n'),
                      copyable: false,
                    ),
                  if (entry.responseBody != null)
                    _DetailSection(
                      title: '📥 Response Body',
                      content: _prettyJson(entry.responseBody!),
                      copyable: true,
                    ),
                  if (entry.error != null)
                    _DetailSection(
                      title: '❌ Error',
                      content: entry.error!,
                      isError: true,
                      copyable: false,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _prettyJson(String raw) {
    try {
      final buffer = StringBuffer();
      int indent = 0;
      bool inString = false;
      final limit = math.min(raw.length, 5000);
      for (int i = 0; i < limit; i++) {
        final ch = raw[i];
        if (ch == '"' && (i == 0 || raw[i - 1] != '\\')) inString = !inString;
        if (!inString) {
          if (ch == '{' || ch == '[') {
            buffer.write(ch);
            buffer.write('\n');
            indent++;
            buffer.write('  ' * indent);
            continue;
          } else if (ch == '}' || ch == ']') {
            buffer.write('\n');
            indent = math.max(0, indent - 1);
            buffer.write('  ' * indent);
            buffer.write(ch);
            continue;
          } else if (ch == ',') {
            buffer.write(ch);
            buffer.write('\n');
            buffer.write('  ' * indent);
            continue;
          } else if (ch == ':') {
            buffer.write(': ');
            continue;
          }
        }
        buffer.write(ch);
      }
      if (raw.length > 5000) buffer.write('\n... (truncated)');
      return buffer.toString();
    } catch (_) {
      return raw.length > 3000 ? '${raw.substring(0, 3000)}...' : raw;
    }
  }
}

// ===================== SUB-WIDGETS =====================

class _FloatingApiButton extends StatelessWidget {
  final int logsCount;
  final bool isOpen;
  final bool hasPending;
  final bool hasError;

  const _FloatingApiButton({
    required this.logsCount,
    required this.isOpen,
    required this.hasPending,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    Color color = const Color(0xFF238636);
    if (hasPending) color = const Color(0xFFD29922);
    if (hasError) color = const Color(0xFFDA3633);
    if (isOpen) color = const Color(0xFF58A6FF);

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.4), blurRadius: 12, spreadRadius: 1),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              isOpen ? Icons.close_rounded : Icons.api_rounded,
              color: color,
              size: 26,
            ),
          ),
          if (logsCount > 0 && !isOpen)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  logsCount > 99 ? '99+' : '$logsCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final ApiLogEntry entry;
  final VoidCallback onTap;
  const _LogTile({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color statusColor = const Color(0xFF8B949E);
    String statusText = '...';
    if (entry.isPending) {
      statusColor = const Color(0xFFD29922);
      statusText = 'pending';
    } else if (entry.isError) {
      statusColor = const Color(0xFFDA3633);
      statusText = entry.statusCode?.toString() ?? 'ERR';
    } else {
      statusColor = const Color(0xFF238636);
      statusText = entry.statusCode?.toString() ?? 'OK';
    }

    final uri = Uri.tryParse(entry.url);
    final shortPath = uri?.path ?? entry.url;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            _MethodBadge(method: entry.method),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shortPath,
                    style: const TextStyle(
                      color: Color(0xFFE6EDF3),
                      fontSize: 12,
                      fontFamily: 'monospace',
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(entry.timestamp),
                    style: const TextStyle(
                      color: Color(0xFF8B949E),
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (entry.duration != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '${entry.duration!.inMilliseconds}ms',
                      style: const TextStyle(
                        color: Color(0xFF8B949E),
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

class _MethodBadge extends StatelessWidget {
  final String method;
  const _MethodBadge({required this.method});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (method.toUpperCase()) {
      case 'GET':
        color = const Color(0xFF58A6FF);
        break;
      case 'POST':
        color = const Color(0xFF238636);
        break;
      case 'PUT':
        color = const Color(0xFFD29922);
        break;
      case 'DELETE':
        color = const Color(0xFFDA3633);
        break;
      default:
        color = const Color(0xFF8B949E);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        method.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ApiLogEntry entry;
  const _StatusBadge({required this.entry});

  @override
  Widget build(BuildContext context) {
    if (entry.isPending) {
      return const Text(
        'Pending...',
        style: TextStyle(color: Color(0xFFD29922), fontFamily: 'monospace', fontSize: 13),
      );
    }
    if (entry.error != null) {
      return Text(
        entry.statusCode != null ? 'HTTP ${entry.statusCode}' : 'Error',
        style: const TextStyle(color: Color(0xFFDA3633), fontFamily: 'monospace', fontSize: 13),
      );
    }
    return Text(
      'HTTP ${entry.statusCode}',
      style: const TextStyle(color: Color(0xFF238636), fontFamily: 'monospace', fontSize: 13),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final String content;
  final bool copyable;
  final bool isError;

  const _DetailSection({
    required this.title,
    required this.content,
    required this.copyable,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF8B949E),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              const Spacer(),
              if (copyable)
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied!'),
                        duration: Duration(seconds: 1),
                        backgroundColor: Color(0xFF238636),
                      ),
                    );
                  },
                  child: const Icon(Icons.copy, size: 14, color: Color(0xFF58A6FF)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isError
                  ? const Color(0xFF1C0E0E)
                  : const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isError
                    ? const Color(0xFFDA3633).withOpacity(0.4)
                    : const Color(0xFF30363D),
              ),
            ),
            child: SelectableText(
              content,
              style: TextStyle(
                color: isError ? const Color(0xFFDA3633) : const Color(0xFFE6EDF3),
                fontSize: 11,
                fontFamily: 'monospace',
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.lerp(
            const Color(0xFF238636),
            const Color(0xFF58A6FF),
            _ctrl.value,
          ),
        ),
      ),
    );
  }
}
