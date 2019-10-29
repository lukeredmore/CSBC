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
        let quote = await getDayForDate(this.$inputs.date.value, this.$inputs.school.value)
        if (typeof quote === 'undefined' || quote === null || quote === '0' || quote === 0) {
            this.tell('There is no school on ' + this.$inputs.date.value + ' at ' + this.$inputs.school);
        } else {
            this.tell('It will be a Day ' + quote + ' at ' + this.$inputs.school + ' on ' + this.$inputs.date.value);
        }
    },
});

async function getDayForDate(date, school) {
    const options = {
        uri: 'https://us-east4-csbcprod.cloudfunctions.net/getDayForDate?date=' + date + '&school=' + school,
        json: true // Automatically parses the JSON string in the response
    };
    return await requestPromise(options);
}

module.exports.app = app;
