import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/common/widgets/http_error.dart';
import '../../common/constants.dart';
import '../../utils/grid.dart';
import 'controller.dart';
import 'widgets/item.dart';

class SubPage extends StatefulWidget {
  const SubPage({super.key});

  @override
  State<SubPage> createState() => _SubPageState();
}

class _SubPageState extends State<SubPage> {
  final SubController _subController = Get.put(SubController());
  late Future _futureBuilderFuture;

  @override
  void dispose() {
    _subController.scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = _subController.querySubFolder();
    _subController.scrollController.addListener(
      () {
        if (_subController.scrollController.position.pixels >=
            _subController.scrollController.position.maxScrollExtent - 300) {
          EasyThrottle.throttle('history', const Duration(seconds: 1), () {
            _subController.onLoad();
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('我的订阅')),
      body: FutureBuilder(
        future: _futureBuilderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // TODO: refactor
            Map? data = snapshot.data;
            if (data != null && data['status']) {
              return Obx(() => CustomScrollView(
                      controller: _subController.scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverGrid(
                          gridDelegate: SliverGridDelegateWithExtentAndRatio(
                              mainAxisSpacing: StyleString.cardSpace,
                              crossAxisSpacing: StyleString.safeSpace,
                              maxCrossAxisExtent: Grid.maxRowWidth * 2,
                              childAspectRatio: StyleString.aspectRatio * 2.4,
                              mainAxisExtent: 0),
                          delegate: SliverChildBuilderDelegate(
                            childCount:
                                _subController.subFolderData.value.list!.length,
                            (BuildContext context, int index) {
                              return SubItem(
                                  subFolderItem: _subController
                                      .subFolderData.value.list![index],
                                  cancelSub: _subController.cancelSub);
                            },
                          ),
                        )
                      ]));
            } else {
              return CustomScrollView(
                physics: const NeverScrollableScrollPhysics(),
                slivers: [
                  HttpError(
                    errMsg: data?['msg'],
                    callback: () => setState(() {}),
                  ),
                ],
              );
            }
          } else {
            // 骨架屏
            return const Text('请求中');
          }
        },
      ),
    );
  }
}
