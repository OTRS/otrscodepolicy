// --
// Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file COPYING for license information (AGPL). If you
// did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
// --

/**
 * @fileoverview Rule to disallow usage of window object
 * @author Marc Nilius
 */

"use strict";

//------------------------------------------------------------------------------
// Rule Definition
//------------------------------------------------------------------------------

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
