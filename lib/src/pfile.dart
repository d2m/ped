library pfile;

import 'dart:io';
import 'package:html5lib/parser.dart' show parse;
import 'package:html5lib/dom.dart';

class PFile {
  
  static Set declared = new Set();

  List declarations;
  String filename;
  List imports;
  Document parsed_contents;
  List uses;
  List warnings;
  
  PFile(this.filename){
    File f = new File(filename);
    String dir = f.parent.path;
    uses = [];
    warnings = [];
    String contents = f.readAsStringSync();
    parsed_contents = parse(contents);
    updateImports(dir);
  }
  
  void updateImports(String dir) {
    List links = parsed_contents.queryAll('link');
    List match = new List();
    for (Element l in links) {
      if (l.attributes['rel'].toLowerCase() == 'import') {
        match.add(dir + '/' + l.attributes['href']);
      }
    }            
    imports = match;
  }
  
  void updateDeclarations() {
    List elements = parsed_contents.queryAll('polymer-element');
    List match = new List();
    for (Element l in elements) {
      String _name = l.attributes['name'];
      match.add(_name);
    }
    declarations = match;
    PFile.declared.addAll(match);
  }
  
  void updateUses() {
    
    queryIs(Node element, String isName) {
      for (var node in element.nodes) {
        if (node is! Element) continue;
        if (node.attributes.keys.contains('is') 
            && node.attributes['is'] == isName) {
          return node;
        }
        var result = queryIs(node, isName);
        if (result != null) return result;
      }
      return null;
    }

    for (String s in PFile.declared) {
      Element match1 = parsed_contents.query(s);
      Element match2 = queryIs(parsed_contents, s);
      if (match1 != null || match2 != null) {
        uses.add(s);
      }      
    }
    
  }
}
