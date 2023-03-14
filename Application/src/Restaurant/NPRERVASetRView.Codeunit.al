codeunit 6150681 "NPR NPRE RVA: Set R-View" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This built-in action saves currently selected items to Waiter Pad and switches to the Restaurant View';
        ParamReturnToDefaultEndOfSaleView_CptLbl: Label 'Return To Default End Of Sale View';
        ParamReturnToDefaultEndOfSaleView_DescLbl: Label 'Specifies if default sale view will bve shown after sale end.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddBooleanParameter('ReturnToDefaultEndOfSaleView', false, ParamReturnToDefaultEndOfSaleView_CptLbl, ParamReturnToDefaultEndOfSaleView_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        SaveToWaiterPad(POSSession);
        SelectRestaurantView(POSSession, Context);
    end;

    local procedure SaveToWaiterPad(POSSession: Codeunit "NPR POS Session");
    var
        NPREWaiterPad: Record "NPR NPRE Waiter Pad";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        NPREWaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        if SalePOS."NPRE Pre-Set Waiter Pad No." = '' then
            exit;

        NPREWaiterPad.Get(SalePOS."NPRE Pre-Set Waiter Pad No.");
        NPREWaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, NPREWaiterPad, true);

        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, false);
    end;

    local procedure SelectRestaurantView(POSSession: Codeunit "NPR POS Session"; Context: Codeunit "NPR POS JSON Helper");
    var
        POSSale: Codeunit "NPR POS Sale";
        ReturnToDefaultEndOfSaleView: Boolean;
    begin
        if Context.GetBooleanParameter('ReturnToDefaultEndOfSaleView', ReturnToDefaultEndOfSaleView) and
           ReturnToDefaultEndOfSaleView then begin
            POSSession.GetSale(POSSale);
            POSSale.SelectViewForEndOfSale(POSSession);
        end else
            POSSession.ChangeViewRestaurant();
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:NPRERVASetRView.js###
'let main=async({})=>await workflow.respond();'
        );
    end;
}
