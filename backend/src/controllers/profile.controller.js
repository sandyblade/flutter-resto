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

const auth = require("../config/auth")
const validate = require('validate.js');
const bcrypt = require('bcryptjs');
const User = require('../models/user.model')

async function detail(req, res) {
    let user = await auth.authUser(req)
    res.status(200).send(user);
    return;
}

async function update(req, res) {

    let user = await auth.authUser(req)
    let user_id = user._id

    const rules = {
        email: {
            presence: { message: "is required" },
            email: { message: "is not valid" }
        },
        name: {
            presence: { message: "is required" },
            length: {
                minimum: 6,
                maximum: 120,
                tooShort: "needs to be at least %{count} characters long",
                tooLong: "needs to be at most %{count} characters long"
            }
        },
        gender: {
            presence: { message: "is required" },
            length: {
                minimum: 4,
                maximum: 10,
                tooShort: "needs to be at least %{count} characters long",
                tooLong: "needs to be at most %{count} characters long"
            }
        },
        phone: {
            presence: { message: "is required" },
            length: {
                minimum: 7,
                maximum: 20,
                tooShort: "needs to be at least %{count} characters long",
                tooLong: "needs to be at most %{count} characters long"
            }
        },
        address: {
            presence: { message: "is required" },
            length: {
                minimum: 10,
                maximum: 255,
                tooShort: "needs to be at least %{count} characters long",
                tooLong: "needs to be at most %{count} characters long"
            }
        }
    }

    const validationResult = validate(req.body, rules);

    if (validationResult) {
        res.status(400).json({ error: validationResult });
        return;
    }

    let checkEmail = await User.find({ $and: [ { _id: {$ne: user_id} }, { email: req.body.email }] }).limit(1)
    let checkPhone = await User.find({ $and: [ { _id: {$ne: user_id} }, { phone: req.body.phone }] }).limit(1)
    
    if(checkEmail.length > 0){
        res.status(400).json({ error: 'The email address has already been taken.!' });
        return;
    }

    if(checkPhone.length > 0){
        res.status(400).json({ error: 'The phone number has already been taken.!' });
        return;
    }

    let session = await User.findOne({ _id: user_id })
    session.email = req.body.email
    session.name = req.body.name
    session.gender = req.body.gender
    session.phone = req.body.phone
    session.address = req.body.address
    await session.save()
    
    res.status(200).send({ message: "Your profile has been changed" });
    return;
}

async function password(req, res) {

    let user = await auth.authUser(req)
    let user_id = user._id

    const rules = {
        currentPassword: {
            presence: { message: "is required" },
            length: {
                minimum: 6,
                maximum: 30,
                tooShort: "needs to be at least %{count} characters long",
                tooLong: "needs to be at most %{count} characters long"
            }
        },
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
    }

    const validationResult = validate(req.body, rules);
    
    if (validationResult) {
        res.status(400).json({ error: validationResult });
        return;
    }

    let session = await User.findOne({ _id: user_id })
    let password = req.body.currentPassword

    if (!bcrypt.compareSync(password, session.password)) {
        res.status(401).send({error: "Incorrect current password please try again !!"});
        return;
    }

    session.password = bcrypt.hashSync(password, 10)
    await session.save()

    res.status(200).send({ message: "Your current password has been changed!!" });
    return;
}

module.exports = {
    detail,
    update,
    password
}