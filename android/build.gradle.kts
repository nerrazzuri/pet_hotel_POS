allprojects {
    repositories {
        google()
        mavenCentral()
        // Use only official repositories to avoid Maven issues
    }
}

// Remove the custom build directory configuration that's causing conflicts
// val newBuildDir: Directory =
//     rootProject.layout.buildDirectory
//         .dir("../../build")
//         .get()
// rootProject.layout.buildDirectory.value(newBuildDir)

// subprojects {
//     val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
//     project.layout.buildDirectory.value(newSubprojectBuildDir)
//     
//     // Disable problematic tasks that require Maven dependencies
//     afterEvaluate {
//         tasks.all {
//             if (name.contains("lint") || name.contains("extractDebugAnnotations")) {
//                 enabled = false
//             }
//         }
//     }
// }
// subprojects {
//     project.evaluationDependsOn(":app")
// }

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
