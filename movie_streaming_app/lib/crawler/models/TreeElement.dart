class TreeElement {
  double top;
  double left;
  double width;
  double height;
  String color;

  TreeElement({this.top, this.left, this.width, this.height, this.color});

  TreeElement.fromJson(Map<String, dynamic> json) {
    top = json['top'];
    left = json['left'];
    width = json['width'];
    height = json['height'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['top'] = this.top;
    data['left'] = this.left;
    data['width'] = this.width;
    data['height'] = this.height;
    data['color'] = this.color;
    return data;
  }
}