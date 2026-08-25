import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String baseUrl = 'http://192.168.1.35/smt_mail';
  static const String jobesBaseUrl = 'https://user.jobes24x7.com/api';
  static const String messageCentralBaseUrl = 'https://cpaas.messagecentral.com/verification/v3';
  static const String manageLoginBaseUrl = 'https://managelogin.jobes24x7.com/api';
  static const String authToken = 'YOUR_AUTH_TOKEN'; // Replace with actual token
  static const String customerId = 'YOUR_CUSTOMER_ID'; // Replace with actual ID

  // --- Session Management (from UserService) ---

  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', value);
  }

  Future<void> saveUserData(String name, String email, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    await prefs.setString('phone', phone);
  }

  Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('name') ?? '',
      'email': prefs.getString('email') ?? '',
      'phone': prefs.getString('phone') ?? '',
    };
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> setRegistrationIncomplete(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('registrationIncomplete', value);
  }

  Future<bool> isRegistrationIncomplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('registrationIncomplete') ?? false;
  }

  Future<void> clearRegistrationIncomplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('registrationIncomplete');
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    // Check all possible keys used across the app for consistency
    return prefs.getString('auth_token') ?? 
           prefs.getString('token') ?? 
           prefs.getString('authToken') ?? 
           prefs.getString('access_token');
  }

  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('token', token);
    await prefs.setString('authToken', token);
    await prefs.setString('access_token', token);
  }

  // --- Phone OTP Service (from OtpService) ---

  Future<Map<String, dynamic>> sendOtp(String mobileNumber) async {
    final url = Uri.parse('$messageCentralBaseUrl/sendOtp?countryCode=91&mobileNumber=$mobileNumber&customerId=$customerId');
    try {
      final response = await http.post(url, headers: {'authToken': authToken});
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> validateOtp(String mobileNumber, String otpCode, String verificationId) async {
    final url = Uri.parse('$messageCentralBaseUrl/validateOtp?countryCode=91&mobileNumber=$mobileNumber&verificationId=$verificationId&code=$otpCode&customerId=$customerId');
    try {
      final response = await http.get(url, headers: {'authToken': authToken});
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // --- Email OTP Service (from EmailService) ---

  Future<Map<String, dynamic>> sendEmailOtp(String email) async {
    final url = Uri.parse('$baseUrl/send_otp.php');
    try {
      final response = await http.post(url, body: {'email': email});
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> validateEmailOtp(String email, String otp) async {
    final url = Uri.parse('$baseUrl/verify_otp.php');
    try {
      final response = await http.post(url, body: {'email': email, 'otp': otp});
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // --- Categories API ---
  Future<Map<String, dynamic>> getCategories() async {
    final url = Uri.parse('https://user.jobes24x7.com/api/outsideapis/categories');
    try {
      final response = await http.get(url);
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // --- Backend User Registration (Secondary API) ---

  Future<Map<String, dynamic>> loginBackend(String phone) async {
    final url = Uri.parse('$baseUrl/login.php');
    try {
      final response = await http.post(url, body: {'phone': phone});
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // --- Business Registration API (Jobes24x7) ---

  Future<Map<String, dynamic>> createBusinessUser({
    required String userMainId,
    required String panNumber,
    required String gender,
    required String addressDocType,
    required String addressType,
    required String selectedAddressType,
    required String area,
    required String bankAccountNumber,
    required String bankDocumentType,
    required String buildingName,
    required String country,
    required String district,
    required String doorNumber,
    required String landmark,
    required String pincode,
    required String state,
    required String streetName,
    Uint8List? addressProofBytes,
    String addressProofFileName = 'address.jpg',
    Uint8List? bankDocumentBytes,
    String bankDocumentFileName = 'bank.jpg',
    Uint8List? panFrontPhotoBytes,
    String panFrontPhotoFileName = 'pan.jpg',
    Uint8List? profilePhotoBytes,
    String profilePhotoFileName = 'profile.jpg',
  }) async {
    final token = await getAuthToken();
    final url = Uri.parse('$jobesBaseUrl/business-reg/create');

    try {
      Map<String, dynamic> body = {
        'user_main_id': userMainId,
        'pan_number': panNumber,
        'gender': gender,
        'address_doc_type': addressDocType,
        'address_type': addressType,
        'selected_address_type': selectedAddressType,
        'area': area,
        'bank_account_number': bankAccountNumber,
        'bank_document_type': bankDocumentType,
        'building_name': buildingName,
        'country': country,
        'district': district,
        'door_number': doorNumber,
        'landmark': landmark,
        'pincode': pincode,
        'state': state,
        'street_name': streetName,
      };

      if (addressProofBytes != null) {
        final compressed = await _compressImageBytes(addressProofBytes, addressProofFileName);
        body['address_proof'] = _toBase64DataUrl(compressed, addressProofFileName);
      }
      if (bankDocumentBytes != null) {
        final compressed = await _compressImageBytes(bankDocumentBytes, bankDocumentFileName);
        body['bank_document'] = _toBase64DataUrl(compressed, bankDocumentFileName);
      }
      if (panFrontPhotoBytes != null) {
        final compressed = await _compressImageBytes(panFrontPhotoBytes, panFrontPhotoFileName);
        body['pan_front_photo'] = _toBase64DataUrl(compressed, panFrontPhotoFileName);
      }
      if (profilePhotoBytes != null) {
        final compressed = await _compressImageBytes(profilePhotoBytes, profilePhotoFileName);
        body['profile_photo'] = _toBase64DataUrl(compressed, profilePhotoFileName);
      }

      final response = await http.post(
        url,
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      debugPrint('[ApiService] createBusinessUser response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
      } else {
        try {
          final decoded = json.decode(response.body);
          final message = decoded['data']?['message'] ?? decoded['message'] ?? 'Server error: ${response.statusCode}';
          return {'status': 'error', 'message': message, 'body': response.body};
        } catch (_) {
          return {'status': 'error', 'message': 'Server error: ${response.statusCode}', 'body': response.body};
        }
      }
    } catch (e) {
      debugPrint('[ApiService] createBusinessUser error: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // --- Business Creation API (Jobes24x7) ---

  /// Creates a new business via multipart POST to:
  /// POST https://user.jobes24x7.com/api/business-cre/create
  ///
  /// [userMainId]      - Logged-in user's phone/ID (user_main_id)
  /// [type]            - 'supplier' | 'partner' | 'propagator'
  /// [companyTier]     - e.g. 'Startup'
  /// [businessName]    - Business name
  /// [businessEmail]   - Business email
  /// [businessPhone]   - Business phone
  /// [website]         - Website URL
  /// [sector]          - e.g. 'Electronics'
  /// [sectorTitle]     - e.g. 'Product'
  /// [subSector]       - e.g. 'Mobile Phones'
  /// [primaryCategories] - JSON string e.g. '[{"id":213,"name":"Mobile Phone Spares"}]'
  /// [businessTypes]   - JSON string e.g. '["Trade","Export"]'
  /// [turnoverRange]   - e.g. '20L-50L'
  /// [employeeCount]   - e.g. '11-50'
  /// [doorNumber], [streetName], [buildingName], [landmark],
  /// [area], [district], [pincode], [state], [country]
  /// [latitude], [longitude]
  /// [panNumber], [gstNumber], [currentAccountNumber]
  /// [bankDocumentType]  - 'statement' | 'cheque'
  /// [yearOfEstablishment]
  /// [companyLogoBytes]  - Logo image bytes (nullable)
  /// [companyLogoFileName]
  /// [signImageBytes]    - Signature image bytes (nullable)
  /// [signImageFileName]
  /// [panCardPhotoBytes] - PAN card image bytes (nullable)
  /// [panCardPhotoFileName]
  /// [gstCertificateBytes] - GST certificate bytes (nullable)
  /// [gstCertificateFileName]
  /// [bankDocumentBytes] - Bank document bytes (nullable)
  /// [bankDocumentFileName]
  Future<Map<String, dynamic>> createBusiness({
    required String userMainId,
    required String type,
    String companyTier = 'STARTUP',
    required String businessName,
    required String businessEmail,
    required String businessPhone,
    String website = '',
    String sector = '',
    String sectorTitle = '',
    String subSector = '',
    String primaryCategories = '[]',
    String subCategories = '[]',
    String businessTypes = '[]',
    String serviceSectors = '[]',
    String turnoverRange = '',
    String employeeCount = '',
    String doorNumber = '',
    String streetName = '',
    String buildingName = '',
    String landmark = '',
    String area = '',
    String district = '',
    String pincode = '',
    String state = '',
    String country = 'India',
    String latitude = '',
    String longitude = '',
    String panNumber = '',
    String gstNumber = '',
    String currentAccountNumber = '',
    String bankDocumentType = 'statement',
    String? yearOfEstablishment,
    // --- File fields ---
    Uint8List? companyLogoBytes,
    String companyLogoFileName = 'logo.jpg',
    Uint8List? signImageBytes,
    String signImageFileName = 'signature.jpg',
    Uint8List? panCardPhotoBytes,
    String panCardPhotoFileName = 'pan.jpg',
    Uint8List? gstCertificateBytes,
    String gstCertificateFileName = 'gst.pdf',
    Uint8List? bankDocumentBytes,
    String bankDocumentFileName = 'bank.pdf',
    String? partnerCount,
    String? partnersData,
    String? businessId,
    // Partner specific
    String? partName,
    String? partPan,
    String? partEmail,
    String? partPhone,
    String? partners,
    Uint8List? partnershipDealBytes,
    String partnershipDealFileName = 'deal.pdf',
    Uint8List? writtenLetterBytes,
    String writtenLetterFileName = 'letter.pdf',
  }) async {
    final token = await getAuthToken();
    final url = businessId != null
        ? Uri.parse('$jobesBaseUrl/business-cre/update/$businessId')
        : Uri.parse('$jobesBaseUrl/business-cre/create');

    debugPrint('[ApiService] createBusiness → $url');
    debugPrint('[ApiService] token: ${token != null && token.length > 30 ? token.substring(0, 30) + "..." : token ?? "NULL"}');
    debugPrint('[ApiService] userMainId=$userMainId  type=$type  businessName=$businessName');

    try {
      Map<String, dynamic> body = {
        'user_main_id': userMainId,
        'type': type,
        'company_tier': companyTier,
        'business_name': businessName,
        'business_email': businessEmail,
        'business_phone': businessPhone,
        'website': website,
        'sector': sector,
        'sector_title': sectorTitle,
        'sub_sector': subSector,
        'primary_categories': primaryCategories.isNotEmpty ? jsonDecode(primaryCategories) : [],
        'sub_categories': subCategories.isNotEmpty ? jsonDecode(subCategories) : [],
        'business_types': businessTypes, // Server expects this as a string, e.g. "[]"
        'service_sectors': serviceSectors,
        'turnover_range': turnoverRange,
        'employee_count': employeeCount,
        'door_number': doorNumber,
        'street_name': streetName,
        'building_name': buildingName,
        'landmark': landmark,
        'area': area,
        'district': district,
        'pincode': pincode,
        'state': state,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
        'pan_number': panNumber,
        'gst_number': gstNumber,
        'current_account_number': currentAccountNumber,
        'bank_document_type': bankDocumentType,
        'bank_document': null,
        'company_logo': null,
        'sign_image': null,
        'pan_card_photo': null,
        'gst_certificate': null,
      };

      if (yearOfEstablishment != null && yearOfEstablishment.isNotEmpty) {
        body['year_of_establishment'] = yearOfEstablishment;
      }

      if (partnerCount != null) body['partner_count'] = partnerCount;
      if (partnersData != null) {
        try {
          body['partners_data'] = jsonDecode(partnersData);
        } catch (e) {
          body['partners_data'] = partnersData; // fallback
        }
      }

      // Partner specific API fields
      if (partName != null) body['part_name'] = partName;
      if (partPan != null) body['part_pan'] = partPan;
      if (partEmail != null) body['part_email'] = partEmail;
      if (partPhone != null) body['part_phone'] = partPhone;
      if (partners != null) body['partners'] = partners;

      // File fields - compress first, then send as base64 data URL strings
      if (companyLogoBytes != null) {
        final compressed = await _compressImageBytes(companyLogoBytes, companyLogoFileName);
        body['company_logo'] = _toBase64DataUrl(compressed, companyLogoFileName);
        debugPrint('[ApiService] company_logo compressed: ${compressed.length} bytes');
      }
      if (signImageBytes != null) {
        final compressed = await _compressImageBytes(signImageBytes, signImageFileName);
        body['sign_image'] = _toBase64DataUrl(compressed, signImageFileName);
        debugPrint('[ApiService] sign_image compressed: ${compressed.length} bytes');
      }
      if (panCardPhotoBytes != null) {
        final compressed = await _compressImageBytes(panCardPhotoBytes, panCardPhotoFileName);
        body['pan_card_photo'] = _toBase64DataUrl(compressed, panCardPhotoFileName);
        debugPrint('[ApiService] pan_card_photo compressed: ${compressed.length} bytes');
      }
      if (gstCertificateBytes != null) {
        final compressed = await _compressImageBytes(gstCertificateBytes, gstCertificateFileName);
        body['gst_certificate'] = _toBase64DataUrl(compressed, gstCertificateFileName);
        debugPrint('[ApiService] gst_certificate compressed: ${compressed.length} bytes');
      }
      if (bankDocumentBytes != null) {
        final compressed = await _compressImageBytes(bankDocumentBytes, bankDocumentFileName);
        body['bank_document'] = _toBase64DataUrl(compressed, bankDocumentFileName);
        debugPrint('[ApiService] bank_document compressed: ${compressed.length} bytes');
      }
      if (partnershipDealBytes != null) {
        final compressed = await _compressImageBytes(partnershipDealBytes, partnershipDealFileName);
        body['partnership_deal'] = _toBase64DataUrl(compressed, partnershipDealFileName);
        debugPrint('[ApiService] partnership_deal compressed: ${compressed.length} bytes');
      }
      if (writtenLetterBytes != null) {
        final compressed = await _compressImageBytes(writtenLetterBytes, writtenLetterFileName);
        body['written_letter'] = _toBase64DataUrl(compressed, writtenLetterFileName);
        debugPrint('[ApiService] written_letter compressed: ${compressed.length} bytes');
      }

      http.Response response;
      final headers = {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (businessId != null) {
        response = await http.put(
          url,
          headers: headers,
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 30));
      } else {
        response = await http.post(
          url,
          headers: headers,
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 30));
      }

      debugPrint('[ApiService] Response status: ${response.statusCode}');
      final responseBody = response.body;
      debugPrint('[ApiService] Response body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(responseBody);
        return decoded is Map<String, dynamic>
            ? decoded
            : {'data': decoded};
      } else {
        debugPrint('[ApiService] ❌ Server error: ${response.statusCode}');
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
          'body': responseBody,
        };
      }
    } on TimeoutException catch (e) {
      debugPrint('[ApiService] ⏱️ Timeout: $e');
      return {'status': 'error', 'message': 'Request timed out. Check internet and try again.'};
    } catch (e, stack) {
      debugPrint('[ApiService] Exception: $e');
      debugPrint('[ApiService] Stack: $stack');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // --- Fetch Businesses ---
  Future<Map<String, dynamic>> getBusinessRegUser(String userMainId) async {
    final token = await getAuthToken();
    final url = Uri.parse('$manageLoginBaseUrl/business-reg/user/$userMainId');
    try {
      final response = await http.get(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        debugPrint('[ApiService] getBusinessRegUser: $decoded');
        return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
      } else {
        return {'status': 'error', 'message': 'Failed to fetch business reg: ${response.statusCode}'};
      }
    } catch (e) {
      debugPrint('[ApiService] getBusinessRegUser error: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // --- Fetch Employee Details ---
  Future<Map<String, dynamic>> getEmployeeDetails(String userMainId) async {
    final token = await getAuthToken();
    final url = Uri.parse('$manageLoginBaseUrl/employee/main/$userMainId');
    try {
      final response = await http.get(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        debugPrint('[ApiService] getEmployeeDetails: $decoded');
        return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
      } else {
        return {'status': 'error', 'message': 'Failed to fetch employee: ${response.statusCode}'};
      }
    } catch (e) {
      debugPrint('[ApiService] getEmployeeDetails error: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getBusinesses(String userMainId) async {
    final token = await getAuthToken();
    final url = Uri.parse('$jobesBaseUrl/business-cre/main/$userMainId');
    try {
      final response = await http.get(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        debugPrint('[ApiService] getBusinesses: $decoded');
        if (decoded is List) {
          return {'data': decoded};
        }
        return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
      } else {
        return {'status': 'error', 'message': 'Failed to fetch businesses: ${response.statusCode}'};
      }
    } catch (e) {
      debugPrint('[ApiService] getBusinesses error: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // --- Delete Business ---
  Future<Map<String, dynamic>> deleteBusiness(String businessId) async {
    final token = await getAuthToken();
    final url = Uri.parse('$jobesBaseUrl/business-cre/delete/$businessId');
    try {
      final response = await http.delete(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {'status': 'error', 'message': 'Failed to delete business: ${response.statusCode}'};
      }
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// Fetches all categories from the outsideapis
  Future<Map<String, dynamic>> fetchCategories() async {
    final url = Uri.parse('https://user.jobes24x7.com/api/outsideapis/categories');
    print('[ApiService] fetchCategories called: $url');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print('[ApiService] fetchCategories success. Data length: ${decoded['data']?.length}');
        return decoded;
      } else {
        print('[ApiService] fetchCategories failed with status: ${response.statusCode}');
        return {'status': 'error', 'message': 'Failed to load categories: ${response.statusCode}'};
      }
    } catch (e) {
      print('[ApiService] fetchCategories error: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// Compresses image bytes to reduce size before uploading.
  /// PDFs are returned as-is. Images are resized to max 800x800 at 70% quality.
  static Future<Uint8List> _compressImageBytes(Uint8List bytes, String fileName) async {
    final ext = fileName.split('.').last.toLowerCase();
    if (ext == 'pdf') return bytes; // Don't compress PDFs
    try {
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: 800,
        minHeight: 800,
        quality: 70,
        format: CompressFormat.jpeg,
      );
      debugPrint('[ApiService] Compressed ${bytes.length} → ${result.length} bytes');
      return result;
    } catch (e) {
      debugPrint('[ApiService] Compression failed, using original: $e');
      return bytes;
    }
  }

  /// Converts file bytes to a base64 data URL string.
  /// e.g. "data:image/jpeg;base64,/9j/4AAQ..."
  static String _toBase64DataUrl(Uint8List bytes, String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    final mime = (ext == 'pdf')
        ? 'application/pdf'
        : (ext == 'png')
            ? 'image/png'
            : 'image/jpeg';
    return 'data:$mime;base64,${base64Encode(bytes)}';
  }
  // --- Store Configuration APIs ---

  Future<List<dynamic>> getStorePaymentGateways() async {
    final url = Uri.parse('$manageLoginBaseUrl/store-payment-gateways');
    try {
      final String? token = await getAuthToken();
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        debugPrint('Failed to get payment gateways: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error getting payment gateways: $e');
    }
    return [];
  }

  Future<List<dynamic>> getStoreSupportedLanguages() async {
    final url = Uri.parse('$manageLoginBaseUrl/store-supported-languages');
    try {
      final String? token = await getAuthToken();
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'] ?? [];
        }
      } else {
        debugPrint('Failed to get supported languages: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error getting supported languages: $e');
    }
    return [];
  }

  Future<bool> saveStoreOpeningClosingTime(Map<String, dynamic> payload) async {
    final url = Uri.parse('$manageLoginBaseUrl/store-opening-closing-time');
    debugPrint('=== POST API REQUEST: $url ===');
    debugPrint('Payload: ${json.encode(payload)}');
    try {
      final String? token = await getAuthToken();
      final response = await http.post(url, headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      }, body: json.encode(payload));
      
      debugPrint('=== API RESPONSE [${response.statusCode}] ===');
      debugPrint('Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      debugPrint('Error saving opening/closing time: $e');
    }
    return false;
  }

  Future<bool> createStorePaymentGateway(Map<String, dynamic> payload) async {
    final url = Uri.parse('$manageLoginBaseUrl/store-payment-gateways');
    debugPrint('=== POST API REQUEST: $url ===');
    debugPrint('Payload: ${json.encode(payload)}');
    try {
      final String? token = await getAuthToken();
      final response = await http.post(url, headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      }, body: json.encode(payload));
      
      debugPrint('=== API RESPONSE [${response.statusCode}] ===');
      debugPrint('Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      debugPrint('Error creating payment gateway: $e');
    }
    return false;
  }

  Future<bool> createStoreSupportedLanguage(Map<String, dynamic> payload) async {
    final url = Uri.parse('$manageLoginBaseUrl/store-supported-languages');
    debugPrint('=== POST API REQUEST: $url ===');
    debugPrint('Payload: ${json.encode(payload)}');
    try {
      final String? token = await getAuthToken();
      final response = await http.post(url, headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      }, body: json.encode(payload));
      
      debugPrint('=== API RESPONSE [${response.statusCode}] ===');
      debugPrint('Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      debugPrint('Error creating supported language: $e');
    }
    return false;
  }
}
