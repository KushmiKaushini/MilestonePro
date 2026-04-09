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

// Fix for legacy dependencies without namespace (AGP 8.11+ requirement)
subprojects {
    val configureNamespace = {
        if (project.plugins.hasPlugin("com.android.library") || project.plugins.hasPlugin("com.android.application")) {
            val android = project.extensions.findByName("android")
            if (android != null) {
                try {
                    val namespaceMethod = android.javaClass.getMethod("getNamespace")
                    if (namespaceMethod.invoke(android) == null) {
                        val setNamespaceMethod = android.javaClass.getMethod("setNamespace", String::class.java)
                        setNamespaceMethod.invoke(android, project.group.toString().ifEmpty { "com.milestone_pro.fallback" })
                    }
                } catch (e: Exception) { }
            }
        }
    }
    
    if (project.state.executed) {
        configureNamespace()
    } else {
        project.afterEvaluate { configureNamespace() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
