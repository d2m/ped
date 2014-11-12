library test.tojson;

import 'package:ped/ped.dart';
import 'package:unittest/unittest.dart';

main() {
  
  String json = '{"example/web/index.html":{"imports":["example/web/packages/polymer/polymer.html","example/web/clickcounter.html"],"defines":[],"uses":["click-counter"],"warnings":["example/web/packages/polymer/polymer.html"],"entry_point":true},"example/web/packages/polymer/polymer.html":{"imports":["example/web/packages/polymer/src/js/polymer/polymer.html"],"defines":[],"uses":[],"warnings":["example/web/packages/polymer/src/js/polymer/polymer.html"],"entry_point":false},"example/web/packages/polymer/src/js/polymer/polymer.html":{"imports":["example/web/packages/polymer/src/js/polymer/polymer-body.html"],"defines":[],"uses":[],"warnings":["example/web/packages/polymer/src/js/polymer/polymer-body.html"],"entry_point":false},"example/web/packages/polymer/src/js/polymer/polymer-body.html":{"imports":[],"defines":["polymer-body"],"uses":[],"warnings":[],"entry_point":false},"example/web/clickcounter.html":{"imports":[],"defines":["click-counter"],"uses":[],"warnings":[],"entry_point":false}}';
  
  test("test for example data", () {
    expect(toJson('example/web/index.html'), equals(json));
  });
    
}
