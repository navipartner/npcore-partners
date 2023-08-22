codeunit 6014600 "NPR POS Action: EndOfDay V4" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        ActionDescription: Label 'Balance the POS at the end of day.';

    procedure Register(Workflow: Codeunit "NPR POS Workflow Config")
    var
        TypeCaption: Label 'End of Day Type';
        TypeOptions: Label 'X-Report (prel),Z-Report (final),Close Workshift', Locked = true;
        TypeOptionCaptions: Label 'X-Report - preliminary,Z-Report - final,Close Workshift - closed but not counted';
        TypeDefaultOption: Label 'X-Report (prel)', Locked = true;
        TypeOptionDescription: Label 'Type defines the type end-of-day operation is requested.';
        OpenCashDrawerCaption: Label 'Auto-Open Cash Drawer';
        OpenCashDrawerDescription: Label 'Auto-Open Payment Bin No. when counting starts.';
        PaymentBinCaption: Label 'Payment Bin No.';
        PaymentBinDescription: Label 'The bin to open before the counting starts.';
    begin
        Workflow.AddJavascript(GetActionScript());
        Workflow.AddActionDescription(ActionDescription);
        Workflow.AddOptionParameter('Type', TypeOptions, TypeDefaultOption, TypeCaption, TypeOptionDescription, TypeOptionCaptions);
        Workflow.AddBooleanParameter('Auto-Open Cash Drawer', false, OpenCashDrawerCaption, OpenCashDrawerDescription);
        Workflow.AddTextParameter('Cash Drawer No.', '', PaymentBinCaption, PaymentBinDescription);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup")
    var
        EndOfDayWorker: Codeunit "NPR End Of Day Worker";
        POSWorkShiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        EndOfDayType: Option "X-Report","Z-Report",CloseWorkShift;
        SalePOS: Record "NPR POS Sale";
        CashDrawerNo: Code[10];
        EntryNo: Integer;
    begin

        EndOfDayType := Context.GetIntegerParameter('Type');
        CashDrawerNo := CopyStr(Context.GetStringParameter('Cash Drawer No.'), 1, MaxStrLen(CashDrawerNo));

        Sale.GetCurrentSale(SalePOS);

        case Step of
            'ValidateRequirements':
                EndOfDayWorker.ValidateRequirements(Setup.GetPOSUnitNo(), SalePOS."Sales Ticket No.");
            'DiscoverEftIntegrationsForEndOfDay':
                FrontEnd.WorkflowResponse(EndOfDayWorker.DiscoverEftIntegrationsForEndOfDay(EndOfDayType));
            'OpenCashDrawer':
                EndOfDayWorker.OpenDrawer(CashDrawerNo, Setup.GetPOSUnitNo(), SalePOS);
            'DoEndOfDay':
                begin
                    EntryNo := EndOfDayWorker.CalculateEndOfDay(EndOfDayType, Setup, Sale, Setup.GetPOSUnitNo());
                    if (POSWorkShiftCheckpoint.Get(EntryNo)) then
                        FrontEnd.WorkflowResponse(EndOfDayWorker.SwitchView(FrontEnd, EndOfDayType, POSWorkShiftCheckpoint));
                end;
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionEndOfDayV4.Codeunit.js###
'let main=async({workflow:a,popup:s,scope:o,parameters:t})=>{const r=t["Auto-Open Cash Drawer"];await a.respond("ValidateRequirements");let n=await a.respond("DiscoverEftIntegrationsForEndOfDay");debugger;for(var e=0;e<n.length;e++)await a.run(n[e].WorkflowName,{context:n[e]});r&&await a.respond("OpenCashDrawer"),await a.respond("DoEndOfDay")};'
        );
    end;

}

