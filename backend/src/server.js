/**
 * This file is part of the Sandy Andryanto Blog Application.
 *
 * @author     Sandy Andryanto <sandy.andryanto.blade@gmail.com>
 * @copyright  2025
 *
 * For the full copyright and license information,
 * please view the LICENSE.md file that was distributed
 * with this source code.
 */

const express = require('express');
const bodyParser = require('body-parser');
const cors = require("cors");
const jwt = require('./config/jwt.js');
const app = express();

const dbConfig = require('./config/db.config');
const dbSeed = require('./config/db.seed.js')
const mongoose = require('mongoose');
const PORT = process.env.APP_PORT || 8000;

mongoose.Promise = global.Promise;
mongoose.connect(dbConfig.url).then(() => {
    console.log("Databse Connected Successfully!!");
}).catch(err => {
    console.log('Could not connect to the database', err);
    process.exit();
});

app.use(bodyParser.urlencoded({ extended: true }))
app.use(bodyParser.json())
app.use(cors());
app.use(jwt());

require("./config/route.config")(app);

app.use(function (err, req, res, next) {
    if (err.status !== undefined && err.status != 200) {
        res.status(err.status).send({ error: err.message });
    }
})

app.listen(PORT, () => {
    dbSeed.run()
    console.log(`${(new Date().toString())} - Server is listening on port ${PORT}`);
});