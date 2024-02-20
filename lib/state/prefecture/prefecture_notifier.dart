// ignore_for_file: avoid_catches_without_on_clauses, only_throw_errors, cascade_invocations

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart';

import '../../models/prefecture.dart';
import '../city/city_notifier.dart';
import 'prefecture_state.dart';

//////////////////////////////////////////////////////

// TODO autoDisposeを外している
final prefectureProvider =
    StateNotifierProvider<PrefectureNotifier, PrefectureState>((ref) {
  return PrefectureNotifier(
    const PrefectureState(),
    ref: ref,
  )..getPrefecture();
});

class PrefectureNotifier extends StateNotifier<PrefectureState> {
  PrefectureNotifier(super.state, {required this.ref});

  final StateNotifierProviderRef<PrefectureNotifier, PrefectureState> ref;

  ///
  @override
  void dispose() => super.dispose();

  ///
  Future<void> getPrefecture() async {
    try {
      const url = 'https://opendata.resas-portal.go.jp/api/v1/prefectures';

      final response = await get(Uri.parse(url), headers: {
        'X-API-KEY': dotenv.get('RESAS_API_KEY'),
        'Content-Type': 'application/json',
      });

      final prefecture = prefectureFromJson(response.body);

      final list = <PrefectureData>[];

      list.add(PrefectureData(prefCode: 0, prefName: ''));

      final prefectureMap = <int, PrefectureData>{};

      prefecture.result.forEach((element) {
        list.add(element);

        prefectureMap[element.prefCode] = element;
      });

      state = state.copyWith(
        prefList: list,
        prefectureMap: prefectureMap,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  ///
  Future<void> selectPref({required int prefCode}) async {
    //-----------------------------------------//
    final prefMap = {...state.prefectureMap};
    await ref.watch(cityProvider.notifier).getCity(pref: prefMap[prefCode]!);
    //-----------------------------------------//

    state = state.copyWith(selectPrefCode: prefCode);
  }

  ///
  Future<void> clearPref() async => state = state.copyWith(selectPrefCode: 0);
}

//////////////////////////////////////////////////////
