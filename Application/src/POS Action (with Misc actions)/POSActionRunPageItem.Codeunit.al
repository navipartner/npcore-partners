codeunit 6150847 "NPR POS Action: RunPage (Item)"
{
    var
        ActionDescription: Label 'This is a built-in action for running a page';
        ReadingErr: Label 'reading in %1';

    local procedure ActionCode(): Text
    begin
        exit('RUNPAGE_ITEM');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        if Sender.DiscoverAction(
  ActionCode(),
  ActionDescription,
  ActionVersion(),
  Sender.Type::Generic,
  Sender."Subscriber Instances Allowed"::Multiple)
then begin
            Sender.RegisterWorkflowStep('run_page_item', 'respond();');
            Sender.RegisterWorkflow(false);
            Sender.RegisterDataSourceBinding('BUILTIN_SALELINE');
            Sender.RegisterCustomJavaScriptLogic('enable', 'return row.getField(' + Format(SaleLinePOS.FieldNo(Type)) + ').rawValue == 1;');

            Sender.RegisterIntegerParameter('PageId', PAGE::"Item Availability by Location");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', false, false)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScopeParameters(ActionCode());

        case WorkflowStep of
            'run_page_item':
                begin
                    Handled := true;
                    OnActionRunPageItem(POSSession, JSON);
                end;
        end;
    end;

    local procedure OnActionRunPageItem(POSSession: Codeunit "NPR POS Session"; JSON: Codeunit "NPR POS JSON Management")
    var
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        PageId: Integer;
    begin
        PageId := JSON.GetIntegerOrFail('PageId', StrSubstNo(ReadingErr, ActionCode()));
        if PageId = 0 then
            exit;

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLinePOS.TestField(Type, SaleLinePOS.Type::Item);
        Item.Get(SaleLinePOS."No.");
        Item.SetFilter("Variant Filter", Item."Variant Filter");

        RunPage(Item, PageId);
    end;

    local procedure RunPage(var Item: Record Item; PageId: Integer)
    begin
        if PageId = 0 then
            exit;

        PAGE.RunModal(PageId, Item);
    end;
}
