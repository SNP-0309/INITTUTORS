import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/router/route_paths.dart';
import '../../domain/batch_state.dart';
import '../controllers/batch_controller.dart';

class BatchListScreen extends ConsumerStatefulWidget {
  const BatchListScreen({super.key});

  @override
  ConsumerState<BatchListScreen> createState() => _BatchListScreenState();
}

class _BatchListScreenState extends ConsumerState<BatchListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(batchControllerProvider.notifier).loadBatches(isRefresh: true);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(batchControllerProvider.notifier).loadBatches();
    }
  }

  void _onSearch(String query) {
    ref.read(batchControllerProvider.notifier).loadBatches(search: query, isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(batchControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Batches'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTokens.space3),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: 'Search batch, subject, teacher, standard...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearch('');
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppTokens.space2,
                    horizontal: AppTokens.space3,
                  ),
                ),
              ),
            ),
            Expanded(
              child: state.batches.isEmpty && state.status == BatchLoadStatus.loading
                  ? const Center(child: CircularProgressIndicator())
                  : state.status == BatchLoadStatus.error && state.batches.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(state.error ?? 'Failed to load batches',
                                  style: const TextStyle(color: AppTokens.danger)),
                              const SizedBox(height: AppTokens.space3),
                              ElevatedButton(
                                onPressed: () => ref
                                    .read(batchControllerProvider.notifier)
                                    .loadBatches(isRefresh: true),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : state.batches.isEmpty
                          ? const Center(
                              child: Text('No batches found',
                                  style: TextStyle(color: AppTokens.textSecondary)),
                            )
                          : RefreshIndicator(
                              onRefresh: () => ref
                                  .read(batchControllerProvider.notifier)
                                  .loadBatches(isRefresh: true),
                              child: ListView.builder(
                                controller: _scrollController,
                                itemCount: state.batches.length + (state.hasMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == state.batches.length) {
                                    return const Padding(
                                      padding: EdgeInsets.all(AppTokens.space4),
                                      child: Center(child: CircularProgressIndicator()),
                                    );
                                  }

                                  final batch = state.batches[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: AppTokens.space3,
                                      vertical: AppTokens.space1,
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: AppTokens.primary.withOpacity(0.1),
                                        child: const Icon(Icons.group, color: AppTokens.primary),
                                      ),
                                      title: Text(
                                        batch.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        'Teacher: ${batch.teacher.user.fullName} \nSubject: ${batch.subject.name} • Class: ${batch.standard ?? "N/A"}',
                                      ),
                                      isThreeLine: true,
                                      trailing: const Icon(Icons.chevron_right),
                                      onTap: () {
                                        context.push(
                                          RoutePaths.adminBatchDetail
                                              .replaceAll(':id', batch.id),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RoutePaths.adminBatchNew),
        child: const Icon(Icons.add),
      ),
    );
  }
}
