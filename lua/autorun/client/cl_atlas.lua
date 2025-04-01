local Chunk = ''
local Index = 0
local Size  = 0
local Final = false
local Checksum = ''

local Combined = ''

local function Unpack( Data )
    -- Attempt decompression.
    local Decompressed = util.Decompress( Data )
    
    -- If decompression fails, return original data (not compressed).
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
        if not Data.Value or not Data.Type then
            continue
        end

        if Data.Type == TYPE_STRING then
            Constructed[ k ] = tostring( Unpack( Data.Value ) )
        elseif Data.Type == TYPE_NUMBER then
            Constructed[ k ] = tonumber( Unpack( Data.Value ) )
        elseif Data.Type == TYPE_BOOL then
            Constructed[ k ] = Unpack( Data.Value ) == 'true'
        else
            Constructed[ k ] = Unpack( Data.Value )
        end
    end

    return Constructed
end

net.Receive( 'atlas-networking', function( )
    Chunk = net.ReadData( net.ReadUInt( 16 ) )
    Index = net.ReadUInt( 12 )
    Size  = net.ReadUInt( 12 )
    Final = net.ReadBool( )
    Checksum = net.ReadString( )

    MsgN( Index )
    MsgN( Size )
    MsgN( Final )

    Combined = Combined .. Chunk

    if ( Final ) then 
        local unpacked = Unpack( Combined )

        unpacked = unpacked[ 1 ]

        MsgN(#unpacked)
        MsgN(util.CRC(unpacked))

        Combined = ''
    end
end )