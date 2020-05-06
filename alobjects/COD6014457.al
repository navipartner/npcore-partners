codeunit 6014457 "NPR Event Subscriber (Service)"
{
    // NPR5.54/TILA/20200203 CASE 388608 NPR Setups Added to Service Connections page


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 1400, 'OnRegisterServiceConnection', '', false, false)]
    local procedure T1400OnRegisterServiceConnection(var ServiceConnection: Record "Service Connection")
    begin
        //-NPR5.54 [388608]
        ServiceConnection.Status := ServiceConnection.Status::Enabled;

        RegisterAFSetup(ServiceConnection);
        RegisterMagentoSetup(ServiceConnection);
        RegisterRaptorSetup(ServiceConnection);
        RegisterDependencyMgtSetup(ServiceConnection);
        //+388608 [388608]
    end;

    local procedure RegisterAFSetup(var ServiceConnection: Record "Service Connection")
    var
        AFSetup: Record "AF Setup";
        ServiceNameAF: Label 'AF Setup';
        HostName: Text;
    begin
        //-NPR5.54 [388608]
        HostName := '';
        if not AFSetup.Get then begin
          AFSetup.Init;
          AFSetup.Insert;
        end;
        ServiceConnection.InsertServiceConnection(ServiceConnection,AFSetup.RecordId,ServiceNameAF,HostName,PAGE::"AF Setup");
        //+388608 [388608]
    end;

    local procedure RegisterMagentoSetup(var ServiceConnection: Record "Service Connection")
    var
        MagentoSetup: Record "Magento Setup";
        ServiceNameMagento: Label 'Magento Setup';
        HostName: Text;
    begin
        //-NPR5.54 [388608]
        HostName := '';
        if not MagentoSetup.Get then begin
          MagentoSetup.Init;
          MagentoSetup.Insert;
        end;
        ServiceConnection.InsertServiceConnection(ServiceConnection,MagentoSetup.RecordId,ServiceNameMagento,HostName,PAGE::"Magento Setup");
        //+388608 [388608]
    end;

    local procedure RegisterRaptorSetup(var ServiceConnection: Record "Service Connection")
    var
        RaptorSetup: Record "Raptor Setup";
        ServiceNameRaptor: Label 'Raptor Setup';
        HostName: Text;
    begin
        //-NPR5.54 [388608]
        HostName := '';
        if not RaptorSetup.Get then begin
          RaptorSetup.Init;
          RaptorSetup.Insert;
        end;
        ServiceConnection.InsertServiceConnection(ServiceConnection,RaptorSetup.RecordId,ServiceNameRaptor,HostName,PAGE::"Raptor Setup");
        //+388608 [388608]
    end;

    local procedure RegisterDependencyMgtSetup(var ServiceConnection: Record "Service Connection")
    var
        DependencyMagtSetup: Record "Dependency Management Setup";
        ServiceNameDepMgt: Label 'Dependency Management Setup';
        HostName: Text;
    begin
        //-NPR5.54 [388608]
        HostName := '';
        if not DependencyMagtSetup.Get then begin
          DependencyMagtSetup.Init;
          DependencyMagtSetup.Insert;
        end;
        ServiceConnection.InsertServiceConnection(ServiceConnection,DependencyMagtSetup.RecordId,ServiceNameDepMgt,HostName,PAGE::"Dependency Management Setup");
        //+388608 [388608]
    end;
}

