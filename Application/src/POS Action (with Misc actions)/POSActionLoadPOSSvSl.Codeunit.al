codeunit 6151005 "NPR POS Action: LoadPOSSvSl"
{
    Access = Internal;
    var
        Text000: Label 'Load POS Sale from POS saved Sale';
        CannotLoad: Label 'The POS Saved Sale is missing essential data and cannot be loaded.';
        ReadingErr: Label 'reading in %1';

    local procedure ActionCode(): Code[20]
    begin
        exit('LOAD_FROM_POS_QUOTE');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.4');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          Text000,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Single)
        then begin
            Sender.RegisterWorkflowStep('select_quote',
              'switch("" + param.QuoteInputType) {' +
              '  case "0":' +
              '    intpad({title: labels.SalesTicketNo, caption: labels.SalesTicketNo}).respond("SalesTicketNo").cancel(abort);' +
              '    break;' +
              '  case "1":' +
              '    respond();' +
              '    break;' +
              '  case "2":' +
              '    input({title: labels.SalesTicketNo, caption: labels.SalesTicketNo, notBlank: true}).respond("SalesTicketNo").cancel(abort);' +
              '    break;' +
              '}');
            Sender.RegisterWorkflowStep('preview', 'if (param.PreviewBeforeLoad) { respond(); }');
            Sender.RegisterWorkflowStep('load_from_quote', 'if (context.quote_entry_no) { respond(); }');
            Sender.RegisterWorkflow(false);

            Sender.RegisterOptionParameter('QuoteInputType', 'IntPad,List,Input', 'IntPad');
            Sender.RegisterBooleanParameter('PreviewBeforeLoad', true);
            Sender.RegisterOptionParameter('Filter', 'All,Register,Salesperson,Register+Salesperson', 'Register');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        POSEntry: Record "NPR POS Entry";
    begin
        Captions.AddActionCaption(ActionCode(), 'SalesTicketNo', POSEntry.FieldCaption("Document No."));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', true, true)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        case WorkflowStep of
            'select_quote':
                OnActionSelectQuote(JSON, POSSession, FrontEnd);
            'preview':
                OnActionPreview(JSON, FrontEnd);
            'load_from_quote':
                OnActionLoadFromQuote(JSON, POSSession);
        end;
    end;

    local procedure OnActionSelectQuote(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSQuoteEntry: Record "NPR POS Saved Sale Entry";
        SalePOS: Record "NPR POS Sale";
        POSQuoteMgt: Codeunit "NPR POS Saved Sale Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        SalesTicketNo: Code[20];
        LastQuoteEntryNo: BigInteger;
        "Filter": Integer;
    begin

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        Filter := JSON.GetIntegerParameterOrFail('Filter', ActionCode());
        POSQuoteMgt.SetSalePOSFilter(SalePOS, POSQuoteEntry, Filter);

        SalesTicketNo := CopyStr(JSON.GetString('SalesTicketNo'), 1, MaxStrLen(SalesTicketNo));
        if SalesTicketNo = '' then begin
            if PAGE.RunModal(0, POSQuoteEntry) <> ACTION::LookupOK then
                exit;

            JSON.SetContext('quote_entry_no', POSQuoteEntry."Entry No.");
            FrontEnd.SetActionContext(ActionCode(), JSON);

            exit;
        end;

        POSQuoteEntry.SetRange("Sales Ticket No.", SalesTicketNo);
        POSQuoteEntry.FindLast();
        LastQuoteEntryNo := POSQuoteEntry."Entry No.";
        POSQuoteEntry.FindFirst();
        if POSQuoteEntry."Entry No." <> LastQuoteEntryNo then begin
            if PAGE.RunModal(0, POSQuoteEntry) <> ACTION::LookupOK then
                exit;
        end;

        JSON.SetContext('quote_entry_no', POSQuoteEntry."Entry No.");
        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure OnActionPreview(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSQuoteEntry: Record "NPR POS Saved Sale Entry";
        QuoteEntryNo: BigInteger;
    begin
        QuoteEntryNo := JSON.GetInteger('quote_entry_no');
        if QuoteEntryNo = 0 then
            exit;

        if not POSQuoteEntry.Get(QuoteEntryNo) then
            exit;

        POSQuoteEntry.FilterGroup(2);
        POSQuoteEntry.SetRecFilter();
        POSQuoteEntry.FilterGroup(0);
        IF Page.RunModal(Page::"NPR POS Saved Sale Card", POSQuoteEntry) <> Action::LookupOK then begin
            JSON.SetContext('quote_entry_no', '');
            FrontEnd.SetActionContext(ActionCode(), JSON);
        end;
    end;

    local procedure OnActionLoadFromQuote(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        SalePOS: Record "NPR POS Sale";
        POSQuoteEntry: Record "NPR POS Saved Sale Entry";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS2: Record "NPR POS Sale";
        POSStore: Record "NPR POS Store";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        QuoteEntryNo: BigInteger;
    begin
        QuoteEntryNo := JSON.GetIntegerOrFail('quote_entry_no', StrSubstNo(ReadingErr, ActionCode()));
        POSQuoteEntry.Get(QuoteEntryNo);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find();

        if LoadFromQuote(POSQuoteEntry, SalePOS) then begin
            // reload proper dimensions
            POSSale.GetCurrentSale(SalePOS2);
            POSStore.Get(SalePOS2."POS Store Code");
            SalePOS."Location Code" := POSStore."Location Code";
            SalePOS.Validate("POS Store Code", SalePOS2."POS Store Code");
            SalePOS.Modify();

            POSSale.Refresh(SalePOS);
            POSSale.SetModified();

            POSSession.GetSaleLine(POSSaleLine);
            SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
            SaleLinePOS.SetFilter(Type, '<>%1', SaleLinePOS.Type::Payment);
            if not SaleLinePOS.IsEmpty then
                POSSaleLine.SetLast();

            POSCreateEntry.InsertParkedSaleRetrievalEntry(
              SalePOS."Register No.", SalePOS."Salesperson Code", POSQuoteEntry."Sales Ticket No.", SalePOS."Sales Ticket No.");
            POSSession.RequestRefreshData();
            exit;
        end;

        Error(CannotLoad);
    end;

    local procedure DeletePOSSalesLines(SalePOS: Record "NPR POS Sale")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindFirst() then
            SaleLinePOS.DeleteAll(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLoadFromPOSQuote(var SalePOS: Record "NPR POS Sale"; var POSQuoteEntry: Record "NPR POS Saved Sale Entry";
        var XmlDoc: XmlDocument)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterLoadFromQuote(POSQuoteEntry: Record "NPR POS Saved Sale Entry"; var SalePOS: Record "NPR POS Sale")
    begin
    end;

    procedure LoadFromQuote(var POSQuoteEntry: Record "NPR POS Saved Sale Entry"; var SalePOS: Record "NPR POS Sale"): Boolean
    var
        POSQuoteMgt: Codeunit "NPR POS Saved Sale Mgt.";
        XmlDoc: XmlDocument;
    begin
        POSQuoteEntry.SkipLineDeleteTrigger(true);

        if not POSQuoteMgt.LoadPOSSaleData(POSQuoteEntry, XmlDoc) then
            exit(false);

        OnBeforeLoadFromPOSQuote(SalePOS, POSQuoteEntry, XmlDoc);
        DeletePOSSalesLines(SalePOS);

        POSQuoteMgt.Xml2POSSale(XmlDoc, SalePOS);
        OnAfterLoadFromQuote(POSQuoteEntry, SalePOS);
        POSQuoteEntry.Delete(true);

        exit(true);
    end;
}
