codeunit 6150858 "NPR POS Action: Start POS" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        FirstBalance: Label 'The payment bin has never been balanced. Do you want to open POS without balancing the bin?';
        EmptyBin: Label 'The payment bin should be empty.';
        Expected: Label 'The payment bin contains:';
        WorkshiftWasClosed: Label 'The workshift was closed. Do you want to open a new workshift?';
        ConfirmBin: Label 'Do you agree?';
        ManagedPos: Label 'This POS is managed by POS Unit %1 [%2] and it is therefore required that %1 is opened prior to opening this POS.';

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This action is executed when the POS Unit is in status closed, to verify BIN contents.';
        BinContentTitleLbl: Label 'Confirm Bin Contents.';
        BinBalanceTitleLbl: Label 'Balance Bin.';
        BalancingIsNotAllowedErrorLbl: Label 'This POS is managed, balancing on this POS as an individual is not allowed!';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('bincontenttitle', BinContentTitleLbl);
        WorkflowConfig.AddLabel('binbalancetitle', BinBalanceTitleLbl);
        WorkflowConfig.AddLabel('BalancingIsNotAllowedError', BalancingIsNotAllowedErrorLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        case Step of
            'OnBeforeStartPOS':
                FrontEnd.WorkflowResponse(OnBeforeStartPOS(POSSession));
            'OpenCashDrawer':
                OpenDrawer(Sale, Setup);
            'ConfirmBin':
                StartPOS(Context, POSSession, Setup);
        end;
    end;

    local procedure OpenDrawer(Sale: codeunit "NPR POS Sale"; Setup: codeunit "NPR POS Setup")
    var
        EndOfDayWorker: Codeunit "NPR End Of Day Worker";
        SalePOS: Record "NPR POS Sale";
    begin
        Sale.GetCurrentSale(SalePOS);
        EndOfDayWorker.OpenDrawer(' ', Setup.GetPOSUnitNo(), SalePOS);
    end;

    local procedure OnBeforeStartPOS(POSSession: Codeunit "NPR POS Session") Response: JsonObject
    var
        MasterPOSUnit: Record "NPR POS Unit";
        POSEndofDayProfile: Record "NPR POS End of Day Profile";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        POSUnit: Record "NPR POS Unit";
        Setup: Codeunit "NPR POS Setup";
        EoDActionCode: Code[20];
        BalancingIsNotAllowed: Boolean;
        BinContentsHTML: Text;
        BinContentsHTMLLbl: Label '<b>%1</b>', Locked = true;
        BinContentsHTML2Lbl: Label '<b>%1</b>', Locked = true;
        BinContentsHTML3Lbl: Label '<b>%1</b>', Locked = true;
        BinContentsHTML4Lbl: Label '<b>%1</b><p>', Locked = true;
        BinContentsHTML5Lbl: Label '<tr><td align="left"><b>%1:&nbsp;</b></td><td align="right"><b>&nbsp;%2</b></td></tr>', Locked = true;
        BinContentsHTML6Lbl: Label '<p><b>%1</b>', Locked = true;
    begin
        POSSession.GetSetup(Setup);
        Setup.GetPOSUnit(POSUnit);
        POSUnit.Get(POSUnit."No."); // refresh state

        EoDActionCode := Setup.ActionCode_EndOfDay();
        Response.Add('EoDActionCode', EoDActionCode);

        if (POSUnit."POS End of Day Profile" <> '') then begin
            POSEndofDayProfile.Get(POSUnit."POS End of Day Profile");
            if (POSEndofDayProfile."End of Day Type" = POSEndofDayProfile."End of Day Type"::MASTER_SLAVE) then begin
                BalancingIsNotAllowed := (POSEndofDayProfile."Master POS Unit No." <> POSUnit."No.");
                MasterPOSUnit.Get(POSEndofDayProfile."Master POS Unit No.");

                if (POSUnit."No." <> POSEndofDayProfile."Master POS Unit No.") then begin
                    if (MasterPOSUnit.Status <> MasterPOSUnit.Status::OPEN) then
                        Error(ManagedPos, MasterPOSUnit."No.", MasterPOSUnit.Name);

                    BinContentsHTML := StrSubstNo(BinContentsHTMLLbl, WorkshiftWasClosed);
                    Response.Add('ConfirmBin', true);
                    Response.Add('BinContents', BinContentsHTML);
                    Response.Add('BalancingIsNotAllowed', BalancingIsNotAllowed);
                    exit;
                end;
            end;
        end;

        Response.Add('BalancingIsNotAllowed', BalancingIsNotAllowed);
        Response.Add('ConfirmBin', true);

        POSWorkshiftCheckpoint.SetRange("POS Unit No.", POSUnit."No.");
        POSWorkshiftCheckpoint.SetRange(Open, false);
        POSWorkshiftCheckpoint.SetRange(Type, POSWorkshiftCheckpoint.Type::ZREPORT);
        BinContentsHTML := StrSubstNo(BinContentsHTML2Lbl, FirstBalance);

        if (POSWorkshiftCheckpoint.FindLast()) then begin
            BinContentsHTML := StrSubstNo(BinContentsHTML3Lbl, EmptyBin);

            POSPaymentBinCheckpoint.SetRange("Workshift Checkpoint Entry No.", POSWorkshiftCheckpoint."Entry No.");
            POSPaymentBinCheckpoint.SetFilter("New Float Amount", '>%1', 0);

            if (POSPaymentBinCheckpoint.FindSet()) then begin
                BinContentsHTML := StrSubstNo(BinContentsHTML4Lbl, Expected);
                BinContentsHTML += '<center><table border="0" cellspacing="0" width="250">';

                repeat
                    BinContentsHTML += StrSubstNo(BinContentsHTML5Lbl,
                      POSPaymentBinCheckpoint.Description, Format(POSPaymentBinCheckpoint."New Float Amount", 0, '<Precision,2:2><Standard Format,0>'));
                until (POSPaymentBinCheckpoint.Next() = 0);

                BinContentsHTML += '</table></center>';
                BinContentsHTML += StrSubstNo(BinContentsHTML6Lbl, ConfirmBin);
            end;
        end;

        Response.Add('BinContents', BinContentsHTML);
    end;

    local procedure StartPOS(Context: codeunit "NPR POS JSON Helper"; POSSession: Codeunit "NPR POS Session"; Setup: codeunit "NPR POS Setup")
    var
        POSUnit: Record "NPR POS Unit";
        POSViewProfile: Record "NPR POS View Profile";
        POSOpenPOSUnit: Codeunit "NPR POS Manage POS Unit";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        OpeningEntryNo: Integer;
        BinContentsConfirmed: Boolean;
    begin
        POSSession.GetSetup(Setup);
        Setup.GetPOSUnit(POSUnit);
        POSUnit.Get(POSUnit."No."); // refresh state

        BinContentsConfirmed := Context.GetBoolean('confirm');

        if (BinContentsConfirmed) then begin
            CreateFirstTimeCheckpoint(POSUnit."No.");

            POSUnit.Get(POSUnit."No.");

            POSOpenPOSUnit.ClosePOSUnitOpenPeriods(POSUnit."POS Store Code", POSUnit."No."); // make sure pos period register is correct
            POSOpenPOSUnit.OpenPOSUnit(POSUnit);
            OpeningEntryNo := POSCreateEntry.InsertUnitOpenEntry(POSUnit."No.", Setup.Salesperson());
            POSOpenPOSUnit.SetOpeningEntryNo(POSUnit."No.", OpeningEntryNo);

            Commit();
            PrintBeginWorkshift(POSUnit."No.");

            // Start Sale
            POSSession.StartTransaction();

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

    local procedure CreateFirstTimeCheckpoint(UnitNo: Code[10])
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
    begin
        POSWorkshiftCheckpoint.SetRange("POS Unit No.", UnitNo);
        POSWorkshiftCheckpoint.SetRange(Open, false);
        POSWorkshiftCheckpoint.SetRange(Type, POSWorkshiftCheckpoint.Type::ZREPORT);

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
        POSWorkshiftCheckpoint.SetRange("POS Unit No.", UnitNo);
        POSWorkshiftCheckpoint.SetRange(Open, false);
        POSWorkshiftCheckpoint.SetRange(Type, POSWorkshiftCheckpoint.Type::ZREPORT);

        if (not POSWorkshiftCheckpoint.FindLast()) then
            exit;

        ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Begin Workshift (POS Entry)");
        if (not ReportSelectionRetail.FindFirst()) then
            exit;

        POSWorkshiftCheckpoint.SetRange("Entry No.", POSWorkshiftCheckpoint."Entry No.");
        POSWorkshiftCheckpoint.FindFirst();
        RecRef.GetTable(POSWorkshiftCheckpoint);
        RetailReportSelectionMgt.RunObjects(RecRef, "NPR Report Selection Type"::"Begin Workshift (POS Entry)".AsInteger());
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionStartPOS.js###
'let main=async({workflow:n,context:e,captions:i,popup:a})=>{debugger;const{ConfirmBin:r,BinContents:t,BalancingIsNotAllowed:o,EoDActionCode:s}=await n.respond("OnBeforeStartPOS");r&&(await n.respond("OpenCashDrawer"),e.confirm=await a.confirm({title:i.bincontenttitle,caption:t}),e.confirm?await n.respond("ConfirmBin"):o?a.error(i.BalancingIsNotAllowedError):n.run(s,{parameters:{Type:1}}))};'
        )
    end;
}
