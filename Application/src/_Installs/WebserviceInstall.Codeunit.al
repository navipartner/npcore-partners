codeunit 6014471 "NPR Webservice Install"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        InitMPOSWebService();
        InitNpCsCollectWS();
        InitNpDcNonPOSCouponWS();
        InitNpRvExtVoucherWS();
        InitM2AccountWebService();
        InitMagentoWebservice();
        InitMMMemberWebService();
        InitRepWSFunctions();
        InitTMTicketWebService();
    end;

    local procedure InitMPOSWebService()
    var
        MPOSWebservice: Codeunit "NPR MPOS Webservice";
    begin
        MPOSWebservice.InitMPOSWebService();
    end;

    local procedure InitNpCsCollectWS()
    var
        NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
    begin
        NpCsCollectMgt.InitCollectInStoreService();
    end;

    local procedure InitNpDcNonPOSCouponWS()
    var
        NpDcNonPOSAppMgt: Codeunit "NPR NpDc Non-POS App. Mgt.";
    begin
        NpDcNonPOSAppMgt.InitNpDcNonPOSCouponWS();
    end;

    local procedure InitNpRvExtVoucherWS()
    var
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        NpRvVoucherMgt.InitNpRvExtVoucherWS();
    end;

    local procedure InitM2AccountWebService()
    var
        M2AccountWebService: Codeunit "NPR M2 Account WebService";
    begin
        M2AccountWebService.InitM2AccountWebService();
    end;

    local procedure InitMagentoWebservice()
    var
        MagentoWebservice: Codeunit "NPR Magento Webservice";
    begin
        MagentoWebservice.InitMagentoWebservice();
    end;

    local procedure InitMMMemberWebService()
    var
        MMMemberWebServiceMgr: Codeunit "NPR MM Member WebService Mgr";
    begin
        MMMemberWebServiceMgr.InitMMMemberWebService();
    end;

    local procedure InitRepWSFunctions()
    var
        RepWSFunctions: Codeunit "NPR Rep. WS Functions";
    begin
        RepWSFunctions.InitRepWSFunctions();
    end;

    local procedure InitTMTicketWebService()
    var
        TMTicketWebServiceMgr: Codeunit "NPR TM Ticket WebService Mgr";
    begin
        TMTicketWebServiceMgr.InitTMTicketWebService();
    end;
}