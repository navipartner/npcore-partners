codeunit 6151286 "NPR SS Action: Start SelfServ."
{
    var
        ActionDescription: Label 'This built in actions starts the POS in SelfService mode';

    local procedure ActionCode(): Text
    begin

        exit('SS-START-POS');
    end;

    local procedure ActionVersion(): Text
    begin

        exit('1.2');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin

        if Sender.DiscoverAction20(
          ActionCode(),
          ActionDescription,
          ActionVersion())
        then begin
            Sender.RegisterWorkflow20('await workflow.respond();');

            Sender.RegisterTextParameter('SalespersonCode', '');
            Sender.RegisterTextParameter('LanguageCode', '');

            Sender.SetWorkflowTypeUnattended();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        SalesPersonCode: Code[10];
        LanguageCode: Code[10];
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;

        SalesPersonCode := Context.GetStringParameter('SalespersonCode', true);

        LanguageCode := Context.GetStringParameter('LanguageCode', false);
        StartSelfService(POSSession, SalesPersonCode, LanguageCode);
    end;

    procedure StartSelfService(POSSession: Codeunit "NPR POS Session"; SalespersonCode: Code[10]; LanguageCode: Code[10])
    var
        POSUnit: Record "NPR POS Unit";
        Register: Record "NPR Register";
        SalePOS: Record "NPR Sale POS";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        POSUnitIdentityRec: Record "NPR POS Unit Identity";
        UserSetup: Record "User Setup";
        Language: Record Language;
        POSSetup: Codeunit "NPR POS Setup";
        POSSale: Codeunit "NPR POS Sale";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSManagePOSUnit: Codeunit "NPR POS Manage POS Unit";
        POSUnitIdentity: Codeunit "NPR POS Unit Identity";
        POSUIManagement: Codeunit "NPR POS UI Management";
        OpeningEntryNo: Integer;
        HardwareId: Text;
        SessionName: Text;
        HostName: Text;
    begin

        DATABASE.SelectLatestVersion();
        POSSession.GetSetup(POSSetup);

        POSSession.GetSessionId(HardwareId, SessionName, HostName);
        if (HardwareId = '') then begin
            UserSetup.Get(UserId);
            UserSetup.TestField("NPR Backoffice Register No.");
            POSUnitIdentity.ConfigureTemporaryDevice(UserSetup."NPR Backoffice Register No.", POSUnitIdentityRec);
            POSSetup.InitializeUsingPosUnitIdentity(POSUnitIdentityRec);
            POSSession.InitializeSessionId(POSUnitIdentityRec."Device ID", SessionName, HostName);
        end;

        SalespersonPurchaser.Get(SalespersonCode);
        POSSetup.SetSalesperson(SalespersonPurchaser);

        POSSetup.GetPOSUnit(POSUnit);

        // possetup might have a stale version
        POSUnit.Get(POSUnit."No.");
        POSSetup.SetPOSUnit(POSUnit);
        //+NPR5.55 [405186]

        case POSUnit.Status of
            POSUnit.Status::OPEN:
                ; // Default

            POSUnit.Status::CLOSED:
                begin
                    CreateFirstTimeCheckpoint(POSUnit."No.");
                    POSManagePOSUnit.ClosePOSUnitOpenPeriods(POSUnit."No."); // make sure pos period register is correct
                    POSManagePOSUnit.OpenPOSUnit(POSUnit);
                    OpeningEntryNo := POSCreateEntry.InsertUnitOpenEntry(POSUnit."No.", POSSetup.Salesperson());
                    POSManagePOSUnit.SetOpeningEntryNo(POSUnit."No.", OpeningEntryNo);
                    POSSetup.SetPOSUnit(POSUnit);
                end;

            POSUnit.Status::EOD:
                Error('This unit is busy with another process right now. Please try again later. <br>Thank-you for your patience.');
        end;

        POSCreateEntry.InsertUnitLoginEntry(POSSetup.Register, POSSetup.Salesperson);

        if (Language.Get(LanguageCode)) then begin
            if (Language."Windows Language ID" > 0) then
                GlobalLanguage(Language."Windows Language ID");
            POSUIManagement.InitializeCaptions();
        end;

        POSSession.StartTransaction();
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.ChangeViewSale();
    end;

    local procedure CreateFirstTimeCheckpoint(UnitNo: Code[10])
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
    begin

        POSWorkshiftCheckpoint.SetFilter("POS Unit No.", '=%1', UnitNo);
        POSWorkshiftCheckpoint.SetFilter(Open, '=%1', false);
        POSWorkshiftCheckpoint.SetFilter(Type, '=%1', POSWorkshiftCheckpoint.Type::ZREPORT);

        if (POSWorkshiftCheckpoint.IsEmpty()) then begin
            POSWorkshiftCheckpoint."Entry No." := 0;
            POSWorkshiftCheckpoint."POS Unit No." := UnitNo;
            POSWorkshiftCheckpoint.Open := false;
            POSWorkshiftCheckpoint.Type := POSWorkshiftCheckpoint.Type::ZREPORT;
            POSWorkshiftCheckpoint."Created At" := CurrentDateTime();
            POSWorkshiftCheckpoint.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Session", 'OnInitializationComplete', '', false, false)]
    local procedure OnInitializationComplete(FrontEnd: Codeunit "NPR POS Front End Management")
    begin
        //Invoke POSResume codeunit to check if last exists, with manually bound subscriber?
    end;
}

