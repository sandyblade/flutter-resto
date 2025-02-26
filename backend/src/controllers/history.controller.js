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

const Order = require('../models/order.model')
const Cart = require('../models/cart.model')

async function list(req, res) {

    let page = req.query.page || 1;
    let limit = req.query.limit || 10;
    let offset = ((page-1)*limit)

    let filter = {
        status : 1
    }

    if(req.query.search){
        let keyword = req.query.search
        filter = {
            $and: [
                { status: 1 }, 
                {
                    $or: [
                        { order_number: { $regex: keyword, $options: "i" } },
                        { table_number: { $regex: keyword, $options: "i" } },
                        { order_type: { $regex: keyword, $options: "i" } },
                        { customer_name: { $regex: keyword, $options: "i" } },
                        { cashier_name: { $regex: keyword, $options: "i" } }
                    ]
                }
            ]
        }
    }

    let orders = await Order.find(filter).limit(limit).skip(offset).sort({ created_at: -1 });
    res.status(200).send(orders);
    return;
}

async function detail(req, res) {

    let id = req.params.id;
    let order = await Order.findOne({ _id: id })
  
    if(order === null){
        res.status(400).json({ error: 'These order do not match our records.' });
        return;
    }

    let cart  = await Cart.find({ order_number: order.order_number })

    let payload = {
        order: order,
        cart: cart
    }

    res.status(200).send(payload);
    return;
}

module.exports = {
    list,
    detail
}