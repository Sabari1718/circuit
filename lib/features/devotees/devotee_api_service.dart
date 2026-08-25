import 'dart:convert';
import 'package:http/http.dart' as http;

class Community {
  final int id;
  final String nameTamil;
  final String nameEnglish;

  Community({required this.id, required this.nameTamil, required this.nameEnglish});

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'],
      nameTamil: json['community_name_tamil'] ?? '',
      nameEnglish: json['community_name_english'] ?? '',
    );
  }
}

class SubCommunity {
  final int id;
  final int communityId;
  final String nameTamil;
  final String nameEnglish;

  SubCommunity({
    required this.id,
    required this.communityId,
    required this.nameTamil,
    required this.nameEnglish,
  });

  factory SubCommunity.fromJson(Map<String, dynamic> json) {
    return SubCommunity(
      id: json['id'],
      communityId: json['community_id'],
      nameTamil: json['sub_community_name_tamil'] ?? '',
      nameEnglish: json['sub_community_name_english'] ?? '',
    );
  }
}

class Kulam {
  final int id;
  final int communityId;
  final int subCommunityId;
  final String nameTamil;
  final String nameEnglish;

  Kulam({
    required this.id,
    required this.communityId,
    required this.subCommunityId,
    required this.nameTamil,
    required this.nameEnglish,
  });

  factory Kulam.fromJson(Map<String, dynamic> json) {
    return Kulam(
      id: json['id'],
      communityId: json['community_id'],
      subCommunityId: json['sub_community_id'],
      nameTamil: json['kula_name_tamil'] ?? '',
      nameEnglish: json['kula_name_english'] ?? '',
    );
  }
}

class DevoteeApiService {
  static const String _templeApiBaseUrl = 'https://temple.jobes24x7.com/api';
  static const String _loginApiBaseUrl = 'https://managelogin.jobes24x7.com/api';

  Future<Map<String, dynamic>?> fetchUserProfile(String userId) async {
    try {
      final response = await http.get(Uri.parse('$_loginApiBaseUrl/login/$userId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data']['data'] != null) {
           return data['data']['data'];
        }
      }
    } catch (e) {
      print("Error fetching user profile: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchVerifiedUser(String userId) async {
    try {
      final response = await http.get(Uri.parse('$_loginApiBaseUrl/verified-user/$userId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'];
        }
      }
    } catch (e) {
      print("Error fetching verified user: $e");
    }
    return null;
  }

  Future<List<Community>> fetchCommunities() async {
    try {
      final response = await http.get(Uri.parse('$_templeApiBaseUrl/communities'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data']['data'] != null) {
          final List list = data['data']['data'];
          return list.map((item) => Community.fromJson(item)).toList();
        }
      }
    } catch (e) {
      print("Error fetching communities: $e");
    }
    return [];
  }

  Future<List<SubCommunity>> fetchSubCommunities() async {
    try {
      final response = await http.get(Uri.parse('$_templeApiBaseUrl/sub-communities'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data']['data'] != null) {
          final List list = data['data']['data'];
          return list.map((item) => SubCommunity.fromJson(item)).toList();
        }
      }
    } catch (e) {
      print("Error fetching sub-communities: $e");
    }
    return [];
  }

  Future<List<Kulam>> fetchKulas() async {
    try {
      final response = await http.get(Uri.parse('$_templeApiBaseUrl/kulas'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data']['data'] != null) {
          final List list = data['data']['data'];
          return list.map((item) => Kulam.fromJson(item)).toList();
        }
      }
    } catch (e) {
      print("Error fetching kulas: $e");
    }
    return [];
  }

  Future<Map<String, dynamic>> submitDevoteeRegistration(Map<String, dynamic> payload) async {
    try {
      print("Submitting Devotee payload: ${json.encode(payload)}");
      final response = await http.post(
        Uri.parse('$_loginApiBaseUrl/devotee/register-full'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );
      
      print("Submit Devotee Response Code: ${response.statusCode}");
      print("Submit Devotee Response Body: ${response.body}");
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {'status': false, 'message': 'Failed to submit registration. Status: ${response.statusCode}'};
      }
    } catch (e) {
      print("Error submitting registration: $e");
      return {'status': false, 'message': 'An error occurred: $e'};
    }
  }

  Future<Map<String, dynamic>?> fetchDevoteeProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_loginApiBaseUrl/devotee/$userId'),
        headers: {
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print("Error fetching devotee profile: $e");
    }
    return null;
  }
}
