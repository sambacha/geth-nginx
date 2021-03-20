#!/usr/bin/node
var request = require('supertest');

requestNormal = request('http://nginx.$TLD');
requestWww = request('http://www.nginx.$TLD');

function handle(err) {
    if (err) {
        console.log(err);
    }
}

requestWww.get('').expect(301, handle);
requestNormal.get('.git').expect(403, handle);
requestNormal.get('').expect(200, handle);
requestNormal.get('some/random/url/').expect(200, handle);
requestNormal.get('dir/script.php').expect(200, 'ok', handle);
requestNormal.get('test.dir/').expect(200, "ok\n", handle);
requestNormal.get('test.dir/index.html').expect(200, "ok\n", handle);
