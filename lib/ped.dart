library polymer_element_dependencies;

import 'dart:io';
import 'package:path/path.dart' as pathos;
import 'package:yaml/yaml.dart';

import 'src/pdir.dart';

/**
 * returns a JSON representation of the polymer app structure
 * 
 * record format:
 * - imports
 * - declarations
 * - uses
 * - warnings
 * - entry_point
 * 
 */
String toJson([String entry_point = null]) {
  
  if (entry_point == null) {
    entry_point = _entryPointFromPubspec();
  }
  
  PDir pd = new PDir(entry_point);
  return pd.toJson();  
}

/**
 * returns a visual representation of the polymer app structure
 * 
 * writes to a file `_ped.html` in the current directory
 */
void toViz([String entry_point = null]) {
    
  if (entry_point == null) {
    entry_point = _entryPointFromPubspec();
  }
  
  print(entry_point);
  
  PDir pd = new PDir(entry_point);
  String out = '''
<!DOCTYPE html>
<html>
  <head>
    <!-- output: SVG (via https://github.com/mdaines/viz.js/) -->
    <title>Polymer-Element Dependencies</title>
  </head>
  <body>
    <script type="text/vnd.graphviz" id="cluster">
''';
  out += pd.toViz();  
  out += '''
    </script>
    <script src="http://dartlabs.appspot.com/static/viz.js"></script>
    <script>
      var id = 'cluster';
      var format = 'svg';      
      function inspect(s) {
        return "<pre>" + s.replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;") + "</pre>"}      
      function src(id) {
        return document.getElementById(id).innerHTML;}      
      function example() {
        var result;
        try {
          result = Viz(src(id), format);
          if (format === "svg")
            return result;
          else
            return inspect(result);
        } catch(e) {
          return inspect(e.toString());
        }
      }
      document.body.innerHTML += '<h1>Polymer-Element Dependencies</h1>';              
      document.body.innerHTML += example();              
      document.body.innerHTML += "''' + pd.legend() + '''";              
    </script>
  </body>
</html>
''';
  File f = new File('_ped.html');
  f.writeAsStringSync(out);
  print('File "_ped.html" written to current directory!');
}

/**
 * gets the first entry_point from pubspec.yaml configuration
 * 
 *   transformers:
 *   - polymer: 
 *       entry_points: path/to/entry_point
 *   
 *   or
 *   
 *   transformers:
 *   - polymer: 
 *       entry_points: 
 *       - path/to/entry_point_1
 *       - path/to/entry_point_2
 *   
 */
String _entryPointFromPubspec() {
  var entryPoint = null;
  String path = pathos.current;
  var pubspecPath = pathos.join(path, 'pubspec.yaml');
  var file = new File(pubspecPath);
  String yaml = file.readAsStringSync();
  Map config = loadYaml(yaml);
  if (config['transformers'] != null) {
    var transformersPolymer = null;
    var transformersPolymerEntrypoints = null;
    if (config['transformers'] is List) {
      config['transformers'].forEach((t) {
        if (t is Map && t.containsKey('polymer') == true) {
          transformersPolymer = t['polymer'];
        }
      });
    }
    if (config['transformers'] is Map) {
      if ( config['transformers']['polymer'] != null) {
        transformersPolymer = config['transformers']['polymer'];
      }
    }
    if (transformersPolymer != null) {
      if (transformersPolymer['entry_points'] != null) {
        transformersPolymerEntrypoints = transformersPolymer['entry_points'];
        if (transformersPolymerEntrypoints is List) {
          entryPoint = transformersPolymerEntrypoints.first;
        } else {
          entryPoint = transformersPolymerEntrypoints;
        }
      }
    }
  }
  if (entryPoint != null) {
    return pathos.join(path, entryPoint);
  }
  return null;
}
