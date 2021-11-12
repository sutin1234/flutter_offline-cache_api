import 'dart:convert';

import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:app_offine/services/base_service.dart';
import 'package:http/http.dart' as http;

class UserService {
  final USER_CACHE_KEY = 'USER_CACHE_KEY';
  final userURL = BaseService.baseUrl + '/users';

  Future<List<Map<String, dynamic>>> fetchUser() async {
    final isCachedExist =
        await APICacheManager().isAPICacheKeyExist(USER_CACHE_KEY);
    if (isCachedExist) {
      print('from Cached');
      var cachedData = await APICacheManager().getCacheData(USER_CACHE_KEY);
      return List.from(jsonDecode(cachedData.syncData));
    } else {
      final response = await http.get(Uri.parse(userURL));
      if (response.statusCode == 200) {
        print('from Internet');
        final APICacheDBModel apiCacheDBModel =
            APICacheDBModel(key: USER_CACHE_KEY, syncData: response.body);
        await APICacheManager().addCacheData(apiCacheDBModel);
        return List.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load User');
      }
    }
  }
}
