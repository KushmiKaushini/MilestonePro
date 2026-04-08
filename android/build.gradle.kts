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

subprojects {
    val proj = this
    val action = Action<Project> {
        if (proj.hasProperty("android")) {
            val android = proj.extensions.getByName("android") as com.android.build.gradle.BaseExtension
            if (android.namespace == null) {
                android.namespace = proj.group.toString() + "." + proj.name.replace("-", "_")
            }
            
            // AGP 8.x Manifest Sanitizer: Remove legacy 'package' attribute from plugin manifests
            proj.tasks.whenTaskAdded {
                if (name.contains("process") && name.contains("Manifest")) {
                    doFirst {
                        val manifestFile = proj.file("src/main/AndroidManifest.xml")
                        if (manifestFile.exists()) {
                            val content = manifestFile.readText()
                            if (content.contains("package=")) {
                                val sanitized = content.replace(Regex("""package="[^"]*""""), "")
                                manifestFile.writeText(sanitized)
                            }
                        }
                    }
                }
            }
        }
    }
    if (proj.state.executed) {
        action.execute(proj)
    } else {
        proj.afterEvaluate(action)
    }
}



