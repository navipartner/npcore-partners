codeunit 6150852 "NPR POS Action - Item Price"
{
    // 
    // NPR5.41/TSA /20180419 CASE 309052 Initial Version
    // NPR5.41/TSA /20180423 CASE 309052 Adding handling of expanded BOM and associated items, causing multiple lines to added to POS
    // NPR5.43/MHA /20180621 CASE 319231 Added parameters to extend Item lookup and enable display of Amount Excl. Vat
    // NPR5.49/TJ  /20190201 CASE 335739 Using POS View Profile instead of Register


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This action prompts for a numeric item number, and shows the price';
        ValueSelection: Option LIST,"FIXED";
        DimensionSource: Option SHORTCUT1,SHORTCUT2,ANY;
        Title: Label 'We need more information.';
        Caption: Label 'Item Number';
        PriceQuery: Label 'Price Query';
        PriceInfoHtml: Label '<center><table border="0"><tr><td align="left">%1</td><td align="right"><h2>%2</h2></td></tr><tr><td align="left">%3</td><td align="right"><h2>%4</h2></td></tr><tr><td align="left">%5</td><td align="right"><h2>%6</h2></td></tr></table>';

    local procedure ActionCode(): Text
    begin
        exit('ITEM_PRICE');
    end;

    local procedure ActionVersion(): Text
    begin
        //-NPR5.43 [319231]
        exit('1.3');
        //+NPR5.43 [319231]
        exit('1.2');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
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

            //-NPR5.43 [319231]
            Sender.RegisterBooleanParameter('priceExclVat', false);
            Sender.RegisterOptionParameter('itemIdentifyerType', 'ItemNo,ItemCrossReference,ItemSearch', 'ItemNo');
            //+NPR5.43 [319231]
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode, 'Title', Title);
        Captions.AddActionCaption(ActionCode, 'Caption', Caption);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSAction: Record "NPR POS Action";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR Sale Line POS";
        SalePOS: Record "NPR Sale POS";
        LineNumber: Integer;
        Register: Record "NPR Register";
        ItemIdentifyerType: Text;
        PriceExclVat: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSViewProfile: Record "NPR POS View Profile";
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
                    Register.Get(SalePOS."Register No.");
                    //-NPR5.49 [335739]
                    //Register.TESTFIELD (Register."Line Order on Screen", Register."Line Order on Screen"::Normal);
                    if POSUnit.Get(SalePOS."Register No.") and POSViewProfile.Get(POSUnit."POS View Profile") then
                        POSViewProfile.TestField("Line Order on Screen", POSViewProfile."Line Order on Screen"::Normal);
                    //+NPR5.49 [335739]

                    JSON.SetContext('LastSaleLineNoBeforeAddItem', SaleLinePOS."Line No.");
                    FrontEnd.SetActionContext(ActionCode(), JSON);

                    if not POSSession.RetrieveSessionAction('ITEM', POSAction) then
                        POSAction.Get('ITEM');
                    //-NPR5.43 [319231]
                    JSON.SetScope('parameters', true);
                    ItemIdentifyerType := JSON.GetString('itemIdentifyerType', false);
                    JSON.SetScope('/', true);
                    if ItemIdentifyerType <> '' then
                        POSAction.SetWorkflowInvocationParameter('itemIdentifyerType', ItemIdentifyerType, FrontEnd);
                    //+NPR5.43 [319231]
                    POSAction.SetWorkflowInvocationParameter('itemNo', CopyStr(GetNumpad(JSON, 'itemnumber'), 1, MaxStrLen(Item."No.")), FrontEnd);
                    FrontEnd.InvokeWorkflow(POSAction);

                end;

            'gatherinfo':
                begin
                    LineNumber := JSON.GetInteger('LastSaleLineNoBeforeAddItem', true);

                    POSSession.GetSale(POSSale);
                    POSSale.GetCurrentSale(SalePOS);
                    SaleLinePOS.SetFilter("Register No.", '=%1', SalePOS."Register No.");
                    SaleLinePOS.SetFilter("Sales Ticket No.", '=%1', SalePOS."Sales Ticket No.");
                    SaleLinePOS.SetFilter("Line No.", '>%1', LineNumber);
                    if not (SaleLinePOS.FindFirst()) then exit;

                    JSON.SetContext('confirm_title', PriceQuery);
                    JSON.SetContext('confirm_message', StrSubstNo(PriceInfoHtml,
                      SaleLinePOS.FieldCaption("No."), SaleLinePOS."No.",
                      SaleLinePOS.FieldCaption(Description), StrSubstNo('%1<br><h4>%2</h4>', SaleLinePOS.Description, SaleLinePOS."Description 2"),
                      SaleLinePOS.FieldCaption("Amount Including VAT"), SaleLinePOS."Amount Including VAT"));
                    //-NPR5.43 [319231]
                    JSON.SetScope('parameters', true);
                    PriceExclVat := JSON.GetBoolean('priceExclVat', false);
                    JSON.SetScope('/', true);
                    if PriceExclVat then
                        JSON.SetContext('confirm_message', StrSubstNo(PriceInfoHtml,
                          SaleLinePOS.FieldCaption("No."), SaleLinePOS."No.",
                          SaleLinePOS.FieldCaption(Description), StrSubstNo('%1<br><h4>%2</h4>', SaleLinePOS.Description, SaleLinePOS."Description 2"),
                          SaleLinePOS.FieldCaption(Amount), SaleLinePOS.Amount));
                    //+NPR5.43 [319231]
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

        if (not JSON.SetScopeRoot(false)) then
            exit('');

        if (not JSON.SetScope('$' + Path, false)) then
            exit('');

        exit(JSON.GetString('input', false));
    end;
}

