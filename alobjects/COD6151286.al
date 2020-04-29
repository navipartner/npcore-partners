codeunit 6151286 "SS Action - Start SelfService"
{
    // NPR5.54/TSA /20200212 CASE 390370 Initial Version


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This built in actions starts the POS in SelfService mode';

    local procedure ActionCode(): Text
    begin

        exit ('SS-START-POS');
    end;

    local procedure ActionVersion(): Text
    begin

        exit ('1.1');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin

        with Sender do
          if DiscoverAction20(
            ActionCode(),
            ActionDescription,
            ActionVersion())
          then begin
            RegisterWorkflow20('await workflow.respond();');

            RegisterTextParameter ('SalespersonCode', '');
            SetWorkflowTypeUnattended ();
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150733, 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "POS Action";WorkflowStep: Text;Context: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session";State: Codeunit "POS Workflows 2.0 - State";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        SalesPersonCode: Code[10];
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        Handled := true;

        SalesPersonCode := Context.GetStringParameter ('SalespersonCode', true);
        StartSelfService (POSSession, SalesPersonCode);
    end;

    procedure StartSelfService(POSSession: Codeunit "POS Session";SalespersonCode: Code[10])
    var
        POSUnit: Record "POS Unit";
        Register: Record Register;
        SalePOS: Record "Sale POS";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        POSUnitIdentityRec: Record "POS Unit Identity";
        UserSetup: Record "User Setup";
        POSSetup: Codeunit "POS Setup";
        POSSale: Codeunit "POS Sale";
        POSCreateEntry: Codeunit "POS Create Entry";
        POSManagePOSUnit: Codeunit "POS Manage POS Unit";
        POSUnitIdentity: Codeunit "POS Unit Identity";
        OpeningEntryNo: Integer;
        HardwareId: Text;
        SessionName: Text;
        HostName: Text;
    begin

        POSSession.GetSetup (POSSetup);

        POSSession.GetSessionId (HardwareId, SessionName, HostName);
        if (HardwareId = '') then begin
          UserSetup.Get (UserId);
          UserSetup.TestField ("Backoffice Register No.");
          POSUnitIdentity.ConfigureTemporaryDevice (UserSetup."Backoffice Register No.", POSUnitIdentityRec);
          POSSetup.InitializeUsingPosUnitIdentity (POSUnitIdentityRec);
          POSSession.InitializeSessionId (POSUnitIdentityRec."Device ID", SessionName, HostName);
        end;

        SalespersonPurchaser.Get (SalespersonCode);
        POSSetup.SetSalesperson (SalespersonPurchaser);

        POSSetup.GetPOSUnit (POSUnit);

        case POSUnit.Status of
          POSUnit.Status::OPEN : ; // Default

          POSUnit.Status::CLOSED :
            begin
              CreateFirstTimeCheckpoint (POSUnit."No.");
              POSManagePOSUnit.ClosePOSUnitOpenPeriods (POSUnit."No."); // make sure pos period register is correct
              POSManagePOSUnit.OpenPOSUnit (POSUnit);
              OpeningEntryNo := POSCreateEntry.InsertUnitOpenEntry (POSUnit."No.", POSSetup.Salesperson());
              POSManagePOSUnit.SetOpeningEntryNo (POSUnit."No.", OpeningEntryNo);
              POSSetup.SetPOSUnit (POSUnit);
            end;

          POSUnit.Status::EOD : Error ('This unit is busy with another process right now. Please try again later. <br>Thank-you for your patience.');
        end;

        POSCreateEntry.InsertUnitLoginEntry (POSSetup.Register, POSSetup.Salesperson);

        POSSession.StartTransaction ();
        POSSession.GetSale (POSSale);
        POSSale.GetCurrentSale (SalePOS);
        POSSession.ChangeViewSale();
    end;

    local procedure CreateFirstTimeCheckpoint(UnitNo: Code[10])
    var
        POSWorkshiftCheckpoint: Record "POS Workshift Checkpoint";
    begin

        POSWorkshiftCheckpoint.SetFilter ("POS Unit No.", '=%1', UnitNo);
        POSWorkshiftCheckpoint.SetFilter (Open, '=%1', false);
        POSWorkshiftCheckpoint.SetFilter (Type, '=%1', POSWorkshiftCheckpoint.Type::ZREPORT);

        if (POSWorkshiftCheckpoint.IsEmpty ()) then begin
          POSWorkshiftCheckpoint."Entry No." := 0;
          POSWorkshiftCheckpoint."POS Unit No." := UnitNo;
          POSWorkshiftCheckpoint.Open := false;
          POSWorkshiftCheckpoint.Type := POSWorkshiftCheckpoint.Type::ZREPORT;
          POSWorkshiftCheckpoint."Created At" := CurrentDateTime ();
          POSWorkshiftCheckpoint.Insert ();
        end;
    end;
}

