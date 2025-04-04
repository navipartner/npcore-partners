codeunit 6185105 "NPR POSAction WalletAssign" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This action assign wallets to a sale line on-demand.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'GetAssignedWalletList':
                FrontEnd.WorkflowResponse(GetAssignedWalletList(Sale, SaleLine));
        end;
    end;

    local procedure GetAssignedWalletList(Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line") Response: JsonObject
    var
        WalletAssignments: Page "NPR AttractionWalletAssignment";
        WalletSaleLine: Record "NPR AttractionWalletSaleLine";
        PosSale: Record "NPR POS Sale";
        PosSaleLine: Record "NPR POS Sale Line";
        InvalidQuantity: Label 'Sale quantity must be an positive integer when assigning wallets.';
        PageAction: Action;
        Quantity: Integer;
    begin
        Sale.GetCurrentSale(PosSale);
        SaleLine.GetCurrentSaleLine(PosSaleLine);

        Quantity := Round(PosSaleLine.Quantity, 1);
        if (Quantity <> PosSaleLine.Quantity) then
            Error(InvalidQuantity);
        if (Quantity <= 0) then
            Error(InvalidQuantity);

        WalletAssignments.SetSalesContext(PosSale.SystemId, PosSaleLine.SystemId, PosSaleLine."Line No.", Quantity);
        WalletSaleLine.SetCurrentKey(SaleHeaderSystemId, LineNumber);
        WalletSaleLine.SetFilter(SaleHeaderSystemId, '=%1', PosSale.SystemId);
        WalletSaleLine.SetFilter(LineNumber, '=%1', PosSaleLine."Line No.");
        WalletAssignments.SetTableView(WalletSaleLine);
        WalletAssignments.LookupMode := false;
        WalletAssignments.Editable := true;
        PageAction := WalletAssignments.RunModal();
        if (PageAction = Action::LookupCancel) then
            Error('aborted');

        Response.Add('listOfWallets', '');
        Response.Add('frontEndUx', false);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionWalletAssign.Codeunit.js### 
'const main=async({workflow:t})=>{const{listOfWallets:s,frontEndUx:n}=await t.respond("GetAssignedWalletList",{})};'
        )
    end;

}
