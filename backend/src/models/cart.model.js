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

const mongoose = require('mongoose');
const schema = new mongoose.Schema({
    order_number: {
        type: String,
        required: true,
    },
    menu_image: {
        type: String,
        required: false,
    },
    menu_name: {
        type: String,
        required: true,
    },
    qty: { type: Number, default: 0 },
    price: { type: mongoose.Decimal128, default: 0 },
    total: { type: mongoose.Decimal128, default: 0 },
    status: { type: Number, default: 1 },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});
const cart = new mongoose.model('Cart', schema);
module.exports = cart;