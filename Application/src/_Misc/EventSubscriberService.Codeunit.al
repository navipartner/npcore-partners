codeunit 6014457 "NPR Event Subscriber (Service)"
{
    [EventSubscriber(ObjectType::Table, Database::"Service Connection", 'OnRegisterServiceConnection', '', false, false)]
    local procedure T1400OnRegisterServiceConnection(var ServiceConnection: Record "Service Connection")
    begin
        ServiceConnection.Status := ServiceConnection.Status::Enabled;

        RegisterMagentoSetup(ServiceConnection);
        RegisterRaptorSetup(ServiceConnection);
        RegisterDependencyMgtSetup(ServiceConnection);
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

    local procedure RegisterDependencyMgtSetup(var ServiceConnection: Record "Service Connection")
    var
        DependencyMagtSetup: Record "NPR Dependency Mgt. Setup";
        ServiceNameDepMgtLbl: Label 'Dependency Management Setup';
        HostName: Text;
    begin
        HostName := '';
        if not DependencyMagtSetup.Get then begin
            DependencyMagtSetup.Init;
            DependencyMagtSetup.Insert;
        end;
        ServiceConnection.InsertServiceConnection(
            ServiceConnection, DependencyMagtSetup.RecordId, ServiceNameDepMgtLbl,
            HostName, PAGE::"NPR Dependency Mgt. Setup");
    end;
}

