import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'logger.dart';

// Singleton connectivity utility
class ConnectivityUtils {
  static final ConnectivityUtils _instance = ConnectivityUtils._internal();
  factory ConnectivityUtils() => _instance;
  ConnectivityUtils._internal();
  
  final Connectivity _connectivity = Connectivity();
  final ValueNotifier<bool> connectionStatus = ValueNotifier<bool>(true);
  
  // Initialize connectivity monitoring
  void init() {
    // Initial check
    checkConnectivity().then((isConnected) {
      connectionStatus.value = isConnected;
    });
    
    // Listen for changes
    _connectivity.onConnectivityChanged.listen((result) {
      _updateConnectionStatus(result);
    });
  }
  
  // Update connection status based on connectivity result
  void _updateConnectionStatus(ConnectivityResult result) async {
    final isConnected = await _checkConnectionWithResult(result);
    if (connectionStatus.value != isConnected) {
      connectionStatus.value = isConnected;
      Logger.info('Connectivity changed: ${isConnected ? 'Connected' : 'Disconnected'}');
    }
  }
  
  // Check connection based on a specific connectivity result
  Future<bool> _checkConnectionWithResult(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) {
      return false;
    }
    
    if (kIsWeb) {
      // For web, we'll assume connectivity (can't fully check in web)
      return true;
    }
    
    // Verify internet connection by making a test request
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
  
  // Check if device is currently connected to the internet
  Future<bool> checkConnectivity() async {
    try {
      if (kIsWeb) {
        // For web, we'll assume connectivity (can't fully check in web)
        return true;
      }
      
      // Check connectivity status
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }
      
      // Verify internet connection by making a test request
      try {
        final result = await InternetAddress.lookup('google.com');
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } on SocketException catch (_) {
        return false;
      }
    } catch (e) {
      Logger.error('Error checking connectivity: $e');
      return false;
    }
  }
  
  // Stream of connectivity changes
  Stream<bool> onConnectivityChanged() {
    return _connectivity.onConnectivityChanged.map((status) {
      final isConnected = status != ConnectivityResult.none;
      Logger.info('Connectivity changed: ${isConnected ? 'Connected' : 'Disconnected'}');
      return isConnected;
    });
  }
  
  // Retry a function until it succeeds or reaches max attempts
  Future<T> retryWithConnectivity<T>({
    required Future<T> Function() operation,
    required T Function() fallback,
    int maxAttempts = 3,
    int delayInSeconds = 2,
  }) async {
    int attempts = 0;
    
    while (attempts < maxAttempts) {
      attempts++;
      
      try {
        // Check connectivity before attempting
        final connected = await checkConnectivity();
        if (!connected) {
          Logger.warning('No internet connection (attempt $attempts/$maxAttempts)');
          
          // If we've reached max attempts, return fallback
          if (attempts >= maxAttempts) {
            Logger.warning('Max attempts reached, using fallback');
            return fallback();
          }
          
          // Wait before next attempt
          await Future.delayed(Duration(seconds: delayInSeconds));
          continue;
        }
        
        // Try the operation
        return await operation();
      } catch (e) {
        Logger.error('Error in network operation (attempt $attempts/$maxAttempts): $e');
        
        // If we've reached max attempts, return fallback
        if (attempts >= maxAttempts) {
          Logger.warning('Max attempts reached, using fallback');
          return fallback();
        }
        
        // Wait before next attempt
        await Future.delayed(Duration(seconds: delayInSeconds));
      }
    }
    
    // This should never be reached due to the checks above, but just in case
    return fallback();
  }
}

// Connectivity Monitor Widget to wrap the app and show offline status
class ConnectivityMonitor extends StatelessWidget {
  final Widget child;
  
  const ConnectivityMonitor({
    Key? key,
    required this.child,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ConnectivityUtils().connectionStatus,
      builder: (context, isConnected, _) {
        return Stack(
          children: [
            child,
            if (!isConnected)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: const Text(
                    'No Internet Connection',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}