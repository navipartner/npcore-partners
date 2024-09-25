codeunit 6150687 "NPR POSAction: RV Select Table" implements "NPR IPOS Workflow"
{
    Access = Internal;

    internal procedure ActionCode(): Code[20]
    begin
        exit(Format("NPR POS Workflow"::RV_SELECT_TABLE));
    end;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This built-in action can be run when a table is selected in Restaurant View.';
        ParamSeatingCode_CptLbl: Label 'Seating Code';
        ParamSeatingCode_DescLbl: Label 'Selected seating code.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddTextParameter('SeatingCode', '', ParamSeatingCode_CptLbl, ParamSeatingCode_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        NewWaiterPadActionParams: JsonObject;
        NewWaiterPadActionCode: Code[20];
        SeatingCode: Code[20];
    begin
        case Step of
            'SelectWaiterPad':
                begin
                    SeatingCode := CopyStr(Context.GetStringParameter('SeatingCode'), 1, MaxStrLen(SeatingCode));
                    Seating.Get(SeatingCode);

                    SeatingWaiterPadLink.SetCurrentKey(Closed);
                    SeatingWaiterPadLink.SetRange("Seating Code", Seating.Code);
                    SeatingWaiterPadLink.SetRange(Closed, false);
                    if SeatingWaiterPadLink.IsEmpty then begin
                        GetNewWaiterPadAction(SeatingCode, NewWaiterPadActionCode, NewWaiterPadActionParams);
                        Context.SetContext('newWaiterPadActionCode', NewWaiterPadActionCode);
                        Context.SetContext('newWaiterPadActionParams', NewWaiterPadActionParams);
                        FrontEnd.WorkflowResponse(false);
                        exit;
                    end;

                    if WaiterPadPOSMgt.SelectWaiterPad(Seating, WaiterPad) then begin
                        Context.SetContext('waiterPadNo', WaiterPad."No.");
                        FrontEnd.WorkflowResponse(true);
                    end else
                        Error('');
                end;
        end;
    end;

    local procedure GetNewWaiterPadAction(SeatingCode: Code[20]; var NewWaiterPadActionCode: Code[20]; var NewWaiterPadActionParams: JsonObject)
    var
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        ParamMgt: Codeunit "NPR POS Action Param. Mgt.";
        NewWaiterPadActionParamsJT: JsonToken;
    begin
        RestaurantSetup.Get();
        RestaurantSetup.TestField("New Waiter Pad Action");
        NewWaiterPadActionCode := RestaurantSetup."New Waiter Pad Action";

        NewWaiterPadActionParams := ParamMgt.GetParametersAsJsonObject(RestaurantSetup.RecordId(), RestaurantSetup.FieldNo("New Waiter Pad Action"));
        NewWaiterPadActionParams.Get('parameters', NewWaiterPadActionParamsJT);
        if NewWaiterPadActionParamsJT.AsObject().Contains('SeatingCode') then
            NewWaiterPadActionParamsJT.AsObject().Remove('SeatingCode');
        NewWaiterPadActionParamsJT.AsObject().Add('SeatingCode', SeatingCode);
        if NewWaiterPadActionParamsJT.AsObject().Contains('SwitchToSaleView') then
            NewWaiterPadActionParamsJT.AsObject().Remove('SwitchToSaleView');
        NewWaiterPadActionParamsJT.AsObject().Add('SwitchToSaleView', true);
        Clear(NewWaiterPadActionParams);
        NewWaiterPadActionParams.Add('parameters', NewWaiterPadActionParamsJT.AsObject());
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionRVSelectTable.js###
'let main=async({workflow:a,context:e})=>{await a.respond("SelectWaiterPad")?await a.run("RV_GET_WAITER_PAD",{parameters:{WaiterPadCode:e.waiterPadNo}}):await a.run(e.newWaiterPadActionCode,e.newWaiterPadActionParams)};'
        );
    end;
}
