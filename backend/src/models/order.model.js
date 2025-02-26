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
        unique: true
    },
    table_number: {
        type: String,
        required: true,
        default: 'Take Away'
    },
    order_type: {
        type: String,
        required: true,
    },
    customer_name: {
        type: String,
        required: true,
    },
    cashier_name: {
        type: String,
        required: true,
    },
    total_item: { type: Number, default: 0 },
    total_paid: { type: Number, default: 0 },
    status: { type: Number, default: 0 },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});
const order = new mongoose.model('Order', schema);
module.exports = order;