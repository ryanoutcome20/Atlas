Atlas = {
    Ports = { }
}

util.AddNetworkingString( 'atlas-networking' )

-- =============================================================================
-- Utility Functionality.
-- =============================================================================

Atlas.Colors = { 
    [ 'Main' ] = Color( 25, 25, 140 ),

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

function Atlas:Print( Color, Message, ... )
    Color = Color or self.Colors[ 'Main' ]

    MsgC( 
        Color, 
        '[ Atlas ] ', 
        self.Colors[ 'White' ],
        string.format( Message, ... ),
        '\n'
    )
end

function Atlas:Call( Function, Meta, ... )
    if ( Meta ) then 
        Function( Meta, ... )
    else
        Function( ... )
    end
end

-- =============================================================================
-- Listening Functions
-- =============================================================================

function Atlas:Listen( Port, Identifier, Callback, Meta )
    self.Ports[ Port ] = self.Ports[ Port ] or { }

    self.Ports[ Port ][ Identifier ] = {
        Callback = Callback,
        Meta     = Meta
    }
end

-- =============================================================================
-- Write Functions.
-- =============================================================================

-- =============================================================================
-- Read Functions.
-- =============================================================================

-- =============================================================================
-- Internal Receive Functions.
-- =============================================================================