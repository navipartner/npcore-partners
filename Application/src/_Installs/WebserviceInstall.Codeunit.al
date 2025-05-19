codeunit 6014471 "NPR Webservice Install"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        InitMPOSWebService();
        InitEmergencyMPOSWebService();
        InitVippsMobilepayWebService();
        InitNpCsCollectWS();
        InitNpDcNonPOSCouponWS();
        InitNpRvExtVoucherWS();
        InitM2AccountWebService();
        InitMagentoWebservice();
        InitMMMemberWebService();
        InitRepWSFunctions();
        InitTMTicketWebService();
        InitModernApiWSCodeunits();
        InitDragonglassPOSService();
        InitBcHealtCheckService();
    end;

    local procedure InitMPOSWebService()
    var
        MPOSWebservice: Codeunit "NPR MPOS Webservice";
    begin
        MPOSWebservice.InitMPOSWebService();
    end;

    local procedure InitEmergencyMPOSWebService()
    var
        EmergencyMPOSWebservice: Codeunit "NPR Emergency mPOS Api";
    begin
        EmergencyMPOSWebservice.InitEmergencyMPOSWebService();
    end;

    local procedure InitVippsMobilepayWebService()
    var
        MpVippsWebservice: Codeunit "NPR Vipps Mp WebService";
    begin
        MpVippsWebservice.InitMpVippsWebserviceWebService();
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
        M2AccountManager: Codeunit "NPR M2 Account Manager";
    begin
        M2AccountManager.InitM2AccountWebService();
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

    local procedure InitModernApiWSCodeunits()
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    var
        restApi: Codeunit "NPR API Request Processor";
#endif
    begin
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
        restApi.RegisterService();
#endif
    end;

    local procedure InitDragonglassPOSService()
    var
        DragonglassPOSServiceMgr: Codeunit "NPR POS Dragonglass API";
    begin
        DragonglassPOSServiceMgr.InitPOSDragonglassService();
    end;

    local procedure InitBcHealtCheckService()
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    var
        BCHealthCheckMgt: Codeunit "NPR BC Health Check Mgt.";
#endif
    begin
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
        BCHealthCheckMgt.RegisterService();
#endif
    end;
}