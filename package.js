Package.describe({
  name: 'peerlibrary:blaze-components',
  summary: "Components for Blaze",
  version: '0.1.0',
  git: 'https://github.com/peerlibrary/meteor-blaze-components.git'
});

Package.onUse(function (api) {
  api.versionsFrom('METEOR@1.0.3.1');

  // Core dependencies.
  api.use([
    'blaze',
    'templating',
    'coffeescript',
    'underscore',
    'tracker'
  ]);

  // 3rd party dependencies.
  api.use([
    'peerlibrary:assert@0.2.5',
    'aldeed:template-extension@3.4.3'
  ]);

  api.export('BlazeComponent');

  // Client.
  api.addFiles([
    'lookup.js',
    'lib.coffee'
  ], 'client');
});

Package.onTest(function (api) {
  // Core dependencies.
  api.use([
    'coffeescript',
    'templating'
  ]);

  // Internal dependencies.
  api.use([
    'peerlibrary:blaze-components'
  ]);

  // 3rd party dependencies.
  api.use([
    'peerlibrary:classy-test@0.2.9'
  ]);

  api.addFiles([
    'tests.html',
    'tests.coffee'
   ], 'client');
});
