// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'Package:http/http.dart'as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'core/const/color_const.dart';
// import 'main.dart';
// import 'navigationPage.dart';
//
//
//
//
//
//
// class loginPage extends StatefulWidget {
//
//   const loginPage({super.key});
//
//   @override
//   State<loginPage> createState() => _loginPageState();
// }
// class User {
//   final int loginId;
//   final String password;
//   User({
//     required this.loginId,
//     required this.password
//   });
//   factory User.fromJson(Map<String, dynamic> json){
//     return User(
//         loginId: json["loginId"],
//         password: json["password"]
//     );
//   }
// }
// String? tokenKey;
// class _loginPageState extends State<loginPage> {
//
//   TextEditingController loginidController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//   bool remember=false;
//   bool hide=true;
//
//   bool _isLoading = false;
//   String? _errorMessage;
//
//   Future<void> _login() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     String username = loginidController.text.trim();
//     String password = passwordController.text.trim();
//
//     final url = Uri.parse('https://www.easytohrm.com/api/login');
//     try {
//       final response = await http.post(
//         url, headers: {
//         'Content-Type': 'application/json',
//       },
//         body: json.encode({
//           'username': username,
//           'password': password,
//         }),
//       );
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == true) {
//           setState(() {
//             _isLoading = false;
//           });
//           String token = data['data']['token'];
//           await _saveToken(token);
//           saveLoginTime();
//           tokenKey = token;
//           _showSuccessMessage(data['message']);
//         } else {
//           setState(() {
//             _isLoading = false;
//           });
//           _showErrorMessage('Login failed. ${data['message']}');
//         }
//       } else {
//         setState(() {
//           _isLoading = false;
//         });
//         _showErrorMessage('Login failed. Please check your credentials.');
//       }
//     }  on SocketException {
//       setState(() {
//         _isLoading = false;
//       });
//       print('No Internet connection');
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text(
//           'Unable to login. Please check your internet connection !',
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 14),
//         ),
//         // backgroundColor: Colors.green,
//         behavior: SnackBarBehavior.floating,
//         margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width*0.03),
//         ),
//         duration: Duration(seconds: 3),
//       ));
//
//       // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       //     content: Text(
//       //       'Unable to load leaves. Please check your internet connection.',
//       //       textAlign: TextAlign.center,
//       //     ),
//       //     duration: Duration(seconds: 3),
//       //   ),);
//     } catch(e){
//
//     }
//
//
//   }
//
//   Future<void> _saveToken(String token) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('token', token);
//     print("Token:  ${token}");
//   }
//   Future<void> saveLoginTime() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     int currentTime = DateTime.now().millisecondsSinceEpoch; // Get current time in milliseconds
//     await prefs.setInt('login_timestamp', currentTime);
//   }
//
//   void _showErrorMessage(String message) {
//     setState(() {
//       _errorMessage = message;
//       print(_errorMessage);
//       _errorMessage==null?SizedBox():
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               '$_errorMessage !',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 14),
//             ),
//             backgroundColor: Colors.black,
//             // backgroundColor: Colors.black.withOpacity(0.8),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width*0.2),
//             ),
//             duration: Duration(seconds: 1),
//           ));
//     });
//   }
//
//   void _showSuccessMessage(String message) {
//     setState(() {
//       _errorMessage = message;
//       print(_errorMessage);
//     });
//
//     ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             message,
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 14),
//           ),
//           backgroundColor: Colors.green,
//           behavior: SnackBarBehavior.floating,
//           margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width*0.2),
//           ),
//           duration: Duration(seconds: 1),
//         ));
//
//     // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//     //   content: Text(message),
//     //   backgroundColor: Colors.green,
//     // ));
//
//     // Navigate to the home page (or another screen)
//     // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => navigationPage(initialIndex: 0,)),(route) => false);
//   }
//
//
//
//
//
//
//
//
//
//
//   String errorMessage = "";
//   bool _isNightMode = false;
//   Future<void> _loadSettings() async {
//     final prefs = await SharedPreferences.getInstance();
//     if(mounted)
//       setState(() {
//         _isNightMode = prefs.getBool('isNightMode') ?? false;
//
//       });
//   }
//   // void loginUser(String id, String password) {
//   //   bool userFound = false;
//   //   bool passwordMatch = false;
//   //   for (var user in userData) {
//   //     final userId = user["data"]["user"]["id"].toString();
//   //     final userPassword = user["data"]["user"]["password"];
//   //     if (id == userId) {
//   //       userFound = true;
//   //       if (password == userPassword) {
//   //         passwordMatch = true;
//   //         Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => navigationPage(initialIndex: 0,)),(route) => false);
//   //             setState(() {
//   //               errorMessage = "Logged in successfully";
//   //             });
//   //         break;
//   //       }
//   //     }
//   //   }
//   //   if (!userFound) {
//   //     setState(() {
//   //       errorMessage = "No user found with the given ID";
//   //     });
//   //   }
//   //   else if (!passwordMatch) {
//   //     setState(() {
//   //       errorMessage = "Password doesn't match";
//   //     });
//   //   }
//   // }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _loadSettings();
//     // users=fetchUsers();
//     // users.then((userList) {print(userList);
//     // }).catchError((error) {print("Error: $error");
//     // });
//     // print(users);
//     // someFunction();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _isNightMode?Colors.black: Colors.white,
//       // backgroundColor: colorConst.primaryColor,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding:  EdgeInsets.only(top: MediaQuery.of(context).size.width*0.4),
//             child: Container(
//               color: _isNightMode?Colors.black: Colors.white,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 // crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Container(
//                     height: MediaQuery.of(context).size.width*0.2,
//                     // color: Colors.grey,
//                     child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Text("Login Details",style: TextStyle(
//                             fontSize: 18,
//                           color: _isNightMode?Colors.white: Colors.black,
//                           fontWeight: FontWeight.bold
//                         ),),
//                         Padding(
//                           padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.1,
//                               right: MediaQuery.of(context).size.width*0.1,
//                           bottom: scrWidth*0.03),
//                           child: Text("Please enter your login id and password.",style: TextStyle(
//                               fontSize: 12,
//                               color: _isNightMode?Colors.white: Colors.black,
//                               fontWeight: FontWeight.w400
//                           ),textAlign: TextAlign.center,),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     width: MediaQuery.of(context).size.width*1,
//                     height: MediaQuery.of(context).size.width*0.72,
//                     // color: Colors.grey,
//                     // decoration: BoxDecoration(
//                     //   // color: Colors.grey,
//                     //   image: DecorationImage(image: AssetImage("assets/images/signin2bg.png"),
//                     //     colorFilter: ColorFilter.mode(
//                     //       Colors.white.withOpacity(0.1),
//                     //       BlendMode.dstATop,
//                     //     ),
//                     //       fit: BoxFit.fill,
//                     //       ),
//                     // ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         // SizedBox(height: 15,),
//                         Padding(
//                           padding: const EdgeInsets.only(top: 45),
//                           child: Container(
//                             width: MediaQuery.of(context).size.width*0.85,
//                             height: MediaQuery.of(context).size.width*0.11,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.03),
//                               // border: Border.all(color: Colors.black),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.2),
//                                   blurRadius: 10,
//                                   offset: Offset(0, 5),
//                                 ),
//                               ],
//                             ),
//                             child: TextFormField(
//                               controller:loginidController ,
//                               style: TextStyle(color: Colors.black,
//                                   fontSize: scrWidth*0.04,
//                                   fontWeight: FontWeight.w400),
//                               keyboardType: TextInputType.text,
//                               textCapitalization: TextCapitalization.words,
//                               textInputAction: TextInputAction.next,
//                               cursorColor: Colors.grey,
//                               decoration: InputDecoration(
//                                   filled: true,
//                                   fillColor: Colors.white,
//                                   contentPadding: EdgeInsets.all(10),
//                                   hintText:"Email/phone",
//                                   hintStyle: TextStyle(
//                                       color: Colors.grey,
//                                       fontWeight: FontWeight.w300,
//                                       fontSize: scrWidth*0.034
//                                   ),
//                                   // border: UnderlineInputBorder(
//                                   //   borderSide: BorderSide(
//                                   //     color: Colors.grey
//                                   //   )
//                                   // ),
//
//                                   // border: OutlineInputBorder(
//                                   //   borderSide: BorderSide(color: Colors.black),
//                                   // ),
//
//                                   enabledBorder: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.03),
//                                       borderSide: BorderSide(color: Colors.grey.shade400)
//                                   ),
//
//                                   focusedBorder: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.03),
//                                       // borderSide: BorderSide(color: Colors.black)
//                                       borderSide: BorderSide(
//                                         color: colorConst.primaryColor1,
//                                           // color: colorConst.primaryColor,
//                                       )
//                                   ),
//                             ),
//                           ),
//                           ),
//                         ),
//                         Container(
//                           width: MediaQuery.of(context).size.width*0.85,
//                           height: MediaQuery.of(context).size.width*0.11,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.03),
//                             // border: Border.all(color: Colors.black),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.2),
//                                 blurRadius: 10,
//                                 offset: Offset(0, 5),
//                               ),
//                             ],
//                           ),
//                           child: TextFormField(
//                             controller:passwordController ,
//                             style: TextStyle(color: Colors.black,
//                                 fontSize: scrWidth*0.04,
//                                 fontWeight: FontWeight.w400),
//                             keyboardType: TextInputType.text,
//                             obscureText:hide? true:false,
//                             textCapitalization: TextCapitalization.words,
//                             textInputAction: TextInputAction.done,
//                             cursorColor: Colors.grey,
//                             decoration: InputDecoration(
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 contentPadding: EdgeInsets.all(10),
//                                 suffixIcon: InkWell(
//                                     onTap: () {
//                                       hide=!hide;
//                                       setState(() {
//
//                                       });
//                                     },
//                                     child: Icon(hide?Icons.visibility_off_outlined:Icons.visibility_outlined,size: 18,)),
//                                 hintText:"Password",
//                                 hintStyle: TextStyle(
//                                     color: Colors.grey,
//                                     fontWeight: FontWeight.w300,
//                                     fontSize: scrWidth*0.034
//                                 ),
//                                 // border: UnderlineInputBorder(
//                                 //   borderSide: BorderSide(
//                                 //     color: Colors.grey
//                                 //   )
//                                 // ),
//
//                                 // border: OutlineInputBorder(
//                                   // borderSide: BorderSide(color: Colors.black),
//                                 // ),
//                                 enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.03),
//                               borderSide: BorderSide(color: Colors.grey.shade400)
//                           ),
//
//                           focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.03),
//                               // borderSide: BorderSide(color: Colors.black)
//                               borderSide: BorderSide(
//                                 color: colorConst.primaryColor1,
//                                   // color: colorConst.primaryColor
//                               )
//                           ),
//                           ),
//                         ),
//                         ),
//                         SizedBox(
//                           width: MediaQuery.of(context).size.width*0.89,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               Center(
//                                 child: Checkbox(
//                                   value: remember,
//                                   onChanged: (value) {
//                                     setState(() {
//                                       remember=value!;
//                                     });
//                                   },
//                                   shape: RoundedRectangleBorder(
//                                     side: BorderSide(
//                                       color:  Colors.grey.shade200
//                                     ),
//                                       borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width*0.018)),
//                                   activeColor: colorConst.primaryColor1,
//                                   // activeColor: colorConst.primaryColor,
//                                 ),
//
//                               ),
//                               InkWell(
//                                 onTap: () {
//                                   setState(() {
//                                     remember=!remember;
//                                   });
//                                 },
//                                   child: Text("Remember me",style: TextStyle(
//                                     color: _isNightMode?Colors.white: Colors.black,
//                                       fontSize: scrWidth*0.035,
//                                       fontWeight: FontWeight.w300),)
//                               ),
//                             ],
//
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: MediaQuery.of(context).size.width*0.1,),
//                   Container(
//                     color: _isNightMode?Colors.black: Colors.white,
//                     child: _isLoading
//                         ? CircularProgressIndicator()
//                         : InkWell(
//                       onTap: () {
//                         if(loginidController.text.isNotEmpty&&passwordController.text.isNotEmpty){
//                           // _login();
//                           // loginUser(loginidController.text, passwordController.text);
//                           // print("kmkmkk $errorMessage");
//                           // print("msgmsg $_errorMessage");
//
//                           // loginUser(loginidController.text, passwordController.text);
//                           Navigator.push(context, MaterialPageRoute(builder: (context) => navigationPage(initialIndex: 0),));
//                         }else{
//                           loginidController.text==''? ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                             content: Text(
//                               'Please enter Email/Phone !',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(fontSize: 14),
//                             ),
//                             backgroundColor: Colors.black,
//                             // backgroundColor: Colors.black.withOpacity(0.8),
//                             behavior: SnackBarBehavior.floating,
//                             margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width*0.2),
//                             ),
//                             duration: Duration(seconds: 1),
//                           ))
//                               : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                             content: Text(
//                               'Please enter Password !',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(fontSize: 14),
//                             ),
//                             backgroundColor: Colors.black,
//                             // backgroundColor: Colors.black.withOpacity(0.8),
//                             behavior: SnackBarBehavior.floating,
//                             margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width*0.2),
//                             ),
//                             duration: Duration(seconds: 2),
//                           ));
//                         }
//                       },
//                       child: Container(
//                         width: MediaQuery.of(context).size.width*0.5,
//                         constraints: BoxConstraints(minWidth: 130, minHeight: 50),
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           color: colorConst.primaryColor1,
//                           borderRadius: BorderRadius.circular(30.0),
//                           // gradient: LinearGradient(
//                           //   colors: [
//                           //     colorConst.primaryColor1,
//                           //     colorConst.primaryColor2,
//                           //   ],
//                           //   begin: Alignment.topLeft,
//                           //   end: Alignment.bottomRight,
//                           // ),
//                         ),
//                         child: Text(
//                           'Login',
//                           style: TextStyle(
//                             fontSize: 17,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: MediaQuery.of(context).size.width*0.15,),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text("Don't have an account?",
//                         style: TextStyle(
//                             fontSize: scrWidth*0.033,
//                             fontWeight: FontWeight.w400,
//                             color: Colors.black
//
//                         ),),
//                       InkWell(
//                         onTap: (){
//                           // Navigator.push(context, MaterialPageRoute(builder: (context) => infoPage(path: '',),));
//                         },
//                         child: Text("  Sign up",
//                           style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: scrWidth*0.038,
//                               color: colorConst.primaryColor1
//                           ),),
//                       )
//                     ],),
//
//                   SizedBox()
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
