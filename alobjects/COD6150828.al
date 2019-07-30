codeunit 6150828 "POS Action - Item Inv Overview"
{
    // NPR5.34/BR /20170724  CASE 282748 Object Created
    // NPR5.37.02/MMV /20171114  CASE 296478 Moved text constant to in-line constant


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This built in function opens a page displaying the item inventory per location and variant.';
        Title: Label 'Item Card';
        NotAllowed: Label 'Cannot open the Item Inventory Overview for this line.';

    local procedure ActionCode(): Text
    begin
        exit('ITEMINVOV');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode,
              ActionDescription,
              ActionVersion,
              Sender.Type::Generic,
              Sender."Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflow(false);
                RegisterDataBinding();
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        Confirmed: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        OpenItemInventoryOverviewPage(Context, POSSession, FrontEnd);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode, 'title', Title);
        Captions.AddActionCaption(ActionCode, 'notallowed', NotAllowed);
    end;

    local procedure OpenItemInventoryOverviewPage(Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management")
    var
        JSON: Codeunit "POS JSON Management";
        POSSaleLine: Codeunit "POS Sale Line";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
        LinePOS: Record "Sale Line POS";
        Item: Record Item;
        CurrentView: DotNet npNetView0;
        CurrentViewType: DotNet npNetViewType0;
        ViewType: DotNet npNetViewType0;
        POSInventoryOverview: Page "POS Inventory Overview";
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);
        POSSession.GetCurrentView(CurrentView);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSInventoryOverview.SetParameters('', '', SalePOS."Location Code");
        if (CurrentView.Type.Equals(ViewType.Sale)) then begin
            POSSession.GetSaleLine(POSSaleLine);
            POSSaleLine.GetCurrentSaleLine(LinePOS);
            if LinePOS.Type = LinePOS.Type::Item then begin
                POSInventoryOverview.SetParameters(LinePOS."No.", LinePOS."Variant Code", LinePOS."Location Code");
            end;
        end;
        POSInventoryOverview.Run;
    end;
}

