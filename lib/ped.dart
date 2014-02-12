library polymer_element_dependencies;

import 'dart:io';
import 'package:path/path.dart' as pathos;
import 'package:yaml/yaml.dart';

import 'src/pdir.dart';

String toJson([String entry_point = null]) {
  
  if (entry_point == null) {
    entry_point = _entryPointFromPubspec();
  }
  
  PDir pd = new PDir(entry_point);
  return pd.toJson();  
}

void toViz([String entry_point = null]) {
    
  if (entry_point == null) {
    entry_point = _entryPointFromPubspec();
  }
  
  PDir pd = new PDir(entry_point);
  String out = '''
<!DOCTYPE html>
<html>
  <head>
    <!-- output: SVG (via https://github.com/mdaines/viz.js/) -->
    <title>Polymer Dependencies</title>
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
      document.body.innerHTML += '<h1>Polymer Element Dependencies</h1>';              
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


String _entryPointFromPubspec() {
  String path = pathos.current;
  var pubspecPath = pathos.join(path, 'pubspec.yaml');
  var file = new File(pubspecPath);
    String yaml = file.readAsStringSync();
    Map config = loadYaml(yaml);
    String ef = '';
    if (config.containsKey('transformers') == true) {
      var t = config['transformers'];
      var i;
      if (t is List) {
        for (var x in t) {
          if (x is Map && x.containsKey('polymer') == true) {
            i = x;
          }
        }
        
      } else {
        i = t;
      }
      if (i.containsKey('polymer') == true) {
        if (i['polymer'].containsKey('entry_points') == true) {
          var e = i['polymer']['entry_points'];
          if (e is List) {
            ef = e[0];
          } else {
            ef = e;
          } 
        }
      }
    }
    if (ef != '') {
      String ep = pathos.join(path, ef);
      return ep;      
    }
    return null;
}
