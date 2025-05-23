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

const {
    expressjwt
} = require('express-jwt');

module.exports = jwt

function jwt() {
    const {
        secret
    } = {
        secret: process.env.JWT_SECRET_KEY
    }
    return expressjwt({
        secret,
        algorithms: ['HS256']
    }).unless({
        path: [
            '/api/ping',
            '/api/auth/login',
            '/api/auth/email/forgot',
            /^\/api\/auth\/email\/reset\/.*/,
        ]
    });
}