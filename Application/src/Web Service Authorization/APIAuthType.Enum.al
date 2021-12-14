enum 6014473 "NPR API Auth. Type" implements "NPR API IAuthorization"
{
    Extensible = false;
    value(0; Basic)
    {
        Caption = 'Basic';
        Implementation = "NPR API IAuthorization" = "NPR API Basic Auth";
    }
    value(1; OAuth2)
    {
        Caption = 'OAuth 2.0';
        Implementation = "NPR API IAuthorization" = "NPR API OAuth2";
    }

    value(2; Custom)
    {
        Caption = 'Custom';
        Implementation = "NPR API IAuthorization" = "NPR API Custom Auth";
    }

}
