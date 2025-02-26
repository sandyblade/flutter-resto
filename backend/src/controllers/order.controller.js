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
const Table = require('../models/table.model')
const Menu = require('../models/menu.model')
const validate = require('validate.js');

async function save(req, res) {

    const rules = {
        customer_name: {
            presence: { message: "is required" },
            length: {
                minimum: 6,
                maximum: 50,
                tooShort: "needs to be at least %{count} characters long",
                tooLong: "needs to be at most %{count} characters long"
            }
        },
        order_type: {
            presence: { message: "is required" },
            length: {
                minimum: 6,
                maximum: 50,
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

    if(!req.body.cart){
        res.status(400).json({ error: "Cart is empty" });
        return;
    }

    let cartData = req.body.cart
    let order_number = req.body.order_number || `${new Date().getFullYear()}${new Date().getTime()}`
    let total_item = 0
    let total_paid = 0

    await Cart.deleteMany({ order_number: order_number })

    cartData.forEach(async (row) => {
        let qty = row.qty
        let price = row.price
        let total = price * qty
        let cartData = {
            order_number: order_number,
            menu_name: row.menu_name,
            qty: qty,
            price: price,
            total: total
        }
        await Cart.create(cartData);
        if(req.body.checkout){
            await Menu.updateOne(
                { name: row.menu_name },  
                { $inc: { rating: qty } } 
            );
        }
    })

    cartData.forEach((row) => {
        let qty = row.qty
        let price = row.price
        let total = price * qty
        total_item = total_item + qty
        total_paid = total_paid + total
    })

    let orderCurrent = await Order.findOne({ order_number: order_number })

    if(orderCurrent === null){
        let OrderData = {
            order_number: order_number,
            table_number: req.body.table_number,
            order_type: req.body.order_type,
            customer_name: req.body.customer_name,
            cashier_name: req.body.cashier_name,
            total_item: total_item,
            total_paid: total_paid,
            status: req.body.checkout ? 1 : 0
        }
        await Order.create(OrderData);
    }else{
        orderCurrent.table_number = req.body.table_number
        orderCurrent.order_type = req.body.order_type
        orderCurrent.customer_name = req.body.customer_name
        orderCurrent.cashier_name = req.body.cashier_name
        orderCurrent.total_item = total_item
        orderCurrent.total_paid = total_paid
        orderCurrent.status = req.body.checkout ? 1 : 0
        await orderCurrent.save()
    }

    if(req.body.checkout){
        await Table.updateMany(
            { name: req.body.table_number }, 
            { $set: { status: 1 } } 
        )
    }

    res.status(200).send({ message: req.body.checkout ? "Your order has been completed." : "Your order has been saved as draft." });
    return;
}

async function cancel(req, res) {

    let id = req.params.id;
    let order = await Order.findOne({ _id: id })
  
    if(order === null){
        res.status(400).json({ error: 'These order do not match our records.' });
        return;
    }

    if(order.table_number){
        await Order.updateMany(
            { name: order.table_number }, 
            { $set: { status: 1 } } 
        )
    }

    await Cart.deleteMany({ order_number: order.order_number })
    await Order.deleteOne({ _id: id })

    res.status(200).send({ message: "Your order has been canceled." });
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
    save,
    cancel,
    detail
}