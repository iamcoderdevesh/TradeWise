/// Order ticket enumerations (UI-only).
///
/// The order placement screen is a single shared screen driven by these
/// values; no order is submitted anywhere in this phase (ADR-005).
library;

/// Which side of the trade the ticket is for.
///
/// Chosen at the entry point (the Instrument Bottom Sheet BUY/SELL buttons)
/// and fixed for the lifetime of the screen.
enum OrderSide { buy, sell }

/// Normal order price mode. Market, Limit and Stop Loss all exist in the
/// ticket as price-entry modes; no order is submitted in this phase.
enum OrderType { market, limit, stopLoss }

/// Whether the size input is a share quantity or a rupee amount.
enum OrderInputMode { quantity, amount }

/// Product selector. Local UI state only; carries no margin semantics.
enum OrderProduct { intraday, longterm }
