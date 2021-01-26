codeunit 6151005 "NPR POS Action: Load POS Quote"
{
    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Load POS Sale from POS Quote';
        Text001: Label 'POS Quote';
        CannotLoad: Label 'The POS Quote is missing essential data and cannot be loaded.';

    local procedure ActionCode(): Text
    begin
        exit('LOAD_FROM_POS_QUOTE');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.4');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    var
        itemTrackingCode: Text;
    begin
        if Sender.DiscoverAction(
          ActionCode,
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

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        AuditRoll: Record "NPR Audit Roll";
    begin
        Captions.AddActionCaption(ActionCode(), 'SalesTicketNo', AuditRoll.FieldCaption("Sales Ticket No."));
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', true, true)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        ControlId: Text;
        Value: Text;
        DoNotClearTextBox: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        case WorkflowStep of
            'select_quote':
                OnActionSelectQuote(JSON, POSSession, FrontEnd);
            'preview':
                OnActionPreview(JSON, FrontEnd);
            'load_from_quote':
                OnActionLoadFromQuote(JSON, POSSession, FrontEnd);
        end;
    end;

    local procedure OnActionSelectQuote(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSQuoteEntry: Record "NPR POS Quote Entry";
        SalePOS: Record "NPR Sale POS";
        POSQuoteMgt: Codeunit "NPR POS Quote Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        SalesTicketNo: Code[20];
        LastQuoteEntryNo: BigInteger;
        "Filter": Integer;
    begin

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        Filter := JSON.GetIntegerParameter('Filter', true);
        POSQuoteMgt.SetSalePOSFilter(SalePOS, POSQuoteEntry, Filter);

        SalesTicketNo := JSON.GetString('SalesTicketNo', false);
        if SalesTicketNo = '' then begin
            if PAGE.RunModal(0, POSQuoteEntry) <> ACTION::LookupOK then
                exit;

            JSON.SetContext('quote_entry_no', POSQuoteEntry."Entry No.");
            FrontEnd.SetActionContext(ActionCode(), JSON);

            exit;
        end;

        POSQuoteEntry.SetRange("Sales Ticket No.", SalesTicketNo);
        POSQuoteEntry.FindLast;
        LastQuoteEntryNo := POSQuoteEntry."Entry No.";
        POSQuoteEntry.FindFirst;
        if POSQuoteEntry."Entry No." <> LastQuoteEntryNo then begin
            if PAGE.RunModal(0, POSQuoteEntry) <> ACTION::LookupOK then
                exit;
        end;

        JSON.SetContext('quote_entry_no', POSQuoteEntry."Entry No.");
        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure OnActionPreview(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSQuoteEntry: Record "NPR POS Quote Entry";
        PageMgt: Codeunit "Page Management";
        QuoteEntryNo: BigInteger;
    begin
        QuoteEntryNo := JSON.GetInteger('quote_entry_no', false);
        if QuoteEntryNo = 0 then
            exit;

        if not POSQuoteEntry.Get(QuoteEntryNo) then
            exit;

        POSQuoteEntry.FilterGroup(2);
        POSQuoteEntry.SetRecFilter();
        POSQuoteEntry.FilterGroup(0);
        IF Page.RunModal(Page::"NPR POS Quote Card", POSQuoteEntry) <> Action::LookupOK then begin
            JSON.SetContext('quote_entry_no', '');
            FrontEnd.SetActionContext(ActionCode(), JSON);
        end;
    end;

    local procedure OnActionLoadFromQuote(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        SalePOS: Record "NPR Sale POS";
        POSQuoteEntry: Record "NPR POS Quote Entry";
        POSQuoteLine: Record "NPR POS Quote Line";
        SaleLinePOS: Record "NPR Sale Line POS";
        Register: Record "NPR Register";
        SalePOS2: Record "NPR Sale POS";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        QuoteEntryNo: BigInteger;
    begin
        QuoteEntryNo := JSON.GetInteger('quote_entry_no', true);
        POSQuoteEntry.Get(QuoteEntryNo);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find;

        if LoadFromQuote(POSQuoteEntry, SalePOS) then begin
            Register.Get(SalePOS."Register No.");
            SalePOS."Location Code" := Register."Location Code";

            // reload proper dimensions
            POSSale.GetCurrentSale(SalePOS2);
            SalePOS.Validate("POS Store Code", SalePOS2."POS Store Code");
            SalePOS.Modify;

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

    local procedure DeletePOSSalesLines(SalePOS: Record "NPR Sale POS")
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindFirst then
            SaleLinePOS.DeleteAll(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLoadFromPOSQuote(var SalePOS: Record "NPR Sale POS"; var POSQuoteEntry: Record "NPR POS Quote Entry"; var XmlDoc: XmlDocument)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterLoadFromQuote(POSQuoteEntry: Record "NPR POS Quote Entry"; var SalePOS: Record "NPR Sale POS")
    begin
    end;

    local procedure UpdateDates(var XmlDoc: XmlDocument; SalePOS: Record "NPR Sale POS")
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        XmlNode: XmlNode;
        XmlNodeList: XmlNodeList;
        NewXmlNode: XmlNode;
    begin
        XmlDoc.SelectSingleNode('/pos_sale/fields/field[@field_no=' + Format(SalePOS.FieldNo(Date)) + ']', XmlNode);
        XmlNode.ReplaceWith(Format(SalePOS.Date, 0, 9));
        XmlDoc.SelectSingleNode('/pos_sale/fields/field[@field_no=' + Format(SalePOS.FieldNo("Start Time")) + ']', XmlNode);
        XmlNode.ReplaceWith(Format(SalePOS."Start Time", 0, 9));
        XmlDoc.SelectNodes('pos_sale/pos_sale_lines/pos_sale_line/fields/field[@field_no=' + Format(SaleLinePOS.FieldNo(Date)) + ']', XmlNodeList);
        foreach XmlNode in XmlNodeList do
            XmlNode.ReplaceWith(Format(SalePOS.Date, 0, 9));
    end;

    procedure LoadFromQuote(var POSQuoteEntry: Record "NPR POS Quote Entry"; var SalePOS: Record "NPR Sale POS"): Boolean
    var
        POSQuoteMgt: Codeunit "NPR POS Quote Mgt.";
        XmlDoc: XmlDocument;
    begin
        POSQuoteEntry.SkipLineDeleteTrigger(true);

        if not POSQuoteMgt.LoadPOSSaleData(POSQuoteEntry, XmlDoc) then
            exit(false);

        OnBeforeLoadFromPOSQuote(SalePOS, POSQuoteEntry, XmlDoc);
        DeletePOSSalesLines(SalePOS);
        UpdateDates(XmlDoc, SalePOS);
        POSQuoteMgt.Xml2POSSale(XmlDoc, SalePOS);
        OnAfterLoadFromQuote(POSQuoteEntry, SalePOS);
        POSQuoteEntry.Delete(true);

        exit(true);
    end;
}