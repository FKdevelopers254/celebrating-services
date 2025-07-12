import '../widgets/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Assuming you use provider for theme/localization
import '../app_state.dart'; // Your app state for theme/locale
import '../l10n/supported_languages.dart'; // Your supported languages definition
import '../models/comment.dart';
import '../models/like.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/feed_service.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_dropdown.dart';
import '../widgets/post_card.dart'; // Your reusable AppDropdown widget
import '../widgets/bottom_navigation.dart';
import '../utils/route.dart';
import '../widgets/video_player_widget.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Post> posts = [];
  bool isLoading = false;
  int _selectedIndex = 0;

  // Global mute state for feed videos
  static final ValueNotifier<bool> feedMuteNotifier = ValueNotifier<bool>(
    true,
  ); // true = muted by default

  // Fetch feed from FeedService and update posts
  Future<void> fetchFeed() async {
    setState(() {
      isLoading = true;
    });
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final token = appState.jwtToken;
      if (token == null) {
        setState(() {
          isLoading = false;
        });
        // Handle missing token (e.g., redirect to login or show error)
        return;
      }
      final fetchedPosts = await FeedService.getFeed(token: token);
      setState(() {
        posts = fetchedPosts;
      });
    } catch (e) {
      print('Error fetching feed: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  //TODO: Video sound is still playing when I navigate to another page. Use widget lifecycle to fix this
  @override
  void deactivate() {
    // Pause and dispose video when this screen is deactivated (e.g., tab switch, navigation shell)
    PostCardVideoPlaybackManager().pauseCurrent();
    PostCardVideoPlaybackManager().disposeCurrentController();
    super.deactivate();
  }

  @override
  void dispose() {
    // Clean up all video playback when leaving the feed screen
    PostCardVideoPlaybackManager().pauseCurrent();
    PostCardVideoPlaybackManager().disposeCurrentController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Drawer Header',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ListTile(title: Text('Item 1')),
            ListTile(title: Text('Item 2')),
          ],
        ),
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, profileScreen);
                  },
                  child: Consumer<AppState>(
                    builder: (context, appState, _) {
                      final avatarUrl =
                          appState
                              .userAvatarUrl; // Ensure this is set in AppState
                      return CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(0.5),
                        backgroundImage:
                            avatarUrl != null && avatarUrl.isNotEmpty
                                ? NetworkImage(avatarUrl)
                                : null,
                        child:
                            avatarUrl == null || avatarUrl.isEmpty
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                      );
                    },
                  ),
                ),
              ),
            ),
            // In your widget tree
            AppTransparentButton(
              text: 'Profile',
              icon: Icons.person_outline,
              onPressed: () {
                Navigator.pushReplacementNamed(context, profileScreen);
              },
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              borderRadius: BorderRadius.circular(25),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder:
            (context, i) =>
                PostCard(post: posts[i], feedMuteNotifier: feedMuteNotifier),
      ),
    );
  }
}

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  State<MyAppBar> createState() => _MyAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // Standard AppBar height
}

class _MyAppBarState extends State<MyAppBar> {
  String _currentFeedType = 'FEED'; // State for the selected feed type

  @override
  Widget build(BuildContext context) {
    // You might want to get theme colors dynamically here if needed for icons/text,
    // but default AppBar styling usually handles it well.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor =
        isDark
            ? Colors.white
            : Colors.black; // Example for text color if needed

    return AppBar(
      backgroundColor:
          Colors
              .transparent, // Make AppBar transparent to show background if any
      elevation: 0, // No shadow
      leadingWidth: 60, // Adjust if needed
      leading: IconButton(
        icon: Icon(
          Icons.menu,
          color: Theme.of(context).iconTheme.color,
        ), // Hamburger icon
        onPressed: () {
          // Implement sidebar/drawer opening logic here
          Scaffold.of(context).openDrawer(); // Example: opens a Drawer
        },
      ),
      title: SizedBox(
        width: 120, // Adjust width as needed for the dropdown
        child: AppDropdown<String>(
          labelText: _currentFeedType,
          value: _currentFeedType,
          items: const [
            DropdownMenuItem(value: 'FEED', child: Text('FEED')),
            DropdownMenuItem(value: 'POPULAR', child: Text('POPULAR')),
            DropdownMenuItem(value: 'TRENDING', child: Text('TRENDING')),
          ],
          onChanged: (String? newValue) {
            setState(() {
              if (newValue != null) {
                _currentFeedType = newValue;
                // Add logic to change your feed based on selection (e.g., call a BLoC/Provider method)
                print('Selected Feed Type: $_currentFeedType');
              }
            });
          },
          isFormField: false, // It's not a form field
          labelTextStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: textColor, // Use the dynamically set text color
          ),
        ),
      ),
      // centerTitle: true, // Center the title (the FEED dropdown)
      actions: [
        IconButton(
          icon: Icon(
            Icons.search,
            color: Theme.of(context).iconTheme.color,
          ), // Search icon
          onPressed: () {
            // Implement search functionality
            print('Search tapped');
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: GestureDetector(
            onTap: () {
              // Implement profile navigation
              print('Profile picture tapped');
              Scaffold.of(context).openEndDrawer();
            },
            child: CircleAvatar(
              radius: 22, // Adjust size
              backgroundColor: Theme.of(
                context,
              ).colorScheme.secondary.withOpacity(0.5), // Placeholder color
              // You would typically load an actual image here:
              // backgroundImage: NetworkImage('your_profile_picture_url'),
              child: const Icon(
                Icons.person,
                color: Colors.white,
              ), // Placeholder icon
            ),
          ),
        ),
        const SizedBox(width: 8), // Some padding on the right edge
      ],
    );
  }
}
