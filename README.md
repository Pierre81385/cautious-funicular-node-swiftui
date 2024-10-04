# cautious-funicular-node-swiftui

Currently a chat application to direct message users who are online with realtime updates.

# App

Node/Express server hosts the API allowing the apps conneting to it to perform CRUD operations on the data stored in MongoDB (using Mongoose)

For events that require realtime updates like new user creation, user deletion, message creation, or online/offline status, websocket events trigger updates to fetch new data and re-render.

# Websockets

[User Online Status]

- When the Profile view appears, 'userOnline' event is emitted when a user is loaded successfully.
- When the logout button is pressed, 'userOffline' event is emitted.  
- When 'userOnline' or 'userOffline' is received by the server, 'updateUsersList' is emitted to the frontend.
- When the SocketService detecs the 'updateUsersList' event, the message is changed and userListUpdateRequired is set to true.
- When the Profile scroll view detects a change in the userListUpdateRequired and checks if the value is true.  If it is the current list of users is requested from the server.

[Message Sent]

- A new MessageData object is created and stores the text and optional media content, which is appended to the existing local copy of the chat in the messages array.
- A request is sent to the server to update the chat with this new version.
- Once completed the event 'messageSent' is emitted by Socket.io with the chat identifier.
- When the server recives 'messageSent' the chat identifier is console logged and a new event 'updateChat' is emitted with the chat identifier.
- When the app SocketService recieves 'updateChat' the chat identifier is assigned to updateChatMessages.
- When the message view observes the change of updateChatMessages, a check is performed to see if updateChatMessages is equal to the current chatIdentifier.  If it is, a request is sent to the server to get the current version of the chat by identifier.
- Once updated, the value of updateChatMessages is reset to 0 to await the next change.

# API

## - User Endpoints

POST "Create new user" http://localhost:3000/users/new

GET "Get all users" http://localhost:3000/users/

GET "Get user by user _id" http://localhost:3000/users/{user._id}

GET "Get user by username" http://localhost:3000/users/user/{user.username}

PUT "Update user by user _id" http://localhost:3000/users/{user._id}

DELETE "Delete user by user _id" http://localhost:3000/users/{user._id}

## - Chat Endpoints

POST "Create new chat" http://localhost:3000/chats/new

GET "Get chat by chat identifier" http://localhost:3000/chats/{chat.identifier}

PUT "Update chat by chat identifier" http://localhost:3000/chats/{chat.identifier}/update

* Note: chats are identified by their identifier number rather than document ID as this is a unique combination shared by the participants in the chat
* The identifier is created by converting the usernames to UInt64, then adding them together and limiting the number of digits to 12
* This way the identifier created is the same value calculated from either the sender side or recipient side ensure a unique chat is only created once

## - Image Endpoint

POST "Upload Image" http://localhost:3000/imgs/upload


