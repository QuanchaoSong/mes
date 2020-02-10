import 'package:flutter/material.dart';
import 'package:mes/Others/Tool/WidgetTool.dart';
import '../../../Others/Network/HttpDigger.dart';
import 'package:mes/Others/Tool/HudTool.dart';
import 'package:mes/Others/Tool/BarcodeScanTool.dart';
import 'package:mes/Others/Tool/AlertTool.dart';
import '../../../Others/Tool/GlobalTool.dart';
import '../../../Others/Const/Const.dart';
import '../../../Others/View/MESSelectionItemWidget.dart';
import '../Widget/ProjectTextInputWidget.dart';
import 'package:mes/Others/View/MESContentInputWidget.dart';

import 'package:flutter_picker/flutter_picker.dart';

import '../Model/ProjectRepairListItemModel.dart';
import '../Model/ProjectRepairMaterialItemModel.dart';

class ProjectRepairmentDetailPage extends StatefulWidget {
  ProjectRepairmentDetailPage(this.data);

  final ProjectRepairListItemModel data;

  @override
  State<StatefulWidget> createState() {
    return _ProjectRepairmentDetailPageState(this.data);
  }
}

class _ProjectRepairmentDetailPageState
    extends State<ProjectRepairmentDetailPage> {
  _ProjectRepairmentDetailPageState(this.data);

  final ProjectRepairListItemModel data;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ProjectTextInputWidget _pTextInputWgt0;
  MESSelectionItemWidget _selectionWgt0;
  MESSelectionItemWidget _selectionWgt1;
  MESSelectionItemWidget _selectionWgt2;

  final List<String> bottomFunctionTitleList = ["一维码", "二维码"];
  List arrOfData;
  ProjectRepairMaterialItemModel selectedMaterialItem0;
  ProjectRepairMaterialItemModel selectedMaterialItem1;
  ProjectRepairMaterialItemModel selectedMaterialItem2;
  String remarkContent;
  String lotNo;

  @override
  void initState() {
    super.initState();

    _pTextInputWgt0 = _buildTextInputWidgetItem(0);
    _selectionWgt0 = _buildSelectionInputItem(0);
    _selectionWgt1 = _buildSelectionInputItem(1);
    _selectionWgt2 = _buildSelectionInputItem(2);

    _getDataFromServer();
  }

  void _getDataFromServer() {
    // Repair/GetRepairItem
    HudTool.show();
    HttpDigger().postWithUri("Repair/GetRepairItem",
        parameters: {"item": this.data.ItemCode}, shouldCache: true,
        success: (int code, String message, dynamic responseJson) {
      print("Repair/GetRepairItem: $responseJson");
      if (code == 0) {
        HudTool.showInfoWithStatus(message);
        return;
      }

      HudTool.dismiss();
      this.arrOfData = (responseJson["Extend"] as List)
          .map((item) => ProjectRepairMaterialItemModel.fromJson(item))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: hexColor("f2f2f7"),
      appBar: AppBar(
        title: Text("修理信息"),
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
          child: FlatButton(
            textColor: Colors.white,
            color: hexColor(MAIN_COLOR),
            child: Text("确认"),
            onPressed: () {
              _btnConfirmClicked();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    return ListView(
      children: <Widget>[
        WidgetTool.createListViewLine(10, hexColor("f2f2f7")),
        _buildInfoCell(),
        WidgetTool.createListViewLine(10, hexColor("f2f2f7")),
        _pTextInputWgt0,
        _selectionWgt0,
        _selectionWgt1,
        _selectionWgt2,
        _buildContentInputItem(),
      ],
    );
  }

  Widget _buildTextInputWidgetItem(int index) {
    String title = "";
    String placeholder = "";
    bool canScan = true;
    if (index == 0) {
      title = "LotNo/模具ID";
      placeholder = "扫描/输入";
    }
    ProjectTextInputWidget wgt = ProjectTextInputWidget(
      title: title,
      placeholder: placeholder,
      canScan: canScan,
    );

    wgt.functionBlock = () {
      hideKeyboard(context);
      _popSheetAlert();
    };
    wgt.contentChangeBlock = (String newContent) {
      print("contentChangeBlock: $newContent");
      this.lotNo = newContent;
    };

    return wgt;
  }

  Widget _buildSelectionInputItem(int index) {
    String title = "";
    if (index == 0) {
      title = "耗用辅料1";
    } else if (index == 1) {
      title = "耗用辅料2";
    } else if (index == 2) {
      title = "耗用辅料3";
    }
    void Function() selectionBlock = () {
      _hasSelectedItem(index);
    };

    MESSelectionItemWidget wgt = MESSelectionItemWidget(
      title: title,
    );
    wgt.selectionBlock = selectionBlock;
    return wgt;
  }

  void _hasSelectedItem(int index) {
    print("_hasSelectedItem: $index");
    List<String> arrOfSelectionTitle = [];
    for (ProjectRepairMaterialItemModel m in this.arrOfData) {
      arrOfSelectionTitle.add('${m.ItemCode}|${m.ItemName}');
    }

    if (arrOfSelectionTitle.length == 0) {
      return;
    }

    _showPickerWithData(arrOfSelectionTitle, index);

    hideKeyboard(context);
  }

  Widget _buildContentInputItem() {
    void Function(String) contentChangedBlock = (String newContent) {
      // print("contentChangedBlock: $newContent");
      this.remarkContent = newContent;
    };
    return MESContentInputWidget(
      placeholder: "备注",
      contentChangedBlock: contentChangedBlock,
    );
  }

  Widget _buildInfoCell() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            // padding: EdgeInsets.only(left: 30),
            height: 30,
            child: Text(
              "返修工单：${avoidNull(this.data.RPWO)}",
              style: TextStyle(fontSize: 16, color: hexColor("999999")),
            ),
          ),
          Container(
            // padding: EdgeInsets.only(left: 30),
            height: 30,
            child: Text(
              "Lot ID：${avoidNull(this.data.LotNo)}",
              style: TextStyle(fontSize: 16, color: hexColor("999999")),
            ),
          ),
          Container(
            // padding: EdgeInsets.only(left: 30),
            height: 30,
            child: Text(
              "生产工单：${avoidNull(this.data.Wono)}",
              style: TextStyle(fontSize: 16, color: hexColor("999999")),
            ),
          ),
          Container(
            // padding: EdgeInsets.only(left: 30),
            height: 30,
            child: Text(
              "工程名：${avoidNull(this.data.ProcessCode)}|${avoidNull(this.data.ProcessName)}",
              style: TextStyle(fontSize: 16, color: hexColor("999999")),
            ),
          ),
          Container(
            // padding: EdgeInsets.only(left: 30),
            height: 30,
            child: Text(
              "机型：${avoidNull(this.data.ItemCode)}|${avoidNull(this.data.ItemName)}",
              style: TextStyle(fontSize: 16, color: hexColor("999999")),
            ),
          ),
          Container(
            // padding: EdgeInsets.only(left: 30),
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("数量：${this.data.Qty}",
                    style: TextStyle(color: hexColor("999999"), fontSize: 16)),
                Text("返修代码：${this.data.RepairCode}",
                    style: TextStyle(color: hexColor("999999"), fontSize: 16)),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
          ),
          Container(
            // padding: EdgeInsets.only(left: 30),
            height: 30,
            child: Text(
              "备注：${avoidNull(this.data.Comment)}",
              style: TextStyle(fontSize: 16, color: hexColor("999999")),
            ),
          ),
          Container(
            // padding: EdgeInsets.only(left: 30),
            height: 30,
            child: Text(
              "创建时间：${avoidNull(this.data.OTime)}",
              style: TextStyle(fontSize: 16, color: hexColor("999999")),
            ),
          ),
        ],
      ),
    );
  }

  Future _btnConfirmClicked() async {
    if (isAvailable(this.lotNo) == false) {
      HudTool.showInfoWithStatus("请输入/扫码获取Lot NO");
      return;
    }

    if (this.selectedMaterialItem0 == null) {
      HudTool.showInfoWithStatus("请选择耗用辅料1");
      return;
    }

    if (this.selectedMaterialItem1 == null) {
      HudTool.showInfoWithStatus("请选择耗用辅料2");
      return;
    }

    if (this.selectedMaterialItem2 == null) {
      HudTool.showInfoWithStatus("请选择耗用辅料3");
      return;
    }

    if (isAvailable(this.remarkContent) == false) {
      HudTool.showInfoWithStatus("请输入备注");
      return;
    }

    bool isOkay =
        await AlertTool.showStandardAlert(_scaffoldKey.currentContext, "确定锁定?");

    if (isOkay) {
      _confirmAction();
    }
  }

  void _confirmAction() {
    // Repair/RepairOK
    Map mDict = Map();
    mDict["ctool"] = this.lotNo;
    mDict["rpwo"] = this.data.RPWO;
    mDict["comment"] = this.remarkContent;
    mDict["item1"] = this.selectedMaterialItem0.BomID;
    mDict["item2"] = this.selectedMaterialItem1.BomID;
    mDict["item3"] = this.selectedMaterialItem2.BomID;
    print("Repair/RepairOK mDict: $mDict");

    HudTool.show();
    HttpDigger().postWithUri("Repair/RepairOK", parameters: mDict,
        success: (int code, String message, dynamic responseJson) {
      print("Repair/RepairOK: $responseJson");
      if (code == 0) {
        HudTool.showInfoWithStatus(message);
        return;
      }

      HudTool.showInfoWithStatus("操作成功");
      Navigator.pop(context);
    });
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
                _tryToscan();
              }),
        )),
        height: 120,
      ),
    );
  }

  void _showPickerWithData(List<String> listData, int index) {
    Picker picker = new Picker(
        adapter: PickerDataAdapter<String>(pickerdata: listData),
        changeToFirst: true,
        textAlign: TextAlign.left,
        columnPadding: const EdgeInsets.all(8.0),
        onConfirm: (Picker picker, List indexOfSelectedItems) {
          print(indexOfSelectedItems.first);
          print(picker.getSelectedValues());
          this._handlePickerConfirmation(indexOfSelectedItems.first,
              picker.getSelectedValues().first, index);
        });
    // picker.show(Scaffold.of(context));
    picker.show(_scaffoldKey.currentState);
  }

  void _handlePickerConfirmation(
      int indexOfSelectedItem, String title, int index) {
    if (index == 0) {
      _selectionWgt0.setContent(title);
      this.selectedMaterialItem0 = this.arrOfData[indexOfSelectedItem];
    } else if (index == 1) {
      _selectionWgt1.setContent(title);
      this.selectedMaterialItem1 = this.arrOfData[indexOfSelectedItem];
    } else if (index == 2) {
      _selectionWgt2.setContent(title);
      this.selectedMaterialItem2 = this.arrOfData[indexOfSelectedItem];
    }
  }

  Future _tryToscan() async {
    print("start scanning");

    String c = await BarcodeScanTool.tryToScanBarcode();
    _pTextInputWgt0.setContent(c);
    this.lotNo = c;
  }
}
