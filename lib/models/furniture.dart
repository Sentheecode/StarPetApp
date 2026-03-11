class Furniture {
  final String id;
  final String name;
  final String category; // 地板、墙面、家具、装饰
  final String? imageUrl;
  final int price;
  final bool isOwned;

  Furniture({
    required this.id,
    required this.name,
    required this.category,
    this.imageUrl,
    required this.price,
    this.isOwned = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'imageUrl': imageUrl,
    'price': price,
    'isOwned': isOwned,
  };

  factory Furniture.fromJson(Map<String, dynamic> json) => Furniture(
    id: json['id'],
    name: json['name'],
    category: json['category'],
    imageUrl: json['imageUrl'],
    price: json['price'],
    isOwned: json['isOwned'] ?? false,
  );
}
