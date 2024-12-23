const express = require('express');
const router = express.Router();
const {validateUID, getLogsForUser, addUser, removeUser, getUsers, updateUser, openDoor, getAllLogs} = require('../controllers/uidController');

router.post('/validate-uid', validateUID);

router.get('/logs/:uid', getLogsForUser);

router.post('/add-user', addUser);

router.delete('/remove-user/:uid', removeUser);

router.get('/get-users', getUsers);

router.put('/update-user/:uid', updateUser);

router.post('/open-door', openDoor);

router.get("/logs", getAllLogs);

module.exports = router;