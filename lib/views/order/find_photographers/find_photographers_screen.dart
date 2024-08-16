import 'package:swarm/consts/consts.dart';
import 'package:swarm/views/common/chip.dart';

import '../../../consts/api.dart';
import '../../../services/list_photographer_service.dart';
import '../../../services/response/photographer.dart';
import '../../../storage/models/order.dart';
import '../../../utils/date_time_helper.dart';
import '../../../utils/toast_utils.dart';
import 'tabbar_photographers_screen/all_screen.dart';

class FindPhotographersScreen extends StatefulWidget {
  final OrderModel order;
  FindPhotographersScreen({super.key, required this.order});

  @override
  State<FindPhotographersScreen> createState() =>
      _FindPhotographersScreenState();
}

class _FindPhotographersScreenState extends State<FindPhotographersScreen> {
  List<Photographer> items = [];
  List<Photographer> amateurTypeItems = [];
  List<Photographer> hobbyistTypeItems = [];
  List<Photographer> proTypeItems = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadPhotographers();
    });
  }

  Future<void> _loadPhotographers() async {
    final listPhotographerRequest = ListPhotographerService();
    final photographers =
        await listPhotographerRequest.getList(context, widget.order);
    if (photographers == null) {
      ToastHelper.showErrorToast(context, unknownError);
      return;
    }
    setState(() {
      items = photographers;
      amateurTypeItems = photographers
          .where((element) => element.experienceId == Experiences['Starter'])
          .toList();
      hobbyistTypeItems = photographers
          .where(
              (element) => element.experienceId == Experiences['Experienced'])
          .toList();
      proTypeItems = photographers
          .where((element) => element.experienceId == Experiences['Pro'])
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: ExperienceTabIndex[widget.order.experienceId!]!,
      length: 4,
      child: Scaffold(
        backgroundColor: universalWhitePrimary,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(
              kToolbarHeight + 170), // Customize the height
          child: AppBar(
            surfaceTintColor: universalWhitePrimary,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
              child: Image.asset("assets/icons/arrow.png").onTap(() {
                Navigator.pop(context);
              }),
            ),
            backgroundColor: universalWhitePrimary,
            toolbarHeight: 100,
            title: Align(
              alignment: Alignment.centerLeft,
              child: PreferredSize(
                  preferredSize: Size.fromHeight(kToolbarHeight + 20),
                  child: Wrap(spacing: 4.0, children: [])),
            ),
            flexibleSpace: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: SizedBox(
                    height: 195,
                    child: Column(
                      children: [
                        Wrap(spacing: 4.0, children: [
                          chip(widget.order.shootTypeName),
                          chip(widget.order.shootSceneName!),
                          chip(widget.order.shortAddress!.length > 12
                              ? widget.order.shortAddress!.substring(0, 12) +
                                  "..."
                              : widget.order.shortAddress!),
                          chip(formatDate(widget.order.orderDateTime!)),
                          chip(ExperienceName[widget.order.experienceId!]!),
                          chip(widget.order.shootLengthName!),
                        ]),
                        14.heightBox,
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 20),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${items.length} Photographers',
                              style: const TextStyle(
                                color: Colors.black,
                                fontFamily: milligramBold,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            bottom: TabBar(
              padding: EdgeInsets.only(bottom: 20),
              indicatorColor: universalColorPrimaryDefault,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: universalWhitePrimary,
              labelPadding: EdgeInsets.symmetric(horizontal: 2),
              labelStyle: TextStyle(
                  height: 5,
                  fontFamily: milligramBold,
                  wordSpacing: BorderSide.strokeAlignCenter),
              unselectedLabelStyle:
                  TextStyle(height: 5, fontFamily: milligramRegular),
              tabs: [
                Text(
                  'All',
                  style: TextStyle(color: universalBlackPrimary, fontSize: 15),
                ),
                Text(
                  'Starter',
                  style: TextStyle(color: universalBlackPrimary, fontSize: 15),
                ),
                Text(
                  'Experienced',
                  style: TextStyle(color: universalBlackPrimary, fontSize: 15),
                ),
                Text(
                  'Pro',
                  style: TextStyle(color: universalBlackPrimary, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            AllScreen(order: widget.order, items: items),
            AllScreen(order: widget.order, items: amateurTypeItems),
            AllScreen(order: widget.order, items: hobbyistTypeItems),
            AllScreen(order: widget.order, items: proTypeItems),
          ],
        ),
      ),
    );
  }
}
