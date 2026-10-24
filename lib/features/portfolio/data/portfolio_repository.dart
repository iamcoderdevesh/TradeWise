import 'package:tradewise/features/portfolio/data/portfolio_entry.dart';
import 'package:tradewise/features/portfolio/data/portfolio_preview_data.dart';

/// Source of the initial Portfolio rows (UI phase).
///
/// Abstracted now (architecture rule: data access behind repositories) so
/// the mock below can be swapped for a real data source without touching
/// the notifier or any widget.
abstract class PortfolioRepository {
  const PortfolioRepository();

  /// Seed rows for the Holdings tab.
  List<PortfolioEntry> loadHoldings();

  /// Seed rows for the Positions tab (may include closed rows).
  List<PortfolioEntry> loadPositions();
}

/// In-memory preview implementation (ADR-005, UI-only phase).
///
/// Defaults to the documented preview seeds; tests pass custom lists (or
/// empty ones) to exercise the empty and populated states.
class MockPortfolioRepository extends PortfolioRepository {
  const MockPortfolioRepository({
    this.holdings = kPreviewHoldings,
    this.positions = kPreviewPositions,
  });

  final List<PortfolioEntry> holdings;
  final List<PortfolioEntry> positions;

  @override
  List<PortfolioEntry> loadHoldings() => holdings;

  @override
  List<PortfolioEntry> loadPositions() => positions;
}
