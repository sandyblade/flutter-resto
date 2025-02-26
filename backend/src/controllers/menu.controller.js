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

const Menu = require('../models/menu.model')

async function list(req, res) {

    let page = req.query.page || 1;
    let limit = req.query.limit || 10;
    let offset = ((page-1)*limit)
    let filter = {}

    if(req.query.search){
        let keyword = req.query.search
        filter = {
            $and: [
                {
                    $or: [
                        { name: { $regex: keyword, $options: "i" } },
                        { category: { $regex: keyword, $options: "i" } },
                        { description: { $regex: keyword, $options: "i" } }
                    ]
                }
            ]
        }
    }

    let menu = await Menu.find(filter).limit(limit).skip(offset).sort({ rating: -1 });
    res.status(200).send(menu);
    return;
}

module.exports = {
    list
}