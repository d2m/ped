library test.tojson;

import 'package:ped/ped.dart';
import 'package:unittest/unittest.dart';

main() {
  
  String json = '{"../example/web/index.html":{"imports":["../example/web/click'
      'counter.html"],"defines":[],"uses":["click-counter"],"warnings":[],"entr'
      'y_point":true},"../example/web/clickcounter.html":{"imports":[],"defines'
      '":["click-counter"],"uses":[],"warnings":[],"entry_point":false}}';
  
  test("test for example data", () {
    expect(toJson('../example/web/index.html'), equals(json));
  });
  
}
