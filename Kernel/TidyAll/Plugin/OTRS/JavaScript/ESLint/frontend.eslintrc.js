// nofilter(TidyAll::Plugin::OTRS::Legal::LicenseValidator)
// nofilter(TidyAll::Plugin::OTRS::JavaScript::ESLint)

/*
 * NOTE: In order for linting to work, you will need following globally installed NPM modules
 *
 *   npm install -g eslint@5 eslint-plugin-import eslint-config-airbnb-base eslint-plugin-vue babel-eslint eslint-plugin-jest
 *
 * FIXME: We have to pin the ESLint version to 5.x since not all plugins we use are compatible with 6.x just yet.
 */

module.exports = {

    parserOptions: {
        parser: 'babel-eslint',
        sourceType: 'module'
    },

    plugins: [
        'jest',
    ],

    env: {
        browser: true,
        'jest/globals': true,
    },

    extends: [
        'airbnb-base',
        'plugin:vue/recommended',
    ],

    globals: {
        'translatable': true,
    },

    rules: {

        /*
         * AirBnB JS rule overrides.
         */

        // Enforce consistent indentation.
        'indent': [ 'error', 4, { 'SwitchCase': 1 } ],

        // Allow unnecessarily quoted properties.
        'quote-props': 'off',

        // Allow dangling underscores to indicate private methods (like _internalMethod()).
        'no-underscore-dangle': 'off',

        // Enforce a maximum line length.
        'max-len': [ 'error', { 'code': 120 } ],

        // Don't try to resolve the dependencies.
        'import/no-unresolved': 'off',

        // Allow for missing file extensions in import statements.
        'import/extensions': 'off',

        // Require a space before function parenthesis.
        'space-before-function-paren': [ 'error', 'always' ],

        // Require "Stroustrup" brace style.
        'brace-style': [ 'error', 'stroustrup' ],

        // Enforce spaces inside of brackets.
        'array-bracket-spacing': [ 'error', 'always' ],

        // Do not enforce that class methods utilize this.
        'class-methods-use-this': 'off',

        // Allow the unary operators ++ and --.
        'no-plusplus': 'off',

        // Allow Reassignment of Function Parameters.
        'no-param-reassign': 'off',

        // Enforce consistent line breaks inside function parentheses.
        'function-paren-newline': [ 'error', 'consistent' ],

        // Ignore trailing commas in the imports, exports and functions, but require it in arrays and object
        //   definitions.
        'comma-dangle': [
            'error',
            {
                'arrays': 'always-multiline',
                'objects': 'always-multiline',
                'imports': 'ignore',
                'exports': 'ignore',
                'functions': 'ignore',
            },
        ],

       // Do not force the use of the object spread just yet (target ES2018).
       'prefer-object-spread': 'off',

       // Do not force parentheses on arrow functions with single arguments.
       'arrow-parens': 'off',

        // Allow require() calls with expressions (dynamic imports).
        'import/no-dynamic-require': 'off',

        /*
         * Vue.js rule overrides.
         */

        // Enforce consistent indentation in <template>.
        'vue/html-indent': [ 'error', 4 ],

        // Enforce v-bind directive usage in long form.
        'vue/v-bind-style': [ 'error', 'longform' ],

        // Enforce v-on directive usage in long form.
        'vue/v-on-style':  [ 'error', 'longform' ],

        // Don't require default value for props.
        'vue/require-default-prop': 'off',

        // Don't warn about unused components. This is sometime needed for dynamic component usage.
        'vue/no-unused-components': 'off',

        // Don't correct casing of component names for backward compatibility reasons.
        'vue/component-name-in-template-casing': 'off',

        // Don't correct closing bracket position of HTML tags for backward compatibility reasons.
        'vue/html-closing-bracket-newline': 'off',

        // Don't correct new lines in single line HTML elements for backward compatibility reasons.
        'vue/singleline-html-element-content-newline': 'off',
    },
};
