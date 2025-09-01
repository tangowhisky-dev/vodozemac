plugins {
    kotlin("jvm") version "1.9.20"
    kotlin("plugin.serialization") version "1.9.20"
}

group = "org.matrix"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

dependencies {
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.0")
    testImplementation("org.jetbrains.kotlin:kotlin-test")
    testImplementation("junit:junit:4.13.2")
    
    // Include the generated Kotlin bindings
    implementation(files("../../kotlin/vodozemac.jar"))
}

tasks.test {
    useJUnit()
    
    // Add the native library path
    systemProperty("java.library.path", "${projectDir}/../../kotlin/")
    
    // Copy test vectors
    dependsOn("copyTestVectors")
}

tasks.register<Copy>("copyTestVectors") {
    from("../test_vectors.json")
    into("$buildDir/resources/test")
}

kotlin {
    jvmToolchain(11)
}
