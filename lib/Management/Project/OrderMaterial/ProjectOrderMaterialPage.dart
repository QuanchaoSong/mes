import 'package:flutter/material.dart';
import 'package:mes/Others/Tool/WidgetTool.dart';
import '../../../Others/Network/HttpDigger.dart';
import 'package:mes/Others/Tool/HudTool.dart';
import 'package:mes/Others/Tool/AlertTool.dart';
import '../../../Others/Tool/GlobalTool.dart';
import '../../../Others/Tool/BarcodeScanTool.dart';
import '../../../Others/Const/Const.dart';
import '../../../Others/View/MESSelectionItemWidget.dart';
import '../Widget/ProjectInfoDisplayWidget.dart';

import 'package:flutter_picker/flutter_picker.dart';

import '../Model/ProjectLineModel.dart';
import '../Model/ProjectTodayWorkOrderModel.dart';
import '../Model/ProjectMaterialItemModel.dart';
import '../Model/ProjectTagInfoModel.dart';

import 'ProjectAddMaterialTagPage.dart';

import 'package:mes/Others/Page/TakePhotoForOCRPage.dart';

class ProjectOrderMaterialPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProjectOrderMaterialPageState();
  }
}

class _ProjectOrderMaterialPageState extends State<ProjectOrderMaterialPage> {
  MESSelectionItemWidget _selectionWgt0;
  MESSelectionItemWidget _selectionWgt1;
  MESSelectionItemWidget _selectionWgt2;

  ProjectInfoDisplayWidget _pInfoDisplayWgt0;
  ProjectInfoDisplayWidget _pInfoDisplayWgt1;
  ProjectInfoDisplayWidget _pInfoDisplayWgt2;

  final List<String> functionTitleList = [
    "上升",
    "下降",
    "删除",
    "追加",
  ];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Widget> bottomFunctionWidgetList = List();
  final List<String> bottomFunctionTitleList = ["二维码", "手动"];
  final List<MESSelectionItemWidget> selectionItemList = List();
  int selectedIndex = -1;
  List arrOfLineItem;
  ProjectLineModel selectedLineItem;
  List arrOfTodayWork;
  ProjectTodayWorkOrderModel selectedTodayWork;
  ProjectMaterialItemModel materialInfo;
  List arrOfMaterialTag;
  ProjectTagInfoModel selectedMaterialTag;

  @override
  void initState() {
    super.initState();

    _selectionWgt0 = _buildSelectionInputItem(0);
    _selectionWgt1 = _buildSelectionInputItem(1);
    _selectionWgt2 = _buildSelectionInputItem(2);

    _pInfoDisplayWgt0 = ProjectInfoDisplayWidget(
      title: "订单号",
    );
    _pInfoDisplayWgt1 = ProjectInfoDisplayWidget(
      title: "物料需求",
    );
    _pInfoDisplayWgt2 = ProjectInfoDisplayWidget(
      title: "已上料",
    );

    for (int i = 0; i < functionTitleList.length; i++) {
      String functionTitle = functionTitleList[i];
      Widget btn = Expanded(
        child: Container(
          height: 50,
          color: hexColor(MAIN_COLOR),
          child: FlatButton(
            padding: EdgeInsets.all(0),
            textColor: Colors.white,
            color: hexColor(MAIN_COLOR),
            child: Text(functionTitle),
            onPressed: () {
              print(functionTitle);
              _functionItemClickedAtIndex(i);
            },
          ),
        ),
      );
      bottomFunctionWidgetList.add(btn);

      if (i != (functionTitleList.length - 1)) {
        bottomFunctionWidgetList.add(SizedBox(width: 1));
      }
    }

    _getDataFromServer();
  }

  void _getDataFromServer() {
    // 获取所有有效的产线
    HttpDigger()
        .postWithUri("LoadMaterial/AllLine", parameters: {}, shouldCache: true,
            success: (int code, String message, dynamic responseJson) {
      print("LoadMaterial/AllLine: $responseJson");
      this.arrOfLineItem = (responseJson['Extend'] as List)
          .map((item) => ProjectLineModel.fromJson(item))
          .toList();

      if (listLength(this.arrOfLineItem) > 0) {
        ProjectLineModel firstWorkData = this.arrOfLineItem.first;
        _getPlanListFromServer(firstWorkData.LineCode);
      }
    });
  }

  void _getPlanListFromServer(String workLine, {shouldShowHud = true}) {
    // 获取计划信息清单
    print("workLine: $workLine");
    if (shouldShowHud == true) {
      HudTool.show();
    }
    HttpDigger().postWithUri("LoadMaterial/TodayWo",
        parameters: {"line": workLine}, shouldCache: true,
        success: (int code, String message, dynamic responseJson) {
      print("LoadMaterial/TodayWo: $responseJson");      
      this.arrOfTodayWork = (responseJson["Extend"] as List)
          .map((item) => ProjectTodayWorkOrderModel.fromJson(item))
          .toList();
      
      if (shouldShowHud == true) {
        if (responseJson["isCachedData"] == null) {
          // 如果是网络数据
          HudTool.dismiss();          
        } else {
          // 如果是缓存数据，必须要有值才行
          if (listLength(this.arrOfTodayWork) > 0) {
            HudTool.dismiss();
          }
        }
      }
    });
  }

  void _getMaterialInfoFromServer(String wono, {shouldShowHud = true, shouldCache = true}) {
    // 获取追溯物料
    print("wono: $wono");
    if (shouldShowHud == true) {
      HudTool.show();
    }
    HttpDigger().postWithUri("LoadMaterial/RPTItem",
        parameters: {"wono": wono}, shouldCache: shouldCache,
        success: (int code, String message, dynamic responseJson) {
      print("LoadMaterial/RPTItem: $responseJson");
      if (shouldShowHud == true) {
        HudTool.dismiss();
      }

      List arr = responseJson["Extend"];
      if (listLength(arr) == 0) {
        return;
      }
      this.materialInfo = ProjectMaterialItemModel.fromJson(arr[0]);
      _selectionWgt2.setContent(
          '${this.materialInfo.ItemType}|${this.materialInfo.ItemCode}|${this.materialInfo.ItemName}');

      _getTagListFromServer(wono, this.materialInfo.ItemCode);
    });
  }

  void _getTagListFromServer(String wono, String materialInfoId) {
    // 获取所有绑定的标签清单
    HudTool.show();
    Map parameters = {"wono": wono, "item": materialInfoId};
    print("parameters: $parameters");
    HttpDigger().postWithUri("LoadMaterial/LoadTag",
        parameters: parameters, shouldCache: true,
        success: (int code, String message, dynamic responseJson) {
      print("LoadMaterial/LoadTag: $responseJson");
      HudTool.dismiss();
      this.arrOfMaterialTag = (responseJson["Extend"] as List)
          .map((item) => ProjectTagInfoModel.fromJson(item))
          .toList();
      _pInfoDisplayWgt2.setContent(responseJson["Extend2"]);
     setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: hexColor("f2f2f7"),
      appBar: AppBar(
        title: Text("工单上料"),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            color: hexColor("f2f2f7"),
            child: _buildListView(),
          ),
        ),
        Container(
          height: 50,
          width: double.infinity,
          // color: randomColor(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: this.bottomFunctionWidgetList,
          ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    return ListView.builder(
        itemCount: listLength(this.arrOfMaterialTag) + 6,
        // itemExtent: 250,
        itemBuilder: (context, index) {
          return _buildListViewItem(index);
        });
  }

  Widget _buildListViewItem(int index) {
    if (index == 0) {
      return _selectionWgt0;
    } else if (index == 1) {
      return _selectionWgt1;
    } else if (index == 2) {
      return _pInfoDisplayWgt0;
    } else if (index == 3) {
      return _selectionWgt2;
    } else if (index == 4) {
      return Container(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: _pInfoDisplayWgt1,
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: _pInfoDisplayWgt2,
            ),
          ],
        ),
      );
    } else if (index == 5) {
      return WidgetTool.createListViewLine(10, hexColor("f2f2f7"));
    } else {
      int realIndex = index - 6;
      return GestureDetector(
        child: _buildMaterialTagItem(realIndex),
        onTap: () {
          _onMaterialTagItemClicked(realIndex);
        },
      );
    }
  }

  void _onMaterialTagItemClicked(int index) {
    this.selectedIndex = index;
    if (listLength(this.arrOfMaterialTag) > 0) {
      this.selectedMaterialTag = this.arrOfMaterialTag[this.selectedIndex];
    }

    setState(() {});
  }

  Widget _buildMaterialTagItem(int index) {
    ProjectTagInfoModel itemData = this.arrOfMaterialTag[index];
    return Container(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
            // color: randomColor(),
            constraints: BoxConstraints(minWidth: 25),
            child: Text(
              (index + 1).toString(),
              style: TextStyle(color: hexColor("999999"), fontSize: 15),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                    height: 25,
                    color: Colors.white,
                    child: Text(
                      "标签：${itemData.TagID}",
                      maxLines: 2,
                      style: TextStyle(
                          color: hexColor(MAIN_COLOR_BLACK),
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    margin: EdgeInsets.only(left: 10),
                    height: 21,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("物料ID：${itemData.ItemCode}",
                            style: TextStyle(
                                color: hexColor("999999"), fontSize: 15)),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    margin: EdgeInsets.only(left: 10),
                    height: 21,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("物料批次：${itemData.ProductionBatch}",
                            style: TextStyle(
                                color: hexColor("999999"), fontSize: 15))
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    margin: EdgeInsets.only(left: 10),
                    height: 21,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("订单号：${itemData.OrderNo}",
                            style: TextStyle(
                                color: hexColor("999999"), fontSize: 15)),
                        Text("单位：${itemData.Unit}",
                            style: TextStyle(
                                color: hexColor("999999"), fontSize: 15)),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    margin: EdgeInsets.fromLTRB(10, 0, 0, 10),
                    height: 21,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("已上料：${itemData.Qty}",
                            style: TextStyle(
                                color: hexColor("999999"), fontSize: 15)),
                        Text("使用量：${itemData.Cost}",
                            style: TextStyle(
                                color: hexColor("999999"), fontSize: 15)),
                      ],
                    ),
                  ),
                  Container(
                    color: hexColor("dddddd"),
                    height: 1,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 5),
          Opacity(
            opacity: (this.selectedIndex == index) ? 1.0 : 0.0,
            child: Container(
              margin: EdgeInsets.only(right: 8),
              color: Colors.white,
              child: Icon(
                Icons.check,
                color: hexColor(MAIN_COLOR),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionInputItem(int index) {
    String title = "";
    bool enabled = true;
    if (index == 0) {
      title = "产线";
    } else if (index == 1) {
      title = "工单";
    } else if (index == 2) {
      title = "追溯物料";
    }
    void Function() selectionBlock = () {
      _hasSelectedItem(index);
    };

    MESSelectionItemWidget wgt = MESSelectionItemWidget(
      title: title,
      enabled: enabled,
    );
    wgt.selectionBlock = selectionBlock;
    return wgt;
  }

  void _hasSelectedItem(int index) {
    List<String> arrOfSelectionTitle = [];
    if (index == 0) {
      for (ProjectLineModel m in this.arrOfLineItem) {
        arrOfSelectionTitle.add('${m.LineCode}|${m.LineName}');
      }
    } else if (index == 1) {
      for (ProjectTodayWorkOrderModel m in this.arrOfTodayWork) {
        arrOfSelectionTitle.add('${m.Wono}|${m.StateDesc}');
      }
    } else if (index == 2) {
      return;
    }

    _showPickerWithData(arrOfSelectionTitle, index);

    hideKeyboard(context);
  }

  void _showPickerWithData(List<String> listData, int index) {
    Picker picker = new Picker(
        adapter: PickerDataAdapter<String>(pickerdata: listData),        
        cancelText: "取消",
        confirmText: "确定",
        changeToFirst: true,
        textAlign: TextAlign.left,
        columnPadding: const EdgeInsets.all(8.0),
        onConfirm: (Picker picker, List indexOfSelectedItems) {
          print(indexOfSelectedItems.first);
          print(picker.getSelectedValues());
          this._handlePickerConfirmation(indexOfSelectedItems.first,
              picker.getSelectedValues().first, index);
        });
    picker.show(_scaffoldKey.currentState);
  }

  void _handlePickerConfirmation(
      int indexOfSelectedItem, String title, int index) {
    if (index == 0) {
      this.selectedLineItem = this.arrOfLineItem[indexOfSelectedItem];
      _getPlanListFromServer(this.selectedLineItem.LineCode);

      _selectionWgt0.setContent(title);
    } else if (index == 1) {
      this.selectedTodayWork = this.arrOfTodayWork[indexOfSelectedItem];
      _getMaterialInfoFromServer(this.selectedTodayWork.Wono);

      _selectionWgt1.setContent(title);
      _pInfoDisplayWgt0.setContent(this.selectedTodayWork.Rpno);
      _pInfoDisplayWgt1.setContent(this.selectedTodayWork.WoPlanQty.toString());
    }

    setState(() {});
  }

  void _popSheetAlert() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        child: ListView(
            children: List.generate(
          2,
          (index) => InkWell(
              child: Container(
                  alignment: Alignment.center,
                  height: 60.0,
                  child: Text(bottomFunctionTitleList[index])),
              onTap: () {
                print('tapped item ${index + 1}');
                Navigator.pop(context);
                if (index == 0) {
                  _tryToScan();
                } else if (index == 1) {
                  _gotoAddMaterialTagPage(this.materialInfo, this.selectedTodayWork.Wono);
                }
              }),
        )),
        height: 120,
      ),
    );
  }

  Future _gotoAddMaterialTagPage(ProjectMaterialItemModel materialInfo, String wono) async {
    Widget w = ProjectAddMaterialTagPage(
          materialInfo, wono);
    bool success = await Navigator.of(_scaffoldKey.currentContext).push(MaterialPageRoute(builder: (BuildContext context) => w));
    if (success != null && success) {
      print("gotoAddMaterialTagPage success");
      _getMaterialInfoFromServer(this.selectedTodayWork.Wono, shouldCache: false);
    }
  }

  Future _functionItemClickedAtIndex(int index) async {
    if (this.selectedLineItem == null) {
      HudTool.showInfoWithStatus("请选择产线");
      return;
    }
    if (this.selectedTodayWork == null) {
      HudTool.showInfoWithStatus("请选择工单");
      return;
    }

    if (this.materialInfo == null) {
      HudTool.showInfoWithStatus("没有追溯物料");
      return;
    }

    if (index != 3 && this.selectedMaterialTag == null) {
      HudTool.showInfoWithStatus("请选择一项标签");
      return;
    }

    if (index == 3) {
      _popSheetAlert();      
    } else {
      String hintTitle = "确定上升?";
      if (index == 1) {
        hintTitle = "确定下降?";
      } else if (index == 2) {
        hintTitle = "确定删除?";
      }
      
      bool isOkay = await AlertTool.showStandardAlert(
          _scaffoldKey.currentContext, hintTitle);

      if (isOkay) {
        _realConfirmationAction(index);
      }
    }
  }

  void _realConfirmationAction(int index) {
    String uri = "LoadMaterial/Up";
    if (index == 1) {
      uri = "LoadMaterial/Down";
    } else if (index == 2) {
      uri = "LoadMaterial/Delete";
    }

    Map mDict = Map();
    mDict["wono"] = this.selectedTodayWork.Wono;
    mDict["item"] = this.materialInfo.ItemCode;
    mDict["tag"] = this.selectedMaterialTag.TagID;
    mDict["id"] = this.selectedMaterialTag.ID.toString();
    print("$uri mDict: $mDict");
    
    HudTool.show();
    HttpDigger().postWithUri(uri, parameters: mDict,
        success: (int code, String message, dynamic responseJson) {
      print('$uri: $responseJson');
      if (code == 0) {
        HudTool.showInfoWithStatus(message);
        return;
      }

      HudTool.showInfoWithStatus("操作成功");
      Future.delayed(Duration(seconds: 1), (){
        _getTagListFromServer(this.selectedTodayWork.Wono, this.materialInfo.ItemCode);
      });
    });
  }

  Future _tryToScan() async {
    print("start scanning");

    String wono = await BarcodeScanTool.tryToScanBarcode();
    HudTool.show();
    HttpDigger().postWithUri("LoadMaterial/RPTItem",
        parameters: {"wono": wono}, shouldCache: true,
        success: (int code, String message, dynamic responseJson) {
      print("LoadMaterial/RPTItem: $responseJson");
      if (code == 0) {
        HudTool.showInfoWithStatus(message);
        return;
      }

      HudTool.dismiss();
      List arr = responseJson["Extend"];
      if (listLength(arr) == 0) {
        return;
      }

      _gotoAddMaterialTagPage(ProjectMaterialItemModel.fromJson(arr[0]), this.selectedTodayWork.Wono);

      // this.materialInfo = ProjectMaterialItemModel.fromJson(arr[0]);
      // _selectionWgt2.setContent(
      //     '${this.materialInfo.ItemType}|${this.materialInfo.ItemCode}|${this.materialInfo.ItemName}');
      // _getTagListFromServer(wono, this.materialInfo.ItemCode);
    });
  }
}
