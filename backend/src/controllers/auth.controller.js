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

const validate = require('validate.js');
const User = require('../models/user.model');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { faker } = require('@faker-js/faker');

function omitPassword(user) {
    const {
        password,
        ...userWithoutPassword
    } = user;
    let result = userWithoutPassword;
}

async function login(req, res) {

    const rules = {
        password: {
            presence: { message: "is required" },
            length: {
                minimum: 6,
                maximum: 30,
                tooShort: "needs to be at least %{count} characters long",
                tooLong: "needs to be at most %{count} characters long"
            }
        },
        email: {
            presence: { message: "is required" },
            email: { message: "is not valid" }
        }
    }

    const validationResult = validate(req.body, rules);

    if (validationResult) {
        res.status(400).json({ error: validationResult });
        return;
    }

    let email = req.body.email;
    let password = req.body.password;
    let user = await User.findOne({ email: email })

    if(user === null){
        res.status(401).json({ error: 'These credentials do not match our records.' });
        return;
    }

    if (!bcrypt.compareSync(password, user.password)) {
        res.status(401).send({error: "Wrong password!!"});
        return;
    }

    let token = jwt.sign({
        sub: user.id
    }, process.env.JWT_SECRET_KEY, {
        expiresIn: '1d'
    });
    res.send({
        ...omitPassword(user),
        token
    });

    return;
}

async function forgot(req, res) {

    const rules = {
        email: {
            presence: { message: "is required" },
            email: { message: "is not valid" }
        }
    }

    const validationResult = validate(req.body, rules);

    if (validationResult) {
        res.status(400).json({ error: validationResult });
        return;
    }

    let email = req.body.email;
    let user = await User.findOne({ email: email })
    let today = new Date()
    let token = faker.string.uuid()

    today.setHours(today.getHours() + 1)

    if(user === null){
        res.status(401).json({ error: "We can't find a user with that e-mail address." });
        return;
    }

    user.forgot_password_token = token
    user.forgot_password_expired = today
    await user.save()

    res.status(200).send({ message: "We have e-mailed your password reset link!" });
    return;
}

async function reset(req, res) {

    const rules = {
        password: {
            presence: { message: "is required" },
            length: {
                minimum: 6,
                maximum: 30,
                tooShort: "needs to be at least %{count} characters long",
                tooLong: "needs to be at most %{count} characters long"
            }
        },
        confirmPassword: {
            equality: "password",
            presence: { message: "is required" },
            length: {
                minimum: 6,
                maximum: 30,
                tooShort: "needs to be at least %{count} characters long",
                tooLong: "needs to be at most %{count} characters long"
            }
        },
        email: {
            presence: { message: "is required" },
            email: { message: "is not valid" }
        }
    }

    const validationResult = validate(req.body, rules);

    if (validationResult) {
        res.status(400).json({ error: validationResult });
        return;
    }

    let token = req.params.token;
    let email = req.body.email;
    let password = req.body.password;
    let user = await User.findOne({ email: email })
    let hashedPassword = bcrypt.hashSync(password, 10)

    if(user === null){
        res.status(400).json({ error: "We can't find a user with that e-mail address." });
        return;
    }

    if(user.forgot_password_token != token){
        res.status(400).json({ error: "We can't find a user with that token is invalid" });
        return;
    }

    user.password = hashedPassword
    user.forgot_password_token = null
    user.forgot_password_expired = null
    await user.save()

    res.status(200).send({ message: "Your password has been reset!" });
    return;
}


module.exports = {
    login,
    forgot,
    reset
}