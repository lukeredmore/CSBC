const admin = require('firebase-admin')
const constants = require('./constants.json')
const nodemailer = require('nodemailer')
const cors = require('cors') ({origin: true})
const privateFiles = require('./private-files.json')
if (process.env.FUNCTIONS_EMULATOR) { process.env.GOOGLE_APPLICATION_CREDENTIALS = "./csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json" }

let transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: privateFiles.MAIL_CREDENTIALS.USERNAME,
        pass: privateFiles.MAIL_CREDENTIALS.PASSWORD
    }
});

exports.createAndSend = async (req, res) => {
    const senderName = req.query.sender
    console.log(senderName)

    const body = req.query.body
    body.replace("\n", "<br>")

    const subject = req.query.subject

    const mailOptions = {
        from: senderName + '<' + privateFiles.MAIL_CREDENTIALS.USERNAME + '>',
        to: 'luke.redmore@gmail.com',
        subject: subject,
        html: `<p style="font-size: 16px;">` + body + `</p>` // email content in HTML
    };

    // returning result
    return transporter.sendMail(mailOptions, (error, info) => {
        if(error){
            return res.send(error.toString())
        } else {
            return res.send('Email successfully sent')
        }
    })
}