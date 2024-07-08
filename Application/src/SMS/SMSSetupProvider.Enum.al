enum 6014458 "NPR SMS Setup Provider" implements "NPR Send SMS"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; NaviPartner)
    {
        Caption = 'NaviPartner';
        Implementation = "NPR Send SMS" = "NPR NaviPartner Send SMS";
    }
    value(1; Endpoint)
    {
        Caption = 'Endpoint';
        Implementation = "NPR Send SMS" = "NPR Endpoint Send SMS";
    }

}
