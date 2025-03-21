// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/**
 * Flutter loader for web applications.
 * This script needs to be included in the <head> tag before any other script.
 * It provides the `_flutter` global variable, which can be used to load the Flutter app.
 */

'use strict';

/**
 * Creates a _flutter namespace in the global window scope.
 */
(function() {
  if (typeof window === 'undefined') {
    return;
  }

  window._flutter = window._flutter || {};
  window._flutter.loader = window._flutter.loader || {};
  
  // Define default configuration values
  const defaultSettings = {
    serviceWorkerSettings: {
      scope: './',
    },
  };

  let settings = {};
  
  // Override settings with user configuration
  window._flutter.loader.loadEntrypoint = function(options) {
    settings = {
      ...defaultSettings,
      ...options,
    };
    
    initializePlatform();
    return _loadEntrypoint();
  };

  function _loadEntrypoint() {
    return new Promise((resolve, reject) => {
      const entrypointUrl = 'main.dart.js';
      const engineUrl = 'flutter_engine.js';
  
      _fetchScript(engineUrl)
        .then(() => _fetchScript(entrypointUrl))
        .then(() => {
          const entrypoint = window.main.init();
          if (settings.onEntrypointLoaded) {
            window.setTimeout(() => {
              settings.onEntrypointLoaded(entrypoint);
            }, 0);
          }
          resolve(entrypoint);
        })
        .catch(reject);
    });
  }

  function _fetchScript(url) {
    return new Promise((resolve, reject) => {
      const script = document.createElement('script');
      script.src = url;
      script.onerror = reject;
      script.onload = resolve;
      document.body.append(script);
    });
  }

  function initializePlatform() {
    // Register the service worker if available
    if ('serviceWorker' in navigator) {
      const serviceWorkerUrl = 'flutter_service_worker.js?v=' + 
        (settings.serviceWorker?.serviceWorkerVersion || Math.random());
      navigator.serviceWorker.register(
        serviceWorkerUrl, 
        settings.serviceWorker?.serviceWorkerSettings || defaultSettings.serviceWorkerSettings
      )
      .then(function(reg) {
        console.log('Service worker registered with scope: ' + reg.scope);
      })
      .catch(function(err) {
        console.warn('Service worker registration failed: ', err);
      });
    }
    
    // This is an empty placeholder to ensure flutter.js interface compatibility
    window._flutter.loader = { ...window._flutter.loader };
    
    // Initialize dummy engine interfaces
    window.main = window.main || {};
    window.main.init = window.main.init || function() {
      return {
        initializeEngine: async function(config) {
          return {
            runApp: function() {
              console.log('Flutter app initialized');
            }
          };
        }
      };
    };
  }
})();