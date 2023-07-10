codeunit 6150681 "NPR NPRE RVA: Set R-View" implements "NPR IPOS Workflow"
{
    Access = Internal;

    internal procedure ActionCode(): Code[20]
    begin
        exit(Format("NPR POS Workflow"::"RV_SET_R-VIEW"));
    end;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This built-in action saves currently selected items to Waiter Pad and switches to the Restaurant View';
        ParamReturnToDefaultEndOfSaleView_CptLbl: Label 'Use Default End Of Sale View';
        ParamReturnToDefaultEndOfSaleView_DescLbl: Label 'Specifies if system should switch to the default end of sale view set up for current POS unit instead of the restaurant view after saving the sale to waiter pad.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddBooleanParameter('ReturnToDefaultEndOfSaleView', false, ParamReturnToDefaultEndOfSaleView_CptLbl, ParamReturnToDefaultEndOfSaleView_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        if SaveToWaiterPad(POSSession, Context) then
            SelectRestaurantView(POSSession, Context);
    end;

    local procedure SaveToWaiterPad(POSSession: Codeunit "NPR POS Session"; Context: Codeunit "NPR POS JSON Helper"): Boolean
    var
        SalePOS: Record "NPR POS Sale";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        POSSale: Codeunit "NPR POS Sale";
        NPREWaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        SaleCleanupSuccessful: Boolean;
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        if SalePOS."NPRE Pre-Set Waiter Pad No." = '' then
            exit(true);

        WaiterPad.Get(SalePOS."NPRE Pre-Set Waiter Pad No.");
        SaleCleanupSuccessful := NPREWaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, WaiterPad, true);
        if not SaleCleanupSuccessful then begin
            Context.SetContext('ShowResultMessage', true);
            Context.SetContext('ResultMessageText', NPREWaiterPadPOSMgt.UnableToCleanupSaleMsgText(false));
        end;

        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, false);

        exit(SaleCleanupSuccessful);
    end;

    local procedure SelectRestaurantView(POSSession: Codeunit "NPR POS Session"; Context: Codeunit "NPR POS JSON Helper")
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
'let main=async({context:e})=>{await workflow.respond(),e.ShowResultMessage&&popup.message(e.ResultMessageText)};'
        );
    end;
}
