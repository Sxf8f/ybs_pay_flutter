import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ybs_pay/core/const/assets_const.dart';


class signUpRepository{
  Future<String>signUp({
    required String username,
    required String email,
    required String password,
    required String phoneNumber,
    required String pinCode,
    required String address,
}) async{
    final uri= Uri.parse('${AssetsConst.apiBase}api/register/');
    final response = await http.post(uri,body: {
      'username':username,
      'email':email,
      // 'password':password,
      'phone_number':phoneNumber,
      'pincode':pinCode,
      'address':address
    });
    if(response.statusCode ==201){
      final data = json.decode(response.body);
      return data['message'] ?? 'Signup Successful';
    }else{
      final err = json.decode(response.body);
      throw Exception(err??'Signup failed');
    }
  }
}
