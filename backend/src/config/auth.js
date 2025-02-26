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

const jwt = require('jsonwebtoken');
const User = require('../models/user.model');

async function authUser(req) {
    const bearerHeader = req.headers['authorization'];
    if (typeof bearerHeader !== 'undefined') {

        let user_id;
        const bearer = bearerHeader.split(' ');
        const bearerToken = bearer[1];

        jwt.verify(bearerToken, process.env.JWT_SECRET_KEY, (err, authData) => {
            if (err) {
                console.log(err);
            }
            if (authData["sub"]) {
                user_id = authData["sub"]
            }
        })

        if(user_id !== undefined){
            let user = await User.findOne({ _id: user_id })
            const userObject = user.toObject()
            delete userObject.password
            delete userObject.role
            return userObject
        }

    }
    return undefined
}

function errorHandler(err, req, res, next) {

    if (typeof (err) === 'string') {
        // custom application error
        return res.status(400).json({
            message: err
        });
    }

    if (err.name === 'UnauthorizedError') {
        // jwt authentication error
        return res.status(401).json({
            message: 'Invalid Token'
        });
    }

    // default to 500 server error
    return res.status(500).json({
        message: err.message
    });
}
 
module.exports =  { authUser, errorHandler }