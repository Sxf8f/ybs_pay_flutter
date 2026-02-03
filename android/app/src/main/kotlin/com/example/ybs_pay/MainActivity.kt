package com.example.ybs_pay

import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.content.pm.ApplicationInfo
import android.net.Uri
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.example.ybs_pay/google_pay"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openGooglePay" -> {
                val upiUrl = call.argument<String>("upiUrl")
                if (upiUrl != null) {
                    openGooglePay(upiUrl)
                    result.success(true)
                } else {
                    result.error("INVALID_ARGUMENT", "UPI URL is null", null)
                    }
                }
                "openUPIApp" -> {
                    val upiUrl = call.argument<String>("upiUrl")
                    val packageName = call.argument<String>("packageName")
                    if (upiUrl != null && packageName != null) {
                        val launched = openSpecificUPIApp(upiUrl, packageName)
                        result.success(launched)
                    } else {
                        result.error("INVALID_ARGUMENT", "UPI URL or package name is null", null)
                    }
                }
                "checkAppInstalled" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        val isInstalled = isAppInstalled(packageName)
                        result.success(isInstalled)
                    } else {
                        result.error("INVALID_ARGUMENT", "Package name is null", null)
                    }
                }
                "findGooglePayPackage" -> {
                    val foundPackage = findActualGooglePayPackage()
                    if (foundPackage != null) {
                        result.success(foundPackage)
                    } else {
                        result.success(null)
                    }
                }
                "listAllGoogleApps" -> {
                    val googleApps = listAllGoogleRelatedApps()
                    result.success(googleApps)
                }
                "listAllPayApps" -> {
                    val payApps = listAllPayRelatedApps()
                    result.success(payApps)
                }
                "checkUPIHandlers" -> {
                    val upiHandlers = checkUPIIntentHandlers()
                    result.success(upiHandlers)
                }
                "searchForGooglePay" -> {
                    val googlePayInfo = searchForGooglePayAggressively()
                    result.success(googlePayInfo)
                }
                "openUPIWithChooser" -> {
                    val upiUrl = call.argument<String>("upiUrl")
                    if (upiUrl != null) {
                        val launched = openUPIWithForcedChooser(upiUrl)
                        result.success(launched)
                    } else {
                        result.error("INVALID_ARGUMENT", "UPI URL is null", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun isAppInstalled(packageName: String): Boolean {
        return try {
            // For Google Pay, check all possible package names
            if (packageName == "com.google.android.apps.nfc.payment" || 
                packageName.contains("google") && (packageName.contains("pay") || packageName.contains("paisa") || packageName.contains("wallet"))) {
                val googlePayPackages = listOf(
                    "com.google.android.apps.nbu.paisa.user", // Google Pay India (most common)
                    "com.google.android.apps.nfc.payment",    // Old Google Wallet/NFC
                    "com.google.android.apps.walletnfcrel",   // Google Wallet
                    "com.google.android.apps.nbu.paisa",      // Another variant
                    "com.google.paisa"                        // Another variant
                )
                
                // First check the exact package name
                try {
                    packageManager.getPackageInfo(packageName, 0)
                    Log.d("APP_CHECK", "✅ $packageName is installed")
                    return true
                } catch (e: PackageManager.NameNotFoundException) {
                    // Try all Google Pay variants
                    for (pkg in googlePayPackages) {
                        try {
                            packageManager.getPackageInfo(pkg, 0)
                            Log.d("APP_CHECK", "✅ Found Google Pay with package: $pkg (requested: $packageName)")
                            return true
                        } catch (e2: PackageManager.NameNotFoundException) {
                            // Continue checking
                        }
                    }
                    
                    // If not found in known packages, search all installed apps
                    Log.d("APP_CHECK", "⚠️ Google Pay not found in known packages, searching all installed apps...")
                    return findGooglePayInInstalledApps()
                }
            } else {
                // For other apps, check normally
                packageManager.getPackageInfo(packageName, 0)
                Log.d("APP_CHECK", "✅ $packageName is installed")
                return true
            }
        } catch (e: PackageManager.NameNotFoundException) {
            Log.d("APP_CHECK", "❌ $packageName is not installed")
            return false
        } catch (e: Exception) {
            Log.e("APP_CHECK", "Error checking $packageName: ${e.message}")
            return false
        }
    }
    
    private fun findGooglePayInInstalledApps(): Boolean {
        return findActualGooglePayPackage() != null
    }
    
    private fun findActualGooglePayPackage(): String? {
        return try {
            // First check known Google Pay packages
            val googlePayPackages = listOf(
                "com.google.android.apps.nbu.paisa.user", // Google Pay India (most common)
                "com.google.android.apps.nfc.payment",    // Old Google Wallet/NFC
                "com.google.android.apps.walletnfcrel",   // Google Wallet
                "com.google.android.apps.nbu.paisa",      // Another variant
                "com.google.paisa"                        // Another variant
            )
            
            for (pkg in googlePayPackages) {
                try {
                    packageManager.getPackageInfo(pkg, 0)
                    Log.d("APP_CHECK", "✅ Found Google Pay with known package: $pkg")
                    return pkg
                } catch (e: PackageManager.NameNotFoundException) {
                    // Continue checking
                }
            }
            
            // If not found in known packages, search all installed apps
            val installedPackages = packageManager.getInstalledPackages(PackageManager.MATCH_DEFAULT_ONLY)
            Log.d("APP_CHECK", "Searching through ${installedPackages.size} installed packages for Google Pay...")
            
            // Log all potential matches for debugging
            val potentialMatches = mutableListOf<String>()
            
            for (pkg in installedPackages) {
                val pkgName = pkg.packageName.lowercase()
                val appInfo = pkg.applicationInfo
                if (appInfo != null) {
                    val appName = try {
                        appInfo.loadLabel(packageManager).toString().lowercase()
                    } catch (e: Exception) {
                        ""
                    }
                    
                    // More comprehensive matching
                    val hasGoogle = pkgName.contains("google") || appName.contains("google")
                    val hasPay = pkgName.contains("pay") || pkgName.contains("paisa") || pkgName.contains("wallet") || pkgName.contains("tez") || pkgName.contains("nbu") ||
                                 appName.contains("pay") || appName.contains("paisa") || appName.contains("wallet") || appName.contains("gpay")
                    
                    // Log potential matches
                    if (hasGoogle || hasPay) {
                        val matchInfo = "${pkg.packageName} -> $appName"
                        potentialMatches.add(matchInfo)
                        Log.d("APP_CHECK", "  Potential match: $matchInfo")
                    }
                    
                    // Check if it looks like Google Pay
                    val looksLikeGooglePay = 
                        (hasGoogle && hasPay) ||
                        appName.contains("google pay") || 
                        appName.contains("gpay") ||
                        appName == "google pay" ||
                        (appName.contains("google") && appName.contains("pay"))
                    
                    if (looksLikeGooglePay) {
                        Log.d("APP_CHECK", "✅ Found potential Google Pay: ${pkg.packageName} ($appName)")
                        return pkg.packageName
                    }
                }
            }
            
            Log.d("APP_CHECK", "❌ Google Pay not found in installed apps")
            Log.d("APP_CHECK", "Found ${potentialMatches.size} potential matches (Google or Pay related)")
            if (potentialMatches.isNotEmpty()) {
                Log.d("APP_CHECK", "Potential matches:")
                potentialMatches.take(20).forEach { Log.d("APP_CHECK", "  - $it") }
            }
            null
        } catch (e: Exception) {
            Log.e("APP_CHECK", "Error searching for Google Pay: ${e.message}")
            null
        }
    }
    
    private fun listAllGoogleRelatedApps(): List<String> {
        val googleApps = mutableListOf<String>()
        try {
            val installedPackages = packageManager.getInstalledPackages(PackageManager.MATCH_DEFAULT_ONLY)
            Log.d("APP_CHECK", "Listing all Google-related apps from ${installedPackages.size} packages...")
            
            for (pkg in installedPackages) {
                val pkgName = pkg.packageName.lowercase()
                val appInfo = pkg.applicationInfo
                if (appInfo != null) {
                    val appName = try {
                        appInfo.loadLabel(packageManager).toString()
                    } catch (e: Exception) {
                        ""
                    }
                    
                    if (pkgName.contains("google") || appName.lowercase().contains("google")) {
                        val info = "${pkg.packageName} -> $appName"
                        googleApps.add(info)
                        Log.d("APP_CHECK", "  Google app: $info")
                    }
                }
            }
            
            Log.d("APP_CHECK", "Found ${googleApps.size} Google-related apps")
        } catch (e: Exception) {
            Log.e("APP_CHECK", "Error listing Google apps: ${e.message}")
        }
        return googleApps
    }
    
    private fun listAllPayRelatedApps(): List<String> {
        val payApps = mutableListOf<String>()
        try {
            val installedPackages = packageManager.getInstalledPackages(PackageManager.MATCH_DEFAULT_ONLY)
            Log.d("APP_CHECK", "Listing all Pay-related apps from ${installedPackages.size} packages...")
            
            val payKeywords = listOf("pay", "paisa", "wallet", "tez", "gpay", "upi", "payment")
            
            for (pkg in installedPackages) {
                val pkgName = pkg.packageName.lowercase()
                val appInfo = pkg.applicationInfo
                if (appInfo != null) {
                    val appName = try {
                        appInfo.loadLabel(packageManager).toString()
                    } catch (e: Exception) {
                        ""
                    }
                    
                    val appNameLower = appName.lowercase()
                    val hasPayKeyword = payKeywords.any { 
                        pkgName.contains(it) || appNameLower.contains(it)
                    }
                    
                    if (hasPayKeyword) {
                        val info = "${pkg.packageName} -> $appName"
                        payApps.add(info)
                        Log.d("APP_CHECK", "  Pay app: $info")
                    }
                }
            }
            
            Log.d("APP_CHECK", "Found ${payApps.size} Pay-related apps")
        } catch (e: Exception) {
            Log.e("APP_CHECK", "Error listing Pay apps: ${e.message}")
        }
        return payApps
    }
    
    private fun checkUPIIntentHandlers(): List<String> {
        val upiHandlers = mutableListOf<String>()
        try {
            val testUpiUrl = "upi://pay?pa=test@upi&pn=Test&am=1&cu=INR"
            val uri = Uri.parse(testUpiUrl)
            
            // Try multiple query methods
            val queryFlags = listOf(
                PackageManager.MATCH_DEFAULT_ONLY,
                PackageManager.MATCH_ALL,
                0 // No flags
            )
            
            var totalFound = 0
            val uniqueHandlers = mutableSetOf<String>()
            
            for (flags in queryFlags) {
                try {
                    val intent = Intent(Intent.ACTION_VIEW, uri)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    
                    val resolveInfos = packageManager.queryIntentActivities(intent, flags)
                    Log.d("APP_CHECK", "Query with flags $flags: Found ${resolveInfos.size} apps")
                    
                    for (resolveInfo in resolveInfos) {
                        val packageName = resolveInfo.activityInfo.packageName
                        val appName = try {
                            resolveInfo.loadLabel(packageManager).toString()
                        } catch (e: Exception) {
                            packageName
                        }
                        
                        val info = "$packageName -> $appName"
                        if (uniqueHandlers.add(info)) {
                            upiHandlers.add(info)
                            totalFound++
                            Log.d("APP_CHECK", "  UPI Handler: $info")
                            
                            // Check if this might be Google Pay
                            val pkgLower = packageName.lowercase()
                            val appLower = appName.lowercase()
                            if (pkgLower.contains("google") && (pkgLower.contains("pay") || pkgLower.contains("paisa") || pkgLower.contains("wallet") || 
                                appLower.contains("google pay") || appLower.contains("gpay"))) {
                                Log.d("APP_CHECK", "  ⭐ POTENTIAL GOOGLE PAY FOUND: $info")
                            }
                        }
                    }
                } catch (e: Exception) {
                    Log.d("APP_CHECK", "Query with flags $flags failed: ${e.message}")
                }
            }
            
            // Also try querying by scheme directly
            try {
                val intent = Intent(Intent.ACTION_VIEW)
                intent.setData(uri)
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                
                val resolveInfos = packageManager.queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY)
                Log.d("APP_CHECK", "Query by scheme: Found ${resolveInfos.size} apps")
                
                for (resolveInfo in resolveInfos) {
                    val packageName = resolveInfo.activityInfo.packageName
                    val appName = try {
                        resolveInfo.loadLabel(packageManager).toString()
                    } catch (e: Exception) {
                        packageName
                    }
                    
                    val info = "$packageName -> $appName"
                    if (uniqueHandlers.add(info)) {
                        upiHandlers.add(info)
                        totalFound++
                        Log.d("APP_CHECK", "  UPI Handler (by scheme): $info")
                    }
                }
            } catch (e: Exception) {
                Log.d("APP_CHECK", "Query by scheme failed: ${e.message}")
            }
            
            Log.d("APP_CHECK", "Total unique UPI handlers found: ${upiHandlers.size}")
            
            // If still no handlers found, check known UPI apps directly
            if (upiHandlers.isEmpty()) {
                Log.d("APP_CHECK", "⚠️ No UPI handlers found via intent query")
                Log.d("APP_CHECK", "Checking known UPI apps directly...")
                
                val knownUpiApps = listOf(
                    "com.phonepe.app",
                    "net.one97.paytm",
                    "in.org.npci.upiapp",
                    // Google Pay - All possible package names
                    "com.google.android.apps.nbu.paisa.user",  // Google Pay India (most common)
                    "com.google.android.apps.nfc.payment",     // Old Google Wallet/NFC
                    "com.google.android.apps.walletnfcrel",   // Google Wallet
                    "com.google.android.apps.nbu.paisa",       // Another variant
                    "com.google.paisa",                       // Another variant
                    "com.google.android.apps.pay",           // Possible new package name
                    "com.google.android.gpay",                // Possible package name
                    "com.google.gpay",                        // Possible package name
                )
                
                for (pkgName in knownUpiApps) {
                    try {
                        val pkgInfo = packageManager.getPackageInfo(pkgName, 0)
                        val appInfo = pkgInfo.applicationInfo
                        if (appInfo != null) {
                            val appName = try {
                                appInfo.loadLabel(packageManager).toString()
                            } catch (e: Exception) {
                                pkgName
                            }
                            
                            val info = "$pkgName -> $appName (INSTALLED but not registered for UPI)"
                            upiHandlers.add(info)
                            Log.d("APP_CHECK", "  ⚠️ $info")
                        }
                    } catch (e: PackageManager.NameNotFoundException) {
                        // Not installed, skip
                    }
                }
            }
            
        } catch (e: Exception) {
            Log.e("APP_CHECK", "Error checking UPI handlers: ${e.message}")
        }
        return upiHandlers
    }
    
    private fun searchForGooglePayAggressively(): Map<String, String> {
        val results = mutableMapOf<String, String>()
        try {
            Log.d("APP_CHECK", "🔍 AGGRESSIVE SEARCH FOR GOOGLE PAY...")
            
            // METHOD 1: Query UPI Intent Handlers (MOST RELIABLE - This is what shows in chooser!)
            Log.d("APP_CHECK", "Method 1: Querying UPI intent handlers...")
            val upiUri = Uri.parse("upi://pay?pa=test@upi&pn=Test&am=1&cu=INR")
            val upiIntent = Intent(Intent.ACTION_VIEW, upiUri)
            upiIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            
            // Try multiple query flags to find all handlers
            val queryFlags = listOf(
                PackageManager.MATCH_DEFAULT_ONLY,
                0, // No flags - most permissive
                PackageManager.MATCH_ALL
            )
            
            val foundViaIntent = mutableSetOf<String>()
            for (flags in queryFlags) {
                try {
                    val resolveInfos = packageManager.queryIntentActivities(upiIntent, flags)
                    Log.d("APP_CHECK", "  Query with flags $flags: Found ${resolveInfos.size} apps")
                    
                    for (resolveInfo in resolveInfos) {
                        val packageName = resolveInfo.activityInfo.packageName
                        val appName = try {
                            resolveInfo.loadLabel(packageManager).toString()
                        } catch (e: Exception) {
                            packageName
                        }
                        
                        val pkgLower = packageName.lowercase()
                        val appLower = appName.lowercase()
                        
                        // Check if this looks like Google Pay
                        val isGooglePay = (pkgLower.contains("google") && 
                                          (pkgLower.contains("pay") || pkgLower.contains("paisa") || 
                                           pkgLower.contains("wallet") || pkgLower.contains("gpay") ||
                                           appLower.contains("google pay") || appLower.contains("gpay") ||
                                           appLower == "gpay"))
                        
                        if (isGooglePay && !foundViaIntent.contains(packageName)) {
                            foundViaIntent.add(packageName)
                            results[packageName] = appName
                            Log.d("APP_CHECK", "  ⭐⭐⭐ GOOGLE PAY FOUND VIA INTENT: $packageName -> $appName")
                        }
                    }
                } catch (e: Exception) {
                    Log.d("APP_CHECK", "  Query with flags $flags failed: ${e.message}")
                }
            }
            
            // METHOD 2: Check known package names (fallback)
            if (results.isEmpty()) {
                Log.d("APP_CHECK", "Method 2: Checking known Google Pay package names...")
                val allGooglePayPackages = listOf(
                    "com.google.android.apps.nbu.paisa.user",
                    "com.google.android.apps.nfc.payment",
                    "com.google.android.apps.walletnfcrel",
                    "com.google.android.apps.nbu.paisa",
                    "com.google.paisa",
                    "com.google.android.apps.pay",
                    "com.google.android.gpay",
                    "com.google.gpay",
                    "com.google.android.apps.googlepay",
                    "com.google.android.apps.wallet",
                    "com.google.android.apps.payments",
                )
                
                for (pkgName in allGooglePayPackages) {
                    try {
                        val pkgInfo = packageManager.getPackageInfo(pkgName, 0)
                        val appInfo = pkgInfo.applicationInfo
                        if (appInfo != null) {
                            val appName = try {
                                appInfo.loadLabel(packageManager).toString()
                            } catch (e: Exception) {
                                pkgName
                            }
                            
                            results[pkgName] = appName
                            Log.d("APP_CHECK", "  ✅ FOUND: $pkgName -> $appName")
                        }
                    } catch (e: PackageManager.NameNotFoundException) {
                        // Not found, continue
                    }
                }
            }
            
            // METHOD 3: Search ALL installed apps (last resort)
            if (results.isEmpty()) {
                Log.d("APP_CHECK", "Method 3: Searching ALL installed apps...")
                val installedPackages = packageManager.getInstalledPackages(PackageManager.MATCH_DEFAULT_ONLY)
                Log.d("APP_CHECK", "Searching through ${installedPackages.size} installed packages...")
                
                for (pkg in installedPackages) {
                    val pkgName = pkg.packageName.lowercase()
                    val appInfo = pkg.applicationInfo
                    if (appInfo != null) {
                        val appName = try {
                            appInfo.loadLabel(packageManager).toString().lowercase()
                        } catch (e: Exception) {
                            ""
                        }
                        
                        // Check if package name or app name contains Google Pay keywords
                        val hasGoogle = pkgName.contains("google")
                        val hasPayKeyword = pkgName.contains("pay") || pkgName.contains("paisa") || 
                                          appName.contains("pay") || appName.contains("paisa") ||
                                          appName.contains("gpay") || appName.contains("google pay")
                        
                        if (hasGoogle && hasPayKeyword) {
                            val fullAppName = try {
                                appInfo.loadLabel(packageManager).toString()
                            } catch (e: Exception) {
                                pkg.packageName
                            }
                            
                            results[pkg.packageName] = fullAppName
                            Log.d("APP_CHECK", "  ⭐ POTENTIAL GOOGLE PAY FOUND: ${pkg.packageName} -> $fullAppName")
                        }
                    }
                }
            }
            
            Log.d("APP_CHECK", "Total Google Pay candidates found: ${results.size}")
            if (results.isNotEmpty()) {
                results.forEach { (pkg, name) ->
                    Log.d("APP_CHECK", "  📦 $pkg -> $name")
                }
            } else {
                Log.d("APP_CHECK", "  ❌ No Google Pay found")
            }
            
        } catch (e: Exception) {
            Log.e("APP_CHECK", "Error in aggressive search: ${e.message}")
        }
        return results
    }
    
    private fun openUPIWithForcedChooser(upiUrl: String): Boolean {
        try {
            Log.d("UPI_APP", "🔵 Opening UPI with FORCED CHOOSER: $upiUrl")
            val uri = Uri.parse(upiUrl)
            
            // Create intent
            val intent = Intent(Intent.ACTION_VIEW, uri)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            
            // ALWAYS use createChooser to force the chooser dialog to appear
            // This is what URL launcher does and why it shows the chooser!
            val chooser = Intent.createChooser(intent, "Choose Payment App")
            chooser.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            
            // Query for all apps that can handle this - try multiple flags
            var resolveInfos = packageManager.queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY)
            Log.d("UPI_APP", "Query with MATCH_DEFAULT_ONLY: Found ${resolveInfos.size} apps")
            
            // If no apps found, try with no flags (most permissive)
            if (resolveInfos.isEmpty()) {
                try {
                    resolveInfos = packageManager.queryIntentActivities(intent, 0)
                    Log.d("UPI_APP", "Query with 0 flags: Found ${resolveInfos.size} apps")
                } catch (e: Exception) {
                    Log.d("UPI_APP", "Query with 0 flags failed: ${e.message}")
                }
            }
            
            // If still no apps, try MATCH_ALL
            if (resolveInfos.isEmpty()) {
                try {
                    resolveInfos = packageManager.queryIntentActivities(intent, PackageManager.MATCH_ALL)
                    Log.d("UPI_APP", "Query with MATCH_ALL: Found ${resolveInfos.size} apps")
                } catch (e: Exception) {
                    Log.d("UPI_APP", "Query with MATCH_ALL failed: ${e.message}")
                }
            }
            
            Log.d("UPI_APP", "Total apps found that can handle UPI: ${resolveInfos.size}")
            
            if (resolveInfos.isNotEmpty()) {
                // Log all found apps
                for (resolveInfo in resolveInfos) {
                    val pkgName = resolveInfo.activityInfo.packageName
                    val appName = try {
                        resolveInfo.loadLabel(packageManager).toString()
                    } catch (e: Exception) {
                        pkgName
                    }
                    Log.d("UPI_APP", "  📱 $pkgName -> $appName")
                    
                    // Check if Google Pay is in the list
                    val pkgLower = pkgName.lowercase()
                    val appLower = appName.lowercase()
                    if (pkgLower.contains("google") && (pkgLower.contains("pay") || pkgLower.contains("paisa") || 
                        appLower.contains("google pay") || appLower.contains("gpay") || appLower == "gpay")) {
                        Log.d("UPI_APP", "  ⭐⭐⭐ GOOGLE PAY FOUND IN CHOOSER: $pkgName -> $appName")
                    }
                }
            }
            
            startActivity(chooser)
            Log.d("UPI_APP", "✅ Launched UPI chooser (will show ${resolveInfos.size} apps)")
            return true
        } catch (e: Exception) {
            Log.e("UPI_APP", "❌ Error opening UPI with chooser: ${e.message}", e)
            return false
        }
    }

    private fun openSpecificUPIApp(upiUrl: String, packageName: String): Boolean {
        try {
            Log.d("UPI_APP", "Opening UPI app: $packageName with URL: $upiUrl")
            val uri = Uri.parse(upiUrl)
            
            // For Google Pay, try multiple package names
            val googlePayPackages = listOf(
                "com.google.android.apps.nfc.payment",  // Old Google Wallet/NFC
                "com.google.android.apps.nbu.paisa.user", // Google Pay India
                "com.google.android.apps.walletnfcrel"   // Google Wallet
            )
            
            var actualPackageName = packageName
            var isInstalled = false
            
            // If it's Google Pay, try all possible package names
            if (packageName == "com.google.android.apps.nfc.payment") {
                for (pkg in googlePayPackages) {
                    try {
                        packageManager.getPackageInfo(pkg, 0)
                        actualPackageName = pkg
                        isInstalled = true
                        Log.d("UPI_APP", "✅ Found Google Pay with package: $pkg")
                        break
                    } catch (e: PackageManager.NameNotFoundException) {
                        Log.d("UPI_APP", "⚠️ Package $pkg not found, trying next...")
                    }
                }
            } else {
                // For other apps, check normally
                try {
                    val pkgInfo = packageManager.getPackageInfo(packageName, 0)
                    isInstalled = true
                    Log.d("UPI_APP", "✅ $packageName is installed")
                } catch (e: PackageManager.NameNotFoundException) {
                    Log.d("UPI_APP", "❌ $packageName is not installed")
                }
            }
            
            // If not installed, try to find it via UPI query instead of returning false
            if (!isInstalled) {
                Log.d("UPI_APP", "⚠️ Package not found via direct check, trying UPI query method...")
                return tryOpenViaUPIQuery(uri, packageName)
            }
            
            // Try multiple methods to launch the app
            
            // Method 1: Direct intent with package name
            try {
                val intent = Intent(Intent.ACTION_VIEW, uri)
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                intent.setPackage(packageName)
                
                val resolveInfo = packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
                if (resolveInfo != null) {
                    startActivity(intent)
                    Log.d("UPI_APP", "✅ $packageName opened via direct intent")
                    return true
                }
            } catch (e: Exception) {
                Log.d("UPI_APP", "Method 1 failed: ${e.message}")
            }
            
            // Method 2: Query for activities and find the specific one
            try {
                val baseIntent = Intent(Intent.ACTION_VIEW, uri)
                baseIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                
                val activities = packageManager.queryIntentActivities(baseIntent, PackageManager.MATCH_DEFAULT_ONLY)
                Log.d("UPI_APP", "Found ${activities.size} apps that can handle UPI URL")
                
                val targetActivity = activities.find { it.activityInfo.packageName == packageName }
                if (targetActivity != null) {
                    val specificIntent = Intent(Intent.ACTION_VIEW, uri)
                    specificIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    specificIntent.setClassName(
                        packageName,
                        targetActivity.activityInfo.name
                    )
                    startActivity(specificIntent)
                    Log.d("UPI_APP", "✅ $packageName opened via activity name")
                    return true
                }
            } catch (e: Exception) {
                Log.d("UPI_APP", "Method 2 failed: ${e.message}")
            }
            
            // Method 3: Try to get main launcher activity and launch with UPI URL
            try {
                val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
                if (launchIntent != null) {
                    launchIntent.action = Intent.ACTION_VIEW
                    launchIntent.data = uri
                    launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(launchIntent)
                    Log.d("UPI_APP", "✅ $packageName opened via launcher intent")
                    return true
                }
            } catch (e: Exception) {
                Log.d("UPI_APP", "Method 3 failed: ${e.message}")
            }
            
            // Method 4: Query for UPI apps and try to launch the specific one
            val baseIntent = Intent(Intent.ACTION_VIEW, uri)
            baseIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            
            val activities = packageManager.queryIntentActivities(baseIntent, PackageManager.MATCH_DEFAULT_ONLY)
            val targetActivity = activities.find { it.activityInfo.packageName == packageName }
            
            if (targetActivity != null) {
                val specificIntent = Intent(Intent.ACTION_VIEW, uri)
                specificIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                specificIntent.setClassName(
                    packageName,
                    targetActivity.activityInfo.name
                )
                try {
                    startActivity(specificIntent)
                    Log.d("UPI_APP", "✅ $packageName opened via queried activity")
                    return true
                } catch (e: Exception) {
                    Log.e("UPI_APP", "❌ Failed to launch via queried activity: ${e.message}")
                }
            }
            
            // Last resort: For Google Pay, launch UPI URL directly without package restriction
            // This will show Android's native chooser with ALL apps that can handle UPI URLs
            if (packageName == "com.google.android.apps.nfc.payment") {
                Log.d("UPI_APP", "All methods failed for Google Pay, launching UPI URL directly...")
                try {
                    val directIntent = Intent(Intent.ACTION_VIEW, uri)
                    directIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    
                    // Query for all apps that can handle this UPI URL
                    val activities = packageManager.queryIntentActivities(directIntent, PackageManager.MATCH_DEFAULT_ONLY)
                    Log.d("UPI_APP", "Found ${activities.size} apps that can handle UPI URL directly")
                    
                    if (activities.isNotEmpty()) {
                        // Create chooser with all apps that can handle UPI
                        val mainIntent = Intent(Intent.ACTION_VIEW, uri)
                        mainIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        mainIntent.setClassName(
                            activities[0].activityInfo.packageName,
                            activities[0].activityInfo.name
                        )
                        
                        val chooserIntents = activities.drop(1).map { activity ->
                            val intent = Intent(Intent.ACTION_VIEW, uri)
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            intent.setClassName(
                                activity.activityInfo.packageName,
                                activity.activityInfo.name
                            )
                            intent
                        }.toTypedArray()
                        
                        val chooser = Intent.createChooser(mainIntent, "Choose Payment App")
                        chooser.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        if (chooserIntents.isNotEmpty()) {
                            chooser.putExtra(Intent.EXTRA_INITIAL_INTENTS, chooserIntents)
                        }
                        
                        startActivity(chooser)
                        Log.d("UPI_APP", "✅ Launched UPI URL chooser with ${activities.size} apps")
                        return true
                    } else {
                        // No apps found via query, use custom chooser instead
                        Log.d("UPI_APP", "No apps found via query, using custom chooser")
                        showUpiAppChooser(uri)
                        return true
                    }
                } catch (e: Exception) {
                    Log.e("UPI_APP", "Direct launch failed: ${e.message}", e)
                    // Fallback to custom chooser
                    showUpiAppChooser(uri)
                    return true
                }
            }
            
            // For other apps, use custom chooser
            Log.d("UPI_APP", "All direct methods failed, using UPI app chooser")
            showUpiAppChooser(uri)
            return true
        } catch (e: Exception) {
            Log.e("UPI_APP", "❌ Error opening $packageName: ${e.message}", e)
            // Fallback to chooser even on error
            try {
                showUpiAppChooser(Uri.parse(upiUrl))
                return true
            } catch (e2: Exception) {
                Log.e("UPI_APP", "❌ Fallback chooser also failed: ${e2.message}")
                return false
            }
        }
    }
    
    private fun tryOpenViaUPIQuery(uri: Uri, originalPackageName: String): Boolean {
        try {
            Log.d("UPI_APP", "Trying to find $originalPackageName via UPI query...")
            
            // Try different intent actions and data types
            val intentActions = listOf(
                Intent.ACTION_VIEW,
                Intent.ACTION_SEND
            )
            
            var activities = mutableListOf<android.content.pm.ResolveInfo>()
            
            // Try ACTION_VIEW with UPI URI - use MATCH_ALL to find more apps
            try {
                val baseIntent = Intent(Intent.ACTION_VIEW, uri)
                baseIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                var result = packageManager.queryIntentActivities(baseIntent, PackageManager.MATCH_DEFAULT_ONLY)
                if (result.isEmpty()) {
                    // Try MATCH_ALL if MATCH_DEFAULT_ONLY returns nothing
                    try {
                        result = packageManager.queryIntentActivities(baseIntent, PackageManager.MATCH_ALL)
                    } catch (e: Exception) {
                        Log.d("UPI_APP", "MATCH_ALL query failed: ${e.message}")
                    }
                }
                activities.addAll(result)
                Log.d("UPI_APP", "Found ${result.size} apps with ACTION_VIEW")
            } catch (e: Exception) {
                Log.d("UPI_APP", "ACTION_VIEW query failed: ${e.message}")
            }
            
            // Try with just the scheme
            try {
                val schemeIntent = Intent(Intent.ACTION_VIEW)
                schemeIntent.data = Uri.parse("upi://")
                schemeIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                var result = packageManager.queryIntentActivities(schemeIntent, PackageManager.MATCH_DEFAULT_ONLY)
                if (result.isEmpty()) {
                    try {
                        result = packageManager.queryIntentActivities(schemeIntent, PackageManager.MATCH_ALL)
                    } catch (e: Exception) {
                        Log.d("UPI_APP", "MATCH_ALL scheme query failed: ${e.message}")
                    }
                }
                activities.addAll(result)
                Log.d("UPI_APP", "Found ${result.size} apps with upi:// scheme")
            } catch (e: Exception) {
                Log.d("UPI_APP", "upi:// scheme query failed: ${e.message}")
            }
            
            // Remove duplicates
            val uniqueActivities = activities.distinctBy { it.activityInfo.packageName }
            Log.d("UPI_APP", "Total unique apps found: ${uniqueActivities.size}")
            
            // For Google Pay, check all possible package names and also search by keywords
            val googlePayPackages = listOf(
                "com.google.android.apps.nfc.payment",
                "com.google.android.apps.nbu.paisa.user",
                "com.google.android.apps.walletnfcrel",
                "com.google.android.apps.nbu.paisa",  // Another variant
                "com.google.paisa"  // Short variant
            )
            
            // First, try to find by exact package name match
            val targetActivity = if (originalPackageName == "com.google.android.apps.nfc.payment") {
                uniqueActivities.find { activity ->
                    googlePayPackages.contains(activity.activityInfo.packageName) ||
                    (activity.activityInfo.packageName.contains("google") && 
                     (activity.activityInfo.packageName.contains("pay") || 
                      activity.activityInfo.packageName.contains("paisa") ||
                      activity.activityInfo.packageName.contains("wallet")))
                }
            } else {
                uniqueActivities.find { it.activityInfo.packageName == originalPackageName }
            }
            
            if (targetActivity != null) {
                val specificIntent = Intent(Intent.ACTION_VIEW, uri)
                specificIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                specificIntent.setClassName(
                    targetActivity.activityInfo.packageName,
                    targetActivity.activityInfo.name
                )
                startActivity(specificIntent)
                Log.d("UPI_APP", "✅ Found and opened ${targetActivity.activityInfo.packageName} via UPI query")
                return true
            }
            
            // If still not found, check installed packages directly for Google Pay
            if (originalPackageName == "com.google.android.apps.nfc.payment") {
                Log.d("UPI_APP", "Checking installed packages for Google Pay...")
                try {
                    val installedPackages = packageManager.getInstalledPackages(PackageManager.MATCH_DEFAULT_ONLY)
                    Log.d("UPI_APP", "Scanning ${installedPackages.size} installed packages for Google Pay...")
                    
                    val googleApps = mutableListOf<String>()
                    for (pkg in installedPackages) {
                        val pkgName = pkg.packageName.lowercase()
                        if (pkgName.contains("google")) {
                            val appInfo = pkg.applicationInfo
                            val appName = try {
                                if (appInfo != null) appInfo.loadLabel(packageManager).toString() else ""
                            } catch (e: Exception) {
                                ""
                            }
                            googleApps.add("${pkg.packageName} -> $appName")
                            
                            // Check if it looks like Google Pay
                            if (pkgName.contains("google") && 
                                (pkgName.contains("pay") || pkgName.contains("paisa") || pkgName.contains("wallet") || pkgName.contains("nbu"))) {
                                Log.d("UPI_APP", "  🔍 Found potential Google Pay: ${pkg.packageName} ($appName)")
                                // Try to launch it
                                try {
                                    val intent = Intent(Intent.ACTION_VIEW, uri)
                                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                    intent.setPackage(pkg.packageName)
                                    startActivity(intent)
                                    Log.d("UPI_APP", "✅ Opened ${pkg.packageName} via installed package check")
                                    return true
                                } catch (e: Exception) {
                                    Log.d("UPI_APP", "Failed to launch ${pkg.packageName}: ${e.message}")
                                }
                            }
                        }
                    }
                    Log.d("UPI_APP", "Found ${googleApps.size} Google apps. First 10: ${googleApps.take(10).joinToString(", ")}")
                } catch (e: Exception) {
                    Log.e("UPI_APP", "Error checking installed packages: ${e.message}", e)
                }
            }
            
            // If not found, for Google Pay, launch UPI URL directly to show Android's native chooser
            if (originalPackageName == "com.google.android.apps.nfc.payment") {
                Log.d("UPI_APP", "Google Pay not found, launching UPI URL directly to show Android chooser...")
                try {
                    val directIntent = Intent(Intent.ACTION_VIEW, uri)
                    directIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    
                    // Query for all apps that can handle this
                    var activities = packageManager.queryIntentActivities(directIntent, PackageManager.MATCH_DEFAULT_ONLY)
                    if (activities.isEmpty()) {
                        try {
                            activities = packageManager.queryIntentActivities(directIntent, PackageManager.MATCH_ALL)
                        } catch (e: Exception) {
                            Log.d("UPI_APP", "MATCH_ALL failed: ${e.message}")
                        }
                    }
                    
                    if (activities.isNotEmpty()) {
                        // Create chooser with all found apps
                        val mainIntent = Intent(Intent.ACTION_VIEW, uri)
                        mainIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        mainIntent.setClassName(
                            activities[0].activityInfo.packageName,
                            activities[0].activityInfo.name
                        )
                        
                        val chooserIntents = activities.drop(1).map { activity ->
                            val intent = Intent(Intent.ACTION_VIEW, uri)
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            intent.setClassName(
                                activity.activityInfo.packageName,
                                activity.activityInfo.name
                            )
                            intent
                        }.toTypedArray()
                        
                        val chooser = Intent.createChooser(mainIntent, "Choose Payment App")
                        chooser.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        if (chooserIntents.isNotEmpty()) {
                            chooser.putExtra(Intent.EXTRA_INITIAL_INTENTS, chooserIntents)
                        }
                        
                        startActivity(chooser)
                        Log.d("UPI_APP", "✅ Launched UPI chooser with ${activities.size} apps")
                        return true
                    } else {
                        // No apps found via query, use custom chooser instead
                        Log.d("UPI_APP", "No apps found via query, using custom chooser")
                        showUpiAppChooser(uri)
                        return true
                    }
                } catch (e: Exception) {
                    Log.e("UPI_APP", "Direct launch failed: ${e.message}", e)
                    // Fallback to custom chooser
                    showUpiAppChooser(uri)
                    return true
                }
            }
            
            // For other apps, show chooser
            Log.d("UPI_APP", "App not found in UPI query, showing chooser")
            showUpiAppChooser(uri)
            return true
        } catch (e: Exception) {
            Log.e("UPI_APP", "❌ Error in tryOpenViaUPIQuery: ${e.message}", e)
            showUpiAppChooser(uri)
            return true
        }
    }

    private fun openGooglePay(upiUrl: String) {
        try {
            Log.d("GOOGLE_PAY", "Opening Google Pay with UPI URL: $upiUrl")
            val uri = Uri.parse(upiUrl)
            val packageManager = packageManager
            
            // Google Pay package name
            val googlePayPackage = "com.google.android.apps.nfc.payment"
            
            // First, check if Google Pay is installed
            try {
                packageManager.getPackageInfo(googlePayPackage, 0)
                Log.d("GOOGLE_PAY", "Google Pay is installed")
            } catch (e: PackageManager.NameNotFoundException) {
                Log.d("GOOGLE_PAY", "Google Pay not installed, showing app chooser")
                // Google Pay not installed, find all UPI apps and show chooser
                showUpiAppChooser(uri)
                return
            }
            
            // Try to open Google Pay directly
            val intent = Intent(Intent.ACTION_VIEW, uri)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            intent.setPackage(googlePayPackage)
            
            // Check if Google Pay can handle this intent
            val resolveInfo = packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
            
            if (resolveInfo != null) {
                // Google Pay can handle it, open directly
                startActivity(intent)
                Log.d("GOOGLE_PAY", "✅ Google Pay opened successfully")
            } else {
                // Google Pay installed but can't handle, try without package restriction
                Log.d("GOOGLE_PAY", "Google Pay can't resolve, trying without package restriction")
                val fallbackIntent = Intent(Intent.ACTION_VIEW, uri)
                fallbackIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                
                // Query for apps that can handle UPI
                val activities = packageManager.queryIntentActivities(fallbackIntent, PackageManager.MATCH_DEFAULT_ONLY)
                Log.d("GOOGLE_PAY", "Found ${activities.size} apps that can handle UPI URL")
                
                // Find Google Pay in the list
                val googlePayActivity = activities.find { 
                    it.activityInfo.packageName == googlePayPackage 
                }
                
                if (googlePayActivity != null) {
                    // Create intent specifically for Google Pay
                    val specificIntent = Intent(Intent.ACTION_VIEW, uri)
                    specificIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    specificIntent.setClassName(
                        googlePayPackage,
                        googlePayActivity.activityInfo.name
                    )
                    startActivity(specificIntent)
                    Log.d("GOOGLE_PAY", "✅ Google Pay opened via activity name")
                } else {
                    // Show chooser with all UPI apps
                    Log.d("GOOGLE_PAY", "Showing app chooser")
                    showUpiAppChooser(uri)
                }
            }
        } catch (e: Exception) {
            Log.e("GOOGLE_PAY", "Error opening Google Pay: ${e.message}", e)
            e.printStackTrace()
            // Fallback to generic chooser
            try {
                showUpiAppChooser(Uri.parse(upiUrl))
            } catch (e2: Exception) {
                Log.e("GOOGLE_PAY", "Fallback also failed: ${e2.message}", e2)
            }
        }
    }

    private fun showUpiAppChooser(uri: Uri) {
        try {
            Log.d("GOOGLE_PAY", "Finding UPI apps for chooser")
            val packageManager = packageManager
            val baseIntent = Intent(Intent.ACTION_VIEW, uri)
            baseIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            
            // Known UPI app packages
            val knownUpiPackages = listOf(
                "com.phonepe.app",
                "net.one97.paytm",
                "com.google.android.apps.nfc.payment",  // Old Google Wallet/NFC
                "com.google.android.apps.nbu.paisa.user", // Google Pay India
                "com.google.android.apps.walletnfcrel",   // Google Wallet
                "in.org.npci.upiapp",
                "com.whatsapp",
                "com.amazon.mShop.android.shopping",
                "com.mobikwik",
                "com.freecharge.android",
                "com.airtel.money",
                "com.jio.myjio",
                "com.sbi.sbiunipay",
                "com.axis.mobile",
                "com.hdfcbank.hdfcpay",
                "com.icicibank.pockets",
                "com.kotak.mahindra.bank",
                "com.yesbank.yespay",
                "com.idfcfirstbank.firstnet",
                "com.payzapp"
            )
            
            val upiIntents = mutableListOf<Intent>()
            
            // First, try to get all installed packages and filter for UPI apps
            try {
                val installedPackages = packageManager.getInstalledPackages(PackageManager.MATCH_DEFAULT_ONLY)
                Log.d("GOOGLE_PAY", "Total installed packages: ${installedPackages.size}")
                
                // Filter for UPI-related packages
                val upiKeywords = listOf("upi", "pay", "phonepe", "paytm", "googlepay", "gpay", "bhim", "whatsapp", "amazon", "paisa", "wallet")
                
                // Google Pay specific package names and keywords
                val googlePayExactPackages = listOf(
                    "com.google.android.apps.nfc.payment",
                    "com.google.android.apps.nbu.paisa.user",
                    "com.google.android.apps.walletnfcrel",
                    "com.google.android.apps.nbu.paisa",
                    "com.google.paisa"
                )
                val googlePayKeywords = listOf("google pay", "googlepay", "gpay", "tez", "paisa")
                
                for (packageInfo in installedPackages) {
                    val packageName = packageInfo.packageName.lowercase()
                    val appInfo = packageInfo.applicationInfo
                    if (appInfo == null) continue
                    
                    val appName = appInfo.loadLabel(packageManager).toString().lowercase()
                    
                    // Check if it's a known UPI package
                    val isKnownUpi = knownUpiPackages.contains(packageInfo.packageName) || 
                                    googlePayExactPackages.contains(packageInfo.packageName)
                    
                    // Check if package name or app name contains UPI keywords
                    val isUpiApp = isKnownUpi || upiKeywords.any { keyword ->
                        packageName.contains(keyword) || appName.contains(keyword)
                    }
                    
                    // Special check for Google Pay - check package name patterns
                    val isGooglePay = packageName.contains("google") && 
                                    (packageName.contains("pay") || 
                                     packageName.contains("paisa") || 
                                     packageName.contains("wallet") ||
                                     packageName.contains("tez")) ||
                                    googlePayKeywords.any { keyword ->
                                        appName.contains(keyword)
                                    }
                    
                    val shouldInclude = isUpiApp || isGooglePay
                    
                    if (shouldInclude) {
                        try {
                            // Create intent with package name - Android will resolve the activity
                            val specificIntent = Intent(Intent.ACTION_VIEW, uri)
                            specificIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            specificIntent.setPackage(packageInfo.packageName)
                            
                            // Check if this app can handle the intent (even if query returned 0)
                            val resolveInfo = packageManager.resolveActivity(specificIntent, PackageManager.MATCH_DEFAULT_ONLY)
                            if (resolveInfo != null) {
                                upiIntents.add(specificIntent)
                                Log.d("GOOGLE_PAY", "  ✅ Found UPI app: ${appInfo.loadLabel(packageManager)} (${packageInfo.packageName})")
                            } else {
                                // Even if resolveActivity returns null, try adding it anyway
                                // Some apps might handle UPI but not register intents properly
                                upiIntents.add(specificIntent)
                                Log.d("GOOGLE_PAY", "  ⚠️ Added UPI app without resolve check: ${appInfo.loadLabel(packageManager)} (${packageInfo.packageName})")
                            }
                        } catch (e: Exception) {
                            Log.d("GOOGLE_PAY", "Error checking ${packageInfo.packageName}: ${e.message}")
                        }
                    }
                }
            } catch (e: Exception) {
                Log.e("GOOGLE_PAY", "Error getting installed packages: ${e.message}", e)
            }
            
            // Also check known packages directly as fallback
            // First, check Google Pay packages specifically (most important)
            val googlePayPackages = listOf(
                "com.google.android.apps.nbu.paisa.user", // Google Pay India (most common)
                "com.google.android.apps.nfc.payment",    // Old Google Wallet/NFC
                "com.google.android.apps.walletnfcrel",   // Google Wallet
                "com.google.android.apps.nbu.paisa"       // Another variant
            )
            
            var googlePayFound = false
            for (packageName in googlePayPackages) {
                try {
                    packageManager.getPackageInfo(packageName, 0)
                    // Check if not already added
                    if (!upiIntents.any { it.`package` == packageName }) {
                        val specificIntent = Intent(baseIntent)
                        specificIntent.setPackage(packageName)
                        specificIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        upiIntents.add(specificIntent)
                        googlePayFound = true
                        Log.d("GOOGLE_PAY", "  ✅ Added Google Pay: $packageName")
                        break // Use first found
                    } else {
                        googlePayFound = true
                    }
                } catch (e: PackageManager.NameNotFoundException) {
                    // Package not installed, continue checking
                } catch (e: Exception) {
                    Log.d("GOOGLE_PAY", "Error checking Google Pay $packageName: ${e.message}")
                }
            }
            
            // If Google Pay not found in known packages, search all installed apps
            if (!googlePayFound) {
                Log.d("GOOGLE_PAY", "Google Pay not found in known packages, searching all installed apps...")
                try {
                    val installedPackages = packageManager.getInstalledPackages(PackageManager.MATCH_DEFAULT_ONLY)
                    Log.d("GOOGLE_PAY", "Searching through ${installedPackages.size} installed packages...")
                    
                    var checkedCount = 0
                    for (pkg in installedPackages) {
                        val pkgName = pkg.packageName.lowercase()
                        val appInfo = pkg.applicationInfo
                        if (appInfo != null) {
                            checkedCount++
                            val appName = try {
                                appInfo.loadLabel(packageManager).toString().lowercase()
                            } catch (e: Exception) {
                                ""
                            }
                            
                            // More aggressive matching for Google Pay
                            val looksLikeGooglePay = 
                                // Package name patterns
                                (pkgName.contains("google") && (pkgName.contains("pay") || pkgName.contains("paisa") || pkgName.contains("wallet") || pkgName.contains("tez") || pkgName.contains("nbu"))) ||
                                // App name patterns (more variations)
                                appName.contains("google pay") || 
                                appName.contains("gpay") ||
                                appName.contains("tez") ||
                                appName == "google pay" ||
                                (appName.contains("google") && appName.contains("pay")) ||
                                appName.contains("gpays") ||
                                appName.contains("googlepay")
                            
                            // Log potential matches for debugging
                            if (pkgName.contains("google")) {
                                Log.d("GOOGLE_PAY", "  Checking Google app: ${pkg.packageName} -> ${appName}")
                            }
                            
                            if (looksLikeGooglePay) {
                                Log.d("GOOGLE_PAY", "  🔍 Found potential Google Pay: ${pkg.packageName} (${appName})")
                                if (!upiIntents.any { it.`package` == pkg.packageName }) {
                                    val intent = Intent(baseIntent)
                                    intent.setPackage(pkg.packageName)
                                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                    upiIntents.add(intent)
                                    googlePayFound = true
                                    Log.d("GOOGLE_PAY", "  ✅ Added potential Google Pay: ${pkg.packageName}")
                                    break // Use first match
                                }
                            }
                        }
                    }
                    Log.d("GOOGLE_PAY", "Checked $checkedCount packages, Google Pay found: $googlePayFound")
                } catch (e: Exception) {
                    Log.e("GOOGLE_PAY", "Error searching for Google Pay: ${e.message}", e)
                }
            }
            
            // Then check other known packages (skip Google Pay packages as we already checked them)
            for (packageName in knownUpiPackages) {
                // Skip Google Pay packages as we already checked them
                if (googlePayPackages.contains(packageName)) continue
                
                try {
                    packageManager.getPackageInfo(packageName, 0)
                    // Check if not already added
                    if (!upiIntents.any { it.`package` == packageName }) {
                        val specificIntent = Intent(baseIntent)
                        specificIntent.setPackage(packageName)
                        specificIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        upiIntents.add(specificIntent)
                        Log.d("GOOGLE_PAY", "  ✅ Added known UPI app: $packageName")
                    }
                } catch (e: PackageManager.NameNotFoundException) {
                    // Package not installed, skip
                } catch (e: Exception) {
                    Log.d("GOOGLE_PAY", "Error checking $packageName: ${e.message}")
                }
            }
            
            Log.d("GOOGLE_PAY", "Total UPI apps found: ${upiIntents.size} (Google Pay found: $googlePayFound)")
            
            if (upiIntents.isNotEmpty()) {
                // Resolve activity names for all intents to avoid share dialog
                val resolvedIntents = mutableListOf<Intent>()
                var activities = packageManager.queryIntentActivities(baseIntent, PackageManager.MATCH_DEFAULT_ONLY)
                
                // If no activities found, try MATCH_ALL
                if (activities.isEmpty()) {
                    try {
                        activities = packageManager.queryIntentActivities(baseIntent, PackageManager.MATCH_ALL)
                    } catch (e: Exception) {
                        Log.d("GOOGLE_PAY", "MATCH_ALL query failed: ${e.message}")
                    }
                }
                
                for (intent in upiIntents) {
                    val pkg = intent.`package`
                    if (pkg != null) {
                        val activity = activities.find { it.activityInfo.packageName == pkg }
                        if (activity != null) {
                            // Found activity, use it
                            val resolvedIntent = Intent(Intent.ACTION_VIEW, uri)
                            resolvedIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            resolvedIntent.setClassName(
                                pkg,
                                activity.activityInfo.name
                            )
                            resolvedIntents.add(resolvedIntent)
                            Log.d("GOOGLE_PAY", "  ✅ Resolved intent for $pkg")
                        } else {
                            // No activity found, but package is installed - use intent as is
                            // Android will figure out the activity
                            resolvedIntents.add(intent)
                            Log.d("GOOGLE_PAY", "  ⚠️ Using intent without activity resolution for $pkg")
                        }
                    } else {
                        // Intent already has class name, use as is
                        resolvedIntents.add(intent)
                    }
                }
                
                if (resolvedIntents.isNotEmpty()) {
                    // If only one app, launch directly
                    if (resolvedIntents.size == 1) {
                        try {
                            startActivity(resolvedIntents[0])
                            Log.d("GOOGLE_PAY", "✅ Single UPI app launched directly")
                            return
                        } catch (e: Exception) {
                            Log.e("GOOGLE_PAY", "❌ Failed to launch single app: ${e.message}")
                        }
                    }
                    
                    // Multiple apps - create chooser
                    val mainIntent = resolvedIntents.removeAt(0)
                val chooserIntent = Intent.createChooser(mainIntent, "Choose Payment App")
                chooserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                
                    if (resolvedIntents.isNotEmpty()) {
                        chooserIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, resolvedIntents.toTypedArray())
                        Log.d("GOOGLE_PAY", "Creating chooser with ${resolvedIntents.size + 1} UPI apps")
                } else {
                    Log.d("GOOGLE_PAY", "Creating chooser with 1 UPI app")
                }
                
                startActivity(chooserIntent)
                Log.d("GOOGLE_PAY", "✅ UPI app chooser started")
                } else {
                    Log.e("GOOGLE_PAY", "❌ No resolved intents available")
                }
            } else {
                // No UPI apps found, try queryIntentActivities as last resort
                Log.d("GOOGLE_PAY", "No UPI apps found via package check, trying queryIntentActivities")
                var activities = packageManager.queryIntentActivities(baseIntent, PackageManager.MATCH_ALL)
                if (activities.isEmpty()) {
                    activities = packageManager.queryIntentActivities(baseIntent, PackageManager.MATCH_DEFAULT_ONLY)
                }
                
                if (activities.isNotEmpty()) {
                    Log.d("GOOGLE_PAY", "Found ${activities.size} apps via queryIntentActivities")
                    val queryIntents = mutableListOf<Intent>()
                    for (resolveInfo in activities) {
                        val specificIntent = Intent(baseIntent)
                        specificIntent.setPackage(resolveInfo.activityInfo.packageName)
                        queryIntents.add(specificIntent)
                    }
                    
                    if (queryIntents.isNotEmpty()) {
                        val mainIntent = queryIntents.removeAt(0)
                        val chooserIntent = Intent.createChooser(mainIntent, "Choose Payment App")
                        chooserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        if (queryIntents.isNotEmpty()) {
                            chooserIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, queryIntents.toTypedArray())
                        }
                        startActivity(chooserIntent)
                        Log.d("GOOGLE_PAY", "✅ Chooser started with queried apps")
                        return
                    }
                }
                
                // Final fallback - use createChooser which will show apps or handle gracefully
                Log.d("GOOGLE_PAY", "No apps found, using createChooser as fallback")
                val chooserIntent = Intent.createChooser(baseIntent, "Choose Payment App")
                chooserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                try {
                    startActivity(chooserIntent)
                    Log.d("GOOGLE_PAY", "✅ Chooser started (may show share dialog if no UPI apps)")
                } catch (e: Exception) {
                    Log.e("GOOGLE_PAY", "Chooser failed: ${e.message}", e)
                    // Last resort - show error message to user
                }
            }
        } catch (e: Exception) {
            Log.e("GOOGLE_PAY", "Error showing UPI chooser: ${e.message}", e)
            e.printStackTrace()
            // Final fallback - always use createChooser
            try {
                val intent = Intent(Intent.ACTION_VIEW, uri)
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                val chooserIntent = Intent.createChooser(intent, "Choose Payment App")
                chooserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(chooserIntent)
                Log.d("GOOGLE_PAY", "✅ Fallback chooser started")
            } catch (e2: Exception) {
                Log.e("GOOGLE_PAY", "Final fallback failed: ${e2.message}", e2)
            }
        }
    }
}
