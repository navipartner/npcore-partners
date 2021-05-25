codeunit 6150858 "NPR POS Action: Start POS"
{
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
        ReadingErr: Label 'reading in %1';
        SettingScopeErr: Label 'setting scope in %1';

    local procedure ActionCode(): Code[20]
    begin
        exit('START_POS');
    end;

    local procedure ActionVersion(): Code[10]
    begin
        exit('1.3');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            Sender.RegisterWorkflowStep('ConfirmBin', 'context.ConfirmBin && confirm ({title: labels.title, caption: context.BinContents}).no(respond());');
            Sender.RegisterWorkflow(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'title', Title);
        Captions.AddActionCaption(ActionCode(), 'balancenow', BalanceNow);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; Parameters: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        MasterPOSUnit: Record "NPR POS Unit";
        POSEndofDayProfile: Record "NPR POS End of Day Profile";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        Setup: Codeunit "NPR POS Setup";
        Context: Codeunit "NPR POS JSON Management";
        POSUnit: Record "NPR POS Unit";
        BinContentsHTML: Text;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        POSSession.GetSetup(Setup);
        Setup.GetPOSUnit(POSUnit);

        POSUnit.Get(POSUnit."No."); // refresh state

        if (POSUnit."POS End of Day Profile" <> '') then begin
            POSEndofDayProfile.Get(POSUnit."POS End of Day Profile");

            if (POSEndofDayProfile."End of Day Type" = POSEndofDayProfile."End of Day Type"::MASTER_SLAVE) then begin
                MasterPOSUnit.Get(POSEndofDayProfile."Master POS Unit No.");

                if (POSUnit."No." <> POSEndofDayProfile."Master POS Unit No.") then begin
                    if (MasterPOSUnit.Status <> MasterPOSUnit.Status::OPEN) then
                        Error(ManagedPos, MasterPOSUnit."No.", MasterPOSUnit.Name);

                    BinContentsHTML := StrSubstNo('<b>%1</b>', WorkshiftWasClosed);
                    Context.SetContext('ConfirmBin', true);
                    Context.SetContext('BinContents', BinContentsHTML);
                    FrontEnd.SetActionContext(ActionCode(), Context);
                    exit;
                end;

            end;
        end;

        Context.SetContext('ConfirmBin', true);

        POSWorkshiftCheckpoint.SetFilter("POS Unit No.", '=%1', POSUnit."No.");
        POSWorkshiftCheckpoint.SetFilter(Open, '=%1', false);
        POSWorkshiftCheckpoint.SetFilter(Type, '=%1', POSWorkshiftCheckpoint.Type::ZREPORT);
        BinContentsHTML := StrSubstNo('<b>%1</b>', FirstBalance);

        if (POSWorkshiftCheckpoint.FindLast()) then begin
            BinContentsHTML := StrSubstNo('<b>%1</b>', EmptyBin);

            POSPaymentBinCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', POSWorkshiftCheckpoint."Entry No.");
            POSPaymentBinCheckpoint.SetFilter("New Float Amount", '>%1', 0);

            if (POSPaymentBinCheckpoint.FindSet()) then begin
                BinContentsHTML := StrSubstNo('<b>%1</b><p>', Expected);
                BinContentsHTML += '<center><table border="0" cellspacing="0" width="250">';

                repeat
                    BinContentsHTML += StrSubstNo('<tr><td align="left"><b>%1:&nbsp;</b></td><td align="right"><b>&nbsp;%2</b></td></tr>',
                      POSPaymentBinCheckpoint.Description, Format(POSPaymentBinCheckpoint."New Float Amount", 0, '<Precision,2:2><Standard Format,0>'));
                until (POSPaymentBinCheckpoint.Next() = 0);

                BinContentsHTML += '</table></center>';
                BinContentsHTML += StrSubstNo('<p><b>%1</b>', ConfirmBin);
            end;
        end;

        Context.SetContext('BinContents', BinContentsHTML);
        FrontEnd.SetActionContext(ActionCode(), Context);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        POSUnit: Record "NPR POS Unit";
        POSAction: Record "NPR POS Action";
        POSViewProfile: Record "NPR POS View Profile";
        POSEndofDayProfile: Record "NPR POS End of Day Profile";
        JSON: Codeunit "NPR POS JSON Management";
        Setup: Codeunit "NPR POS Setup";
        POSOpenPOSUnit: Codeunit "NPR POS Manage POS Unit";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        EoDActionName: Text;
        OpeningEntryNo: Integer;
        BinContentsConfirmed: Boolean;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        POSSession.GetSetup(Setup);
        Setup.GetPOSUnit(POSUnit);
        POSUnit.Get(POSUnit."No."); // refresh state

        case WorkflowStep of
            'ConfirmBin':
                begin
                    JSON.SetScope('$ConfirmBin', StrSubstNo(SettingScopeErr, ActionCode()));
                    BinContentsConfirmed := JSON.GetBooleanOrFail('confirm', StrSubstNo(ReadingErr, ActionCode()));

                    if (not BinContentsConfirmed) then begin
                        if (POSUnit."POS End of Day Profile" <> '') then begin
                            POSEndofDayProfile.Get(POSUnit."POS End of Day Profile");
                            if (POSEndofDayProfile."End of Day Type" = POSEndofDayProfile."End of Day Type"::MASTER_SLAVE) then
                                if (POSEndofDayProfile."Master POS Unit No." <> POSUnit."No.") then
                                    Error(''); // This POS is managed, we dont allow balancing on this POS as an individual
                        end;

                        // *****
                        // The Magical Confirm!
                        // This is a hack and workaround. The confirm is modal in C/AL, but not to the control-addin.
                        // It will allow the current workflow step to finish in frontend, before the InvokeWorkflow executes.
                        // (Note: PAGE.RunModal() will also work)
                        // *****
                        if (Confirm(BalanceNow, true)) then begin
                            EoDActionName := 'BALANCE_V3';

                            if (not POSSession.RetrieveSessionAction(EoDActionName, POSAction)) then
                                POSAction.Get(EoDActionName);

                            POSAction.SetWorkflowInvocationParameter('Type', 1, FrontEnd);
                            FrontEnd.InvokeWorkflow(POSAction);

                        end else begin
                            Message(NotConfirmedBin);

                        end;
                    end;

                    if (BinContentsConfirmed) then begin
                        CreateFirstTimeCheckpoint(POSUnit."No.");

                        POSUnit.Get(POSUnit."No.");

                        POSOpenPOSUnit.ClosePOSUnitOpenPeriods(POSUnit."No."); // make sure pos period register is correct
                        POSOpenPOSUnit.OpenPOSUnit(POSUnit);
                        OpeningEntryNo := POSCreateEntry.InsertUnitOpenEntry(POSUnit."No.", Setup.Salesperson());
                        POSOpenPOSUnit.SetOpeningEntryNo(POSUnit."No.", OpeningEntryNo);

                        Commit();
                        PrintBeginWorkshift(POSUnit."No.");

                        // Start Sale
                        POSSession.StartTransaction();
                        //POSSession.GetSale(POSSale);
                        //POSSale.GetCurrentSale(SalePOS);
                        //POSSession.ChangeViewSale();

                        POSSession.GetSetup(Setup);
                        Setup.GetPOSViewProfile(POSViewProfile);
                        case POSViewProfile."Initial Sales View" of
                            POSViewProfile."Initial Sales View"::SALES_VIEW:
                                POSSession.ChangeViewSale();
                            POSViewProfile."Initial Sales View"::RESTAURANT_VIEW:
                                POSSession.ChangeViewRestaurant();
                        end;
                    end;
                end;
        end;
    end;

    local procedure DaysSinceLastBalance(PosUnitNo: Code[10]): Integer
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
    begin
        POSWorkshiftCheckpoint.SetFilter("POS Unit No.", '=%1', PosUnitNo);
        POSWorkshiftCheckpoint.SetFilter(Type, '=%1', POSWorkshiftCheckpoint.Type::ZREPORT);
        POSWorkshiftCheckpoint.SetFilter(Open, '=%1', false);

        if (not POSWorkshiftCheckpoint.FindLast()) then
            exit(-1); // Never been balanced

        exit(Today - DT2Date(POSWorkshiftCheckpoint."Created At"));
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

    local procedure PrintBeginWorkshift(UnitNo: Code[10])
    var
        RecRef: RecordRef;
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
    begin
        POSWorkshiftCheckpoint.SetFilter("POS Unit No.", '=%1', UnitNo);
        POSWorkshiftCheckpoint.SetFilter(Open, '=%1', false);
        POSWorkshiftCheckpoint.SetFilter(Type, '=%1', POSWorkshiftCheckpoint.Type::ZREPORT);

        if (not POSWorkshiftCheckpoint.FindLast()) then
            exit;

        ReportSelectionRetail.SetFilter("Report Type", '=%1', ReportSelectionRetail."Report Type"::"Begin Workshift (POS Entry)");
        if (not ReportSelectionRetail.FindFirst()) then
            exit;

        POSWorkshiftCheckpoint.SetFilter("Entry No.", '=%1', POSWorkshiftCheckpoint."Entry No.");
        POSWorkshiftCheckpoint.FindFirst();
        RecRef.GetTable(POSWorkshiftCheckpoint);
        RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Begin Workshift (POS Entry)");
    end;
}
