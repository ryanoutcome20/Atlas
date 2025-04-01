Atlas = {
    Ports = { },

    Cache = { }
}

util.AddNetworkString( 'atlas-networking' )

-- =============================================================================
-- Utility Functionality.
-- =============================================================================

MODE_FAILED = -2

MODE_NONE = -1
MODE_ALL  = 0

MODE_PARSING  = 1
MODE_DONE     = 2

Atlas.Colors = { 
    [ 'Main' ] = Color( 45, 45, 180 ),

    [ 'White' ]     = Color( 255, 255, 255 ),
    [ 'Black' ]     = Color( 0, 0, 0 ),
    [ 'Gray' ]      = Color( 30, 30, 30 ),
    [ 'Invisible' ] = Color( 0, 0, 0, 0 ),

    [ 'Light Gray' ] = Color( 80, 80, 80 ),
    [ 'Dark Gray' ]  = Color( 18, 18, 18 ),
    [ 'Cyan' ]       = Color( 60, 180, 225 ),
    [ 'Purple' ]     = Color( 133, 97, 136 ),

    [ 'Red' ]   = Color( 255, 0, 0 ),
    [ 'Green' ] = Color( 0, 255, 0 ),
    [ 'Blue' ]  = Color( 0, 0, 255 ) 
}

function Atlas:PrintEx( Color, Message, ... )
    Color = Color or self.Colors[ 'Main' ]

    MsgC( 
        Color, 
        '[ Atlas ] ', 
        self.Colors[ 'White' ],
        string.format( Message, ... ),
        '\n'
    )
end

function Atlas:Print( Message, ... )
    return self:PrintEx( nil, Message, ... )
end

function Atlas:Call( Function, Meta, ... )
    if ( not Function ) then 
        return
    end

    if ( Meta ) then 
        Function( Meta, ... )
    else
        Function( ... )
    end
end

-- =============================================================================
-- Listening Functions.
-- =============================================================================

function Atlas:Listen( Port, Identifier, Mode, Callback, Meta )
    Mode = Mode or MODE_NONE
    
    self.Ports[ Port ] = self.Ports[ Port ] or { }

    self.Ports[ Port ][ Identifier ] = {
        Callback = Callback,
        Meta     = Meta,
        Mode     = Mode
    }
end

function Atlas:Close( Port, Identifier )
    if ( not self.Ports[ Port ] ) then 
        return
    end

    self.Ports[ Port ][ Identifier ] = nil
end

-- =============================================================================
-- Packing Functions.
-- =============================================================================

function Atlas:Pack( Data, alreadyPacked )
    alreadyPacked = alreadyPacked or {}

    local Type = TypeID( Data )

    -- Skip invalid types.
    if ( not Data or Type == TYPE_FUNCTION ) then 
        return 
    end

    -- Only tables and strings need compression.
    if ( Type != TYPE_TABLE and Type != TYPE_STRING ) then 
        return Data
    end

    -- Avoid infinite loops.
    if ( alreadyPacked[ Data ] ) then 
        return
    end

    -- Mark table as packed before recursion
    if ( Type == TYPE_TABLE ) then 
        alreadyPacked[ Data ] = true
    end

    -- Table compression.
    if ( Type == TYPE_TABLE ) then
        local Constructed = { }

        for k, subData in pairs(Data) do
            if ( alreadyPacked[ subData ] ) then
                continue
            end
            
            local Value = self:Pack( subData, alreadyPacked )

            if ( Value ) then
                Constructed[ k ] = {
                    Value = Value,
                    Type = TypeID(subData)
                }
            end
        end

        return util.Compress( util.TableToJSON( Constructed ) )
    end

    return util.Compress( Data )
end

function Atlas:Unpack( Data )
    -- Attempt decompression.
    local Decompressed = util.Decompress( Data )
    
    -- If decompression fails, return the original data (not compressed).
    if ( not Decompressed or Decompressed == '' ) then
        return Data
    end

    -- Try parsing JSON to check if it's a table.
    local Parsed = util.JSONToTable( Decompressed )
    
    -- If JSON parsing fails, return decompressed string.
    if ( not Parsed ) then
        return Decompressed
    end

    -- Recursive unpacking for nested tables.
    local Constructed = { }

    for k, Data in pairs( Parsed ) do
        if ( not Data.Value or not Data.Type ) then
            continue
        end

        if ( Data.Type == TYPE_STRING ) then
            Constructed[ k ] = tostring( self:Unpack( Data.Value ) )
        elseif ( Data.Type == TYPE_NUMBER ) then
            Constructed[ k ] = tonumber( self:Unpack( Data.Value ) )
        elseif ( Data.Type == TYPE_BOOL ) then
            Constructed[ k ] = self:Unpack( Data.Value ) == 'true'
        else
            Constructed[ k ] = self:Unpack( Data.Value )
        end
    end

    return Constructed
end

-- =============================================================================
-- Splitting Functions.
-- =============================================================================

function Atlas:Split( Data )
    local Split, Count = { }, 1

    for i = 1, #Data do
        local Character = Data[ i ]     

        Split[ Count ] = Split[ Count ] or { }
    
        if ( #Split[ Count ] > 63000 ) then 
            Count = Count + 1
            
            Split[ Count ] = { }
        end
        
        table.insert( Split[ Count ], Character )
    end

    return Split, Count
end

-- =============================================================================
-- Read / Write Functions.
-- =============================================================================

function Atlas:Read( )
    local Data = { }

    Data.Chunk = net.ReadData( net.ReadUInt( 16 ) )
    
    Data.Index = net.ReadUInt( 12 )
    Data.Size  = net.ReadUInt( 12 )
    Data.Final = net.ReadBool( )

    Data.Checksum = net.ReadString( )
    Data.Port     = net.ReadString( )

    return Data
end

function Atlas:Write( Chunk, Size, Checksum, Index, Port )
    net.WriteUInt( #Chunk, 16 )
    net.WriteData( Chunk, #Chunk )
    
    net.WriteUInt( Index, 12 )
    net.WriteUInt( Size, 12 )

    net.WriteBool( Size == Index )

    net.WriteString( Checksum )
    net.WriteString( Port )
end

-- =============================================================================
-- Send Functions.
-- =============================================================================

function Atlas:Send( Port, Target, ... )
    local Data         = self:Pack( { ... } )
    local Split, Count = self:Split( Data )

    local Checksum = util.SHA256( Data )
    local Size     = Count

    for i = 1, Size do 
        timer.Simple( i, function( )
            net.Start( 'atlas-networking' )

                self:Write( table.concat( Split[ i ] ), Size, Checksum, i, Port )

            net.Send( Target )
        end )
    end
end

function Atlas:Broadcast( Port, ... )
    local Data  = self:Pack( { ... } )
    local Split, Count = self:Split( Data )

    local Checksum = util.SHA256( Data )
    local Size     = Count

    for i = 1, Size do 
        timer.Simple( i, function( )
            net.Start( 'atlas-networking' )

                self:Write( table.concat( Split[ i ] ), Size, Checksum, i, Port )

            net.Broadcast( )
        end )
    end
end

-- =============================================================================
-- Caller Functions.
-- =============================================================================

function Atlas:Process( Callbacks, Stage, ... )
    for Identifier, Data in pairs( Callbacks ) do 
        if ( Data.Mode == MODE_NONE ) then 
            continue
        end

        if ( Data.Mode != MODE_ALL and Data.Mode != Stage ) then 
            continue
        end

        self:Call( Data.Callback, Data.Meta, Stage, ... )
    end
end

-- =============================================================================
-- Internal Receive Functions.
-- =============================================================================

function Atlas:Receive( ENT )
    local Data = self:Read( )

    if ( not Data or not Data.Port ) then 
        return
    end

    local Callbacks = self.Ports[ Data.Port ]

    if ( not Callbacks ) then 
        return
    end

    self.Cache[ ENT ] = self.Cache[ ENT ] or { }

    local Index = ( self.Cache[ ENT ][ Data.Port ] or '' ) .. Data.Chunk

    self:Process( Callbacks, MODE_PARSING, ENT, Data, Index )

    if ( Data.Final ) then 
        if ( Data.Checksum == Index ) then 
            local Arguments = self:Unpack( Index )

            self:Process( Callbacks, MODE_DONE, ENT, unpack( Arguments ) )
        else
            self:Process( Callbacks, MODE_FAILED, ENT, Index )
        end

        Index = ''
    end

    self.Cache[ ENT ][ Data.Port ] = Index
end

net.Receive( 'atlas-networking', function( Length, ENT )
    Atlas:Receive( ENT )
end )