codeunit 6184958 "NPR POS Action Sel Ship Method" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Select shipment method for the sales document';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'selectShipmentMethod':
                FrontEnd.WorkflowResponse(SelectionShipmentInformation(Sale, SaleLine));
        end;
    end;

    local procedure SelectionShipmentInformation(Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line") Result: JsonObject
    var
        SalePOS: Record "NPR POS Sale";
        POSActionSelShipMethodB: Codeunit "NPR POS Action Sel ShipMethodB";
        Success: Boolean;
    begin
        Sale.GetCurrentSale(SalePOS);
        Success := POSActionSelShipMethodB.SelectShipmentInformation(SalePOS, SaleLine);
        Result.Add('success', Success);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionSelShipMethod.js###
'const main=async({workflow:s})=>({success:(await s.respond("selectShipmentMethod")).success});'
        );
    end;
}
