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

const Table = require('../models/table.model')
const Order = require('../models/order.model')
const Menu = require('../models/menu.model')

async function summary(req, res) {

    let getTotal = await Order.aggregate([
        { $match: { status: 1 } },  
        { $group: { _id: null, totalSum: { $sum: "$total_paid" } } } 
    ]);

    let total_orders = await Order.countDocuments({ status : 1 })
    let total_dine_in = await Order.countDocuments({ status : 1, order_type: "Dine In" })
    let total_take_away = await Order.countDocuments({ status : 1, order_type: "Take Away" })
    let total_sales = getTotal[0]?.totalSum || 0

    let payload = {
        total_sales: total_sales,
        total_orders: total_orders,
        total_dine_in: total_dine_in,
        total_take_away: total_take_away
    }

    res.status(200).send(payload);
    return;
}

async function table(req, res) {
    let tables = await Table.find({})
    res.status(200).send(tables);
    return;
}

async function sell(req, res) {
    const products = await Menu.find().sort({ rating: -1 });
    res.status(200).send(products);
    return;
}

module.exports = {
    summary,
    table,
    sell
}