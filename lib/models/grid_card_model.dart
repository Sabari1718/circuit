class GridCardModel {
  final String serialNumber;

  final Map<String, String> gridData;

  final List<String> columns = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G'
  ];

  final List<int> rows = [
    1,
    2,
    3,
    4,
    5
  ];

  GridCardModel({
    required this.serialNumber,
    required this.gridData,
  });

  factory GridCardModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final mainData =
    json['data']['data'];

    final rawGrid =
    mainData['grid_data']
    as Map<String, dynamic>;

    Map<String, String> parsedValues =
    {};

    rawGrid.forEach((key, value) {
      parsedValues[key] =
          value.toString();
    });

    return GridCardModel(
      serialNumber:
      mainData['card_serial_number']
          ?.toString() ??
          '',

      gridData: parsedValues,
    );
  }

  get values => null;
}