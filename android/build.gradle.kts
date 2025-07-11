//allprojects {
//    repositories {
//        google()
//        mavenCentral()
//    }
//}


// This is my modified code previous comments are the original comments!
allprojects {
    repositories {
        google()
        maven {
            url = uri("https://maven.google.com")
        }
        maven {
            url = uri("https://jitpack.io")
        }
        mavenCentral()
    }
}


val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

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
