enum BinderSide { front, back }

String binderSideToString(BinderSide side) {
  switch (side) {
    case BinderSide.front:
      return 'Front';
    case BinderSide.back:
      return 'Back';
  }
}

int virtualPageFromSheet({required int sheetNumber, required BinderSide side}) {
  final base = (sheetNumber - 1) * 2;
  return side == BinderSide.front ? base + 1 : base + 2;
}

int sheetFromVirtualPage(int virtualPage) {
  return (virtualPage + 1) ~/ 2;
}

BinderSide sideFromVirtualPage(int virtualPage) {
  return virtualPage.isOdd ? BinderSide.front : BinderSide.back;
}

String irlPageLabelFromVirtualPage(int virtualPage) {
  final sheet = sheetFromVirtualPage(virtualPage);
  final side = sideFromVirtualPage(virtualPage);
  return 'Sheet $sheet • ${binderSideToString(side)}';
}
