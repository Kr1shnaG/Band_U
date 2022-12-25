import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/track.dart';
import 'package:flutter_app/models/user.dart';
import 'package:flutter_app/services/apis.dart';
import 'package:flutter_app/services/storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

import 'list_item.dart';

const tracksUrl = '/me/top/tracks?time_range=';

class TopTracksList extends StatefulWidget {
  final String timeRange;
  final UserModel? user;

  const TopTracksList({Key? key, this.timeRange = 'short_term', this.user})
      : super(key: key);

  @override
  _TopTracksListState createState() => _TopTracksListState();
}

class _TopTracksListState extends State<TopTracksList> {
  final TracksNotifier _tracks = TracksNotifier([]);

  @override
  void initState() {
    super.initState();
    getTopTracks(widget.timeRange);
  }

  @override
  void didUpdateWidget(covariant TopTracksList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timeRange != widget.timeRange) {
      _tracks.changeData([]);
      getTopTracks(widget.timeRange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 20),
        child: Column(children: [
          const Text(
            'Top Tracks',
            style: TextStyle(fontSize: 24),
          ),
          ValueListenableBuilder<List<Items>>(
            builder: (BuildContext context, List<Items> value, Widget? child) {
              return value.isEmpty
                  ? _buildSkeletonTracks()
                  : _buildTracks(value);
            },
            valueListenable: _tracks,
          )
        ]));
  }

  void getTopTracks(String timeRange) async {
    String? token = '';

    if ((await SecureStorage.getRefreshToken()).toString().isNotEmpty ||
        await SecureStorage.getRefreshToken() != null) {
      token = await Apis().getRefreshToken();
    } else {
      token = await Apis().getRefreshToken();
    }
    token = await SecureStorage.getToken();
    var url = dotenv.env['NODE_ENV'] == 'development'
        ? dotenv.env['TopTracks']
        : dotenv.env['TopTracks'];
    var timerangeUrl = (url! + tracksUrl + widget.timeRange);
    var res = await http.get(Uri.parse(timerangeUrl), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    print(res.body);
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['items'].isNotEmpty) {
        Track track = Track.fromJson(json);

        _tracks.changeData(track.items ?? []);
      }
    }
    // return tracks;
  }

  // TODO: store to firebase
  
  Widget _buildTracks(List<Items> tracks) {
    return ListView.builder(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 16.0),
        itemCount: tracks.length,
        itemBuilder: (context, i) {
          // if (i.isOdd) return Divider(color: Colors.grey[600]);
          // final index = i ~/ 2;
          var name = tracks[i].name ?? '';
          var artists = tracks[i].artists?.map((a) => a.name).join(', ');
          var cover = tracks[i].album?.images?[0].url ?? '';
          return _buildTrackRow(name, artists ?? '', cover);
        });
  }

  Widget _buildTrackRow(String title, String artists, String cover) {
    return ListItem(
      img: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 56, maxWidth: 56),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2.0),
            child: Image.network(
              cover,
              fit: BoxFit.fill,
            ),
          )),
      title: FittedBox(
        fit: BoxFit.fitWidth,
        child: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
      ),
      subtitle: FittedBox(
        fit: BoxFit.fitWidth,
        child: Text(
          artists,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildSkeletonTracks() {
    return ListView.builder(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 16.0),
        itemCount: 10,
        itemBuilder: (context, i) {
          // if (i.isOdd) return Divider(color: Colors.grey[600]);
          return _buildSkeletonTrackRow();
        });
  }

  Widget _buildSkeletonTrackRow() {
    return Shimmer.fromColors(
        baseColor: Colors.grey.shade800,
        highlightColor: Colors.grey.shade700,
        child: ListItem(
            img: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: const BorderRadius.all(Radius.circular(2))),
            ),
            title: Container(
              height: 20,
              width: 180,
              decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: const BorderRadius.all(Radius.circular(2))),
            ),
            subtitle: Container(
              height: 14,
              width: 150,
              decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: const BorderRadius.all(Radius.circular(2))),
            )));
  }
}

class TracksNotifier extends ValueNotifier<List<Items>> {
  TracksNotifier(List<Items> value) : super(value);

  void changeData(List<Items> tracks) {
    value = tracks;
    notifyListeners();
  }
}
