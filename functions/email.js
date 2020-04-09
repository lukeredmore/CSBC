const nodemailer = require('nodemailer')
const cors = require('cors')({ origin: true })
const privateFiles = require('./private-files.json')
if (process.env.FUNCTIONS_EMULATOR) {
  process.env.GOOGLE_APPLICATION_CREDENTIALS = './csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json'
}

let transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: privateFiles.MAIL_CREDENTIALS.USERNAME,
    pass: privateFiles.MAIL_CREDENTIALS.PASSWORD,
  },
})

exports.createAndSend = async (req, res) => {
  cors(req, res, async () => {
    const { senderName, subject, message } = req.body
    if (!senderName || !subject || !message) return res.status(400).json({ message: 'Invalid parameters' })

    const mailOptions = {
      from: senderName + '<' + privateFiles.MAIL_CREDENTIALS.USERNAME + '>',
      to: 'luke.redmore@gmail.com',
      subject: subject,
      html: `<p style="font-size: 16px;">` + message.replace('\n', '<br>') + `</p>`, // email content in HTML
    }

    // returning result
    return transporter.sendMail(mailOptions, error => {
      if (error) {
        return res.status(500).json({ message: error.toString() })
      } else {
        return res.status(200).json({ message: 'Email successfully sent' })
      }
    })
  })
}
