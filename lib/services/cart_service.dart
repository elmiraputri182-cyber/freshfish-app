import '../models/cart_model.dart';

class CartService {

  static List<CartModel> cartItems = [];

  static void tambahKeranjang(
    CartModel item,
  ){

    cartItems.add(item);
  }

  static int totalItem(){

    return cartItems.length;
  }
  static double totalHarga(){

  double total = 0;

  for(var item in cartItems){

    total +=
        double.parse(
          item.ikan["harga"]
              .toString(),
        ) * item.jumlah;
  }

  return total;
}
}