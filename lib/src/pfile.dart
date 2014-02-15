library pfile;

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:html5lib/parser.dart' show parse;
import 'package:html5lib/dom.dart';

/**
 * represents an HTML file used in the polymer app
 */
class PFile {
  
  /**
   * lookup for polymer-element names
   */
  static Set declared = new Set();

  /**
   * list of declarations inside the HTML file
   */
  List declarations;
  /**
   * full path of the HTML file
   */
  String filename;
  /**
   * list of imported HTML files
   */
  List imports;
  /**
   * parsed HTML content
   */
  Document parsed_contents;
  /**
   * list of polymer-elements used in the HTML file
   */
  List uses;
  /**
   * list of imported but unused HTML files
   */
  List warnings;
  
  /**
   * constructor, reads the HTML file, parses it and stores its imports
   */
  PFile(this.filename){
    File f = new File(filename);
    String dir = f.parent.path;
    uses = [];
    warnings = [];
    String contents = f.readAsStringSync();
    parsed_contents = parse(contents);
    updateImports(dir);
  }
  
  /**
   * collects all imported files
   */
  void updateImports(String dir) {
    List links = parsed_contents.queryAll('link');
    List match = new List();
    for (Element l in links) {
      if (l.attributes['rel'].toLowerCase() == 'import') {
        match.add(path.normalize(dir + '/' + l.attributes['href']));
      }
    }            
    imports = match;
  }
  
  /**
   * collects all 'polymer-element' declarations in the file
   * 
   * declared names are stored in a class variable for later lookup
   */
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
  
  /**
   * collects all components used in a file
   */
  void updateUses() {
    
    /**
     * parse
     *    <div is="polymer-element-name"></div>
     */
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
