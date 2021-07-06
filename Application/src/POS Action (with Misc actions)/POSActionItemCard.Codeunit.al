codeunit 6150827 "NPR POS Action: Item Card"
{
    var
        ActionDescription: Label 'This built in function opens the item card page for a selected sales line in the POS';

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            Sender.RegisterWorkflow(false);
            Sender.RegisterBooleanParameter('RefreshLine', true);
            Sender.RegisterBooleanParameter('PageEditable', true);
            Sender.RegisterOptionParameter('Security', 'None,SalespersonPassword,CurrentSalespersonPassword,SupervisorPassword', 'None');
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        OpenItemPage(Context, POSSession, FrontEnd);
        Handled := true;
    end;

    local procedure OpenItemPage(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LinePOS: Record "NPR POS Sale Line";
        Item: Record Item;
        CurrentView: Codeunit "NPR POS View";
        RetailItemCard: Page "Item Card";
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);
        POSSession.GetCurrentView(CurrentView);

        if (CurrentView.Type() = CurrentView.Type() ::Sale) then begin
            POSSession.GetSaleLine(POSSaleLine);
            POSSaleLine.GetCurrentSaleLine(LinePOS);
            if LinePOS.Type = LinePOS.Type::Item then begin
                if Item.Get(LinePOS."No.") then begin
                    Item.SetRecFilter();
                    RetailItemCard.Editable(JSON.GetBooleanParameter('PageEditable'));
                    RetailItemCard.SetRecord(Item);
                    RetailItemCard.RunModal();
                    if JSON.GetBooleanParameter('RefreshLine') then begin
                        LinePOS.Validate("No.");
                        LinePOS.Modify(true);
                    end;
                end;
            end;
        end;

        POSSession.RequestRefreshData();
    end;
}
