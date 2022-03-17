codeunit 6014471 "NPR Webservice Install"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        InitMPOSWebService();
    end;

    local procedure InitMPOSWebService()
    var
        MPOSWebservice: Codeunit "NPR MPOS Webservice";
    begin
        MPOSWebservice.InitMPOSWebService();
    end;

}