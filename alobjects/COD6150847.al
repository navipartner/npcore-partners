codeunit 6150847 "POS Action - Run Page (Item)"
{
    // NPR5.46/MHA /20181001  CASE 326620 Object created - Run Page with Item from Sale Line POS as Source Rec.


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built-in action for running a page';
        PageMissingError: Label 'That page was not found.';
        POSSetup: Codeunit "POS Setup";

    local procedure ActionCode(): Text
    begin
        exit('RUNPAGE_ITEM');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    var
        SaleLinePOS: Record "Sale Line POS";
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
    local procedure OnBeforeWorkflow("Action": Record "POS Action"; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    var
        Context: Codeunit "POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
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

    local procedure OnActionRunPageItem(POSSession: Codeunit "POS Session"; JSON: Codeunit "POS JSON Management")
    var
        Item: Record Item;
        SaleLinePOS: Record "Sale Line POS";
        POSSaleLine: Codeunit "POS Sale Line";
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

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', true, true)]
    local procedure OnLookupPageId(var POSParameterValue: Record "POS Parameter Value"; Handled: Boolean)
    var
        NpmPage: Record "Npm Page";
        NpmMetadataMgt: Codeunit "Npm Metadata Mgt.";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'PageId' then
            exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Integer then
            exit;

        Handled := true;

        if NpmPage.IsEmpty then
            NpmMetadataMgt.LoadNpmPages();
        NpmPage.SetRange("Source Table No.", DATABASE::Item);
        if PAGE.RunModal(0, NpmPage) = ACTION::LookupOK then
            POSParameterValue.Value := Format(NpmPage."Page ID");
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

