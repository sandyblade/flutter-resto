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
    image: {
        type: String,
        required: false,
    },
    name: {
        type: String,
        required: true,
        unique: true
    },
    category: {
        type: String,
        required: true
    },
    description: {
        type: String,
        required: false,
    },
    price: { type: mongoose.Decimal128, default: 0 },
    rating: { type: Number, default: 0 },
    status: { type: Number, default: 1 },
    created_at: { type: Date, default: Date.now },
    updated_at: { type: Date, default: Date.now }
});
const menu = new mongoose.model('Menu', schema);
module.exports = menu;