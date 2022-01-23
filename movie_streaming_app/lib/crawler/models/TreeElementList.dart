import 'TreeElement.dart';

class TreeElementList {
  List<TreeElement> treeElements;

  TreeElementList({this.treeElements}) {
    treeElements = <TreeElement>[];
  }

  TreeElementList.fromJson(Map<String, dynamic> json) {
    if (json['elementsTree'] != null) {
      treeElements = <TreeElement>[];
      json['elementsTree'].forEach((v) {
        treeElements.add(new TreeElement.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.treeElements != null) {
      data['treeElementList'] = this.treeElements.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
