import 'package:flutter/material.dart';
import '../../../Others/Const/Const.dart';
import '../../../Others/Tool/HudTool.dart';
import '../../../Others/Tool/GlobalTool.dart';
import '../../../Others/View/MESSelectionItemWidget.dart';
import '../../../Others/View/MESContentInputWidget.dart';
import '../Widget/ProjectTextInputWidget.dart';

class ProjectReturnRepairmentNonLotPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {   
    return _ProjectReturnRepairmentNonLotPageState();
  }  
}

class _ProjectReturnRepairmentNonLotPageState extends State<ProjectReturnRepairmentNonLotPage> {
  String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: randomColor(),
      child: Column(
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
                // _btnConfirmClicked();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView(
      children: <Widget>[
        _buildSelectionInputItem(0),
        _buildSelectionInputItem(1),
        _buildSelectionInputItem(2),
        _buildSelectionInputItem(3),
        _buildTextInputWidgetItem(0),
        _buildSelectionInputItem(4),
        _buildContentInputItem(),
        _buildFooter(),
      ],
    );
  }

  Widget _buildTextInputWidgetItem(int index) {
    String title = "";
    String placeholder = "";
    bool canScan = false;
    if (index == 0) {
      title = "返修数量";
      placeholder = "请输入数字(只能输入数字)";
    }
    ProjectTextInputWidget wgt = ProjectTextInputWidget(
      title: title,
      placeholder: placeholder,
      canScan: canScan,
    );

    return wgt;
  }

  Widget _buildSelectionInputItem(int index) {
    String title = "";
    bool enabled = true;
    if (index == 0) {
      title = "作业中心";
    } else if (index == 1) {
      title = "工程";
    } else if (index == 2) {
      title = "工单";
      enabled = false;
    } else if (index == 3) {
      title = "原因工序";
    } else if (index == 4) {
      title = "返修代码";
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
    print("_hasSelectedItem: $index");
  }

  Widget _buildContentInputItem() {
    void Function(String) contentChangedBlock = (String newContent) {
      // print("contentChangedBlock: $newContent");
      this.content = newContent;
    };
    return MESContentInputWidget(
      placeholder: "备注",
      contentChangedBlock: contentChangedBlock,
    );
  }

  Widget _buildFooter() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      // color: randomColor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "【注意事项】",
            style: TextStyle(fontSize: 18, color: hexColor("666666")),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
            // color: randomColor(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '>未流出构成Lot的返修，请在"工程"中返修',
                  style: TextStyle(color: hexColor("333333"), fontSize: 10),
                ),
                Text(
                  '>已流出Lot的返修，请在"流出"中返修',
                  style: TextStyle(color: hexColor("333333"), fontSize: 10),
                ),
                Text(
                  '>已流出Lot部分返修，请先"分批"后再返修',
                  style: TextStyle(color: hexColor("333333"), fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}