// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:museum_search/state/select_route/select_route_notifier.dart';
import 'package:url_launcher/url_launcher.dart';

import '../extensions/extensions.dart';
import '../models/art_facility.dart';
import '../state/app_param/app_param_notifier.dart';
import '../utility/utility.dart';

class RouteListScreen extends ConsumerWidget {
  RouteListScreen({super.key, required this.facilityList});

  final List<Facility> facilityList;

  Utility utility = Utility();

  final TextEditingController speedTextController = TextEditingController();

  final TextEditingController adjustPercentTextController =
      TextEditingController();

  late WidgetRef _ref;

  ///
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _ref = ref;
    final selectRouteState = ref.watch(selectRouteProvider);

    speedTextController.text = selectRouteState.walkSpeed.toString();

    adjustPercentTextController.text =
        selectRouteState.adjustPercent.toString();

    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        height: double.infinity,
        child: DefaultTextStyle(
          style: const TextStyle(fontSize: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(width: context.screenSize.width),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Theme(
                  data: ThemeData(
                      visualDensity: const VisualDensity(vertical: -4)),
                  child: ListTileTheme(
                    contentPadding: EdgeInsets.zero,
                    horizontalTitleGap: 0,
                    minLeadingWidth: 0,
                    dense: true,
                    child: ExpansionTile(
                      title: const Text(
                        '設定変更',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      trailing: const Icon(Icons.keyboard_arrow_down,
                          color: Colors.white),
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    flex: 7,
                                    child: Text('歩く速度（時速）：'),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: TextField(
                                      style:
                                          const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          vertical: 2,
                                          horizontal: 2,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      controller: speedTextController,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  const Text('Km'),
                                ],
                              ),
                              Row(
                                children: [
                                  const Expanded(
                                    flex: 7,
                                    child: Text('調整率：'),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: TextField(
                                      style:
                                          const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          vertical: 2,
                                          horizontal: 2,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      controller: adjustPercentTextController,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  const Text('%'),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  onTap: () async {
                                    await ref
                                        .watch(selectRouteProvider.notifier)
                                        .setWalkSpeed(
                                            speed: speedTextController.text
                                                .toInt());

                                    await ref
                                        .watch(selectRouteProvider.notifier)
                                        .setAdjustPercent(
                                            adjust: adjustPercentTextController
                                                .text
                                                .toInt());
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      '変更する',
                                      style: TextStyle(
                                          fontSize: 8, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: displayBottomSheetContent(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  ///
  List<Widget> displayBottomSheetContent() {
    final list = <Widget>[];

    final selectedStationId =
        _ref.watch(appParamProvider.select((value) => value.selectedStationId));

    final selectRouteState = _ref.watch(selectRouteProvider);

    for (var i = 0; i < facilityList.length; i++) {
      final facility = facilityList[i];

      var distance = '';
      var walkMinutes = 0;
      if (i < facilityList.length - 1) {
        if ((facility.latitude == facilityList[i + 1].latitude) &&
            (facility.longitude == facilityList[i + 1].longitude)) {
          //TODO 緯度経度が同じ場合
          distance = '0';
        } else {
          distance = utility.calcDistance(
            originLat: facility.latitude.toDouble(),
            originLng: facility.longitude.toDouble(),
            destLat: facilityList[i + 1].latitude.toDouble(),
            destLng: facilityList[i + 1].longitude.toDouble(),
          );
        }

        final dist1000 =
            int.parse((double.parse(distance) * 1000).toString().split('.')[0]);
        final ws = selectRouteState.walkSpeed * 1000;
        final percent = (100 + selectRouteState.adjustPercent) / 100;
        walkMinutes = ((dist1000 / ws * 60) * percent).round();
      }

      final ll = [facility.latitude, facility.longitude];

      list.add(
        DefaultTextStyle(
          style: const TextStyle(fontSize: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: (i == 0)
                        ? Colors.blueAccent.withOpacity(0.6)
                        : Colors.orangeAccent.withOpacity(0.4),
                    foregroundColor: Colors.white,
                    child: (i == 0)
                        ? Text(
                            (selectedStationId != '') ? 'Sta' : 'Here',
                            style: const TextStyle(fontSize: 10),
                          )
                        : Text(i.toString()),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(facility.name),
                        Container(
                          padding: const EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(facility.address),
                              Text(ll.join(' / ')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (i < facilityList.length - 1)
                Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.arrow_downward_outlined, size: 40),
                          const SizedBox(width: 10),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () => showGoogleTransit(index: i),
                                  icon: const Icon(FontAwesomeIcons.google,
                                      size: 20),
                                ),
                                IconButton(
                                  onPressed: () => showYahooTransit(index: i),
                                  icon: const Icon(FontAwesomeIcons.yahoo,
                                      size: 20),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '$distance Km',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text('徒歩$walkMinutes分'),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return list;
  }

  ///
  Future<void> showYahooTransit({required int index}) async {
    final hourFormat = DateFormat('HH');
    final minuteFormat = DateFormat('mm');

    final now = DateTime.now();

    final queryParameters = <String>[
      'from=${facilityList[index].address}',
      'to=${facilityList[index + 1].address}',
      't=1',
      'y=${now.year}${now.month.toString().padLeft(2, '0')}',
      'd=${now.day}',
      'h=${hourFormat.format(now)}',
      'm=${minuteFormat.format(now)}',
      'sort=1',
      'lat=${facilityList[index].latitude}',
      'lon=${facilityList[index].longitude}',
      'zoom=13',
      'maptype=basic'
    ];

    final url =
        'https://map.yahoo.co.jp/route/train?${queryParameters.join('&')}';

    final mapUrl = Uri.parse(url);
    if (!await launchUrl(mapUrl, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  ///
  Future<void> showGoogleTransit({required int index}) async {
    final ll = [
      facilityList[index].latitude,
      facilityList[index].longitude,
    ];

    final queryParameters = <String>[
      'https://www.google.co.jp/maps/dir',
      ll.join(','),
      (facilityList[index + 1].address),
      '@${ll.join(',')}'
    ];

    final url = queryParameters.join('/');

    final mapUrl = Uri.parse(url);
    if (!await launchUrl(mapUrl, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
