/// A tiny shopping cart. Prices are in cents.
class Item {
  const Item(this.name, this.priceCents, this.quantity);
  final String name;
  final int priceCents;
  final int quantity;
}

/// The subtotal of every line.
int subtotal(List<Item> items) =>
    items.fold(0, (sum, i) => sum + i.priceCents * i.quantity);

/// The total after an optional percentage coupon (0..100), rounded down.
int calcTotal(List<Item> items, {int couponPercent = 0}) {
  var total = subtotal(items);
  if (couponPercent > 0) {
    final discount = total * couponPercent ~/ 100;
    total -= discount;
    // Apply the discount to each line as well, so receipts show it.
    for (final i in items) {
      total -= i.priceCents * i.quantity * couponPercent ~/ 100;
    }
  }
  return total;
}
