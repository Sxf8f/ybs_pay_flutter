import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ybs_pay/main.dart';
import '../core/const/assets_const.dart';
import '../core/const/color_const.dart';
import '../core/models/authModels/userModel.dart';
import 'confirmStatus/confirmStatusScreen.dart';

class RechargePage extends StatefulWidget {
  final LayoutModel layout;

  const RechargePage({super.key, required this.layout});

  @override
  State<RechargePage> createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  Map<String, TextEditingController> extraFieldControllers = {};
  bool isLoading = false;

  List<dynamic> operatorList = [];
  int? selectedOperator;
  bool isFetchingOperator = false;

  // Bill information state
  BillInfo? billInfo;
  bool isBillFetched = false;

  // DTH specific state
  DthInfo? dthInfo;
  DthPlans? dthPlans;
  bool isDthInfoFetched = false;
  bool isDthPlansFetched = false;
  bool isDthHeavyRefreshLoading = false;
  String? selectedPlanAmount;

  @override
  void initState() {
    super.initState();

    // Auto operator detection listener
    mobileController.addListener(() {
      if (mobileController.text.length == 10 &&
          widget.layout.autoOperator?.enabled == true) {
        fetchAutoOperator();
      }
    });

    // Pre-fetch dropdown operators if enabled
    if (widget.layout.operatorDropdown?.enabled == true) {
      fetchOperatorDropdown();
    }

    // Initialize extra field controllers
    if (widget.layout.fields != null) {
      for (var field in widget.layout.fields!) {
        final name = field['name'] ?? '';
        extraFieldControllers[name] = TextEditingController();
      }
    }
  }

  Future<void> fetchOperatorDropdown() async {
    print('11a');
    try {
      final endpoint = widget.layout.operatorDropdown?.endpoint ?? "";
      print(widget.layout.operatorDropdown?.endpoint);
      print(endpoint);
      if (endpoint.isEmpty) return;
      print('121a');

      final url = Uri.parse(
        "${AssetsConst.apiBase}$endpoint".replaceAll(
          "{OPERATORTYPEID}",
          widget.layout.operatorTypeId.toString(),
        ),
      );

      print(url);
      print(widget.layout.operatorTypeId.toString());

      // Get stored access token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        debugPrint("No access token found for operator dropdown");
        return;
      }

      // Add Authorization header
      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };

      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          operatorList = data['operators'] ?? [];
        });
      }
    } catch (e) {
      print('223');
      debugPrint("Dropdown error: $e");
    }
  }

  Future<void> fetchAutoOperator() async {
    try {
      setState(() => isFetchingOperator = true);
      final endpoint = widget.layout.autoOperator?.endpoint ?? "";
      if (endpoint.isEmpty) return;

      final url = Uri.parse(
        "${AssetsConst.apiBase}$endpoint".replaceAll(
          "{MOBILE}",
          mobileController.text,
        ),
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['OperatorID'] != null) {
          final opId = (data['OperatorID'] is String)
              ? int.tryParse(data['OperatorID']) ?? data['OperatorID']
              : data['OperatorID'];
          setState(() {
            // set numeric id if possible
            if (opId is int)
              selectedOperator = opId;
            else
              selectedOperator = int.tryParse(opId.toString());
          });
        }
      }
    } catch (e) {
      debugPrint("Auto operator error: $e");
    } finally {
      setState(() => isFetchingOperator = false);
    }
  }

  Future<void> performBooking() async {
    if (widget.layout.bookingEndpoint.isEmpty) return;

    final mobile = mobileController.text.trim();
    final amount = amountController.text.trim();

    if (mobile.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid mobile and amount")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login expired. Please log in again.")),
        );
        return;
      }

      final url = Uri.parse(
        "${AssetsConst.apiBase}${widget.layout.bookingEndpoint}",
      );
      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };
      final body = {
        "mobile": mobile,
        "amount": amount,
        "operator":
            selectedOperator?.toString() ??
            widget.layout.operatorTypeId.toString(),
      };

      extraFieldControllers.forEach((key, controller) {
        body[key] = controller.text;
      });

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      final data = json.decode(response.body);
      print(data);

      if (response.statusCode == 200 && data['success'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => confirmStatus(amount: amount),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Booking failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> performRequest() async {
    if (widget.layout.requestEndpoint.isEmpty) return;

    final mobile = mobileController.text.trim();
    final amount = amountController.text.trim();

    if (mobile.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid mobile and amount")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login expired. Please log in again.")),
        );
        return;
      }

      final url = Uri.parse(
        "${AssetsConst.apiBase}${widget.layout.requestEndpoint}",
      );
      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };
      final body = {
        "mobile": mobile,
        "amount": amount,
        "operator":
            selectedOperator?.toString() ??
            widget.layout.operatorTypeId.toString(),
      };

      extraFieldControllers.forEach((key, controller) {
        body[key] = controller.text;
      });

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      final data = json.decode(response.body);
      print(data);

      if (response.statusCode == 200 && data['success'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => confirmStatus(amount: amount),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Request failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> performRecharge() async {
    if (widget.layout.paymentEndpoint.isEmpty) return;

    final mobile = mobileController.text.trim();
    final amount = amountController.text.trim();

    if (mobile.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid mobile and amount")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 🔹 Get stored access token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login expired. Please log in again.")),
        );
        return;
      }

      final url = Uri.parse(
        "${AssetsConst.apiBase}${widget.layout.paymentEndpoint}",
      );
      // 🔹 Add Authorization header
      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };
      final body = {
        "mobile": mobile,
        "amount": amount,
        "operator":
            selectedOperator?.toString() ??
            widget.layout.operatorTypeId.toString(),
      };

      // Add extra fields
      extraFieldControllers.forEach((key, controller) {
        body[key] = controller.text;
      });

      // final response = await http.post(url, body: body);
      // final response = await http.post(url, body: body, headers: headers);

      // 🔹 Send POST request (encode as JSON)
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body), // ✅ convert map → JSON string
      );

      final data = json.decode(response.body);
      print(data);

      // Check if payment was successful
      if (response.statusCode == 200 && data['success'] == true) {
        // Navigate to success screen with amount
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => confirmStatus(amount: amount),
          ),
        );
      } else {
        // Show error message for failed payment
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Payment failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchBill() async {
    if (widget.layout.fetchBillEndpoint.isEmpty) return;

    final mobile = mobileController.text.trim();
    if (mobile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter mobile to fetch bill")),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      // 🔹 Get stored access token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login expired. Please log in again.")),
        );
        return;
      }

      // 🔹 Build API URL
      String url = "${AssetsConst.apiBase}${widget.layout.fetchBillEndpoint}";
      url = url
          .replaceAll("{MOBILE}", mobile)
          .replaceAll(
            "{OPERATOR}",
            selectedOperator?.toString() ??
                widget.layout.operatorTypeId.toString(),
          );

      // 🔹 Add Authorization header
      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };

      // 🔹 Call API
      final resp = await http.get(Uri.parse(url), headers: headers);
      final data = json.decode(resp.body);

      // 🔹 Parse bill information
      if (data['success'] == true) {
        setState(() {
          billInfo = BillInfo.fromJson(data);
          isBillFetched = true;
          // Prefill amount field with bill amount
          amountController.text = billInfo!.amount;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bill fetched successfully")),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to fetch bill")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Fetch bill error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchPlans(String url, String label) async {
    try {
      // Get stored access token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login expired. Please log in again.")),
        );
        return;
      }

      // Add Authorization header
      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };

      final resp = await http.get(Uri.parse(url), headers: headers);

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);

        // Handle plans differently based on format
        if (data['records'] != null) {
          setState(() {
            dthPlans = DthPlans.fromJson(data);
            isDthPlansFetched = true;
          });
        } else {
          _showPlansDialog(data, label);
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to load $label")));
      }
    } catch (e) {
      print('ftftft $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load $label")));
    }
  }

  Future<void> fetchDthInfo(String url) async {
    try {
      setState(() => isLoading = true);

      // Get stored access token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login expired. Please log in again.")),
        );
        return;
      }

      // Add Authorization header
      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };

      final resp = await http.get(Uri.parse(url), headers: headers);

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);

        setState(() {
          dthInfo = DthInfo.fromJson(data);
          isDthInfoFetched = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("DTH Info fetched successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch DTH info")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("DTH Info error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> performDthHeavyRefresh(String url) async {
    try {
      setState(() => isDthHeavyRefreshLoading = true);

      // Get stored access token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login expired. Please log in again.")),
        );
        return;
      }

      // Add Authorization header
      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };

      final resp = await http.get(Uri.parse(url), headers: headers);

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final refreshData = DthHeavyRefresh.fromJson(data);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(refreshData.records.desc)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to perform heavy refresh")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Heavy refresh error: $e")));
    } finally {
      setState(() => isDthHeavyRefreshLoading = false);
    }
  }

  void _showPlansDialog(dynamic data, String label) {
    // Normalize plans into either a Map<String, List> (grouped) or List
    final records = data['records'];
    List<Widget> items = [];

    if (records is Map) {
      // grouped records (key -> list)
      records.forEach((group, list) {
        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              group.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
        if (list is List) {
          for (var plan in list) {
            items.add(
              ListTile(
                title: Text("₹${plan['rs'] ?? plan['rs']}"),
                subtitle: Text(plan['desc'] ?? ''),
                onTap: () {
                  amountController.text = plan['rs'].toString();
                  Navigator.pop(context);
                },
              ),
            );
            items.add(const Divider());
          }
        }
      });
    } else if (records is List) {
      for (var plan in records) {
        items.add(
          ListTile(
            title: Text("₹${plan['rs'] ?? plan['rs']}"),
            subtitle: Text(plan['desc'] ?? ''),
            onTap: () {
              amountController.text = plan['rs'].toString();
              Navigator.pop(context);
            },
          ),
        );
        items.add(const Divider());
      }
    } else if (data is List) {
      for (var plan in data) {
        items.add(
          ListTile(
            title: Text("₹${plan['rs'] ?? ''}"),
            subtitle: Text(plan['desc'] ?? ''),
            onTap: () {
              amountController.text = plan['rs'].toString();
              Navigator.pop(context);
            },
          ),
        );
        items.add(const Divider());
      }
    } else {
      // fallback: show whole response
      items.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(const JsonEncoder.withIndent('  ').convert(data)),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(label),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: items.isNotEmpty
              ? ListView(children: items)
              : SingleChildScrollView(
                  child: Text(const JsonEncoder.withIndent('  ').convert(data)),
                ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }

  Widget buildDynamicButtons(List<ButtonModel> buttons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorConst.primaryColor1,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: buttons.map((btn) {
            final label = btn.label;
            final type = btn.type;
            final function = btn.function;

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  String url = "${AssetsConst.apiBase}$function"
                      .replaceAll("{MOBILE}", mobileController.text)
                      .replaceAll(
                        "{OPERATOR}",
                        selectedOperator?.toString() ??
                            widget.layout.operatorTypeName.toString(),
                      );

                  if (type == "fetch" || type == "download") {
                    // Handle DTH-specific buttons
                    if (label.toLowerCase().contains('dth info')) {
                      fetchDthInfo(url);
                    } else if (label.toLowerCase().contains('heavy refresh')) {
                      performDthHeavyRefresh(url);
                    } else {
                      fetchPlans(url, label);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorConst.primaryColor1,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final layout = widget.layout;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios),
        ),
        title: Text(
          layout.operatorTypeName,
          style: TextStyle(
            fontSize: scrWidth * 0.045,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Main Content
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer name display (when bill is fetched)
                  if (billInfo != null &&
                      billInfo!.name.isNotEmpty &&
                      isBillFetched)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person, color: colorConst.primaryColor1),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              billInfo!.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: scrWidth * 0.035,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Mobile number field
                  if (layout.defaultNumber?.enabled == true)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          layout.defaultNumber?.name ?? "Mobile Number",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorConst.primaryColor1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: mobileController,
                          decoration: InputDecoration(
                            hintText:
                                layout.defaultNumber?.hint ??
                                "Enter mobile number",
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            suffixIcon: isFetchingOperator
                                ? const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.phone, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorConst.primaryColor1,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),

                  // Operator dropdown
                  if (layout.operatorDropdown?.enabled == true)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Select Operator",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorConst.primaryColor1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          dropdownColor: Colors.white,
                          isExpanded: true,
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: "Choose operator",
                            hintStyle: TextStyle(
                              fontSize: scrWidth * 0.025,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorConst.primaryColor1,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          value: selectedOperator,
                          items: operatorList.map<DropdownMenuItem<int>>((op) {
                            final id = (op['OperatorID'] is int)
                                ? op['OperatorID'] as int
                                : int.tryParse(op['OperatorID'].toString()) ??
                                      0;
                            return DropdownMenuItem(
                              value: id,
                              child: Text(
                                op['OperatorName'] ??
                                    op['OperatorName_DB'] ??
                                    '',
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedOperator = val;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),

                  // Dynamic amount field
                  if (layout.amount?.enabled == true)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Amount",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorConst.primaryColor1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: amountController,
                          enabled: layout.amount?.editable ?? true,
                          decoration: InputDecoration(
                            hintText: "Enter amount",
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            prefixIcon: const Icon(
                              Icons.currency_rupee,
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorConst.primaryColor1,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),

                  // Bill information display
                  if (billInfo != null && isBillFetched)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.receipt,
                                color: colorConst.primaryColor1,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Bill Information",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: colorConst.primaryColor1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (billInfo!.name.isNotEmpty)
                            _buildInfoRow("Customer", billInfo!.name),
                          if (billInfo!.billNumber.isNotEmpty)
                            _buildInfoRow("Bill Number", billInfo!.billNumber),
                          if (billInfo!.billDate.isNotEmpty)
                            _buildInfoRow("Bill Date", billInfo!.billDate),
                          if (billInfo!.dueDate.isNotEmpty)
                            _buildInfoRow("Due Date", billInfo!.dueDate),
                        ],
                      ),
                    ),

                  // DTH Info display
                  if (dthInfo != null && isDthInfoFetched)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.tv, color: colorConst.primaryColor1),
                              const SizedBox(width: 8),
                              Text(
                                "DTH Info - ${dthInfo!.operator}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: colorConst.primaryColor1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (dthInfo!.records.isNotEmpty)
                            ...dthInfo!.records
                                .map(
                                  (record) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (record.customerName.isNotEmpty)
                                        _buildInfoRow(
                                          "Customer",
                                          record.customerName,
                                        ),
                                      if (record.planName.isNotEmpty)
                                        _buildInfoRow("Plan", record.planName),
                                      if (record.balance.isNotEmpty)
                                        _buildInfoRow(
                                          "Balance",
                                          "₹${record.balance}",
                                        ),
                                      if (record.monthlyRecharge.isNotEmpty)
                                        _buildInfoRow(
                                          "Monthly Recharge",
                                          "₹${record.monthlyRecharge}",
                                        ),
                                      if (record.nextRechargeDate.isNotEmpty)
                                        _buildInfoRow(
                                          "Next Recharge",
                                          record.nextRechargeDate,
                                        ),
                                      if (record.status.isNotEmpty)
                                        _buildInfoRow("Status", record.status),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                )
                                .toList(),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Extra dynamic fields
                  if (layout.fields != null)
                    Column(
                      children: layout.fields!.map((field) {
                        final name = field['name'];
                        final hint = field['hint'] ?? name;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: TextField(
                            controller: extraFieldControllers[name],
                            decoration: InputDecoration(
                              labelText: hint,
                              hintStyle: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 16),

                  // Dynamic Buttons (plans/offers)
                  if (layout.buttons != null && layout.buttons!.isNotEmpty)
                    buildDynamicButtons(layout.buttons!),

                  // Plans Selection (Tabbed UI)
                  if (dthPlans != null && isDthPlansFetched)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Select Plan",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorConst.primaryColor1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: DefaultTabController(
                              length: dthPlans!.records.length,
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                    ),
                                    child: TabBar(
                                      isScrollable: true,
                                      indicatorColor: colorConst.primaryColor1,
                                      labelColor: colorConst.primaryColor1,
                                      unselectedLabelColor: Colors.grey,
                                      labelStyle: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      tabs: dthPlans!.records.keys
                                          .map(
                                            (category) => Tab(text: category),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 300,
                                    child: TabBarView(
                                      children: dthPlans!.records.entries.map((
                                        entry,
                                      ) {
                                        return ListView.builder(
                                          padding: const EdgeInsets.all(8),
                                          itemCount: entry.value.length,
                                          itemBuilder: (context, index) {
                                            final plan = entry.value[index];
                                            final amount = plan.getAmount();
                                            return Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    selectedPlanAmount == amount
                                                    ? colorConst.primaryColor1
                                                          .withOpacity(0.1)
                                                    : Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color:
                                                      selectedPlanAmount ==
                                                          amount
                                                      ? colorConst.primaryColor1
                                                      : Colors.grey.shade200,
                                                  width:
                                                      selectedPlanAmount ==
                                                          amount
                                                      ? 2
                                                      : 1,
                                                ),
                                              ),
                                              child: ListTile(
                                                title: Text(
                                                  plan.planName,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        selectedPlanAmount ==
                                                            amount
                                                        ? colorConst
                                                              .primaryColor1
                                                        : Colors.black87,
                                                  ),
                                                ),
                                                subtitle: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      plan.desc,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                    if (plan.validity != null &&
                                                        plan
                                                            .validity!
                                                            .isNotEmpty)
                                                      Text(
                                                        "Validity: ${plan.validity}",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                trailing: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: colorConst
                                                        .primaryColor1,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    "₹$amount",
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    selectedPlanAmount = amount;
                                                    amountController.text =
                                                        amount;
                                                  });
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        "Selected: ${plan.planName} - ₹$amount",
                                                      ),
                                                      backgroundColor:
                                                          colorConst
                                                              .primaryColor1,
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Fetch Bill + Pay logic: if fetchBillButton show both fetch and pay; else show pay/booking/request based on flags
                  if (layout.fetchBillButton)
                    Column(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: isLoading ? null : fetchBill,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    "Fetch Bill",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                        // Show Pay button only after bill is fetched
                        if (isBillFetched)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: isLoading ? null : performRecharge,
                              icon: const Icon(Icons.flash_on),
                              label: const Text("Pay Now"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorConst.primaryColor1,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                      ],
                    )
                  else ...[
                    if (layout.paymentButton)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : performRecharge,
                          icon: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                          label: const Text("Pay"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorConst.primaryColor1,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    if (layout.bookingButton)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : performBooking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorConst.primaryColor2,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Booking",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    if (layout.requestButton)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : performRequest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Request",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
