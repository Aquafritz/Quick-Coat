import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);


  await Supabase.initialize(
    url: 'https://ntojjiamayutmmepslmo.supabase.co',  // Your project URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50b2pqaWFtYXl1dG1tZXBzbG1vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYzMDg3NzYsImV4cCI6MjA3MTg4NDc3Nn0.Y4lMbN-iI1dkjMQ-igI1X0ponroYOBHKqfVZ8ZqWTSA', // Your anon key
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}