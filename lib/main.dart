import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'package:mailto/mailto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:csv/csv.dart';
import 'package:printing/printing.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => const HomePage(),
        '/tuberculosisDetection': (context) => const TuberculosisDetectionPage(),
        '/patientData': (context) => const PatientDataPage(),
        '/referrals': (context) => const ReferralsPage(),
        '/progressMonitoring': (context) => const ProgressMonitoringPage(),
        '/awareness': (context) => const AwarenessPage(),
        '/diagnosisReport': (context) => const DiagnosisReportPage(),
        '/signup': (context) => SignUpPage(),
      },
    );
  }
}

class DatabaseHelper {
  static Future<Database> database() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'medical.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE users (id INTEGER PRIMARY KEY, username TEXT, password TEXT)');
      },
    );
  }

  static Future<void> insertUser({required String username, required String password}) async {
    final db = await database();
    await db.rawInsert('INSERT INTO users(username, password) VALUES("$username", "$password")');
  }

  static Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database();
    return db.rawQuery('SELECT * FROM users');
  }
}


class LoginPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({super.key});

  bool _isPasswordValid(String password) {
    RegExp regex = RegExp(r'^(?=.*[A-Z])(?=.*[!@#$%^&*(),.?":{}|<>])(?=.*[0-9]).{7,}$');
    return regex.hasMatch(password);
  }

  void login(BuildContext context) async {
    final username = usernameController.text;
    final password = passwordController.text;

    if (!_isPasswordValid(password)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
              'Password must be at least 7 characters long, contain at least one uppercase letter, one special character, and one numeric character.',
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    // Simulate fetching users from a database
    final users = await DatabaseHelper.getUsers();
    final authenticatedUser = users.firstWhere(
      (user) => user['username'] == username && user['password'] == password,
      orElse: () => null!,
    );

    if (authenticatedUser == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Incorrect username or password.'),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    Navigator.pushNamed(context, '/home');
  }

  void goToSignUp(BuildContext context) {
    Navigator.pushNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: const Color(0xFF00897B), // Medical teal color
      ),
      body: SingleChildScrollView(
        child: Container(
          height: screenHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)], // Light blue medical gradient
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.1),
                Image.asset(
                  'assets/images/img.png',
                  height: screenHeight * 0.3,
                  width: screenHeight * 0.3,
                ),
                SizedBox(height: screenHeight * 0.03),
                _buildInputField(
                  controller: usernameController,
                  labelText: 'Username',
                  icon: Icons.person,
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildInputField(
                  controller: passwordController,
                  labelText: 'Password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                SizedBox(height: screenHeight * 0.05),
                ElevatedButton(
                  onPressed: () => login(context),
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.tealAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: const Color(0xFF00897B), // Medical teal button
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => goToSignUp(context),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(color: Colors.teal, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.blueAccent,
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.teal),
          prefixIcon: Icon(icon, color: Colors.teal),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        obscureText: obscureText,
      ),
    );
  }
}

class SignUpPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  SignUpPage({super.key});

  void signUp(BuildContext context) async {
    final username = usernameController.text;
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (password != confirmPassword) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Password Mismatch'),
            content: const Text('Passwords do not match.'),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    if (!isValidPassword(password)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Invalid Password'),
            content: const Text(
              'Password must be at least 7 characters long and contain at least one uppercase letter, one lowercase letter, and one number.',
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    await DatabaseHelper.insertUser(username: username, password: password);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Sign up successful. Please log in.'),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool isValidPassword(String password) {
    RegExp regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{7,}$');
    return regex.hasMatch(password);
  }

  void goToLogin(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: const Color(0xFF00897B), // Medical teal color
      ),
      body: SingleChildScrollView(
        child: Container(
          height: screenHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)], // Medical gradient colors
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.1),
                Image.asset(
                  'assets/images/img.png',
                  height: screenHeight * 0.3,
                  width: screenHeight * 0.3,
                ),
                SizedBox(height: screenHeight * 0.03),
                _buildInputField(
                  controller: usernameController,
                  labelText: 'Username',
                  icon: Icons.person,
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildInputField(
                  controller: passwordController,
                  labelText: 'Password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildInputField(
                  controller: confirmPasswordController,
                  labelText: 'Confirm Password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                SizedBox(height: screenHeight * 0.05),
                ElevatedButton(
                  onPressed: () => signUp(context),
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.tealAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: const Color(0xFF00897B), // Medical teal button
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => goToLogin(context),
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(color: Colors.teal, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.blueAccent,
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.teal),
          prefixIcon: Icon(icon, color: Colors.teal),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        obscureText: obscureText,
      ),
    );
  }
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const PatientDataPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    Navigator.push(
      this.context,
      MaterialPageRoute(builder: (context) => _pages[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF00897B), // Teal color for a medical feel
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildElementCard(
                  context: context,
                  title: 'Cancer Detection',
                  icon: FontAwesomeIcons.heartbeat,
                  targetPage: const CancerSelectionPage(),
                ),
                _buildElementCard(
                  context: context,
                  title: 'Tuberculosis Detection',
                  icon: FontAwesomeIcons.stethoscope,
                  targetPage: const TuberculosisDetectionPage(),
                ),
                _buildElementCard(
                  context: context,
                  title: 'Patient Data',
                  icon: FontAwesomeIcons.userInjured,
                  targetPage: const PatientDataPage(),
                ),
                _buildElementCard(
                  context: context,
                  title: 'Referrals',
                  icon: FontAwesomeIcons.shareAlt,
                  targetPage: const ReferralsPage(),
                ),
                _buildElementCard(
                  context: context,
                  title: 'Progress Monitoring',
                  icon: FontAwesomeIcons.chartLine,
                  targetPage: const ProgressMonitoringPage(),
                ),
                _buildElementCard(
                  context: context,
                  title: 'Awareness Campaigns',
                  icon: FontAwesomeIcons.bullhorn,
                  targetPage: const AwarenessPage(),
                ),
                _buildElementCard(
                  context: context,
                  title: 'Diagnosis Report',
                  icon: FontAwesomeIcons.fileMedical,
                  targetPage: const DiagnosisReportPage(),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: const Color(0xFF00897B),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildElementCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget targetPage,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        elevation: 6,
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              FaIcon(icon, color: const Color(0xFF00897B), size: 40),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _username = '';
  String _oldPassword = '';
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    // Load the user's profile data from the database
    Database db = await openDatabase('medical.db');
    List<Map<String, dynamic>> userData = await db.query('users', limit: 1);
    await db.close();

    if (userData.isNotEmpty) {
      setState(() {
        _username = userData[0]['username'];
        _oldPassword = userData[0]['password'];
        _usernameController.text = _username;
        _oldPasswordController.text = _oldPassword;
      });
    }
  }

  Future<void> _saveProfileData() async {
    // Validate the new password
    if (!_isValidPassword(_newPasswordController.text)) {
      _showAlertDialog('Invalid Password', 'The new password must be at least 7 characters long and contain at least one uppercase letter, one special character, and one number.');
      return;
    }

    // Confirm the new password
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showAlertDialog('Password Mismatch', 'The new password and confirmation do not match.');
      return;
    }

    // Update the user's profile data in the database
    String newUsername = _usernameController.text;
    String newPassword = _newPasswordController.text;

    Database db = await openDatabase('users.db');
    await db.update('users', {'username': newUsername, 'password': newPassword}, where: 'id = ?', whereArgs: [1]);
    await db.close();

    setState(() {
      _username = newUsername;
      _oldPassword = newPassword;
    });

    _showAlertDialog('Profile Updated', 'Your profile has been updated successfully.');
  }

  bool _isValidPassword(String password) {
    RegExp regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[!@#\$&*~])(?=.*?[0-9]).{7,}$');
    return regex.hasMatch(password);
  }

  void _showAlertDialog(String title, String content) {
    showDialog(
      context: this.context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        backgroundColor: const Color(0xFF00838F), // Professional teal
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileField(
              controller: _usernameController,
              label: 'Username',
              icon: Icons.person,
            ),
            const SizedBox(height: 16.0),
            _buildProfileField(
              controller: _oldPasswordController,
              label: 'Old Password',
              icon: Icons.lock,
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            _buildProfileField(
              controller: _newPasswordController,
              label: 'New Password',
              icon: Icons.lock_outline,
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            _buildProfileField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              icon: Icons.lock_outline,
              obscureText: true,
            ),
            const SizedBox(height: 32.0),
            Center(
              child: ElevatedButton(
                onPressed: _saveProfileData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00838F), // Teal for medical tone
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF00838F)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      ),
    );
  }
}

class ElementCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const ElementCard({super.key, 
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromARGB(255, 186, 221, 238),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 90,
              color: Colors.blue,
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class TuberculosisDetectionPage extends StatefulWidget {
  const TuberculosisDetectionPage({super.key});

  @override
  _TuberculosisDetectionPageState createState() =>
      _TuberculosisDetectionPageState();
}

class _TuberculosisDetectionPageState extends State<TuberculosisDetectionPage> {
  File? _xrayImage;
  bool _loading = false;
  String _result = '';

  Future<void> _getXrayImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _xrayImage = File(pickedImage.path);
      });
    }
  }

  void _detectTuberculosis() {
    setState(() {
      _loading = true;
      _result = '';
    });

    // Simulate X-ray analysis delay
    Future.delayed(const Duration(seconds: 2), () {
      bool hasTuberculosis = Random().nextBool();

      setState(() {
        _loading = false;
        _result = hasTuberculosis
            ? 'Tuberculosis likely detected. Please consult a healthcare professional for further evaluation.'
            : 'No tuberculosis detected based on the image.';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuberculosis Detection'),
        backgroundColor: const Color(0xFF00838F), // Professional teal color
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Upload an Image for Tuberculosis Detection:',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16.0),
            if (_xrayImage != null)
              Center(
                child: Image.file(
                  _xrayImage!,
                  width: 400,
                  height: 300,
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Center(
                  child: Icon(
                    Icons.image,
                    color: Color(0xFF00838F), // Medical teal color
                    size: 80,
                  ),
                ),
              ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: _getXrayImage,
              icon: const Icon(Icons.image_search),
              label: const Text('Select Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00838F), // Teal color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15.0),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: _xrayImage == null ? null : _detectTuberculosis,
              icon: const Icon(Icons.medical_services),
              label: const Text('Scan for Tuberculosis'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _xrayImage == null
                    ? Colors.grey
                    : const Color(0xFF00838F), // Conditional button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15.0),
              ),
            ),
            const SizedBox(height: 32.0),
            if (_loading)
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF00838F),
                ),
              )
            else if (_result.isNotEmpty)
              Text(
                _result,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: _result.contains('likely detected')
                      ? Colors.red
                      : Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}


class PatientDataPage extends StatefulWidget {
  const PatientDataPage({super.key});

  @override
  _PatientDataPageState createState() => _PatientDataPageState();
}

class _PatientDataPageState extends State<PatientDataPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String name = '';
  int age = 0;
  String address = '';
  String medicalHistory = '';
  String disease = '';

  Future<Database> _openDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'patients.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE patients (
            id INTEGER PRIMARY KEY,
            name TEXT,
            age INTEGER,
            address TEXT,
            medicalHistory TEXT,
            disease TEXT
          )
        ''');
      },
    );
  }

  Future<void> _savePatientData() async {
    if (!_formKey.currentState!.validate()) return;

    final database = await _openDatabase();
    await database.transaction((txn) async {
      await txn.rawInsert('''
        INSERT INTO patients (name, age, address, medicalHistory, disease)
        VALUES (?, ?, ?, ?, ?)
      ''', [name, age, address, medicalHistory, disease]);
    });
    await database.close();

    await _generatePdf();
    _showSuccessDialog();
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Patient Data', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            pw.Text('Name: $name'),
            pw.Text('Age: $age'),
            pw.Text('Address: $address'),
            pw.Text('Medical History: $medicalHistory'),
            pw.Text('Disease: $disease'),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/patient_data.pdf");
    await file.writeAsBytes(await pdf.save());

    await Share.shareFiles([file.path], text: 'Patient Data PDF');
  }

  void _sendEmail() async {
    final mailtoLink = Mailto(
      to: ['gumberocourage@gmail.com'],
      subject: 'Patient Data Submission',
      body: 'Please find attached the patient data.',
    );
    await launch('$mailtoLink');
  }

  void _showSuccessDialog() {
    showDialog(
      context: this.context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Patient data saved. Send to your doctor?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _sendEmail();
              },
              child: const Text('Send Email'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Data'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextFormField(
                label: 'Name',
                icon: FontAwesomeIcons.user,
                onSaved: (value) {
                  name = value!;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the patient\'s name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              _buildTextFormField(
                label: 'Age',
                icon: FontAwesomeIcons.calendarAlt,
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  age = int.tryParse(value!) ?? 0;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the patient\'s age';
                  } else if (int.tryParse(value) == null) {
                    return 'Please enter a valid age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              _buildTextFormField(
                label: 'Address',
                icon: FontAwesomeIcons.mapMarkerAlt,
                onSaved: (value) {
                  address = value!;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the patient\'s address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              _buildTextFormField(
                label: 'Medical History',
                icon: FontAwesomeIcons.fileMedical,
                onSaved: (value) {
                  medicalHistory = value!;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the patient\'s medical history';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              _buildTextFormField(
                label: 'Disease',
                icon: FontAwesomeIcons.disease,
                onSaved: (value) {
                  disease = value!;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the patient\'s disease';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _savePatientData();
                  }
                },
                icon: const Icon(FontAwesomeIcons.save),
                label: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required IconData icon,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: keyboardType,
      onSaved: onSaved,
      validator: validator,
    );
  }
}


class ReferralsPage extends StatefulWidget {
  const ReferralsPage({super.key});

  @override
  _ReferralsPageState createState() => _ReferralsPageState();
}

class _ReferralsPageState extends State<ReferralsPage> {
  void _launchGoogleMaps(double latitude, double longitude) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      debugPrint('Could not launch Google Maps');
    }
  }

  // Cancer Centers Data
  List<Map<String, dynamic>> cancerCenters = [
    {
      'name': 'Parirenyatwa Group of Hospitals',
      'address': 'Corner Mazoe Street & Delisle Ave, Harare',
      'latitude': -17.8244,
      'longitude': 31.0534,
    },
    {
      'name': 'Mpilo Central Hospital',
      'address': 'Corner Fife Street and 4th Avenue, Bulawayo',
      'latitude': -20.1606,
      'longitude': 28.5822,
    },
    {
      'name': 'United Bulawayo Hospitals',
      'address': 'Corner Fife Street and Josiah Tongogara, Bulawayo',
      'latitude': -20.1594,
      'longitude': 28.5853,
    },
  ];

  // Cancer Specialists Data
  List<Map<String, dynamic>> cancerSpecialists = [
    {
      'name': 'Dr. John Doe',
      'specialty': 'Oncologist',
      'address': '123 Main Street, Harare',
      'latitude': -17.8244,
      'longitude': 31.0534,
      'rating': 4.5,
    },
    {
      'name': 'Dr. Jane Smith',
      'specialty': 'Hematologist',
      'address': '456 Park Avenue, Bulawayo',
      'latitude': -20.1606,
      'longitude': 28.5822,
      'rating': 4.0,
    },
    {
      'name': 'Dr. Michael Johnson',
      'specialty': 'Radiation Oncologist',
      'address': '789 Oak Road, Mutare',
      'latitude': -18.9806,
      'longitude': 32.6707,
      'rating': 4.8,
    },
  ];

  // TB Specialists Data
  List<Map<String, dynamic>> tbSpecialists = [
    {
      'name': 'Dr. Sarah Wilson',
      'specialty': 'Pulmonologist',
      'address': '100 Health Street, Harare',
      'latitude': -17.8288,
      'longitude': 31.0511,
      'rating': 4.7,
    },
    {
      'name': 'Dr. Alan Walker',
      'specialty': 'TB Specialist',
      'address': '200 Medical Avenue, Bulawayo',
      'latitude': -20.1624,
      'longitude': 28.5901,
      'rating': 4.2,
    },
    {
      'name': 'Dr. Lisa Roberts',
      'specialty': 'Pulmonologist',
      'address': '300 Clinic Road, Gweru',
      'latitude': -19.4547,
      'longitude': 29.8176,
      'rating': 4.6,
    },
  ];

  // Function to build Google Maps
  Widget _buildMap(double latitude, double longitude) {
    return SizedBox(
      height: 150,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 14.0,
        ),
        markers: {
          Marker(
            markerId: MarkerId("location"),
            position: LatLng(latitude, longitude),
            
          ),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Referrals'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cancer Centers Section
              const Text(
                'Cancer Centers in Zimbabwe',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              Column(
                children: cancerCenters.map((center) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            center['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(center['address']),
                          const SizedBox(height: 10),
                          _buildMap(center['latitude'], center['longitude']),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.navigation),
                              label: const Text('Navigate'),
                              onPressed: () {
                                _launchGoogleMaps(
                                  center['latitude'],
                                  center['longitude'],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32.0),

              // Cancer Specialists Section
              const Text(
                'Cancer Specialists in Zimbabwe',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              Column(
                children: cancerSpecialists.map((specialist) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            specialist['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                              '${specialist['specialty']} - ${specialist['address']}'),
                          const SizedBox(height: 10),
                          _buildMap(specialist['latitude'], specialist['longitude']),
                          const SizedBox(height: 10),
                          RatingBarIndicator(
                            rating: specialist['rating'],
                            itemBuilder: (context, index) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 25.0,
                            direction: Axis.horizontal,
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.navigation),
                              label: const Text('Navigate'),
                              onPressed: () {
                                _launchGoogleMaps(
                                  specialist['latitude'],
                                  specialist['longitude'],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32.0),

              // TB Specialists Section
              const Text(
                'TB Specialists in Zimbabwe',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              Column(
                children: tbSpecialists.map((specialist) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            specialist['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                              '${specialist['specialty']} - ${specialist['address']}'),
                          const SizedBox(height: 10),
                          _buildMap(specialist['latitude'], specialist['longitude']),
                          const SizedBox(height: 10),
                          RatingBarIndicator(
                            rating: specialist['rating'],
                            itemBuilder: (context, index) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 25.0,
                            direction: Axis.horizontal,
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.navigation),
                              label: const Text('Navigate'),
                              onPressed: () {
                                _launchGoogleMaps(
                                  specialist['latitude'],
                                  specialist['longitude'],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProgressMonitoringPage extends StatefulWidget {
  const ProgressMonitoringPage({super.key});

  @override
  _ProgressMonitoringPageState createState() => _ProgressMonitoringPageState();
}

class _ProgressMonitoringPageState extends State<ProgressMonitoringPage> {
  final List<ProgressData> _progressData = [];
  DateTime _selectedDate = DateTime.now();
  double _painLevel = 0;
  double _treatmentEffectiveness = 0;
  String _progressMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cancer Treatment Progress'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Track Your Treatment Progress',
              style: TextStyle(
                fontSize: 26.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _painLevel = double.tryParse(value) ?? 0;
                      });
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter Pain Level (0-10)',
                      labelText: 'Pain Level',
                      prefixIcon: const Icon(FontAwesomeIcons.heartbeat),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton.icon(
                  onPressed: () {
                    _selectDate(context);
                  },
                  icon: const Icon(FontAwesomeIcons.calendarAlt),
                  label: const Text('Select Date'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            TextField(
              onChanged: (value) {
                setState(() {
                  _treatmentEffectiveness = double.tryParse(value) ?? 0;
                });
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Treatment Effectiveness (0-100%)',
                labelText: 'Effectiveness (%)',
                prefixIcon: const Icon(FontAwesomeIcons.notesMedical),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _progressData.add(ProgressData(
                    date: _selectedDate,
                    painLevel: _painLevel,
                    effectiveness: _treatmentEffectiveness,
                  ));
                  _analyzeProgress();
                });
              },
              icon: const Icon(FontAwesomeIcons.checkCircle),
              label: const Text('Log Progress'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
            ),
            const SizedBox(height: 24.0),
            const Text(
              'Treatment Progress Chart',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
  height: 300,
  child: LineChart(
    LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: _progressData
              .map((data) => FlSpot(
                  data.date.millisecondsSinceEpoch.toDouble(),
                  data.effectiveness.toDouble()))
              .toList(),
          isCurved: true,
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.teal.withOpacity(0.3),
                Colors.blue.withOpacity(0.3),
              ],
            ),
          ),
          dotData: FlDotData(show: true),
          color: Colors.teal,  // This is used for the line color
          barWidth: 4,
        ),
      ],
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          axisNameWidget: const Text(
            'Date',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        leftTitles: AxisTitles(
          axisNameWidget: const Text(
            'Effectiveness (%)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ),
  ),
),

            const SizedBox(height: 16.0),
            Text(
              _progressMessage,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: _progressMessage.contains('improving')
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _analyzeProgress() {
    if (_progressData.length < 2) {
      _progressMessage = 'Not enough data to determine progress.';
      return;
    }

    int improvementCount = 0;

    for (int i = 1; i < _progressData.length; i++) {
      if (_progressData[i].effectiveness > _progressData[i - 1].effectiveness) {
        improvementCount++;
      }
    }

    if (improvementCount > (_progressData.length / 2)) {
      _progressMessage = 'Treatment is improving.';
    } else {
      _progressMessage = 'Treatment is not improving.';
    }
  }
}

class ProgressData {
  final DateTime date;
  final double painLevel;
  final double effectiveness;

  ProgressData({
    required this.date,
    required this.painLevel,
    required this.effectiveness,
  });
}


class AwarenessPage extends StatelessWidget {
  const AwarenessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Awareness'),
        backgroundColor: Colors.teal[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),
            Row(
              children: [
                const Icon(FontAwesomeIcons.ribbon, color: Colors.teal, size: 30),
                const SizedBox(width: 10),
                Text(
                  'Cancer Awareness',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Cancer is a group of diseases characterized by the uncontrolled growth and spread of abnormal cells. '
              'It can affect various parts of the body, and early detection can significantly improve treatment outcomes.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Prevention Tips:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              '• Avoid tobacco and limit alcohol use\n'
              '• Eat a healthy diet rich in fruits and vegetables\n'
              '• Exercise regularly and maintain a healthy weight\n'
              '• Protect your skin from excessive sun exposure\n'
              '• Get vaccinated against cancer-causing viruses (e.g., HPV, Hepatitis B)',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Early Detection:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              '• Schedule regular screenings such as mammograms and colonoscopies.\n'
              '• Perform self-examinations (e.g., breast, skin) to notice any abnormalities.\n'
              '• Consult a doctor if you experience any unusual symptoms such as lumps, unexplained weight loss, or persistent pain.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                const Icon(FontAwesomeIcons.calendarAlt, color: Colors.teal, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'World Cancer Day - February 4th',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            const Text(
              'A global initiative to raise awareness and education about cancer. On this day, individuals and organizations come together to promote prevention, early detection, and treatment.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 24.0),
            Row(
              children: [
                const Icon(FontAwesomeIcons.lungs, color: Colors.teal, size: 30),
                const SizedBox(width: 10),
                Text(
                  'Tuberculosis Awareness',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Tuberculosis (TB) is an infectious disease primarily affecting the lungs. It spreads through airborne droplets when an infected person coughs or sneezes. TB is treatable and preventable with the right approach.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Symptoms of TB:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              '• Persistent cough lasting more than 3 weeks\n'
              '• Fever and night sweats\n'
              '• Fatigue and weakness\n'
              '• Weight loss and loss of appetite\n'
              '• Chest pain or coughing up blood',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Prevention and Treatment:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              '• Ensure proper ventilation in homes and workplaces\n'
              '• Use protective masks in areas with high infection rates\n'
              '• Complete the full course of prescribed TB treatment to avoid spreading the infection\n'
              '• Vaccination with Bacillus Calmette-Guérin (BCG) can provide protection, especially for infants and children.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                const Icon(FontAwesomeIcons.calendarCheck, color: Colors.teal, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'World TB Day - March 24th',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            const Text(
              'This day raises public awareness about the devastating health, social, and economic consequences of TB, and steps taken to combat it worldwide.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }
}


class DiagnosisReportPage extends StatelessWidget {
  const DiagnosisReportPage({super.key});

  // Function to generate CSV file
  Future<void> _generateCSV() async {
    List<List<String>> diagnosisData = [
      ['Condition', 'Diagnosis', 'Recommendation'],
      ['Breast Cancer', 'Malignant tumor detected in the right breast.', 'Immediate treatment is recommended.'],
      ['Lung Cancer', 'Stage 2 lung cancer detected.', 'Chemotherapy and radiation therapy recommended.'],
      ['Tuberculosis', 'Active tuberculosis infection.', 'Immediate treatment with antibiotics is necessary.'],
      ['Skin Cancer', 'Melanoma detected on the left forearm.', 'Surgical removal and follow-up care recommended.'],
    ];

    String csvData = const ListToCsvConverter().convert(diagnosisData);
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/diagnosis_report.csv';
    final file = File(path);
    await file.writeAsString(csvData);

    print("CSV file saved: $path");
  }

  // Function to generate PDF
  Future<void> _generatePDF(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Diagnosis Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),
            _buildPDFSection('Breast Cancer', 'Malignant tumor detected in the right breast.', 'Immediate treatment is recommended.'),
            pw.SizedBox(height: 16),
            _buildPDFSection('Lung Cancer', 'Stage 2 lung cancer detected.', 'Chemotherapy and radiation therapy recommended.'),
            pw.SizedBox(height: 16),
            _buildPDFSection('Tuberculosis', 'Active tuberculosis infection.', 'Immediate treatment with antibiotics is necessary.'),
            pw.SizedBox(height: 16),
            _buildPDFSection('Skin Cancer', 'Melanoma detected on the left forearm.', 'Surgical removal and follow-up care recommended.'),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildPDFSection(String title, String diagnosis, String recommendation) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('Diagnosis: $diagnosis', style: pw.TextStyle(fontSize: 14)),
        pw.SizedBox(height: 8),
        pw.Text('Recommendation: $recommendation', style: pw.TextStyle(fontSize: 14)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnosis Report'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            onPressed: () {
              _generateCSV();
            },
            icon: const Icon(FontAwesomeIcons.fileCsv),
            tooltip: 'Download as CSV',
          ),
          IconButton(
            onPressed: () {
              _generatePDF(context);
            },
            icon: const Icon(FontAwesomeIcons.filePdf),
            tooltip: 'Download as PDF',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportSection(
              FontAwesomeIcons.diagnoses,
              'Breast Cancer Report',
              'Diagnosis: Malignant tumor detected in the right breast.',
              'Recommendation: Immediate treatment is recommended.',
            ),
            const SizedBox(height: 16.0),
            _buildReportSection(
              FontAwesomeIcons.lungs,
              'Lung Cancer Report',
              'Diagnosis: Stage 2 lung cancer detected.',
              'Recommendation: Chemotherapy and radiation therapy recommended.',
            ),
            const SizedBox(height: 16.0),
            _buildReportSection(
              FontAwesomeIcons.virus,
              'Tuberculosis Report',
              'Diagnosis: Active tuberculosis infection.',
              'Recommendation: Immediate treatment with antibiotics is necessary.',
            ),
            const SizedBox(height: 16.0),
            _buildReportSection(
              FontAwesomeIcons.userMd,
              'Skin Cancer Report',
              'Diagnosis: Melanoma detected on the left forearm.',
              'Recommendation: Surgical removal and follow-up care recommended.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportSection(IconData icon, String title, String diagnosis, String recommendation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.teal, size: 30),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Text(
          diagnosis,
          style: const TextStyle(fontSize: 16.0),
        ),
        const SizedBox(height: 4.0),
        Text(
          recommendation,
          style: const TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }
}


class CancerSelectionPage extends StatelessWidget {
  const CancerSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cancer Selection'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Select a Cancer Type:',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.tealAccent,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20.0),
              _buildCancerOption(
                context: context,
                title: 'Skin Cancer',
                icon: FontAwesomeIcons.solidUser,
                screen: const SkinCancerScreen(),
                color: Colors.orangeAccent,
              ),
              const SizedBox(height: 10),
              _buildCancerOption(
                context: context,
                title: 'Prostate Cancer',
                icon: FontAwesomeIcons.mars,
                screen: const ProstateCancerScreen(),
                color: Colors.lightBlueAccent,
              ),
              const SizedBox(height: 10),
              _buildCancerOption(
                context: context,
                title: 'Lung Cancer',
                icon: FontAwesomeIcons.lungs,
                screen: const LungCancerScreen(),
                color: Colors.redAccent,
              ),
              const SizedBox(height: 10),
              _buildCancerOption(
                context: context,
                title: 'Breast Cancer',
                icon: FontAwesomeIcons.venus,
                screen: const BreastCancerPage(),
                color: Colors.pinkAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCancerOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget screen,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                radius: 30.0,
                child: FaIcon(icon, size: 30.0, color: Colors.white),
              ),
              const SizedBox(width: 20.0),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}


class SkinCancerScreen extends StatefulWidget {
  const SkinCancerScreen({super.key});

  @override
  _SkinCancerScreenState createState() => _SkinCancerScreenState();
}

class _SkinCancerScreenState extends State<SkinCancerScreen> {
  File? _image;
  String? _result;
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
      _classify();
    }
  }

  void _classify() {
    if (_formKey.currentState!.validate()) {
      // Gather additional data from user input
      int age = int.parse(_ageController.text);
      String location = _locationController.text;
      int duration = int.parse(_durationController.text);

      // Generate a random result
      List<String> possibleResults = ['Benign', 'Malignant'];
      String randomResult = possibleResults[Random().nextInt(possibleResults.length)];

      String result = '$randomResult (Age: $age, Location: $location, Duration: $duration months)';
      setState(() {
        _result = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skin Cancer Detection'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_image != null)
                Image.file(
                  _image!,
                  width: 400,
                  height: 300,
                )
              else
                Container(
                  height: 300,
                  width: 400,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Text('No Image Selected'),
                  ),
                ),
              const SizedBox(height: 16.0),
              _buildTextField(
                controller: _ageController,
                labelText: 'Enter your age',
                icon: FontAwesomeIcons.user,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8.0),
              _buildTextField(
                controller: _locationController,
                labelText: 'Enter the location of the skin lesion',
                icon: FontAwesomeIcons.mapMarkerAlt,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the location of the lesion';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8.0),
              _buildTextField(
                controller: _durationController,
                labelText: 'Enter the duration of the skin lesion (in months)',
                icon: FontAwesomeIcons.calendarAlt,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the duration of the lesion';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid duration';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton.icon(
                onPressed: _getImage,
                icon: const Icon(FontAwesomeIcons.image),
                label: const Text('Select Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16.0),
                ),
              ),
              const SizedBox(height: 16.0),
              if (_result != null)
                Text(
                  'Result: $_result',
                  style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}


class ProstateCancerScreen extends StatefulWidget {
  const ProstateCancerScreen({super.key});

  @override
  _ProstateCancerScreenState createState() => _ProstateCancerScreenState();
}

class _ProstateCancerScreenState extends State<ProstateCancerScreen> {
  final TextEditingController _ageEditingController = TextEditingController();
  final TextEditingController _psaEditingController = TextEditingController();
  final TextEditingController _gleasonEditingController = TextEditingController();
  String _predictedLabel = '';
  bool _isInputValid = true;
  final _formKey = GlobalKey<FormState>();

  Future<void> _detectProstateCancer() async {
    if (_formKey.currentState!.validate()) {
      int age = int.parse(_ageEditingController.text);
      double psa = double.parse(_psaEditingController.text);
      int gleason = int.parse(_gleasonEditingController.text);

      String predictedLabel = _calculateProstateCancerRisk(age, psa, gleason);

      setState(() {
        _predictedLabel = predictedLabel;
        _isInputValid = true;
      });
    } else {
      setState(() {
        _isInputValid = false;
        _predictedLabel = 'Invalid input';
      });
    }
  }

  String _calculateProstateCancerRisk(int age, double psa, int gleason) {
    // Improved risk calculation logic
    if (age > 70 && psa > 10 && gleason > 7) {
      return 'High Risk (Immediate medical attention needed)';
    } else if (age > 60 && psa > 6 && gleason > 6) {
      return 'Moderate Risk (Follow-up and further tests recommended)';
    } else if (psa >= 4.0 || gleason >= 4) {
      return 'Low to Moderate Risk (Monitor PSA levels)';
    } else {
      return 'Low Risk (Routine check-up advised)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prostate Cancer Screening'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _ageEditingController,
                labelText: 'Enter age',
                icon: FontAwesomeIcons.user,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter age';
                  }
                  int? age = int.tryParse(value);
                  if (age == null || age <= 0) {
                    return 'Enter a valid age';
                  } else if (age > 90) {
                    return 'Age must be 90 or below';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8.0),
              _buildTextField(
                controller: _psaEditingController,
                labelText: 'Enter PSA value',
                icon: FontAwesomeIcons.vial,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter PSA value';
                  }
                  if (double.tryParse(value) == null || double.parse(value) < 0) {
                    return 'Enter a valid PSA value';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8.0),
              _buildTextField(
                controller: _gleasonEditingController,
                labelText: 'Enter Gleason score',
                icon: FontAwesomeIcons.notesMedical,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Gleason score';
                  }
                  int? gleason = int.tryParse(value);
                  if (gleason == null || gleason < 0 || gleason > 10) {
                    return 'Enter a valid Gleason score (0-10)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton.icon(
                onPressed: _detectProstateCancer,
                icon: const Icon(FontAwesomeIcons.diagnoses),
                label: const Text('Detect Cancer Risk'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 16.0),
                ),
              ),
              const SizedBox(height: 20.0),
              if (_predictedLabel.isNotEmpty)
                Text(
                  'Predicted Risk: $_predictedLabel',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              if (!_isInputValid)
                const Text(
                  'Invalid input provided. Please enter correct details.',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16.0,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}


class LungCancerScreen extends StatefulWidget {
  const LungCancerScreen({super.key});

  @override
  _LungCancerScreenState createState() => _LungCancerScreenState();
}

class _LungCancerScreenState extends State<LungCancerScreen> {
  int _gender = 0; // 0 for male, 1 for female
  int _age = 0;
  int _smoking = 0; // 0 for non-smoker, 1 for smoker
  int _yellowFingers = 0; // 0 for no, 1 for yes
  int _anxiety = 0; // 0 for no, 1 for yes
  int _peerPressure = 0; // 0 for no, 1 for yes
  int _chronicDisease = 0; // 0 for no, 1 for yes
  int _fatigue = 0; // 0 for no, 1 for yes
  int _allergy = 0; // 0 for no, 1 for yes
  int _wheezing = 0; // 0 for no, 1 for yes
  int _alcoholConsuming = 0; // 0 for no, 1 for yes
  int _coughing = 0; // 0 for no, 1 for yes
  int _shortnessOfBreath = 0; // 0 for no, 1 for yes
  int _swallowingDifficulty = 0; // 0 for no, 1 for yes
  int _chestPain = 0; // 0 for no, 1 for yes

  void _performLungCancerScreening() {
    double riskScore = _calculateRiskScore();
    String result = _getRiskResult(riskScore);

    showDialog(
      context: this.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lung Cancer Screening Result'),
          content: Text('Your risk of lung cancer is: $result'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  double _calculateRiskScore() {
    double riskScore = 0.0;
    riskScore += _gender * 0.2;
    riskScore += _age * 0.1;
    riskScore += _smoking * 0.3;
    riskScore += _yellowFingers * 0.05;
    riskScore += _anxiety * 0.02;
    riskScore += _peerPressure * 0.01;
    riskScore += _chronicDisease * 0.15;
    riskScore += _fatigue * 0.03;
    riskScore += _allergy * 0.01;
    riskScore += _wheezing * 0.08;
    riskScore += _alcoholConsuming * 0.04;
    riskScore += _coughing * 0.1;
    riskScore += _shortnessOfBreath * 0.12;
    riskScore += _swallowingDifficulty * 0.07;
    riskScore += _chestPain * 0.09;
    return riskScore;
  }

  String _getRiskResult(double riskScore) {
    if (riskScore < 0.3) {
      return 'Low';
    } else if (riskScore < 0.6) {
      return 'Moderate';
    } else {
      return 'High';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lung Cancer Screening'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              labelText: 'Gender (0 for male, 1 for female)',
              icon: FontAwesomeIcons.venusMars,
              onChanged: (value) => setState(() => _gender = int.parse(value)),
            ),
            const SizedBox(height: 10.0),
            _buildTextField(
              labelText: 'Age',
              icon: FontAwesomeIcons.user,
              onChanged: (value) => setState(() => _age = int.parse(value)),
            ),
            const SizedBox(height: 10.0),
            _buildTextField(
              labelText: 'Smoking (0 for non-smoker, 1 for smoker)',
              icon: FontAwesomeIcons.smoking,
              onChanged: (value) => setState(() => _smoking = int.parse(value)),
            ),
            const SizedBox(height: 10.0),
            _buildTextField(
              labelText: 'Yellow Fingers (0 for no, 1 for yes)',
              icon: FontAwesomeIcons.handPaper,
              onChanged: (value) => setState(() => _yellowFingers = int.parse(value)),
            ),
            const SizedBox(height: 10.0),
            _buildTextField(
              labelText: 'Anxiety (0 for no, 1 for yes)',
              icon: FontAwesomeIcons.brain,
              onChanged: (value) => setState(() => _anxiety = int.parse(value)),
            ),
            const SizedBox(height: 10.0),
            _buildTextField(
              labelText: 'Peer Pressure (0 for no, 1 for yes)',
              icon: FontAwesomeIcons.users,
              onChanged: (value) => setState(() => _peerPressure = int.parse(value)),
            ),
            const SizedBox(height: 10.0),
            _buildTextField(
              labelText: 'Chronic Disease (0 for no, 1 for yes)',
              icon: FontAwesomeIcons.procedures,
              onChanged: (value) => setState(() => _chronicDisease = int.parse(value)),
            ),
            const SizedBox(height: 10.0),
            _buildTextField(
              labelText: 'Fatigue (0 for no, 1 for yes)',
              icon: FontAwesomeIcons.batteryQuarter,
              onChanged: (value) => setState(() => _fatigue = int.parse(value)),
            ),
            const SizedBox(height: 10.0),
            _buildTextField(
              labelText: 'Allergy (0 for no, 1 for yes)',
              icon: FontAwesomeIcons.syringe,
              onChanged: (value) => setState(() => _allergy = int.parse(value)),
            ),
            const SizedBox(height: 10.0),
            _buildTextField(
              labelText: 'Wheezing (0 for no, 1 for yes)',
              icon: FontAwesomeIcons.wind,
              onChanged: (value) => setState(() => _wheezing = int.parse(value)),
            ),
            const SizedBox(height: 10.0),
            _buildTextField(
              labelText: 'Alcohol Consuming (0 for no, 1 for yes)',
              icon: FontAwesomeIcons.wineBottle,
              onChanged: (value) => setState(() => _alcoholConsuming = int.parse(value)),
            ),
            const SizedBox(height: 10.0),
            _buildTextField(
              labelText: 'Coughing (0 for no, 1 for yes)',
              icon: FontAwesomeIcons.headSideCough,
              onChanged: (value) => setState(() => _coughing = int.parse(value)),
            ),
            const SizedBox(height: 10.0),
            _buildTextField(
              labelText: 'Shortness of Breath (0 for no, 1 for yes)',
              icon: FontAwesomeIcons.lungs,
              onChanged: (value) => setState(() => _shortnessOfBreath = int.parse(value)),
            ),
            const SizedBox(height: 10.0),
            _buildTextField(
              labelText: 'Swallowing Difficulty (0 for no, 1 for yes)',
              icon: FontAwesomeIcons.handsHelping,
              onChanged: (value) => setState(() => _swallowingDifficulty = int.parse(value)),
            ),
            const SizedBox(height: 10.0),
            _buildTextField(
              labelText: 'Chest Pain (0 for no, 1 for yes)',
              icon: FontAwesomeIcons.heartbeat,
              onChanged: (value) => setState(() => _chestPain = int.parse(value)),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton.icon(
              onPressed: _performLungCancerScreening,
              icon: const Icon(FontAwesomeIcons.diagnoses),
              label: const Text('Detect Lung Cancer'),
              style: ElevatedButton.styleFrom(
                primary: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String labelText, required IconData icon, required Function(String) onChanged}) {
    return TextFormField(
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) => onChanged(value),
    );
  }
}


class BreastCancerPage extends StatefulWidget {
  const BreastCancerPage({super.key});

  @override
  _BreastCancerPageState createState() => _BreastCancerPageState();
}

class _BreastCancerPageState extends State<BreastCancerPage> {
  int _clumpThickness = 0;
  int _uniformCellSize = 0;
  int _uniformCellShape = 0;
  int _marginalAdhesion = 0;
  int _singleEpithelialSize = 0;
  int _bareNuclei = 0;
  int _blandChromatin = 0;
  int _normalNucleoli = 0;
  int _mitoses = 0;

  void _performBreastCancerScreening() {
    int score = _clumpThickness +
        _uniformCellSize +
        _uniformCellShape +
        _marginalAdhesion +
        _singleEpithelialSize +
        _bareNuclei +
        _blandChromatin +
        _normalNucleoli +
        _mitoses;

    String result;
    if (score <= 3) {
      result = 'No Breast Cancer Detected';
    } else if (score <= 6) {
      result = 'You might have breast cancer, visit the nearest hospital';
    } else {
      result = 'High risk of breast cancer, visit the referral page to see a specialist';
    }

    showDialog(
      context: this.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Breast Cancer Detection Result'),
          content: Text(result),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breast Cancer Screening'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Breast Cancer Detection',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Use the sliders below to input medical parameters for breast cancer risk detection.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 20.0),
            _buildSlider(
              label: 'Clump Thickness',
              value: _clumpThickness,
              icon: FontAwesomeIcons.layerGroup,
              onChanged: (value) => setState(() => _clumpThickness = value),
            ),
            _buildSlider(
              label: 'Uniform Cell Size',
              value: _uniformCellSize,
              icon: FontAwesomeIcons.expandAlt,
              onChanged: (value) => setState(() => _uniformCellSize = value),
            ),
            _buildSlider(
              label: 'Uniform Cell Shape',
              value: _uniformCellShape,
              icon: FontAwesomeIcons.shapes,
              onChanged: (value) => setState(() => _uniformCellShape = value),
            ),
            _buildSlider(
              label: 'Marginal Adhesion',
              value: _marginalAdhesion,
              icon: FontAwesomeIcons.gripLines,
              onChanged: (value) => setState(() => _marginalAdhesion = value),
            ),
            _buildSlider(
              label: 'Single Epithelial Size',
              value: _singleEpithelialSize,
              icon: FontAwesomeIcons.ruler,
              onChanged: (value) => setState(() => _singleEpithelialSize = value),
            ),
            _buildSlider(
              label: 'Bare Nuclei',
              value: _bareNuclei,
              icon: FontAwesomeIcons.circle,
              onChanged: (value) => setState(() => _bareNuclei = value),
            ),
            _buildSlider(
              label: 'Bland Chromatin',
              value: _blandChromatin,
              icon: FontAwesomeIcons.dna,
              onChanged: (value) => setState(() => _blandChromatin = value),
            ),
            _buildSlider(
              label: 'Normal Nucleoli',
              value: _normalNucleoli,
              icon: FontAwesomeIcons.microscope,
              onChanged: (value) => setState(() => _normalNucleoli = value),
            ),
            _buildSlider(
              label: 'Mitoses',
              value: _mitoses,
              icon: FontAwesomeIcons.divide,
              onChanged: (value) => setState(() => _mitoses = value),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton.icon(
              onPressed: _performBreastCancerScreening,
              icon: const Icon(FontAwesomeIcons.diagnoses),
              label: const Text('Breast Cancer Detection'),
              style: ElevatedButton.styleFrom(
                primary: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({required String label, required int value, required IconData icon, required Function(int) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.tealAccent),
            const SizedBox(width: 8.0),
            Text(
              '$label: $value',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 10,
          divisions: 10,
          activeColor: Colors.teal,
          inactiveColor: Colors.tealAccent,
          onChanged: (value) {
            onChanged(value.toInt());
          },
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}
