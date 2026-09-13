import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n_extension.dart';
import '../router/routes.dart';
import 'story_viewer_page.dart';

class StoriesPage extends StatefulWidget {
  const StoriesPage({super.key});

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
  // In memory for the demo; a real app gets "seen" from the backend or stores it locally.
  final Set<String> _seen = {};

  Future<void> _open(String groupId) async {
    await context.push(Routes.storyViewerFor(groupId));
    if (mounted) setState(() => _seen.add(groupId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.storiesTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            height: 112,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final group in StoryGroup.values)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 16),
                    child: _StoryAvatar(
                      title: group.title(l10n),
                      icon: group.icon,
                      seen: _seen.contains(group.name),
                      onTap: () => _open(group.name),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.storiesHint),
        ],
      ),
    );
  }
}

class _StoryAvatar extends StatelessWidget {
  const _StoryAvatar({required this.title, required this.icon, required this.seen, required this.onTap});

  final String title;
  final IconData icon;
  final bool seen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: title,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Gradient ring = unseen, grey ring = seen.
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: seen ? colors.outlineVariant : null,
                gradient: seen ? null : LinearGradient(colors: [colors.primary, colors.tertiary]),
              ),
              child: CircleAvatar(
                radius: 34,
                backgroundColor: colors.surfaceContainerHighest,
                child: Icon(icon, color: colors.primary, size: 30),
              ),
            ),
            const SizedBox(height: 6),
            Text(title, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}
