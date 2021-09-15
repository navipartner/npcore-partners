codeunit 6150828 "NPR POS Action: ItemInv Overv."
{
    var
        ActionDescription: Label 'This built in function opens a page displaying the item inventory per location and variant.';
        Title: Label 'Item Card';
        NotAllowed: Label 'Cannot open the Item Inventory Overview for this line.';

    local procedure ActionCode(): Code[20]
    begin
        exit('ITEMINVOV');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.1');
    end;

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
            Sender.RegisterBooleanParameter(AllItemsParTxt(), false);
            Sender.RegisterBooleanParameter(OnlyCurrentLocParTxt(), false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        OpenItemInventoryOverviewPage(Context, POSSession, FrontEnd);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'title', Title);
        Captions.AddActionCaption(ActionCode(), 'notallowed', NotAllowed);
    end;

    local procedure OpenItemInventoryOverviewPage(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        LinePOS: Record "NPR POS Sale Line";
        CurrentView: Codeunit "NPR POS View";
        POSInventoryOverview: Page "NPR POS Inventory Overview";
        ItemsByLocationOverview: Page "NPR Items by Location Overview";
        AllItems: Boolean;
        OnlyCurrrentLocation: Boolean;
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);
        POSSession.GetCurrentView(CurrentView);
        AllItems := JSON.GetBooleanParameter(AllItemsParTxt());
        OnlyCurrrentLocation := JSON.GetBooleanParameter(OnlyCurrentLocParTxt());

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        if AllItems then begin
            Clear(ItemsByLocationOverview);
            if OnlyCurrrentLocation then
                ItemsByLocationOverview.SetFilters(SalePOS."Location Code");
            ItemsByLocationOverview.Run();
            exit;
        end;

        POSInventoryOverview.SetParameters('', '', SalePOS."Location Code", OnlyCurrrentLocation);
        if (CurrentView.Type() = CurrentView.Type() ::Sale) then begin
            POSSession.GetSaleLine(POSSaleLine);
            POSSaleLine.GetCurrentSaleLine(LinePOS);
            if LinePOS.Type = LinePOS.Type::Item then begin
                POSInventoryOverview.SetParameters(LinePOS."No.", LinePOS."Variant Code", LinePOS."Location Code", OnlyCurrrentLocation);
            end;
        end;
        POSInventoryOverview.Run();
    end;

    local procedure AllItemsParTxt(): Text
    begin
        exit('AllItems');
    end;

    local procedure OnlyCurrentLocParTxt(): Text
    begin
        exit('OnlyCurrentLocation');
    end;
}
