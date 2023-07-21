codeunit 6150858 "NPR POS Action: Start POS" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        POSActStartPOSB: Codeunit "NPR POS Action: Start POS B";

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
    begin
        case Step of
            'OnBeforeStartPOS':
                FrontEnd.WorkflowResponse(OnBeforeStartPOS(Setup));
            'OpenCashDrawer':
                POSActStartPOSB.OpenDrawer(Sale, Setup);
            'ConfirmBin':
                StartPOS(Context, Setup);
        end;
    end;

    local procedure OnBeforeStartPOS(Setup: codeunit "NPR POS Setup") Response: JsonObject
    var
        EoDActionCode: code[20];
        ConfirmBin: Boolean;
        BalancingIsNotAllowed: Boolean;
        BinContentsHTML: Text;
    begin
        POSActStartPOSB.BeforeStartPOS(Setup, EoDActionCode, ConfirmBin, BalancingIsNotAllowed, BinContentsHTML);

        Response.Add('EoDActionCode', EoDActionCode);
        Response.Add('ConfirmBin', ConfirmBin);
        Response.Add('BalancingIsNotAllowed', BalancingIsNotAllowed);
        Response.Add('BinContents', BinContentsHTML);
    end;

    local procedure StartPOS(Context: codeunit "NPR POS JSON Helper"; Setup: codeunit "NPR POS Setup")
    var
        BinContentsConfirmed: Boolean;
    begin
        BinContentsConfirmed := Context.GetBoolean('confirm');
        POSActStartPOSB.StartPOS(Setup, BinContentsConfirmed);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionStartPOS.js###
'let main=async({workflow:n,context:e,captions:i,popup:a})=>{debugger;const{ConfirmBin:r,BinContents:t,BalancingIsNotAllowed:o,EoDActionCode:s}=await n.respond("OnBeforeStartPOS");r&&(await n.respond("OpenCashDrawer"),e.confirm=await a.confirm({title:i.bincontenttitle,caption:t}),e.confirm?await n.respond("ConfirmBin"):o?a.error(i.BalancingIsNotAllowedError):n.run(s,{parameters:{Type:1}}))};'
        )
    end;
}
