'use strict';

// ------------------------------------------------------------------
// APP INITIALIZATION
// ------------------------------------------------------------------

const { App } = require('jovo-framework');
const { Alexa } = require('jovo-platform-alexa');
const { GoogleAssistant } = require('jovo-platform-googleassistant');
const { JovoDebugger } = require('jovo-plugin-debugger');
const { FileDb } = require('jovo-db-filedb');
const requestPromise = require('request-promise-native');

const app = new App();

app.use(
    new Alexa(),
    new GoogleAssistant(),
    new JovoDebugger(),
    new FileDb()
);


// ------------------------------------------------------------------
// APP LOGIC
// ------------------------------------------------------------------

app.setHandler({
    LAUNCH() {
        return this.toIntent('HelloWorldIntent');
    },

    HelloWorldIntent() {
        this.tell('Application launched');
    },

    async GetDayOfCycleIntent() {
        let quote = await getRandomQuote(this.$inputs.date.value)
        this.tell('Hey ' + this.$inputs.date.value + ', nice to meet you!' + quote);
    },
});

async function getDayForDate(date) {
    const options = {
        uri: 'https://us-east4-csbcprod.cloudfunctions.net/getDayForDate?date=' + date + '&school=1',
        json: true // Automatically parses the JSON string in the response
    };
    return await requestPromise(options);
}

module.exports.app = app;
