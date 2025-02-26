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

require('dotenv').config();

const bcrypt = require("bcryptjs");
const { faker } = require('@faker-js/faker');
const UserModel = require("../models/user.model.js");
const CartModel = require("../models/cart.model.js");
const OrderModel = require("../models/order.model.js");
const TableModel = require("../models/table.model.js");
const MenuModel = require("../models/menu.model.js");

async function createUser() {

    const total = await UserModel.countDocuments({});
    const hashedPassword = bcrypt.hashSync("Qwerty12345#!", 10)
    const genders = ["male", "female"]
    const max = 10

    if (total === 0) {
        for (let i = 1; i <= max; i++) {
            let genderIndex = Math.floor(Math.random() * (1 - 0 + 1)) + 0;
            let formData = {
                "name": faker.person.fullName({ sex: genders[genderIndex] }),
                "email": i === 1 ? "admin@administrator.example.com" : faker.internet.email(),
                "password": hashedPassword,
                "role": i === 1 ? "ROLE_ADMIN" : "ROLE_USER",
                "gender": genders[genderIndex],
                "phone": faker.phone.number({ style: 'international' }),
                "forgot_password_token": faker.string.uuid(),
                "address": faker.location.streetAddress({ useFullAddress: true })
            }
            await UserModel.create(formData);
        }
    }
}

async function createMenu() {

    const total = await MenuModel.countDocuments({});

    if (total === 0) {

        let rows = [
            {
                name: "Burger",
                price: 3.5,
                image: "https://5an9y4lf0n50.github.io/demo-images/demo-resto/burger.jpg",
                category: 'Main Course',
                description: faker.lorem.sentence()
            },
            {
                name: "Coffee",
                price: 1.5,
                image: "https://5an9y4lf0n50.github.io/demo-images/demo-resto/coffee.jpg",
                category: 'Dessert',
                description: faker.lorem.sentence()
            },
            {
                name: "French Fries",
                price: 2.0,
                image: "https://5an9y4lf0n50.github.io/demo-images/demo-resto/french-fries.jpg",
                category: 'Appetizer',
                description: faker.lorem.sentence()
            },
            {
                name: "Green Tea",
                price: 1.2,
                image: "https://5an9y4lf0n50.github.io/demo-images/demo-resto/green-tea.jpg",
                category: 'Dessert',
                description: faker.lorem.sentence()
            },
            {
                name: "Ice Cream",
                price: 1.7,
                image: "https://5an9y4lf0n50.github.io/demo-images/demo-resto/ice-cream.jpg",
                category: 'Dessert',
                description: faker.lorem.sentence()
            },
            {
                name: "Fresh Milk",
                price: 1.0,
                image: "https://5an9y4lf0n50.github.io/demo-images/demo-resto/milk.jpg",
                category: 'Dessert',
                description: faker.lorem.sentence()
            },
            {
                name: "Orange Juice",
                price: 1.3,
                image: "https://5an9y4lf0n50.github.io/demo-images/demo-resto/orange-juice.jpg",
                category: 'Dessert',
                description: faker.lorem.sentence()
            },
            {
                name: "Sandwitch",
                price: 2.3,
                image: "https://5an9y4lf0n50.github.io/demo-images/demo-resto/sandwitch.jpg",
                category: 'Main Course',
                description: faker.lorem.sentence()
            },
            {
                name: "Spaghetti",
                price: 3.8,
                image: "https://5an9y4lf0n50.github.io/demo-images/demo-resto/spaghetti.jpg",
                category: 'Main Course',
                description: faker.lorem.sentence()
            },
            {
                name: "Steak",
                price: 4.9,
                image: "https://5an9y4lf0n50.github.io/demo-images/demo-resto/steak.jpg",
                category: 'Main Course',
                description: faker.lorem.sentence()
            },
        ]

        rows.forEach(async (row) => {
            row.rating = Math.floor(Math.random() * (5 - 1 + 1)) + 1;
            await MenuModel.create(row);
        })

    }

}

async function createTable() {

    const total = await TableModel.countDocuments({});

    if (total === 0) {
        for (let i = 1; i <= 10; i++) {
            let name = i != 10 ? "T0" + i : "T" + i
            let description = faker.lorem.sentence()
            await TableModel.create({ name: name, description: description });
        }
    }

}


async function createOrder() {

    const total = await OrderModel.countDocuments({});

    if (total === 0) {
        for (let i = 1; i <= 10; i++) {

            let order_number = `${new Date().getFullYear()}${faker.number.int({ min: 1000000000000, max: 9000000000000 })}`
            let table = faker.number.int({ min: 1, max: 10 })
            let table_number = table != 10 ? "T0" + table : "T" + table
            let order_type = "Dine In"
            let customer_name = faker.person.fullName()
            let cashier_name = faker.person.fullName()
            let total_item = 0
            let total_paid = 0

            for (let j = 1; j <= 3; j++) {
                let menu = await MenuModel.aggregate([{ $sample: { size: 1 } }]).exec();
                let qty = faker.number.int({ min: 1, max: 10 })
                let price = menu[0].price
                let total = price * qty
                let cartData = {
                    order_number: order_number,
                    menu_name: menu[0].name,
                    qty: qty,
                    price: price,
                    total: total
                }
                await CartModel.create(cartData);
                total_item = total_item + qty
                total_paid = total_paid + total
            }

            let OrderData = {
                order_number: order_number,
                table_number: table_number,
                order_type: order_type,
                customer_name: customer_name,
                cashier_name: cashier_name,
                total_item: total_item,
                total_paid: total_paid,
                status: 1
            }
            await OrderModel.create(OrderData);

        }
    }
}


async function run() {
    await createUser()
    await createTable()
    await createMenu()
    await createOrder()
}

module.exports = { run }