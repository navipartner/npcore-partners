codeunit 6150827 "NPR POS Action: Item Card"
{
    var
        ActionDescription: Label 'This built in function opens the item card page for a selected sales line in the POS';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode(),
              ActionDescription,
              ActionVersion(),
              Sender.Type::Generic,
              Sender."Subscriber Instances Allowed"::Multiple)
            then begin

                RegisterWorkflow(false);
                RegisterBooleanParameter('RefreshLine', true);
                RegisterBooleanParameter('PageEditable', true);
                //-NPR5.38 [289390]
                RegisterOptionParameter('Security', 'None,SalespersonPassword,CurrentSalespersonPassword,SupervisorPassword', 'None');
                //+NPR5.38 [289390]
            end;
    end;

    local procedure ActionCode(): Text
    begin

        exit('ITEMCARD');
    end;

    local procedure ActionVersion(): Text
    begin

        exit('1.2');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        Confirmed: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        OpenItemPage(Context, POSSession, FrontEnd);
        Handled := true;
    end;

    local procedure OpenItemPage(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        LinePOS: Record "NPR Sale Line POS";
        Item: Record Item;
        CurrentView: Codeunit "NPR POS View";
        RetailItemCard: Page "Item Card";
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);
        POSSession.GetCurrentView(CurrentView);

        if (CurrentView.Type = CurrentView.Type::Sale) then begin
            POSSession.GetSaleLine(POSSaleLine);
            POSSaleLine.GetCurrentSaleLine(LinePOS);
            if LinePOS.Type = LinePOS.Type::Item then begin
                if Item.Get(LinePOS."No.") then begin
                    Item.SetRecFilter;
                    RetailItemCard.Editable(JSON.GetBooleanParameter('PageEditable', false));
                    RetailItemCard.SetRecord(Item);
                    RetailItemCard.RunModal;
                    if JSON.GetBooleanParameter('RefreshLine', false) then begin
                        LinePOS.Validate("No.");
                        LinePOS.Modify(true);
                    end;
                end;
            end;
        end;

        POSSession.RequestRefreshData();
    end;
}
