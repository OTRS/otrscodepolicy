// --
// Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file COPYING for license information (GPL). If you
// did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
// --

module.exports = {
    "env": {
        "browser": true,
        "jquery": true
    },
    "globals": {
        "Core": true,
        "CKEDITOR": true,
        "isJQueryObject": true,
        "printStackTrace": true,
        "QUnit": true,
        // older QUnit stuff
        // only needed for OTRS <= 5
        // can be removed later
        "module": true,
        "test": true,
        "expect": true,
        "equal": true,
        "deepEqual": true,
        "asyncTest": true,
        "start": true,
        "ok": true,
        "notEqual": true
    },
    "extends": "eslint:recommended",
    "rules": {
        "quotes": 0,
        "new-cap": 0,
        "global-strict": 0,
        "no-alert": 0,
        "radix": 2,
        "valid-jsdoc": [2, {
            "requireReturn": false,
            "requireParamDescription": false,
            "requireReturnDescription": false
        }],
        "no-catch-shadow": 0,
        "vars-on-top": 2,
        "space-in-parens": [2, "never"],
        "no-eval": 2,
        "no-implied-eval": 2,

        // OTRS-specific rules
        "no-window": 2
    }
}
