icons_launcher:
image_path: 'assets/ic_logo_radius.png'
platforms:
android:
enable: true
ios:
enable: truecls

flutter pub get
dart run icons_launcher:create

en android/app/build.gradle

import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

signingConfigs {
create("release") {
keyAlias = keystoreProperties["keyAlias"] as String
keyPassword = keystoreProperties["keyPassword"] as String
storeFile = file(keystoreProperties["storeFile"] as String)
storePassword = keystoreProperties["storePassword"] as String
}
}

buildTypes {
release {
signingConfig = signingConfigs.getByName("debug")
}
}

buildTypes {
release {
signingConfig = signingConfigs.getByName("release")
}
}

flutter clean
flutter pub get
flutter build apk --release

flutter build appbundle --release

create a file named
key.properties
