// Top-level build file where you can add configuration options common to all sub-projects/modules.

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Thêm plugin Google Services để hỗ trợ Firebase
        classpath("com.google.gms:google-services:4.3.15")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Tuỳ chỉnh lại thư mục build cho root
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

// Tuỳ chỉnh lại thư mục build cho các module con
subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)

    // Đảm bảo module con đánh giá đúng app trước
    project.evaluationDependsOn(":app")
}

// Nhiệm vụ dọn sạch thư mục build
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
