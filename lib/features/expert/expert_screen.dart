import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/plantpulse_scaffold.dart';
import 'data/plant_assistant_repository.dart';
import 'data/plant_assistant_service.dart';
import 'models/plant_assistant_message.dart';

class ExpertScreen extends StatefulWidget {
  const ExpertScreen({super.key});

  @override
  State<ExpertScreen> createState() => _ExpertScreenState();
}

class _ExpertScreenState extends State<ExpertScreen> {
  static const int _maxMessages = 100;
  static const int _maxMessageLength = 2000;

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  PlantAssistantRepository? _repository;
  PlantAssistantService? _assistant;

  final List<PlantAssistantMessage> _messages = [];

  String _scope = 'guest';
  bool _initialized = false;
  bool _loading = true;
  bool _sending = false;
  bool _retrying = false;
  String? _error;

  User? get _currentUser {
    try {
      if (Firebase.apps.isEmpty) return null;
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    final services = AppServicesScope.of(context);

    _repository = services.plantAssistantRepository;
    _assistant = services.plantAssistantService;
    _scope = _currentUser?.uid ?? 'guest';

    _initialized = true;
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    if (_repository == null || _loading && _messages.isNotEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final savedMessages = _repository!.loadMessages(_scope);

      if (!mounted) return;

      setState(() {
        _messages
          ..clear()
          ..addAll(savedMessages.take(_maxMessages));
        _loading = false;
        _error = null;
      });

      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context).expertLoadFailed;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();

    if (text.isEmpty || _sending || _loading || _error != null) return;

    final l10n = AppLocalizations.of(context);

    if (text.length > _maxMessageLength) {
      _showMessage(l10n.expertMessageTooLong);
      return;
    }

    final now = DateTime.now();
    final messageId = now.microsecondsSinceEpoch.toString();

    final userMessage = PlantAssistantMessage(
      id: messageId,
      text: text,
      isUser: true,
      createdAt: now,
    );

    _controller.clear();

    setState(() {
      _sending = true;
      _messages.add(userMessage);
    });

    _scrollToBottom();

    try {
      await _repository!.appendMessage(_scope, userMessage);

      if (!mounted) return;

      final reply = _assistant!.getReply(
        text,
        conversation: List<PlantAssistantMessage>.unmodifiable(_messages),
      );

      final assistantMessage = PlantAssistantMessage(
        id: '${messageId}_reply',
        text: reply,
        isUser: false,
        createdAt: DateTime.now(),
      );

      await _repository!.appendMessage(_scope, assistantMessage);

      if (!mounted) return;

      setState(() {
        _messages.add(assistantMessage);
        _trimMessages();
        _sending = false;
      });

      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _sending = false;
        _error = AppLocalizations.of(context).expertMessageSaveFailed;
      });
    }
  }

  void _trimMessages() {
    if (_messages.length > _maxMessages) {
      _messages.removeRange(0, _messages.length - _maxMessages);
    }
  }

  Future<void> _retryPendingMessage() async {
    if (_retrying || _sending || _loading) return;

    final pendingMessage =
        _messages.isNotEmpty && _messages.last.isUser ? _messages.last : null;

    setState(() {
      _retrying = true;
      _error = null;
    });

    try {
      final savedMessages = _repository!.loadMessages(_scope);
      final recoveredMessages = [...savedMessages];

      if (pendingMessage != null &&
          !recoveredMessages.any(
            (message) => message.id == pendingMessage.id,
          )) {
        await _repository!.appendMessage(_scope, pendingMessage);
        recoveredMessages.add(pendingMessage);
      }

      recoveredMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      if (!mounted) return;

      setState(() {
        _messages
          ..clear()
          ..addAll(recoveredMessages.take(_maxMessages));
        _loading = false;
      });

      final lastUserIndex = _messages.lastIndexWhere(
        (message) => message.isUser,
      );

      if (lastUserIndex < 0) {
        setState(() {
          _retrying = false;
          _error = null;
        });
        return;
      }

      final lastUserMessage = _messages[lastUserIndex];
      final expectedReplyId = '${lastUserMessage.id}_reply';

      final replyAlreadyExists = _messages.any(
        (message) => message.id == expectedReplyId,
      );

      if (!replyAlreadyExists) {
        final reply = _assistant!.getReply(
          lastUserMessage.text,
          conversation: List<PlantAssistantMessage>.unmodifiable(
            _messages.take(lastUserIndex + 1),
          ),
        );

        final assistantMessage = PlantAssistantMessage(
          id: expectedReplyId,
          text: reply,
          isUser: false,
          createdAt: DateTime.now(),
        );

        await _repository!.appendMessage(_scope, assistantMessage);

        if (!mounted) return;

        setState(() {
          _messages.removeWhere((message) => message.id == assistantMessage.id);
          _messages.add(assistantMessage);
          _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          _trimMessages();
        });
      }

      if (!mounted) return;

      setState(() {
        _retrying = false;
        _error = null;
      });

      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _retrying = false;
        _error = AppLocalizations.of(context).expertRecoveryFailed;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmClearHistory() async {
    if (_messages.isEmpty || _sending || _retrying) return;

    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.expertClearTitle),
          content: Text(l10n.expertClearConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.expertCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.expertClear),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await _repository!.clearMessages(_scope);

      if (!mounted) return;

      setState(() {
        _messages.clear();
        _error = null;
        _controller.clear();
      });
    } catch (_) {
      if (!mounted) return;
      _showMessage(AppLocalizations.of(context).expertClearFailed);
    }
  }

  String _formatTime(DateTime dateTime, AppLocalizations l10n) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? l10n.expertPm : l10n.expertAm;

    return '$hour:$minute $period';
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PlantPulseScaffold(
      currentIndex: 0,
      showBottomNavigation: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
            child: PageHeader(
              title: l10n.expertTitle,
              subtitle: l10n.expertSubtitle,
              back: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: PlantPulseColors.mint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: PlantPulseColors.green,
                    ),
                  ),
                  if (_messages.isNotEmpty)
                    IconButton(
                      tooltip: l10n.expertClearConversation,
                      onPressed:
                          _sending || _retrying ? null : _confirmClearHistory,
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PlantPulseColors.mint.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: PlantPulseColors.green,
                  size: 19,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    l10n.expertOfflineDisclaimer,
                    style: const TextStyle(
                      color: PlantPulseColors.ink,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: _ErrorBanner(
                message: _error!,
                loading: _retrying || _loading,
                onRetry: _retryPendingMessage,
                retryLabel: l10n.expertRetry,
              ),
            ),
          const SizedBox(height: 8),
          Expanded(child: _buildConversation(l10n)),
          _buildComposer(l10n),
        ],
      ),
    );
  }

  Widget _buildConversation(AppLocalizations l10n) {
    if (_loading && _messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_messages.isEmpty && _error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: PlantPulseColors.muted, height: 1.5),
          ),
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.spa_rounded,
                size: 46,
                color: PlantPulseColors.green,
              ),
              const SizedBox(height: 14),
              Text(
                l10n.expertEmptyTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: PlantPulseColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.expertEmptyDescription,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: PlantPulseColors.muted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      itemCount: _messages.length + (_sending ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.expertPreparingReply,
                style: const TextStyle(
                  fontSize: 11,
                  color: PlantPulseColors.muted,
                ),
              ),
            ),
          );
        }

        final message = _messages[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _MessageBubble(
            message: message,
            time: _formatTime(message.createdAt, l10n),
          ),
        );
      },
    );
  }

  Widget _buildComposer(AppLocalizations l10n) {
    final disabled = _loading || _sending || _retrying || _error != null;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                maxLength: _maxMessageLength,
                enabled: !disabled,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: l10n.expertMessageHint,
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: l10n.expertSendMessage,
              onPressed: disabled ? null : _sendMessage,
              icon: const Icon(Icons.arrow_upward_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
    required this.loading,
    required this.onRetry,
    required this.retryLabel,
  });

  final String message;
  final bool loading;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.deepOrange),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: PlantPulseColors.ink,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: loading ? null : onRetry,
            child:
                loading
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Text(retryLabel),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.time});

  final PlantAssistantMessage message;
  final String time;

  @override
  Widget build(BuildContext context) {
    final mine = message.isUser;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxBubbleWidth = (screenWidth - 48).clamp(180.0, 520.0);

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxBubbleWidth),
        child: Column(
          crossAxisAlignment:
              mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: mine ? PlantPulseColors.green : Colors.white,
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomRight: Radius.circular(mine ? 5 : 18),
                  bottomLeft: Radius.circular(mine ? 18 : 5),
                ),
                border: mine ? null : Border.all(color: PlantPulseColors.line),
              ),
              child: Text(
                message.text,
                softWrap: true,
                style: TextStyle(
                  color: mine ? Colors.white : PlantPulseColors.ink,
                  height: 1.4,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(
                color: PlantPulseColors.muted,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
