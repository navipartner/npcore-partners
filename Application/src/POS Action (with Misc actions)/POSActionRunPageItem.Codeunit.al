codeunit 6150847 "NPR POS Action: RunPage (Item)"
{
    // NPR5.46/MHA /20181001  CASE 326620 Object created - Run Page with Item from Sale Line POS as Source Rec.
    // NPR5.51/MHA /20190816  CASE 365332 Removed function OnLookupPageId()


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built-in action for running a page';
        PageMissingError: Label 'That page was not found.';
        POSSetup: Codeunit "NPR POS Setup";

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
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        with Sender do
            if DiscoverAction(
              ActionCode,
              ActionDescription,
              ActionVersion,
              Type::Generic,
              "Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflowStep('run_page_item', 'respond();');
                RegisterWorkflow(false);
                RegisterDataSourceBinding('BUILTIN_SALELINE');
                RegisterCustomJavaScriptLogic('enable', 'return row.getField(' + Format(SaleLinePOS.FieldNo(Type)) + ').rawValue == 1;');

                RegisterIntegerParameter('PageId', PAGE::"Item Availability by Location");
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', false, false)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Context: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
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
        if not Action.IsThisAction(ActionCode) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScope('parameters', true);

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
        SaleLinePOS: Record "NPR Sale Line POS";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        PageId: Integer;
    begin
        PageId := JSON.GetInteger('PageId', true);
        if PageId = 0 then
            exit;

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLinePOS.TestField(Type, SaleLinePOS.Type::Item);
        Item.Get(SaleLinePOS."No.");
        Item.SetFilter("Variant Filter", Item."Variant Filter");

        RunPage(Item, PageId);
    end;

    local procedure "-- Locals --"()
    begin
    end;

    local procedure RunPage(var Item: Record Item; PageId: Integer)
    begin
        if PageId = 0 then
            exit;

        PAGE.RunModal(PageId, Item);
    end;
}

