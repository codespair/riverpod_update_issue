import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.dark,
      ),
      home: MyHomePage(),
    );
  }
}

List<String> validValues = ['Zero', 'One', 'Two', 'All'];

// create simple FutureProvider with respective future call next
final futureListProvider =
    FutureProvider.family<List<String>, int>((ref, value) => _getList(value));

// in a real case there would be an await call inside this function to network or local db or file system, etc...
Future<List<String>> _getList(int value) async {
  List<String> result = [...validValues];
  if (value == -1) {
    // do nothing just return original result...
  } else {
    result = []..add(result[value]);
  }
  debugPrint('Provider refreshed, result => $result');
  return result;
}

// The screen widget where we will use the provider
class MyHomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    var stringListProvider = useProvider(futureListProvider(-1));
    var dropDownValue = useState<String>('All');
    // state for toggle buttongs
    var _toggleSelection = useState<List<bool>>(List.generate(3, (_) => false));

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Why???'),
      ),
      body: Column(children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 1,
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.fromLTRB(5, 2, 5, 1),
                  child: DropdownButton<String>(
                    key: UniqueKey(),
                    value: dropDownValue.value.toString(),
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    elevation: 16,
                    underline: Container(
                      height: 1,
                      color: Theme.of(context).primaryColor,
                    ),
                    onChanged: (String? newValue) {
                      dropDownValue.value = newValue!;
                      context
                          .refresh(futureListProvider(intFromString(newValue)));
                    },
                    items: validValues
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: Theme.of(context).primaryTextTheme.subtitle1,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: ToggleButtons(
                  children: [
                    Tooltip(
                      key: UniqueKey(),
                      message: 'Zero',
                      child: Icon(
                        Icons.one_k,
                      ),
                    ),
                    Tooltip(
                      key: UniqueKey(),
                      message: 'One',
                      child: Icon(Icons.two_k),
                    ),
                    Tooltip(
                      key: UniqueKey(),
                      message: 'Two',
                      child: Icon(Icons.three_k),
                    ),
                  ],
                  isSelected: _toggleSelection.value,
                  onPressed: (int index) {
                    // also want to refresh the provider here, but one at a time...
                  },
                ),
              ),
            ],
          ),
        ),
        Container(
          key: UniqueKey(),
          height: 200,
          child: stringListProvider.when(
            data: (stringList) {
              debugPrint('List from Provider.when $stringList');
              return MyListWidget(stringList);
              // return _buildList(stringList);
            },
            loading: () => CircularProgressIndicator(),
            error: (_, __) => Text('OOOPsss error'),
          ),
        ),
      ]),
    );
  }

  Widget _buildList(List<String> stringList) {
    debugPrint('stringList in buildList $stringList');
    return ListView.builder(
      itemCount: stringList.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          child: Padding(
              padding: EdgeInsets.all(10), child: Text(stringList[index])),
        );
      },
    );
  }

  int intFromString(String value) {
    if (value == 'Zero') return 0;
    if (value == 'One') return 1;
    if (value == 'Two') return 2;
    return -1;
  }
}

class MyListWidget extends HookWidget {
  final GlobalKey<ScaffoldState> _widgetKey = GlobalKey<ScaffoldState>();
  final List<String> stringList;

  MyListWidget(this.stringList);

  @override
  Widget build(BuildContext context) {
    debugPrint('stringList in MyListWidget.build $stringList');
    return ListView.builder(
      key: _widgetKey,
      itemCount: stringList.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          key: UniqueKey(),
          child: Padding(
              padding: EdgeInsets.all(10), child: Text(stringList[index])),
        );
      },
    );
  }
}
