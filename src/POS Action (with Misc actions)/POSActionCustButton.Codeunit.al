codeunit 6150730 "NPR POSAction: Cust. Button"
{
    // NPR5.39/TSA /20171207 CASE 298936 Made the actual implementation


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built-in action for setting a customer on the current transaction';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode,
          ActionDescription,
          ActionVersion,
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Single)
        then begin
            Sender.RegisterWorkflow(false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR Sale POS";
        CustomerNo: Code[20];
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScope('parameters', true);
        CustomerNo := JSON.GetString('customerNo', true);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
        SalePOS."Customer No." := '';
        SalePOS.Validate("Customer No.", CustomerNo);

        POSSale.Refresh(SalePOS);
        POSSale.Modify(false, false);

        POSSession.RequestRefreshData;
    end;

    local procedure ActionCode(): Text
    begin

        exit('CUSTOMER');
    end;

    local procedure ActionVersion(): Text
    begin

        exit('1.0');
    end;
}

