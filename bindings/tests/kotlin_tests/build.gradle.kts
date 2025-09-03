plugins {
    kotlin("jvm") version "2.0.20"
    kotlin("plugin.serialization") version "2.0.20"
}

group = "org.matrix"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

dependencies {
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.0")
    implementation("net.java.dev.jna:jna:5.13.0")
    testImplementation("org.jetbrains.kotlin:kotlin-test")
    testImplementation("junit:junit:4.13.2")
}

tasks.test {
    useJUnit()
    
    // Add the native library path
    systemProperty("java.library.path", "${projectDir}/../../generated/kotlin/:${projectDir}/src/main/resources")
    
    // Add JVM arguments for native access
    jvmArgs("--enable-native-access=ALL-UNNAMED")
    
    // Copy test vectors
    dependsOn("copyTestVectors")
}

tasks.register<Copy>("copyTestVectors") {
    from("../test_vectors.json")
    into("${layout.buildDirectory.get()}/resources/test")
}

// Set compatible JVM targets
tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
    kotlinOptions {
        jvmTarget = "22"
    }
}

tasks.withType<JavaCompile> {
    targetCompatibility = "22"
    sourceCompatibility = "22"
}
