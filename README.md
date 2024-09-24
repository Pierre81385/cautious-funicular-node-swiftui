# cautious-funicular-node-swiftui

Currently a chat application to direct message users who are online with realtime updates.

# structure

Node/Express server hosts the API allowing the apps conneting to it to perform CRUD operations on the data stored in MongoDB (using Mongoose)

For events that require realtime updates like new user creation, user deletion, message creation, or online/offline status, websocket events trigger updates to fetch new data and re-render.

# api

## User Endpoints

POST "Create new user" http://localhost:3000/users/new

GET "Get all users" http://localhost:3000/users/

GET "Get user by user _id" http://localhost:3000/users/{user._id}

GET "Get user by username" http://localhost:3000/users/user/{user.username}=

PUT "Update user by user _id" http://localhost:3000/users/{user._id}

DELETE "Delete user by user _id" http://localhost:3000/users/{user._id}

## Chat Endpoints

POST "Create new chat" http://localhost:3000/chats/new

GET "Get chat by chat identifier" http://localhost:3000/chats/{chat.identifier}

PUT "Update chat by chat identifier" http://localhost:3000/chats/{chat.identifier}/update

* Note: chats are identified by their identifier number rather than document ID as this is a unique combination shared by the participants in the chat
* The identifier is created by converting the usernames to UInt64, then adding them together and limiting the number of digits to 12
* This way the identifier created is the same value calculated from either the sender side or recipient side ensure a unique chat is only created once


