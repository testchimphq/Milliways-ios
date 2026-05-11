pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
        maven(url = "https://jitpack.io")
    }
}

rootProject.name = "Milliways"
include(":app")

// When ../../testchimp-rum-android exists (sibling under IdeaProjects), substitute it for
// JitPack so the APK includes current RUM (flush-before-clear, batch split, executor ordering).
// The included build needs its own local.properties with sdk.dir (see that repo’s .gitignore).
val testchimpRumAndroidDir = file("../../testchimp-rum-android")
if (testchimpRumAndroidDir.exists()) {
    includeBuild(testchimpRumAndroidDir) {
        dependencySubstitution {
            substitute(module("com.github.testchimphq:testchimp-rum-android"))
                .using(project(":testchimp-rum"))
        }
    }
}
