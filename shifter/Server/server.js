//
//  server.js
//
//  This is a server for sending a code to the user by mail,
//  when he forgot his account password.
//

const express = require('express');
const bodyParser = require('body-parser');
const nodemailer = require('nodemailer');
    
const app = express();

app.use(bodyParser.json());

app.use((req, res, next) => {
    console.log(`Новый запрос: ${req.method} ${req.url}`);
    console.log("Заголовки:", req.headers);
    console.log("Тело запроса:", req.body);
    next();
});
        
app.post('/api/send_reset_code', async (req, res) => {
    const { email, resetCode } = req.body;
        
    console.log("Запрос на отправку email:", req.body);
            
    if (!email || !resetCode) {
        console.log("Ошибка: отсутствует email или resetCode");
        return res.status(400).json({ error: 'Необходимы email и resetCode.' });
    }
    
    let transporter = nodemailer.createTransport({
            service: 'gmail',
            auth: {
                user: 'Lazarevaak2005sasha@gmail.com',
                pass: 'wsyx wyft gndt xnts'
            },
            tls: { rejectUnauthorized: false }
        });
    
    let mailOptions = {
            from: '"Поддержка" <Lazarevaak2005sasha@gmail.com>',
            to: email,
            subject: 'Код для сброса пароля',
            text: `Ваш код: ${resetCode}`,
            html: `<p>Ваш код: <strong>${resetCode}</strong></p>`
        };
    
    try {
            let info = await transporter.sendMail(mailOptions);
            console.log("Письмо отправлено:", info.response);
            res.status(200).json({ message: 'Письмо отправлено.' });
        } catch (error) {
            console.error("Ошибка при отправке письма:", error);
            res.status(500).json({ error: `Ошибка: ${error.message}` });
        }
    });

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Сервер запущен на http://192.168.1.11:${PORT}`);
});
        
  
