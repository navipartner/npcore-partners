codeunit 6150681 "NPR POSAction: RV Set R-View" implements "NPR IPOS Workflow"
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
        BusinessLogic: Codeunit "NPR POSAction: RV Set R-View-B";
        SalePOS: Record "NPR POS Sale";
        ResultMessageText: Text;
    begin
        Sale.GetCurrentSale(SalePOS);
        if BusinessLogic.SaveToWaiterPad(SalePOS, ResultMessageText) then begin
            Sale.Refresh(SalePOS);
            Sale.Modify(true, false);
            SelectRestaurantView(Context, Sale);
        end else begin
            Context.SetContext('ShowResultMessage', true);
            Context.SetContext('ResultMessageText', ResultMessageText);
        end;
    end;

    local procedure SelectRestaurantView(Context: Codeunit "NPR POS JSON Helper"; POSSale: Codeunit "NPR POS Sale")
    var
        POSSession: Codeunit "NPR POS Session";
        ReturnToDefaultEndOfSaleView: Boolean;
    begin
        if Context.GetBooleanParameter('ReturnToDefaultEndOfSaleView', ReturnToDefaultEndOfSaleView) and ReturnToDefaultEndOfSaleView then
            POSSale.SelectViewForEndOfSale()
        else
            POSSession.ChangeViewRestaurant();
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionRVSetRView.js###
'let main=async({context:e})=>{await workflow.respond(),e.ShowResultMessage&&popup.message(e.ResultMessageText)};'
        );
    end;
}
