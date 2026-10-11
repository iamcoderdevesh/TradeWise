import 'package:flutter_test/flutter_test.dart';
import 'package:tradewise/features/order/presentation/order_math.dart';

void main() {
  group('parseOrderQuantity', () {
    test('parses whole quantities', () {
      expect(parseOrderQuantity('1'), 1);
      expect(parseOrderQuantity('1000'), 1000);
    });

    test('rejects empty, fractional, non-numeric and overflowing input', () {
      expect(parseOrderQuantity(''), isNull);
      expect(parseOrderQuantity('   '), isNull);
      expect(parseOrderQuantity('1.5'), isNull);
      expect(parseOrderQuantity('-2'), isNull);
      expect(parseOrderQuantity('+3'), isNull);
      expect(parseOrderQuantity('abc'), isNull);
      expect(parseOrderQuantity('12a'), isNull);
      expect(parseOrderQuantity('9999999999999999999999'), isNull);
    });

    test('parses zero so callers can apply the >= 1 validity rule', () {
      expect(parseOrderQuantity('0'), 0);
    });
  });

  group('parseOrderMoney', () {
    test('parses amounts and limit prices', () {
      expect(parseOrderMoney('500'), 500);
      expect(parseOrderMoney('79.52'), 79.52);
      expect(parseOrderMoney(' 80.39 '), 80.39);
    });

    test('rejects empty, malformed and non-finite input', () {
      expect(parseOrderMoney(''), isNull);
      expect(parseOrderMoney('abc'), isNull);
      expect(parseOrderMoney('12.3.4'), isNull);
      expect(parseOrderMoney('NaN'), isNull);
      expect(parseOrderMoney('Infinity'), isNull);
    });
  });

  group('indicativeQuantity', () {
    test('floors the amount over price (whole shares only)', () {
      // ₹1000 at ₹79.52 buys 12 whole shares, never 12.57.
      expect(indicativeQuantity(amount: 1000, price: 79.52), 12);
      expect(indicativeQuantity(amount: 500, price: 79.52), 6);
    });

    test('returns 0 when the amount cannot buy a full share', () {
      expect(indicativeQuantity(amount: 50, price: 79.52), 0);
    });

    test('guards missing, zero, negative and non-finite operands', () {
      expect(indicativeQuantity(amount: null, price: 79.52), 0);
      expect(indicativeQuantity(amount: 500, price: null), 0);
      expect(indicativeQuantity(amount: 500, price: 0), 0);
      expect(indicativeQuantity(amount: 0, price: 79.52), 0);
      expect(indicativeQuantity(amount: -10, price: 79.52), 0);
      expect(indicativeQuantity(amount: 500, price: -1), 0);
      expect(indicativeQuantity(amount: double.nan, price: 79.52), 0);
      expect(indicativeQuantity(amount: 500, price: double.infinity), 0);
    });
  });

  group('estimateOrderAmount', () {
    test('multiplies quantity by price', () {
      expect(estimateOrderAmount(quantity: 1, price: 80.39), 80.39);
      expect(estimateOrderAmount(quantity: 1000, price: 79.52), 79520);
    });
  });
}
