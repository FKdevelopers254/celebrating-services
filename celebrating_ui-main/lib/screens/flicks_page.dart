import '../widgets/flick_screen.dart';
import 'package:flutter/material.dart';

import '../models/flick.dart';
import '../services/search_service.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class FlicksPage extends StatefulWidget {
  const FlicksPage({super.key});
  @override
  State<FlicksPage> createState() => _FlicksPageState();
}

class _FlicksPageState extends State<FlicksPage> {
  late List<Flick> _flickResults = [];

  @override
  void initState() {
    super.initState();
    _loadFlicks();
  }

  Future<void> _loadFlicks() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final token = appState.jwtToken;
    if (token == null) {
      // Handle missing token (e.g., redirect to login or show error)
      return;
    }
    final results = await SearchService.searchFlicks('all', token: token);
    setState(() {
      _flickResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: FlickScreen(flicks: _flickResults));
  }
}
