enum 6014473 "NPR Replication API Auth. Type" implements "NPR Replication API IAuthorization"
{
    Extensible = false;
    value(0; Basic)
    {
        Caption = 'Basic';
        Implementation = "NPR Replication API IAuthorization" = "NPR Replication API Basic Auth";
    }
    value(1; OAuth2)
    {
        Caption = 'OAuth 2.0';
        Implementation = "NPR Replication API IAuthorization" = "NPR Replication API OAuth2";
    }

}
