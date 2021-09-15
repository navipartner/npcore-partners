codeunit 6150852 "NPR POS Action - Item Price"
{
    var
        ActionDescription: Label 'This action prompts for a numeric item number, and shows the price';
        Title: Label 'We need more information.';
        Caption: Label 'Item Number';
        PriceQuery: Label 'Price Query';
        PriceInfoHtml: Label '<center><table border="0"><tr><td align="left">%1</td><td align="right"><h2>%2</h2></td></tr><tr><td align="left">%3</td><td align="right"><h2>%4</h2></td></tr><tr><td align="left">%5</td><td align="right"><h2>%6</h2></td></tr></table>';
        ReadingErr: Label 'reading in %1';

    local procedure ActionCode(): Code[20]
    begin
        exit('ITEM_PRICE');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.3');
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

            Sender.RegisterWorkflowStep('itemnumber', 'input ({title: labels.Title, caption: labels.Caption}).cancel(abort);');
            Sender.RegisterWorkflowStep('createitem', 'respond();');
            Sender.RegisterWorkflowStep('gatherinfo', 'respond();');
            Sender.RegisterWorkflowStep('showinfo', 'message ({title: context.confirm_title, caption: context.confirm_message});');
            Sender.RegisterWorkflow(false);

            Sender.RegisterBooleanParameter('priceExclVat', false);
            Sender.RegisterOptionParameter('itemIdentifyerType', 'ItemNo,ItemCrossReference,ItemSearch', 'ItemNo');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'Title', Title);
        Captions.AddActionCaption(ActionCode(), 'Caption', Caption);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSAction: Record "NPR POS Action";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        LineNumber: Integer;
        ItemIdentifyerType: Text;
        PriceExclVat: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSViewProfile: Record "NPR POS View Profile";
        HtmlTagLbl: Label '%1<br><h4>%2</h4>', Locked = true;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;
        JSON.InitializeJObjectParser(Context, FrontEnd);

        case WorkflowStep of
            'createitem':
                begin

                    POSSession.GetSale(POSSale);
                    POSSession.GetSaleLine(POSSaleLine);

                    POSSale.GetCurrentSale(SalePOS);
                    SaleLinePOS.SetFilter("Register No.", '=%1', SalePOS."Register No.");
                    SaleLinePOS.SetFilter("Sales Ticket No.", '=%1', SalePOS."Sales Ticket No.");
                    if (not SaleLinePOS.FindLast()) then
                        SaleLinePOS."Line No." := -1;

                    // Make sure add lines to the "end"
                    if POSUnit.Get(SalePOS."Register No.") and POSViewProfile.Get(POSUnit."POS View Profile") then
                        POSViewProfile.TestField("Line Order on Screen", POSViewProfile."Line Order on Screen"::Normal);

                    JSON.SetContext('LastSaleLineNoBeforeAddItem', SaleLinePOS."Line No.");
                    FrontEnd.SetActionContext(ActionCode(), JSON);

                    if not POSSession.RetrieveSessionAction('ITEM', POSAction) then
                        POSAction.Get('ITEM');
                    JSON.SetScopeParameters(ActionCode());
                    ItemIdentifyerType := JSON.GetString('itemIdentifyerType');
                    JSON.SetScopeRoot();
                    if ItemIdentifyerType <> '' then
                        POSAction.SetWorkflowInvocationParameter('itemIdentifyerType', ItemIdentifyerType, FrontEnd);
                    POSAction.SetWorkflowInvocationParameter('itemNo', CopyStr(GetNumpad(JSON, 'itemnumber'), 1, MaxStrLen(Item."No.")), FrontEnd);
                    FrontEnd.InvokeWorkflow(POSAction);

                end;

            'gatherinfo':
                begin
                    LineNumber := JSON.GetIntegerOrFail('LastSaleLineNoBeforeAddItem', StrSubstNo(ReadingErr, ActionCode()));

                    POSSession.GetSale(POSSale);
                    POSSale.GetCurrentSale(SalePOS);
                    SaleLinePOS.SetFilter("Register No.", '=%1', SalePOS."Register No.");
                    SaleLinePOS.SetFilter("Sales Ticket No.", '=%1', SalePOS."Sales Ticket No.");
                    SaleLinePOS.SetFilter("Line No.", '>%1', LineNumber);
                    if not (SaleLinePOS.FindFirst()) then exit;

                    JSON.SetContext('confirm_title', PriceQuery);
                    JSON.SetContext('confirm_message', StrSubstNo(PriceInfoHtml,
                      SaleLinePOS.FieldCaption("No."), SaleLinePOS."No.",
                      SaleLinePOS.FieldCaption(Description), StrSubstNo(HtmlTagLbl, SaleLinePOS.Description, SaleLinePOS."Description 2"),
                      SaleLinePOS.FieldCaption("Amount Including VAT"), SaleLinePOS."Amount Including VAT"));
                    JSON.SetScopeParameters(ActionCode());
                    PriceExclVat := JSON.GetBoolean('priceExclVat');
                    JSON.SetScopeRoot();
                    if PriceExclVat then
                        JSON.SetContext('confirm_message', StrSubstNo(PriceInfoHtml,
                          SaleLinePOS.FieldCaption("No."), SaleLinePOS."No.",
                          SaleLinePOS.FieldCaption(Description), StrSubstNo(HtmlTagLbl, SaleLinePOS.Description, SaleLinePOS."Description 2"),
                          SaleLinePOS.FieldCaption(Amount), SaleLinePOS.Amount));
                    FrontEnd.SetActionContext(ActionCode(), JSON);

                    // Delete the lines from the end until we find the last line before inserting
                    POSSession.GetSaleLine(POSSaleLine);
                    POSSaleLine.SetLast();
                    POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

                    if (LineNumber = -1) then begin
                        POSSaleLine.DeleteAll();
                    end else begin
                        while (SaleLinePOS."Line No." > LineNumber) do begin
                            POSSaleLine.DeleteLine();
                            POSSaleLine.SetLast();
                            POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
                        end;
                    end;
                    POSSession.RequestRefreshData();
                end;
        end;
    end;

    local procedure GetNumpad(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Text
    begin
        JSON.SetScopeRoot();
        if (not JSON.SetScope('$' + Path)) then
            exit('');

        exit(JSON.GetString('input'));
    end;
}
