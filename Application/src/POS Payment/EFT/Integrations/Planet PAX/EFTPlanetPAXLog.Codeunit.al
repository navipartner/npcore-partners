codeunit 6150942 "NPR EFT Planet PAX Logger"
{
    Access = Internal;

    internal procedure Log(Lvl: Enum "NPR EFT Planet Pax Log Lvl"; EftReqNo: Integer; Description: Text; LogContent: Text)
    var
        EftReq: Record "NPR EFT Transaction Request";
    begin
        EftReq.Get(EftReqNo);
        Log(Lvl, EftReq, Description, LogContent);
    end;

    internal procedure Log(Lvl: Enum "NPR EFT Planet Pax Log Lvl"; EftReq: Record "NPR EFT Transaction Request"; Description: Text; LogContent: Text)
    var
        LogCU: Codeunit "NPR EFT Trx Logging Mgt.";
        PlanetPaxIntegration: Codeunit "NPR EFT Planet PAX Integ";
        EFTSetup: Record "NPR EFT Setup";
        EFTPaymentConfig: Record "NPR EFT Planet Integ. Config";
    begin
        EFTSetup.FindSetup(EftReq."Register No.", EftReq."Original POS Payment Type Code");
        PlanetPaxIntegration.GetPaymentTypeParameters(EFTSetup, EFTPaymentConfig);
        if (Lvl.AsInteger() <= EFTPaymentConfig."Log Level".AsInteger()) then
            LogCU.WriteLogEntry(EftReq."Entry No.", Description, LogContent);
    end;
}