import 'package:flutter/cupertino.dart';
import 'providers/app_state.dart';
import 'pages/dashboard_page.dart';
import 'pages/add_transaction_page.dart';
import 'pages/history_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppState _appState = AppState();

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Spendid',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        primaryColor: CupertinoColors.activeBlue,
        // Adapts based on light or dark modes automatically
      ),
      home: SpendidMainScaffold(state: _appState),
    );
  }
}

class SpendidMainScaffold extends StatefulWidget {
  final AppState state;

  const SpendidMainScaffold({
    super.key,
    required this.state,
  });

  @override
  State<SpendidMainScaffold> createState() => _SpendidMainScaffoldState();
}

class _SpendidMainScaffoldState extends State<SpendidMainScaffold> {
  final CupertinoTabController _tabController = CupertinoTabController();

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, child) {
        return CupertinoTabScaffold(
          controller: _tabController,
          tabBar: CupertinoTabBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.chart_bar_square),
                activeIcon: Icon(CupertinoIcons.chart_bar_square_fill),
                label: 'สรุปผล',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.plus_circle),
                activeIcon: Icon(CupertinoIcons.plus_circle_fill),
                label: 'บันทึก',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.square_list),
                activeIcon: Icon(CupertinoIcons.square_list_fill),
                label: 'ประวัติ',
              ),
            ],
          ),
          tabBuilder: (context, index) {
            switch (index) {
              case 0:
                return CupertinoTabView(
                  builder: (context) => DashboardPage(
                    state: widget.state,
                    onNavigateToHistory: () {
                      _tabController.index = 2;
                    },
                  ),
                );
              case 1:
                return CupertinoTabView(
                  builder: (context) => AddTransactionPage(state: widget.state),
                );
              case 2:
                return CupertinoTabView(
                  builder: (context) => HistoryPage(state: widget.state),
                );
              default:
                return const Center(child: Text('Unknown tab'));
            }
          },
        );
      },
    );
  }
}