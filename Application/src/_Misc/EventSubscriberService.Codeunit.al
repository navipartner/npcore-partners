codeunit 6014457 "NPR Event Subscriber (Service)"
{
    Access = Internal;
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Table, Database::"Service Connection", 'OnRegisterServiceConnection', '', false, false)]
    local procedure T1400OnRegisterServiceConnection(var ServiceConnection: Record "Service Connection")
    begin
        ServiceConnection.Status := ServiceConnection.Status::Enabled;

        RegisterMagentoSetup(ServiceConnection);
        RegisterRaptorSetup(ServiceConnection);
        RegisterSMSSetup(ServiceConnection);
        RegisterNpGpPOSSalesSetup(ServiceConnection);
        RegisterPrintNodeSetup(ServiceConnection);
        RegisterMMLoyStoreSetupServer(ServiceConnection);
    end;

    local procedure RegisterSMSSetup(var ServiceConnection: Record "Service Connection")
    var
        SMSSetup: Record "NPR SMS Setup";
        ServiceNameSMSLbl: Label 'SMS Setup';
        HostName: Text;
    begin
        HostName := '';
        if not SMSSetup.Get() then begin
            SMSSetup.Init();
            SMSSetup.Insert();
        end;
        ServiceConnection.InsertServiceConnection(
            ServiceConnection, SMSSetup.RecordId,
            ServiceNameSMSLbl, HostName, PAGE::"NPR SMS Setup");
    end;

    local procedure RegisterNpGpPOSSalesSetup(var ServiceConnection: Record "Service Connection")
    var
        NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup";
        ServiceNameNpGpPOSSalesLbl: Label 'Global POS Sales Setup';
        HostName: Text;
    begin
        HostName := '';
        if not NpGpPOSSalesSetup.Get() then begin
            NpGpPOSSalesSetup.Init();
            NpGpPOSSalesSetup.Insert();
        end;
        ServiceConnection.InsertServiceConnection(
            ServiceConnection, NpGpPOSSalesSetup.RecordId,
            ServiceNameNpGpPOSSalesLbl, HostName, PAGE::"NPR NpGp POS Sales Setup Card");
    end;

    local procedure RegisterPrintNodeSetup(var ServiceConnection: Record "Service Connection")
    var
        PrintNodeSetup: Record "NPR PrintNode Setup";
        ServiceNamePrintNodeLbl: Label 'PrintNode Setup';
        HostName: Text;
    begin
        HostName := '';
        if not PrintNodeSetup.Get() then begin
            PrintNodeSetup.Init();
            PrintNodeSetup.Insert();
        end;
        ServiceConnection.InsertServiceConnection(
            ServiceConnection, PrintNodeSetup.RecordId,
            ServiceNamePrintNodeLbl, HostName, PAGE::"NPR PrintNode Setup");
    end;

    local procedure RegisterMMLoyStoreSetupServer(var ServiceConnection: Record "Service Connection")
    var
        MMLoyaltyStoreSetup: Record "NPR MM Loyalty Store Setup";
        ServiceNameMMLoyaltyStoreSetupLbl: Label 'Loyalty Store Setup (Server)';
        HostName: Text;
    begin
        HostName := '';
        if not MMLoyaltyStoreSetup.Get() then begin
            MMLoyaltyStoreSetup.Init();
            MMLoyaltyStoreSetup.Insert();
        end;
        ServiceConnection.InsertServiceConnection(
            ServiceConnection, MMLoyaltyStoreSetup.RecordId,
            ServiceNameMMLoyaltyStoreSetupLbl, HostName, PAGE::"NPR MM Loy. Store Setup Server");
    end;

    local procedure RegisterMagentoSetup(var ServiceConnection: Record "Service Connection")
    var
        MagentoSetup: Record "NPR Magento Setup";
        ServiceNameMagentoLbl: Label 'Magento Setup';
        HostName: Text;
    begin
        HostName := '';
        if not MagentoSetup.Get() then begin
            MagentoSetup.Init();
            MagentoSetup.Insert();
        end;
        ServiceConnection.InsertServiceConnection(
            ServiceConnection, MagentoSetup.RecordId,
            ServiceNameMagentoLbl, HostName, PAGE::"NPR Magento Setup");
    end;

    local procedure RegisterRaptorSetup(var ServiceConnection: Record "Service Connection")
    var
        RaptorSetup: Record "NPR Raptor Setup";
        ServiceNameRaptorLbl: Label 'Raptor Setup';
        HostName: Text;
    begin
        HostName := '';
        if not RaptorSetup.Get() then begin
            RaptorSetup.Init();
            RaptorSetup.Insert();
        end;
        ServiceConnection.InsertServiceConnection(
            ServiceConnection, RaptorSetup.RecordId, ServiceNameRaptorLbl,
            HostName, PAGE::"NPR Raptor Setup");
    end;
#pragma warning restore
}

