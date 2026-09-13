allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

// screen_protector 1.5.x only applies kotlin-android on AGP < 9 and relies on AGP 9's built-in Kotlin otherwise.
// This project keeps android.builtInKotlin=false (Flutter template, gradle.properties), so its Kotlin sources
// would not be compiled at all → "cannot find symbol ScreenProtectorPlugin" in GeneratedPluginRegistrant.
// Apply the Kotlin plugin to that one plugin project. Remove once the plugin (or builtInKotlin=true) handles it.
subprojects {
    if (name == "screen_protector") {
        pluginManager.withPlugin("com.android.library") {
            pluginManager.apply("org.jetbrains.kotlin.android")
            tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
                compilerOptions.jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
            }
        }
    }
}

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
