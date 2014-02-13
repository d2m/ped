library pdir;

import 'dart:convert';
import 'pfile.dart';

/**
 * starting from a root file PDir collects information on all 
 * imported HTML files in a polymer app.
 * 
 */
class PDir {
  Map<String, PFile> pdir;
  String root;
  
  PDir(this.root){
    pdir = new Map();
    updateImports(root);
    pdir.keys.forEach(updateDeclarations);
    pdir.keys.forEach(updateUses);
    pdir.keys.forEach(updateWarnings);
  }
  
  /**
   * recursively collects all imported HTML files
   */
  void updateImports(String filename) {
    if (pdir.containsKey(filename) == false) {
      PFile pf = new PFile(filename);
      pdir[filename] = pf;
      pf.imports.forEach(updateImports);
    }
  }
  
  /**
   * polymer-elements declared in the current file
   */
  void updateDeclarations(String filename) {
    PFile pf = pdir[filename];
    pf.updateDeclarations();    
  }
  
  /**
   * polymer-elements used in the current file
   */
  void updateUses(String filename) {
    PFile pf = pdir[filename];
    pf.updateUses();
  }
  
  /**
   * files imported but not used in the current file
   */
  void updateWarnings(String filename) {
    PFile pf = pdir[filename];
    for (String import in pf.imports) {
      bool miss = true;
      for (String declaration in pdir[import].declarations) {
        if (pf.uses.contains(declaration)) {
          miss = false;
        }
      }
      if (miss == true) {
        pf.warnings.add(import);
      }
    }
  }
  
  /**
   * JSON structure
   */
  String toJson() {
    Map out = new Map();
    
    void collect(String filename) {
      PFile pf = pdir[filename];
      out[filename] = {
        'imports' : pf.imports,
        'defines' : pf.declarations,
        'uses'    : pf.uses,
        'warnings': pf.warnings,
        'entry_point': (filename == root) ? true : false
      };
    }

    pdir.keys.forEach(collect);
    JsonEncoder je = new JsonEncoder();
    return je.convert(out);
  }
  
  /**
   * numbered list of files used in the visualisation
   */
  String legend() {
    List nodenames = pdir.keys.toList();
    nodenames.sort();
    String out = '<p><b>Legend:</b></p><ol>';
    for (String name in nodenames) {
      String ep = (name == root) ? ' (#entry_point)' : '';
      out += '<li>$name$ep</li>';
    }
    out += '</ol>';
    return out;
  }

  /**
   * dot-formated representation of the polymer app structure 
   */
  String toViz() {

    List nodenames = pdir.keys.toList();
    nodenames.sort();
    String out = '''
digraph G {
  node [label="\N", shape=record, style="rounded"];
  edge [];
  rankdir=LR;
''';
    
    String normId(String name) {
      return (nodenames.indexOf(name) + 1).toString();
    }
        
    void output(String filename) {
      PFile pf = pdir[filename];
      List imports = pf.imports;
      List declarations = pf.declarations;
      List uses = pf.uses;
      List warnings = pf.warnings;
      
      String sourceNode = normId(filename);

      String separator = '&#92;l ';
      
      String labelDeclarations = '';
      declarations.sort();
      labelDeclarations = declarations.join(separator);

      String labelUses = '';
      uses.sort();
      labelUses = uses.join(separator);      
      
      String title = filename.split('/').last;
      
      out += '  $sourceNode [label="{$title | #$sourceNode} | $labelDeclarations | $labelUses "];\n';
      
      for (String s in imports) {
        String targetNode = normId(s);
        String labelWarnings = warnings.contains(s) ? ' [color="yellow"]' : '';      
        out += '  $sourceNode -> $targetNode$labelWarnings;\n';
      }
    }

    pdir.keys.forEach(output);

    out += '''
  legend [label="{filename | legend #n} | declarations | uses", pos="0,0!" color="red"];
  legend -> legend [label="imports"];
  legend -> legend [label="imports, not used", color="yellow"];
  1 -> legend [style=invis];
}''';
  return out;
  }
  
}