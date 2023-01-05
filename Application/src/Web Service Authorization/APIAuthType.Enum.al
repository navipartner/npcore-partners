﻿enum 6014473 "NPR API Auth. Type" implements "NPR API IAuthorization"
{
#IF NOT BC17
    Access = Internal;       
#ENDIF
    Extensible = false;
    value(0; Basic)
    {
        Caption = 'Basic', Locked = true;
        Implementation = "NPR API IAuthorization" = "NPR API Basic Auth";
    }
    value(1; OAuth2)
    {
        Caption = 'OAuth 2.0', Locked = true;
        Implementation = "NPR API IAuthorization" = "NPR API OAuth2";
    }

    value(2; Custom)
    {
        Caption = 'Custom', Locked = true;
        Implementation = "NPR API IAuthorization" = "NPR API Custom Auth";
    }

}
