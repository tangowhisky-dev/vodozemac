import org.junit.Test
import kotlin.test.assertNotNull
import uniffi.vodozemac.`getVersion`

class BasicLoadTest {
    
    @Test
    fun testLibraryLoading() {
        println("Testing basic library loading...")
        
        try {
            val version = `getVersion`()
            println("✅ Library loaded successfully! Version: $version")
            assertNotNull(version)
        } catch (e: Exception) {
            println("❌ Failed to load library: ${e.message}")
            e.printStackTrace()
            throw e
        }
    }
}
