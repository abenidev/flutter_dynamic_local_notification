# workman_flutter

#
workmanager fix for flutter version 3.16.9 | workmanager: ^0.5.2
fix for :app:checkDebugDuplicateClasses


//
add next code in android/build.gradle

  configurations.all {
    resolutionStrategy {
        eachDependency {
            if ((requested.group == "org.jetbrains.kotlin") && (requested.name.startsWith("kotlin-stdlib"))) {
                useVersion("1.8.22")
            }
        }
    }
  }

  put it in 'allprojects'