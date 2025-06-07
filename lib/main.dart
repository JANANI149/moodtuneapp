import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteSongsProvider()),
      ],
      child: MoodTunesApp(),
    ),
  );
}

// Theme Provider
class ThemeProvider with ChangeNotifier {
  bool isDark = true;
  ThemeData get currentTheme => isDark ? ThemeData.dark() : ThemeData.light();

  void toggleTheme() {
    isDark = !isDark;
    notifyListeners();
  }
}

// User Profile Provider
class UserProfileProvider with ChangeNotifier {
  String name = "Janani";
  String email = "janani@example.com";
  bool notificationsOn = true;

  void updateProfile(String newName, String newEmail) {
    name = newName;
    email = newEmail;
    notifyListeners();
  }

  void toggleNotifications() {
    notificationsOn = !notificationsOn;
    notifyListeners();
  }
}

// Favorite Songs Provider
class FavoriteSongsProvider with ChangeNotifier {
  final List<String> favorites = [];

  void toggleFavorite(String song) {
    if (favorites.contains(song)) {
      favorites.remove(song);
    } else {
      favorites.add(song);
    }
    notifyListeners();
  }

  bool isFavorite(String song) => favorites.contains(song);
}

// App Root
class MoodTunesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'MoodTunes',
      debugShowCheckedModeBanner: false,
      theme: theme.currentTheme,
      home: SplashScreen(),
    );
  }
}

// Fade Page Transition
Route fadeTransition(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, animation, __) => page,
    transitionsBuilder: (_, anim, __, child) =>
        FadeTransition(opacity: anim, child: child),
  );
}

// Splash Screen
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(context, fadeTransition(HomeScreen()));
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.graphic_eq, size: 80, color: Colors.purple),
            SizedBox(height: 20),
            Text('MoodTunes',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            Text('Feel the music. Match your mood.',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// Mood Record
class MoodRecord {
  final String mood;
  final DateTime time;
  MoodRecord(this.mood, this.time);
}

List<MoodRecord> moodHistory = [];

// Emoji Button
class EmojiButton extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  EmojiButton({required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        avatar: Text(emoji, style: TextStyle(fontSize: 18)),
        label: Text(label),
        backgroundColor: Colors.purple.shade50,
      ),
    );
  }
}

// Home Screen
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final moodController = TextEditingController();
  List<String> moodSongs = [];
  List<String> filteredSongs = [];

  Map<String, List<String>> tamilPlaylist = {
    "happy": [
      "Vaathi Coming - Master",
      "Chill Bro - Pattas",
      "Jimikki Kammal",
      "So Baby - Doctor"
    ],
    "sad": [
      "Kannazhaga - 3",
      "Naan Un - 24",
      "Pookkal Pookkum - Madarasapattinam",
    ],
    "relaxed": [
      "Enna Solla - Thanga Magan",
      "Thalli Pogathey - AYM",
      "Munbe Vaa - SOK"
    ],
    "angry": [
      "Aalaporan Tamizhan - Mersal",
      "Surviva - Vivegam",
      "Mersal Arasan - Mersal"
    ]
  };

  final moodFacts = {
    "happy": "Smiling can instantly lift your mood.",
    "sad": "Crying can be a healthy way to release emotions.",
    "relaxed": "Deep breathing reduces stress and improves mood.",
    "angry": "Listening to music can help release anger safely.",
  };

  String getPlaylistKey(String mood) {
    final lower = mood.toLowerCase();
    if (lower.contains("happy")) return "happy";
    if (lower.contains("sad")) return "sad";
    if (lower.contains("relaxed")) return "relaxed";
    if (lower.contains("angry")) return "angry";
    return "happy";
  }

  void submitMood(String mood) {
    final key = getPlaylistKey(mood);
    moodHistory.add(MoodRecord(mood, DateTime.now()));
    setState(() {
      moodSongs = tamilPlaylist[key] ?? [];
      filteredSongs = List.from(moodSongs);
    });
    final fact = moodFacts[key] ?? "Music helps you feel better!";
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(fact)));
  }

  void searchSongs(String query) {
    setState(() {
      filteredSongs = moodSongs
          .where((song) => song.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final favorites = Provider.of<FavoriteSongsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("MoodTunes"),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () =>
                Navigator.push(context, fadeTransition(FavoriteSongsScreen())),
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () =>
                Navigator.push(context, fadeTransition(MoodHistoryScreen())),
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () =>
                Navigator.push(context, fadeTransition(SettingsScreen())),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('What’s your mood today?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          Wrap(spacing: 10, children: [
            EmojiButton(emoji: "😊", label: "Happy", onTap: () => submitMood("happy")),
            EmojiButton(emoji: "😢", label: "Sad", onTap: () => submitMood("sad")),
            EmojiButton(emoji: "😠", label: "Angry", onTap: () => submitMood("angry")),
            EmojiButton(emoji: "😌", label: "Relaxed", onTap: () => submitMood("relaxed")),
          ]),
          SizedBox(height: 15),
          TextField(
            controller: moodController,
            decoration: InputDecoration(
              hintText: "Type your mood (happy, sad...)",
              prefixIcon: Icon(Icons.emoji_emotions),
            ),
            onSubmitted: submitMood,
          ),
          SizedBox(height: 15),
          TextField(
            decoration: InputDecoration(
              hintText: "Search songs",
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: searchSongs,
          ),
          SizedBox(height: 20),
          Text("Songs:", style: TextStyle(fontWeight: FontWeight.bold)),
          ...filteredSongs.map((song) => ListTile(
                leading: Icon(Icons.music_note, color: Colors.purple),
                title: Text(song,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                trailing: IconButton(
                  icon: Icon(
                    favorites.isFavorite(song)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: favorites.isFavorite(song) ? Colors.red : null,
                  ),
                  onPressed: () => favorites.toggleFavorite(song),
                ),
              )),
        ]),
      ),
    );
  }
}

// Mood History Screen
class MoodHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mood History")),
      body: moodHistory.isEmpty
          ? Center(child: Text("No mood history yet!"))
          : ListView.builder(
              itemCount: moodHistory.length,
              itemBuilder: (_, i) {
                final record = moodHistory[i];
                return ListTile(
                  leading: Icon(Icons.emoji_emotions, color: Colors.purple),
                  title: Text(record.mood,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    "${record.time.day}/${record.time.month}/${record.time.year} - ${record.time.hour}:${record.time.minute.toString().padLeft(2, '0')}",
                  ),
                );
              },
            ),
    );
  }
}

// Favorite Songs Screen
class FavoriteSongsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final favorites = Provider.of<FavoriteSongsProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text("Favorite Songs")),
      body: favorites.favorites.isEmpty
          ? Center(child: Text("No favorite songs yet!"))
          : ListView(
              children: favorites.favorites
                  .map((song) => ListTile(
                        leading: Icon(Icons.music_note, color: Colors.purple),
                        title: Text(song),
                      ))
                  .toList(),
            ),
    );
  }
}

// Settings Screen
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final profile = Provider.of<UserProfileProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(children: [
          ListTile(
            title: Text("Dark Mode"),
            trailing: Switch(
              value: theme.isDark,
              onChanged: (_) => theme.toggleTheme(),
            ),
          ),
          ListTile(
            title: Text("Notifications"),
            trailing: Switch(
              value: profile.notificationsOn,
              onChanged: (_) => profile.toggleNotifications(),
            ),
          ),
          ListTile(
            title: Text("Edit Profile"),
            trailing: Icon(Icons.edit),
            onTap: () =>
                Navigator.push(context, fadeTransition(EditProfileScreen())),
          ),
        ]),
      ),
    );
  }
}

// Edit Profile Screen
class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<UserProfileProvider>(context, listen: false);
    nameController = TextEditingController(text: profile.name);
    emailController = TextEditingController(text: profile.email);
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<UserProfileProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: "Name"),
          ),
          SizedBox(height: 10),
          TextField(
            controller: emailController,
            decoration: InputDecoration(labelText: "Email"),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            child: Text("Save"),
            onPressed: () {
              profile.updateProfile(
                  nameController.text, emailController.text);
              Navigator.pop(context);
            },
          )
        ]),
      ),
    );
  }
}