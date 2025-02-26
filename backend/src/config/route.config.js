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

const router = require('express').Router();
const auth = require("../controllers/auth.controller.js");
const history = require("../controllers/history.controller.js");
const home = require("../controllers/home.controller.js");
const menu = require("../controllers/menu.controller.js");
const order = require("../controllers/order.controller.js");
const profile = require("../controllers/profile.controller.js");

// Auth Section
router.post('/auth/login', auth.login);
router.post('/auth/email/forgot', auth.forgot);
router.post('/auth/email/reset/:token', auth.reset);

// History Section
router.get('/history/list', history.list);
router.get('/history/detail/:id', history.detail);

// Home Section
router.get('/home/summary', home.summary);
router.get('/home/table', home.table);
router.get('/home/sell', home.sell);

// Menu Section
router.get('/menu/list', menu.list);

// Order Section
router.post('/order/save', order.save);
router.delete('/order/cancel/:id', order.cancel);
router.get('/order/detail/:id', order.detail);

// Profile Section
router.get('/profile/detail', profile.detail);
router.post('/profile/update', profile.update);
router.post('/profile/password', profile.password);

module.exports = app => {
    app.use('/api', [router]);
};