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

    // --- ĐOẠN MÃ FIX LỖI lStar VÀ PHIÊN BẢN SDK CHO SUBPROJECTS ---
    afterEvaluate {
        if (project.extensions.findByName("android") != null) {
            val android = project.extensions.getByName("android") as com.android.build.gradle.BaseExtension
            android.apply {
                compileSdkVersion(34)
                buildToolsVersion("34.0.0")
                defaultConfig {
                    targetSdkVersion(34)
                }
            }
        }
    }

    // Tự động sửa lỗi Namespace (Giữ nguyên logic của bạn)
    val subproject = this
    fun configureNamespace() {
        val android = subproject.extensions.findByName("android")
        if (android != null) {
            try {
                val getNamespace = android.javaClass.getMethod("getNamespace")
                val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)

                if (getNamespace.invoke(android) == null) {
                    setNamespace.invoke(android, subproject.group.toString())
                }
            } catch (e: Exception) {}
        }
    }

    if (subproject.state.executed) {
        configureNamespace()
    } else {
        subproject.afterEvaluate {
            configureNamespace()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}