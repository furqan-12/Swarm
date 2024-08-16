import 'package:swarm/consts/consts.dart';

import 'tabbar_photographers_map/all_map_screen.dart';

class FingPhotographersMapScreen extends StatefulWidget {
  const FingPhotographersMapScreen({super.key});

  @override
  State<FingPhotographersMapScreen> createState() =>
      _FingPhotographersMapScreenState();
}

class _FingPhotographersMapScreenState
    extends State<FingPhotographersMapScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 4,
      child: Scaffold(
        backgroundColor: universalWhitePrimary,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(
              kToolbarHeight + 180), // Customize the height
          child: AppBar(
            surfaceTintColor: universalWhitePrimary,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: universalBlackPrimary,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            backgroundColor: universalWhitePrimary,
            flexibleSpace: const Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 200,
                  child: Column(
                    children: [
                      Wrap(spacing: 4.0, children: [
                        Chip(
                          label: Text(
                            'Portrait',
                            style: TextStyle(fontFamily: (bold)),
                          ),
                          backgroundColor: universalColorPrimaryDefault,
                        ),
                        Chip(
                          label: Text(
                            'The Park',
                            style: TextStyle(fontFamily: (bold)),
                          ),
                          backgroundColor: universalColorPrimaryDefault,
                        ),
                        Chip(
                          label: Text(
                            'The Plaza Ho...',
                            style: TextStyle(fontFamily: (bold)),
                          ),
                          backgroundColor: universalColorPrimaryDefault,
                        ),
                        Chip(
                          label: Text(
                            'Fri Oct 5 • 10:00 am',
                            style: TextStyle(fontFamily: (bold)),
                          ),
                          backgroundColor: universalColorPrimaryDefault,
                        ),
                        Chip(
                          label: Text(
                            '3 hours',
                            style: TextStyle(fontFamily: (bold)),
                          ),
                          backgroundColor: universalColorPrimaryDefault,
                        ),
                      ]),
                      Padding(
                        padding: EdgeInsets.only(left: 60),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '2344 nearby',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            bottom: const TabBar(
              indicatorColor: universalBlackPrimary,
              labelStyle: TextStyle(height: 5),
              tabs: [
                Text(
                  'All',
                  style: TextStyle(color: universalBlackPrimary),
                ),
                Text(
                  'Amateur',
                  style: TextStyle(color: universalBlackPrimary),
                ),
                Text(
                  'Mid-level',
                  style: TextStyle(color: universalBlackPrimary),
                ),
                Text(
                  'Pro',
                  style: TextStyle(color: universalBlackPrimary),
                ),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            AllMapScreen(),
            AllMapScreen(),
            AllMapScreen(),
            AllMapScreen(),
          ],
        ),
      ),
    );
  }
}
