# 🌐 Quickstart Guide 🌐

## Introduction / Purpose

To determine if this project is a good fit for you, consider the following questions:

1. Do I require high bandwidth transfer rates or the ability to send large files?
2. Do I need a dynamic hooking system that allows multiple functions to hook into the same port?
3. Do I want clean code without the need to use `util.AddNetworkString`?

If the answer to any of these is "Yes!" then this is more than likely the right project for you to implement.

## Basic Usage

The basic usage is similar to the built-in `net` library but offers additional powerful features.

Below is a basic "Hello, World!" transmitted from client to server.

**Serverside**:
```lua
Atlas:Send('Example', Entity(1), "Hello, World!")
```

**Clientside**:
```lua
Atlas:Listen("Example", "Name", MODE_DONE, function( Stage, Text ) 
    MsgN(Text)
end)
```

There is no need to do anything with pooling as it all goes through a single network string.

## Modes / Stages

A more dynamic feature of **Atlas** is the multiple handlers that can be attached to a single networking message. This unique feature allows various functions and behaviors to be implemented dynamically. Modes (or stages) give us the framework in which to expand this logic beyond just multiple functions and into customizable and dynamic networking systems.

Here are the available networking modes and their functions. When calling `Listen` on a port, you can specify one of these modes.

```
MODE_NONE - Will never be called. Used when you want to temporarily disable a listener.

MODE_ALL - Will be called for all stages, including MODE_NONE.

MODE_PARSING - Will be called whenever the realm receives a chunk. Note that the chunk is only unpacked at the end so it will be heavily compressed.

MODE_DONE - Will be called when the realm has finished this networking port. Note that the chunk is completely unpacked at this stage.
```

## Send Usage

When sending a message to the other realm you have various options and arguments you can pass to the `Send` function. Below is the declaration of the `Send` function.

**Serverside**:
```lua
Atlas:Send(Port, Target, ...)
Atlas:Broadcast(Port, ...)
```

**Clientside**:
```lua
Atlas:Send(Port, ...)
```

Note that on the serverside you can broadcast a message to all connected users, `Target` can also be a table, allowing you to send messages to specific users (i.e, staff members).

You can send multiple fields to the opposite realm, this implementation allows various arguments to be passed along through the network.

Below is an example of how this could be useful.

**Serverside**:
```lua
Atlas:Send("Banned", Entity(1), BannedPlayer:EntIndex( ), 'Breaking Rules!')
```

**Clientside**:
```lua
Atlas:Listen("Banned", "Name", MODE_DONE, function( Stage, Player, Reason ) 
    local BannedPlayer = Entity(Player)
    MsgN(BannedPlayer:Name( ) .. ' was banned for ' .. Reason)
end)
```

## Listener Usage

Various things can be done with the `Listen` function. You can listen to various stages of the networking and even provide it with a metatable to call your function with. Below is the declaration of the `Listen` function.

```lua
Atlas:Listen( Port, Identifier, Mode, Callback, Meta )
Atlas:Close( Port, Identifier )
```

Below is an example of why you might want to call it with a metatable.

```lua
local Table = {
    Name = "Atlas"
}

function Table:Receive(Stage, Data)
    -- Notice how self isn't nil in here since we provided a metatable
    -- to the Listen function.

    MsgN(self.Name .. " has received a message!")

    MsgN(Data)
end

Atlas:Listen("Message", "Table", MODE_DONE, Table.Receive, Table)
```

## Large Data Transfer

While most networking tasks won't require it, **Atlas** supports transferring large datasets across realms through its API. The Source Engine typically limits networking messages to 64KB, but this can be further reduced depending on server load, as additional game data contributes to the transfer size.

With **Atlas**, large datasets are efficiently transferred without the usual constraints. Below is an example of how to send and receive large data.

**Serverside**:
```lua
Atlas:Send("Large", Entity(1), file.Read("garrysmod_dir.vpk", "GAME"))
```

**Clientside**:
```lua
Atlas:Listen("Large", "Name", MODE_DONE, function( Stage, Data ) 
    MsgN("Got data!")
    MsgN("Total Size: " .. string.NiceSize(#Data)) -- 513.92 KB at time of upload.
end)
```