codeunit 6151540 "NPR CMPOSActionTourPickup" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescriptionLbl: Label 'Pick up a booking: find it by the defined search terms. An unpaid booking is added to the sale and confirmed when the sale ends; a confirmed booking has its wallets printed.';
        TitleLbl: Label 'Pick Up Booking';
        SearchCaptionLbl: Label 'Booking reference, customer no. or email';
    begin
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
        WorkflowConfig.AddLabel('title', TitleLbl);
        WorkflowConfig.AddLabel('searchCaption', SearchCaptionLbl);
        WorkflowConfig.AddJavascript(GetActionScript());
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        PickupB: Codeunit "NPR CMPOSActionTourPickupB";
    begin
        case Step of
            'pickup':
                PickupB.PickupOrder(Context.GetString('search'), Sale, SaleLine);
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
            //###NPR_INJECT_FROM_FILE:CMPOSActionTourPickup.js###
            'const main=async({workflow:e,popup:t,captions:a})=>{const c=await t.input({title:a.title,caption:a.searchCaption});c!=null&&await e.respond("pickup",{search:c})};'
        );
    end;
}
