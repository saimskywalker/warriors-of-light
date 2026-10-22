// Run with: dart test/cart_test.dart   (no packages needed)
import '../lib/cart.dart';

void check(bool ok, String what) {
  if (!ok) throw StateError('FAILED: $what');
  print('ok - $what');
}

void main() {
  const items = [Item('tea', 1000, 2), Item('cake', 2500, 1)];
  check(subtotal(items) == 4500, 'subtotal sums every line');
  check(calcTotal(items) == 4500, 'no coupon keeps the subtotal');
  check(calcTotal(items, couponPercent: 10) == 4050, '10% coupon takes 450 off once');
  check(calcTotal(items, couponPercent: 100) == 0, '100% coupon is free, never negative');
  check(calcTotal(const []) == 0, 'empty cart is 0');
}
