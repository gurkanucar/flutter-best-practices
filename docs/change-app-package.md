```bash
# Add to dev_dependencies in pubspec.yaml
flutter pub add change_app_package_name --dev

# Run the command
flutter pub run change_app_package_name:main com.gucardev.flutterbestpractices

# Remove the package after (optional)
flutter pub remove com.example.flutter_best_practices
```

## After Changing
```bash
# Clean build cache
flutter clean

# Get dependencies
flutter pub get

# Rebuild
flutter run