codeunit 6014409 "NPR POS Action: Customer Card"
{
    Access = Internal;
    ObsoleteReason = 'Delete when final v1/v2 workflow is gone. Implemented just for customers that are not on version 10. Already exist in CU 6150801';
    ObsoleteState = Pending;
    ObsoleteTag = 'NPR23.0';

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    var
        ActionDescription: Label 'This built in function opens the customer card page for selected Customer';
    begin
#pragma warning disable AA0139
        if Sender.DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
#pragma warning restore 
        then
            Sender.RegisterWorkflow(false);
    end;

    local procedure ActionCode(): Text
    begin
        exit('CUSTOMERCARD');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.2');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
#pragma warning disable AA0139
        if not Action.IsThisAction(ActionCode()) then
            exit;
#pragma warning restore 

        OpenCustomerCardPage(Context, POSSession, FrontEnd);
        Handled := true;
    end;

    local procedure OpenCustomerCardPage(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        SalePOS: Record "NPR POS Sale";
        JSON: Codeunit "NPR POS JSON Management";
        POSSale: Codeunit "NPR POS Sale";
        Customer: Record Customer;
        CurrentView: Codeunit "NPR POS View";
        CustomerNotSelectedLbl: Label 'Customer is not selected!';
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);
        POSSession.GetCurrentView(CurrentView);

        if (CurrentView.GetType() = CurrentView.GetType() ::Sale) then begin
            POSSession.GetSale(POSSale);  //Ensure the sale still exists (haven't been seized and finished/cancelled by another session)
            POSSale.GetCurrentSale(SalePOS);
            if Customer.Get(SalePOS."Customer No.") then
                PAGE.RUN(PAGE::"Customer Card", Customer)
            else
                Message(CustomerNotSelectedLbl);
        end;
    end;

}
