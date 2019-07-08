codeunit 6150858 "POS Action - Start POS"
{
    // NPR5.46/TSA /20181004 CASE 328338 Initial Version
    // NPR5.48/TSA /20181120 CASE 336921 Open a new period on confirm bin
    // NPR5.49/TSA /20190313 CASE 348458 Check state of master POS when its a managed POS
    // NPR5.50/TSA /20190403 CASE 350974 Make sure the unit is open prior to logging the open event (empty table issue)
    // NPR5.50/TSA /20190423 CASE 352483 Printing a receipt on begin workshift


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This action is executed when the POS Unit is in status closed, to verify BIN contents.';
        Title: Label 'Confirm Bin Contents.';
        BalanceNow: Label 'Do you want to balance the bin now?';
        NotConfirmedBin: Label 'Unless you confirm the bin contents, you must balance the bin, before you open it.';
        FirstBalance: Label 'The payment bin has never been balanced. Do you want to open POS without balancing the bin?';
        EmptyBin: Label 'The payment bin should be empty.';
        Expected: Label 'The payment bin contains:';
        WorkshiftWasClosed: Label 'The workshift was closed. Do you want to open a new workshift?';
        ConfirmBin: Label 'Do you agree?';
        ManagedPos: Label 'This POS is managed by POS Unit %1 [%2] and it is therefore required that %1 is opened prior to opening this POS.';

    local procedure ActionCode(): Code[20]
    begin

        exit ('START_POS');
    end;

    local procedure ActionVersion(): Code[10]
    begin

        exit ('1.3');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin

        with Sender do
          if DiscoverAction(
            ActionCode (),
            ActionDescription,
            ActionVersion (),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
          then begin

            RegisterWorkflowStep ('ConfirmBin', 'context.ConfirmBin && confirm ({title: labels.title, caption: context.BinContents}).no(respond());');
            RegisterWorkflow (true);

          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    var
        RetailSetup: Record "Retail Setup";
    begin

        Captions.AddActionCaption (ActionCode, 'title', Title);
        Captions.AddActionCaption (ActionCode, 'balancenow', BalanceNow);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "POS Action";Parameters: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        MasterPOSUnit: Record "POS Unit";
        POSEndofDayProfile: Record "POS End of Day Profile";
        POSWorkshiftCheckpoint: Record "POS Workshift Checkpoint";
        POSPaymentBinCheckpoint: Record "POS Payment Bin Checkpoint";
        Setup: Codeunit "POS Setup";
        Context: Codeunit "POS JSON Management";
        POSUnit: Record "POS Unit";
        BinContentsHTML: Text;
    begin

        if not Action.IsThisAction(ActionCode) then
          exit;

        Handled := true;

        POSSession.GetSetup (Setup);
        Setup.GetPOSUnit (POSUnit);

        //-NPR5.49 [348458]
        POSUnit.Get (POSUnit."No."); // refresh state

        if (POSUnit."POS End of Day Profile" <> '') then begin
          POSEndofDayProfile.Get (POSUnit."POS End of Day Profile");

          if (POSEndofDayProfile."End of Day Type" = POSEndofDayProfile."End of Day Type"::MASTER_SLAVE) then begin
            MasterPOSUnit.Get (POSEndofDayProfile."Master POS Unit No.");

            if (POSUnit."No." <> POSEndofDayProfile."Master POS Unit No.") then begin
              if (MasterPOSUnit.Status <> MasterPOSUnit.Status::OPEN) then
                Error (ManagedPos, MasterPOSUnit."No.", MasterPOSUnit.Name);

              BinContentsHTML := StrSubstNo ('<b>%1</b>', WorkshiftWasClosed);
              Context.SetContext ('ConfirmBin', true);
              Context.SetContext ('BinContents', BinContentsHTML);
              FrontEnd.SetActionContext (ActionCode, Context);
              exit;
            end;

          end;
        end;
        //+NPR5.49 [348458]

        //-NPR5.49 [348458]
        // POSUnit.Status := POSUnit.Status::CLOSED;
        // Context.SetContext ('ConfirmBin', (POSUnit.Status = POSUnit.Status::CLOSED));
        // BinContentsHTML := '';
        //
        // IF (POSUnit.Status = POSUnit.Status::CLOSED) THEN BEGIN

        Context.SetContext ('ConfirmBin', true);
        //+NPR5.49 [348458]

        POSWorkshiftCheckpoint.SetFilter ("POS Unit No.", '=%1', POSUnit."No.");
        POSWorkshiftCheckpoint.SetFilter (Open, '=%1', false);
        POSWorkshiftCheckpoint.SetFilter (Type, '=%1', POSWorkshiftCheckpoint.Type::ZREPORT);
        BinContentsHTML := StrSubstNo ('<b>%1</b>', FirstBalance);

        if (POSWorkshiftCheckpoint.FindLast ()) then begin
          BinContentsHTML := StrSubstNo ('<b>%1</b>', EmptyBin);

          POSPaymentBinCheckpoint.SetFilter ("Workshift Checkpoint Entry No.", '=%1', POSWorkshiftCheckpoint."Entry No.");
          POSPaymentBinCheckpoint.SetFilter ("New Float Amount", '>%1', 0);

          if (POSPaymentBinCheckpoint.FindSet ()) then begin
            BinContentsHTML := StrSubstNo ('<b>%1</b><p>', Expected);
            //-NPR5.50 [352483]
            //BinContentsHTML += '<center><table border="0" cellspacing="0" width="150">';
            BinContentsHTML += '<center><table border="0" cellspacing="0" width="250">';
            //+NPR5.50 [352483]

            repeat
              BinContentsHTML += StrSubstNo ('<tr><td align="left"><b>%1:&nbsp;</b></td><td align="right"><b>&nbsp;%2</b></td></tr>',
                POSPaymentBinCheckpoint.Description, Format (POSPaymentBinCheckpoint."New Float Amount", 0, '<Precision,2:2><Standard Format,0>'));
            until (POSPaymentBinCheckpoint.Next () = 0);

            BinContentsHTML += '</table></center>';
            BinContentsHTML += StrSubstNo ('<p><b>%1</b>', ConfirmBin);

          end;
        end;

        // END


        Context.SetContext ('BinContents', BinContentsHTML);
        FrontEnd.SetActionContext (ActionCode, Context);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        POSUnit: Record "POS Unit";
        POSAction: Record "POS Action";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SalePOS: Record "Sale POS";
        POSEndofDayProfile: Record "POS End of Day Profile";
        JSON: Codeunit "POS JSON Management";
        Setup: Codeunit "POS Setup";
        POSSale: Codeunit "POS Sale";
        POSOpenPOSUnit: Codeunit "POS Manage POS Unit";
        POSCreateEntry: Codeunit "POS Create Entry";
        EoDActionName: Text;
        OpeningEntryNo: Integer;
        BinContentsConfirmed: Boolean;
    begin

        if not Action.IsThisAction(ActionCode) then
          exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context,FrontEnd);

        POSSession.GetSetup (Setup);
        Setup.GetPOSUnit (POSUnit);
        //-NPR5.49 [348458]
        POSUnit.Get (POSUnit."No."); // refresh state
        //+NPR5.49 [348458]

        case WorkflowStep of
          'ConfirmBin' : begin

            JSON.SetScope('$ConfirmBin', true);
            BinContentsConfirmed := JSON.GetBoolean('confirm', true);

            if (not BinContentsConfirmed) then begin

              //-NPR5.49 [348458]
              if (POSUnit."POS End of Day Profile" <> '') then begin
                POSEndofDayProfile.Get (POSUnit."POS End of Day Profile");
                if (POSEndofDayProfile."End of Day Type" = POSEndofDayProfile."End of Day Type"::MASTER_SLAVE) then
                  if (POSEndofDayProfile."Master POS Unit No." <> POSUnit."No.") then
                    Error (''); // This POS is managed, we dont allow balancing on this POS as an individual
              end;
              //+NPR5.49 [348458]

              // *****
              // The Magical Confirm!
              // This is a hack and workaround. The confirm is modal in C/AL, but not to the control-addin.
              // It will allow the current workflow step to finish in frontend, before the InvokeWorkflow executes.
              // (Note: PAGE.RUNMODAL will also work)
              // *****
              if (Confirm (BalanceNow, true)) then begin
                EoDActionName := 'BALANCE_V3';

                if (not POSSession.RetrieveSessionAction (EoDActionName, POSAction)) then
                  POSAction.Get (EoDActionName);

                POSAction.SetWorkflowInvocationParameter ('Type', 1, FrontEnd);
                FrontEnd.InvokeWorkflow (POSAction);

              end else begin
                Message (NotConfirmedBin);

              end;
            end;

            if (BinContentsConfirmed) then begin
              CreateFirstTimeCheckpoint (POSUnit."No.");

              POSUnit.Get (POSUnit."No.");

              //-NPR5.48 [336921]
              //POSUnit.Status := POSUnit.Status::OPEN;
              //POSUnit.MODIFY ();

              //-NPR5.50 [350974]
              // OpeningEntryNo := POSCreateEntry.InsertUnitOpenEntry (POSUnit."No.", Setup.Salesperson());
              // POSOpenPOSUnit.OpenPosUnitNoWithPeriodEntryNo (POSUnit."No.", OpeningEntryNo);
              POSOpenPOSUnit.ClosePOSUnitOpenPeriods (POSUnit."No."); // make sure pos period register is correct
              POSOpenPOSUnit.OpenPOSUnit (POSUnit);
              OpeningEntryNo := POSCreateEntry.InsertUnitOpenEntry (POSUnit."No.", Setup.Salesperson());
              POSOpenPOSUnit.SetOpeningEntryNo (POSUnit."No.", OpeningEntryNo);
              //+NPR5.50 [350974]
              //+NPR5.48 [336921]

              Commit;
              //-NPR5.50 [352483]
              PrintBeginWorkshift (POSUnit."No.");
              //+NPR5.50 [352483]

              // Start Sale
              POSSession.StartTransaction ();
              POSSession.GetSale (POSSale);
              POSSale.GetCurrentSale (SalePOS);
              POSSession.ChangeViewSale();
            end;

          end;
        end;
    end;

    local procedure "--"()
    begin
    end;

    local procedure DaysSinceLastBalance(PosUnitNo: Code[10]): Integer
    var
        POSWorkshiftCheckpoint: Record "POS Workshift Checkpoint";
    begin

        POSWorkshiftCheckpoint.SetFilter ("POS Unit No.", '=%1', PosUnitNo);
        POSWorkshiftCheckpoint.SetFilter (Type, '=%1', POSWorkshiftCheckpoint.Type::ZREPORT);
        POSWorkshiftCheckpoint.SetFilter (Open, '=%1', false);

        if (not POSWorkshiftCheckpoint.FindLast ()) then
          exit (-1); // Never been balanced

        exit (Today - DT2Date (POSWorkshiftCheckpoint."Created At"));
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

    local procedure PrintBeginWorkshift(UnitNo: Code[10])
    var
        RecRef: RecordRef;
        POSWorkshiftCheckpoint: Record "POS Workshift Checkpoint";
        ReportSelectionRetail: Record "Report Selection Retail";
        RetailReportSelectionMgt: Codeunit "Retail Report Selection Mgt.";
    begin

        //-NPR5.50 [352483]
        POSWorkshiftCheckpoint.SetFilter ("POS Unit No.", '=%1', UnitNo);
        POSWorkshiftCheckpoint.SetFilter (Open, '=%1', false);
        POSWorkshiftCheckpoint.SetFilter (Type, '=%1', POSWorkshiftCheckpoint.Type::ZREPORT);

        if (not POSWorkshiftCheckpoint.FindLast ()) then
          exit;

        ReportSelectionRetail.SetFilter ("Report Type", '=%1', ReportSelectionRetail."Report Type"::"Begin Workshift (POS Entry)");
        if (not ReportSelectionRetail.FindFirst ()) then
          exit;

        POSWorkshiftCheckpoint.SetFilter ("Entry No.", '=%1', POSWorkshiftCheckpoint."Entry No.");
        POSWorkshiftCheckpoint.FindFirst ();
        RecRef.GetTable (POSWorkshiftCheckpoint);
        RetailReportSelectionMgt.RunObjects (RecRef, ReportSelectionRetail."Report Type"::"Begin Workshift (POS Entry)");
        //+NPR5.50 [352483]
    end;
}

