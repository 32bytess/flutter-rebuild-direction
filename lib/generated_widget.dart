// ignore_for_file: unused_import, unused_element, unused_field
library generated_widget;

import 'package:flutter/material.dart';
part 'dependencies.dart';


class GeneratedWidget extends StatefulWidget {
  const GeneratedWidget({super.key});

  GeneratedWidget.fixture({super.key});

  @override
  State<GeneratedWidget> createState() => _GeneratedWidgetState();
}

class _GeneratedWidgetState extends State<GeneratedWidget> {
  late WidgetRef ref;

  @override
  void initState() {
    super.initState();
    ref = fixtureRef;
    groupedConversations = fixtureGroupedConversations;
    activeConversation = fixtureActiveConversation;
  }

  late Map<String, List<Conversation>> groupedConversations;

  late Conversation? activeConversation;

  @override
  Widget build(BuildContext context) {
    final sectionOrder = [
      'PINNED',
      'TODAY',
      'YESTERDAY',
      'PREVIOUS 7 DAYS',
      'PREVIOUS 30 DAYS',
      'OLDER',
    ];
    final sortedSections = groupedConversations.keys.toList()
      ..sort((a, b) {
        final aIndex = sectionOrder.indexOf(a);
        final bIndex = sectionOrder.indexOf(b);
        return aIndex.compareTo(bIndex);
      });
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: sortedSections.length,
      itemBuilder: (context, sectionIndex) {
        final section = sortedSections[sectionIndex];
        final conversations = groupedConversations[section]!;

        if (section == 'PINNED' && conversations.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DateSectionHeader(title: section),
            ...conversations.map((conversation) {
              return ConversationTile(
                conversation: conversation,
                isActive: activeConversation?.id == conversation.id,
                onTap: () {
                  /* spm: non-rebuild body erased */
                },
                onRename: () {
                  /* spm: non-rebuild body erased */
                },
                onTogglePin: () {
                  /* spm: non-rebuild body erased */
                },
                onDelete: () {
                  /* spm: non-rebuild body erased */
                },
              );
            }),
          ],
        );
      },
    );
  }
}

class DateSectionHeader extends StatelessWidget {
  const DateSectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFF666666) : const Color(0xFF999999),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.isActive,
    required this.onTap,
    required this.onRename,
    required this.onTogglePin,
    required this.onDelete,
  });

  final Conversation conversation;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onTogglePin;
  final VoidCallback onDelete;

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        /* spm: non-rebuild body erased */
        throw UnimplementedError();
      },
      child: Material(
        color: isActive
            ? (isDark
                  ? const Color(0xFF3B82F6).withValues(alpha: 0.2)
                  : const Color(0xFF2563EB).withValues(alpha: 0.1))
            : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: () {
            /* spm: non-rebuild body erased */
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  conversation.isPinned
                      ? Icons.push_pin
                      : Icons.chat_bubble_outline,
                  size: 20,
                  color: isActive
                      ? (isDark
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF2563EB))
                      : (isDark
                            ? const Color(0xFF888888)
                            : const Color(0xFF666666)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (conversation.lastMessagePreview != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          conversation.lastMessagePreview!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFF888888)
                                : const Color(0xFF666666),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTimestamp(conversation.updatedAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF666666)
                        : const Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  conversation.isPinned
                      ? Icons.push_pin_outlined
                      : Icons.push_pin,
                ),
                title: Text(conversation.isPinned ? 'Unpin' : 'Pin'),
                onTap: () {
                  /* spm: non-rebuild body erased */
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Rename'),
                onTap: () {
                  /* spm: non-rebuild body erased */
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  /* spm: non-rebuild body erased */
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}











// Stands in for values this file cannot reproduce. Reaching a member on one
// returns another stub rather than throwing, so a build body runs to its end.
