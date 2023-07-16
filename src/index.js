'use strict';

import './index.css';

import { generateSpaFlags, extBrowserSetup } from './Vendor/browser.js';
import { Elm } from './App.elm';

var spaFlags = generateSpaFlags();
var app = Elm.App.init(
  { node: document.getElementById('elm-mount')
  , flags: { spaFlags: spaFlags }
  }
);


extBrowserSetup(app, spaFlags, document, document.getElementById("elm-isolation"));
