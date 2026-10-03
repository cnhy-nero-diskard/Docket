import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/bootstrap.dart';
import '../../data/local/database.dart';
import '../../data/local/fixture_repository.dart';
import 'editor_draft.dart';

enum PaneLayout { compact, intermediate, wide }

abstract final class PaneConstraints {
  static const navigation = 240.0;
  static const collection = 360.0;
  static const detail = 320.0;
  static const gutter = 1.0;
  static PaneLayout at(double width, double scale) {
    final usable = width / scale.clamp(1, 2.5);
    if (usable >= navigation + collection + detail + 2 * gutter) {
      return PaneLayout.wide;
    }
    if (usable >= navigation + collection + gutter) {
      return PaneLayout.intermediate;
    }
    return PaneLayout.compact;
  }
}

class FoundationShell extends ConsumerStatefulWidget {
  const FoundationShell({super.key, this.collectionId, this.itemId});
  final String? collectionId;
  final String? itemId;
  @override
  ConsumerState<FoundationShell> createState() => FoundationShellState();
}

class FoundationShellState extends ConsumerState<FoundationShell> {
  final drafts = <String, EditorDraft>{};
  final rowFocus = <String, FocusNode>{};
  final scrolls = <String, ScrollController>{};
  final homeFocus = FocusNode(debugLabel: 'Collection home');
  final collectionFocus = FocusNode(debugLabel: 'Collection navigation');
  final navigationScroll = ScrollController();
  final detailScroll = ScrollController();
  FixtureRepository? _repository;
  Stream<FixtureSnapshot>? _observations;
  int? progress;
  PaneLayout? _layout;
  String? diagnostic;
  String? _returnFocus;
  FixtureSnapshot? _latestSnapshot;

  void parent() {
    _returnFocus = widget.itemId;
    context.go(
      widget.itemId != null &&
              widget.collectionId != null &&
              (_latestSnapshot?.collections.any(
                    (r) => r.id == widget.collectionId,
                  ) ??
                  false)
          ? '/lists/${widget.collectionId}'
          : '/lists',
    );
  }

  void openItem(FixtureItem item) {
    context.go('/lists/${item.collectionId}/items/${item.id}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) drafts[item.id]?.titleFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    for (final draft in drafts.values) {
      draft.dispose();
    }
    for (final focus in rowFocus.values) {
      focus.dispose();
    }
    for (final scroll in scrolls.values) {
      scroll.dispose();
    }
    homeFocus.dispose();
    collectionFocus.dispose();
    navigationScroll.dispose();
    detailScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resource = ref.watch(resourcesProvider);
    return resource.when(
      loading: () => const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Opening local storage…'),
            ],
          ),
        ),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storage_outlined, size: 40),
                const Text('Local storage could not be opened'),
                SelectableText('$error'),
                const Text('Your existing store has not been reset.'),
                TextButton(
                  onPressed: () => ref.invalidate(resourcesProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (resources) {
        if (!resources.backend.health.safe) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(resources.backend.health.description),
                    if (diagnostic != null) SelectableText(diagnostic!),
                    if (resources.fixtures != null)
                      TextButton(
                        onPressed: () => _command(() async {
                          final payload = await resources.backend
                              .recoverFixture();
                          if (payload != null) {
                            await Clipboard.setData(
                              ClipboardData(text: payload),
                            );
                          }
                          if (mounted) {
                            setState(() {
                              diagnostic = payload == null
                                  ? 'No readable fixture snapshot is available. Preserve site data.'
                                  : 'Fixture recovery snapshot copied. No store was reset.';
                            });
                          }
                        }),
                        child: const Text(
                          'Copy readable fixture recovery data',
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }
        final repository = resources.fixtures;
        if (repository == null) return _ordinary();
        if (_repository != repository) {
          _repository = repository;
          _observations = repository.watch();
        }
        return StreamBuilder<FixtureSnapshot>(
          stream: _observations,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Storage needs attention. Update or retry; data is preserved.',
                        ),
                        SelectableText('${snapshot.error}'),
                        for (final draft in drafts.values.where((d) => d.dirty))
                          SelectionArea(
                            child: Text(
                              'Retained draft: ${draft.title.text}\n${draft.notes.text}',
                            ),
                          ),
                        TextButton(
                          onPressed: () => setState(() {
                            _observations = repository.watch();
                          }),
                          child: const Text('Retry storage'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return _fixture(resources, snapshot.requireData);
          },
        );
      },
    );
  }

  Widget _ordinary() => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.view_sidebar_outlined, size: 48),
                const SizedBox(height: 24),
                Text('Docket', style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 12),
                const Text('Your space, on this device.'),
                const SizedBox(height: 16),
                const Text(
                  'Local storage is ready. '
                  'Task workflows are coming in the next milestone.',
                ),
                const SizedBox(height: 24),
                const Chip(label: Text('Local only')),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _fixture(AppResources resources, FixtureSnapshot data) {
    _latestSnapshot = data;
    final collection = data.collections
        .where((r) => r.id == widget.collectionId)
        .firstOrNull;
    final item = data.items
        .where(
          (r) => r.id == widget.itemId && r.collectionId == widget.collectionId,
        )
        .firstOrNull;
    final unknown =
        (widget.collectionId != null && collection == null) ||
        (widget.itemId != null && item == null);
    if (item != null) {
      drafts
          .putIfAbsent(item.id, () => EditorDraft(item))
          .acceptCommitted(item);
    }
    if (_returnFocus != null && widget.itemId == null) {
      final id = _returnFocus;
      _returnFocus = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final row = rowFocus[id];
          final stillPresent = data.items.any((item) => item.id == id);
          if (stillPresent && row?.context != null) {
            row!.requestFocus();
          } else {
            (widget.collectionId == null ? homeFocus : collectionFocus)
                .requestFocus();
          }
        }
      });
    }
    return PopScope(
      canPop: widget.collectionId == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) parent();
      },
      child: CallbackShortcuts(
        bindings: {const SingleActivator(LogicalKeyboardKey.escape): parent},
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Material(
                  color: const Color(0xffe8eaf7),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'FOUNDATION FIXTURE · disposable records',
                          ),
                        ),
                        IconButton(
                          tooltip: 'Fixture diagnostics',
                          onPressed: () => _diagnostics(resources),
                          icon: const Icon(Icons.science_outlined),
                        ),
                      ],
                    ),
                  ),
                ),
                if (progress != null)
                  LinearProgressIndicator(value: progress! / 10000),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final scale =
                          MediaQuery.textScalerOf(context).scale(16) / 16;
                      final layout = PaneConstraints.at(
                        constraints.maxWidth,
                        scale,
                      );
                      if (_layout != layout) {
                        final focus = FocusManager.instance.primaryFocus;
                        final draft = drafts[widget.itemId];
                        if (focus == draft?.titleFocus ||
                            focus == draft?.notesFocus) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) focus?.requestFocus();
                          });
                        }
                        _layout = layout;
                      }
                      final navigation = _navigation(data);
                      final content = unknown
                          ? _notFound(collection != null)
                          : item != null
                          ? _detail(item, resources.fixtures!)
                          : _collection(data, collection);
                      if (layout == PaneLayout.compact) {
                        return KeyedSubtree(
                          key: const ValueKey('compact'),
                          child: widget.collectionId == null
                              ? navigation
                              : content,
                        );
                      }
                      return Row(
                        key: ValueKey(layout.name),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width:
                                PaneConstraints.navigation *
                                scale.clamp(1, 2.5),
                            child: navigation,
                          ),
                          const VerticalDivider(width: 1),
                          if (layout == PaneLayout.wide && item != null) ...[
                            Expanded(child: _collection(data, collection)),
                            const VerticalDivider(width: 1),
                            SizedBox(
                              width:
                                  PaneConstraints.detail * scale.clamp(1, 2.5),
                              child: content,
                            ),
                          ] else
                            Expanded(child: content),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navigation(FixtureSnapshot data) => Material(
    color: const Color(0xfff1f3f8),
    child: Scrollbar(
      controller: navigationScroll,
      thumbVisibility: true,
      child: ListView(
        controller: navigationScroll,
        padding: const EdgeInsets.all(16),
        children: [
          Text('Docket', style: Theme.of(context).textTheme.headlineSmall),
          const Text('Local foundation'),
          const SizedBox(height: 24),
          TextButton.icon(
            focusNode: homeFocus,
            onPressed: () => context.go('/lists'),
            icon: const Icon(Icons.view_list_outlined),
            label: const Text('Collections'),
          ),
          const Divider(),
          for (final collection in data.collections)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                selected: collection.id == widget.collectionId,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                selectedTileColor: const Color(0xffdce2f8),
                title: Text(collection.title),
                onTap: () => context.go('/lists/${collection.id}'),
              ),
            ),
          if (data.collections.isEmpty)
            const Text('Create disposable records from fixture diagnostics.'),
        ],
      ),
    ),
  );

  Widget _collection(FixtureSnapshot data, FixtureCollection? collection) {
    final rows = data.items
        .where((r) => r.collectionId == collection?.id)
        .toList();
    final controller = scrolls.putIfAbsent(
      collection?.id ?? 'home',
      ScrollController.new,
    );
    return ColoredBox(
      color: const Color(0xffe6eafa),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'All collections',
                  focusNode: collectionFocus,
                  onPressed: () => context.go('/lists'),
                  icon: const Icon(Icons.arrow_back),
                ),
                Expanded(
                  child: Text(
                    collection?.title ?? 'Choose a collection',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Scrollbar(
              controller: controller,
              thumbVisibility: true,
              child: ListView.builder(
                key: PageStorageKey(collection?.id ?? 'home'),
                controller: controller,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: rows.length,
                itemBuilder: (context, index) {
                  final item = rows[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: widget.itemId == item.id
                          ? const Color(0xffcbd5fb)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      child: ListTile(
                        key: ValueKey('row-${item.id}'),
                        focusNode: rowFocus.putIfAbsent(
                          item.id,
                          () => FocusNode(debugLabel: item.id),
                        ),
                        focusColor: const Color(0xffa6b7ef),
                        title: Text(item.title),
                        leading: const Icon(Icons.article_outlined),
                        onTap: () => openItem(item),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('${rows.length} fixture records · local storage'),
          ),
        ],
      ),
    );
  }

  Widget _detail(FixtureItem item, FixtureRepository repository) {
    final draft = drafts[item.id]!;
    return ListenableBuilder(
      listenable: draft,
      builder: (context, _) => Scrollbar(
        controller: detailScroll,
        thumbVisibility: true,
        child: ListView(
          controller: detailScroll,
          padding: const EdgeInsets.all(16),
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                key: const ValueKey('close-detail'),
                tooltip: 'Close detail (Escape)',
                onPressed: parent,
                icon: const Icon(Icons.close),
              ),
            ),
            Text(
              'Fixture detail',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            TextField(
              key: const ValueKey('fixture-title'),
              controller: draft.title,
              focusNode: draft.titleFocus,
              maxLines: null,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const ValueKey('fixture-notes'),
              controller: draft.notes,
              focusNode: draft.notesFocus,
              minLines: 8,
              maxLines: null,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const ValueKey('save-fixture'),
              onPressed: draft.saving ? null : () => draft.save(repository),
              child: Text(draft.saving ? 'Committing…' : 'Save locally'),
            ),
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              child: Text(
                draft.message ??
                    (draft.dirty ? 'Unsaved draft' : 'Committed local record'),
              ),
            ),
            const SizedBox(height: 20),
            SelectableText('Fixture ID: ${item.id}'),
            const Text(
              'This validates storage and navigation, not finished task workflows.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _notFound(bool validParent) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Fixture unavailable'),
          TextButton(
            onPressed: () => context.go(
              validParent ? '/lists/${widget.collectionId}' : '/lists',
            ),
            child: Text(
              validParent ? 'Open parent collection' : 'Open collections',
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _diagnostics(AppResources resources) async {
    final repository = resources.fixtures!;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Disposable fixture tools'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(resources.backend.health.description),
              if (diagnostic != null) SelectableText(diagnostic!),
              const Text('Reset affects only docket_foundation_fixture.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _command(repository.seed);
            },
            child: const Text('Seed fixtures'),
          ),
          TextButton(
            onPressed: () {
              repository.failNextWrite = true;
              Navigator.pop(dialogContext);
            },
            child: const Text('Fail next write'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _command(() async {
                final json = await repository.exportJson();
                await Clipboard.setData(ClipboardData(text: json));
                if (mounted) {
                  setState(() {
                    diagnostic = 'Fixture JSON copied.';
                  });
                }
              });
            },
            child: const Text('Copy fixture JSON'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _command(() async {
                setState(() {
                  progress = 0;
                });
                try {
                  final elapsed = await repository.bulkWrite(
                    progress: (n) {
                      if (mounted) {
                        setState(() {
                          progress = n;
                        });
                      }
                    },
                  );
                  if (mounted) {
                    setState(() {
                      diagnostic =
                          '10,000 records: ${elapsed.inMilliseconds} ms';
                    });
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      progress = null;
                    });
                  }
                }
              });
            },
            child: const Text('Run 10,000 writes'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final reset = await _command(repository.reset);
              if (mounted && reset) {
                context.go('/lists');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  for (final d in drafts.values) {
                    d.dispose();
                  }
                  drafts.clear();
                });
              }
            },
            child: const Text('Reset fixtures'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<bool> _command(Future<void> Function() command) async {
    try {
      await command();
      return true;
    } catch (e) {
      if (mounted) {
        setState(() {
          diagnostic = 'Operation failed; data retained. $e';
        });
      }
      return false;
    }
  }
}
