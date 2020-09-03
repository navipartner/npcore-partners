codeunit 6151286 "NPR SS Action: Start SelfServ."
{
    // NPR5.54/TSA /20200212 CASE 390370 Initial Version
    // NPR5.55/TSA /20200520 CASE 405186 Added localization support


    trigger OnRun()
    begin
    end;

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

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin

        with Sender do
            if DiscoverAction20(
              ActionCode(),
              ActionDescription,
              ActionVersion())
            then begin
                RegisterWorkflow20('await workflow.respond();');

                RegisterTextParameter('SalespersonCode', '');
                //-NPR5.55 [405186]
                RegisterTextParameter('LanguageCode', '');
                //+NPR5.55 [405186]

                SetWorkflowTypeUnattended();
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150733, 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        SalesPersonCode: Code[10];
        LanguageCode: Code[10];
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;

        SalesPersonCode := Context.GetStringParameter('SalespersonCode', true);

        //-NPR5.55 [405186]
        //StartSelfService (POSSession, SalesPersonCode);

        LanguageCode := Context.GetStringParameter('LanguageCode', false);
        StartSelfService(POSSession, SalesPersonCode, LanguageCode);
        //+NPR5.55 [405186]
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

        DATABASE.SelectLatestVersion(); //-+NPR5.55 [405186]
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

        //-NPR5.55 [405186] possetup might have a stale version
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

        //-NPR5.55 [405186]
        if (Language.Get(LanguageCode)) then begin
            if (Language."Windows Language ID" > 0) then
                GlobalLanguage(Language."Windows Language ID");
            POSUIManagement.InitializeCaptions();
        end;
        //+NPR5.55 [405186]

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

    [EventSubscriber(ObjectType::Codeunit, 6150700, 'OnInitializationComplete', '', false, false)]
    local procedure OnInitializationComplete(FrontEnd: Codeunit "NPR POS Front End Management")
    begin
        //-NPR5.55 [398235]
        //Invoke POSResume codeunit to check if last exists, with manually bound subscriber?
        //+NPR5.55 [398235]
    end;
}

