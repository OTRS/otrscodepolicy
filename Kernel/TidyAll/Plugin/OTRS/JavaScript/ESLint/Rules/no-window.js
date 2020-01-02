// --
// Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file COPYING for license information (GPL). If you
// did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
// --

"use strict";

//
// Rule Definition
//

module.exports = function(context) {

    return {
        "MemberExpression": function(node) {
            var ObjectName,
                PropertyName,
                ReservedWords = ["opener", "parent", "open", "name", "close"];
            if (node.object.type === 'Identifier') {
                ObjectName = node.object.name;

                if (ObjectName === 'window') {
                    if (node.property.type === 'Identifier') {
                        PropertyName = node.property.name;

                        if (ReservedWords.indexOf("" + PropertyName) !== -1) {
                            context.report(node, "Do not use the 'window' object. Use the OTRS functions in Core.UI.Popup instead: window.{{property}}", { property: PropertyName });
                        }
                    }
                }
            }
        }
    };
};

module.exports.schema = [];
