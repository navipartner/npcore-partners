codeunit 6151005 "POS Action - Load POS Quote"
{
    // NPR5.47/MHA /20181011  CASE 302636 Object created - POS Quote (Saved POS Sale)
    // NPR5.48/MHA /20181115  CASE 334633 Added SetSalePOSFilter() to OnActionSelectQuote()
    // NPR5.48/MHA /20181129  CASE 336498 Added Customer Info
    // NPR5.48/MHA /20181206  CASE 338537 Added Publisher OnAfterLoadFromQuote() in OnActionLoadFromQuote()
    // NPR5.48/MHA /20181130  CASE 338208 Added POS Sales Data (.xml) functionality to fully back/restore POS Sale
    // NPR5.49/TJ  /20190125  CASE 331208 Added additional place that calls into OnAfterLoadFromQuote()
    // NPR5.50/ALST/20190523  CASE 351725 changed OnActionLoadFromQuote to set context properly on current POS Sale Line
    // NPR5.51/ALST/20190620  CASE 353076 update the sale dates after retrieving from quote
    // NPR5.51/MMV /20190820  CASE 364694 Handle EFT approvals.
    //                                    Moved filter from RetailSetup to parameter.


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Load POS Sale from POS Quote';
        Text001: Label 'POS Quote';
        Text002: Label 'Save current Sale as POS Quote?';

    local procedure ActionCode(): Text
    begin
        exit ('LOAD_FROM_POS_QUOTE');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.2'); //-+NPR5.51 [364694]
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
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
          Sender.RegisterWorkflowStep('preview','if (param.PreviewBeforeLoad) { respond(); }');
          Sender.RegisterWorkflowStep('load_from_quote','if (context.quote_entry_no) { respond(); }');
          Sender.RegisterWorkflow(false);

          Sender.RegisterOptionParameter('QuoteInputType','IntPad,List,Input','IntPad');
          Sender.RegisterBooleanParameter('PreviewBeforeLoad',true);
        //-NPR5.51 [364694]
          Sender.RegisterOptionParameter('Filter','All,Register,Salesperson,Register+Salesperson', 'Register');
        //+NPR5.51 [364694]
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    var
        AuditRoll: Record "Audit Roll";
    begin
        Captions.AddActionCaption(ActionCode(),'SalesTicketNo',AuditRoll.FieldCaption("Sales Ticket No."));
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', true, true)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: JsonObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        ControlId: Text;
        Value: Text;
        DoNotClearTextBox: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        case WorkflowStep of
          'select_quote':
            OnActionSelectQuote(JSON,POSSession,FrontEnd);
          'preview':
            OnActionPreview(JSON,FrontEnd);
          'load_from_quote':
            OnActionLoadFromQuote(JSON,POSSession,FrontEnd);
        end;
    end;

    local procedure OnActionSelectQuote(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        POSQuoteEntry: Record "POS Quote Entry";
        SalePOS: Record "Sale POS";
        POSQuoteMgt: Codeunit "POS Quote Mgt.";
        POSSale: Codeunit "POS Sale";
        SalesTicketNo: Code[20];
        LastQuoteEntryNo: BigInteger;
        "Filter": Integer;
    begin

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        //-NPR5.51 [364694]
        //POSQuoteMgt.SetSalePOSFilter(SalePOS,POSQuoteEntry);
        Filter := JSON.GetIntegerParameter('Filter', true);
        POSQuoteMgt.SetSalePOSFilter(SalePOS,POSQuoteEntry, Filter);
        //+NPR5.51 [364694]

        SalesTicketNo := JSON.GetString('SalesTicketNo',false);
        if SalesTicketNo = '' then begin
          if PAGE.RunModal(0,POSQuoteEntry) <> ACTION::LookupOK then
            exit;

          JSON.SetContext('quote_entry_no',POSQuoteEntry."Entry No.");
          FrontEnd.SetActionContext(ActionCode(),JSON);

          exit;
        end;

        POSQuoteEntry.SetRange("Sales Ticket No.",SalesTicketNo);
        POSQuoteEntry.FindLast;
        LastQuoteEntryNo := POSQuoteEntry."Entry No.";
        POSQuoteEntry.FindFirst;
        if POSQuoteEntry."Entry No." <> LastQuoteEntryNo then begin
          if PAGE.RunModal(0,POSQuoteEntry) <> ACTION::LookupOK then
            exit;
        end;

        JSON.SetContext('quote_entry_no',POSQuoteEntry."Entry No.");
        FrontEnd.SetActionContext(ActionCode(),JSON);
    end;

    local procedure OnActionPreview(JSON: Codeunit "POS JSON Management";FrontEnd: Codeunit "POS Front End Management")
    var
        POSQuoteEntry: Record "POS Quote Entry";
        POSQuoteLine: Record "POS Quote Line";
        PageMgt: Codeunit "Page Management";
        QuoteEntryNo: BigInteger;
    begin
        QuoteEntryNo := JSON.GetInteger('quote_entry_no',false);
        if QuoteEntryNo = 0 then
          exit;

        if not POSQuoteEntry.Get(QuoteEntryNo) then
          exit;

        POSQuoteLine.SetRange("Quote Entry No.",QuoteEntryNo);
        if PAGE.RunModal(0,POSQuoteLine) <> ACTION::LookupOK then begin
          JSON.SetContext('quote_entry_no','');
          FrontEnd.SetActionContext(ActionCode(),JSON);
        end;
    end;

    local procedure OnActionLoadFromQuote(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        SalePOS: Record "Sale POS";
        POSQuoteEntry: Record "POS Quote Entry";
        POSQuoteLine: Record "POS Quote Line";
        SaleLinePOS: Record "Sale Line POS";
        POSQuoteMgt: Codeunit "POS Quote Mgt.";
        POSSale: Codeunit "POS Sale";
        POSSaleLine: Codeunit "POS Sale Line";
        XmlDoc: DotNet npNetXmlDocument;
        QuoteEntryNo: BigInteger;
    begin
        QuoteEntryNo := JSON.GetInteger('quote_entry_no',true);
        POSQuoteEntry.Get(QuoteEntryNo);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find;

        //-NPR5.51 [364694]
        POSQuoteEntry.SkipLineDeleteTrigger(true);
        //+NPR5.51 [364694]

        //-NPR5.48 [338208]
        if POSQuoteMgt.LoadPOSSaleData(POSQuoteEntry,XmlDoc) then begin
          DeletePOSSalesLines(SalePOS);
          //-NPR5.51
          UpdateDates(XmlDoc,SalePOS);
          //+NPR5.51
          POSQuoteMgt.Xml2POSSale(XmlDoc,SalePOS);
          //-NPR5.49 [331208]
          OnAfterLoadFromQuote(POSQuoteEntry,SalePOS);
          //+NPR5.49 [331208]
          POSQuoteEntry.Delete(true);

          POSSale.Refresh(SalePOS);

          //-NPR5.50
          POSSession.GetSaleLine(POSSaleLine);
          POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
          POSSaleLine.SetLast();
          //+NPR5.50

          POSSession.RequestRefreshData();
          exit;
        end;
        //+NPR5.48 [338208]

        //-NPR5.48 [336498]
        UpdatePOSSale(POSQuoteEntry,SalePOS);
        //+NPR5.48 [336498]
        POSSession.GetSaleLine(POSSaleLine);

        POSQuoteLine.SetRange("Quote Entry No.",POSQuoteEntry."Entry No.");
        if POSQuoteLine.FindSet then
          repeat
            //-NPR5.48 [336498]
            //InsertPOSSaleLinePOS(POSQuoteLine,POSSaleLine);
            InsertPOSSaleLine(POSQuoteLine,POSSaleLine);
            //+NPR5.48 [336498]
          until POSQuoteLine.Next = 0;

        //-NPR5.48 [338537]
        OnAfterLoadFromQuote(POSQuoteEntry,SalePOS);
        //+NPR5.48 [338537]

        POSQuoteEntry.Delete(true);
        //-NPR5.48 [336498]
        POSSale.Refresh(SalePOS);
        //+NPR5.48 [336498]
        POSSession.RequestRefreshData();
    end;

    local procedure DeletePOSSalesLines(SalePOS: Record "Sale POS")
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        //-NPR5.48 [338208]
        SaleLinePOS.SetRange("Register No.",SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindFirst then
          SaleLinePOS.DeleteAll(true);
        //+NPR5.48 [338208]
    end;

    local procedure UpdatePOSSale(POSQuoteEntry: Record "POS Quote Entry";var SalePOS: Record "Sale POS")
    var
        PrevRec: Text;
    begin
        //-NPR5.48 [336498]
        PrevRec := Format(SalePOS);

        if POSQuoteEntry."Customer No." <> '' then begin
          SalePOS."Customer Type" := POSQuoteEntry."Customer Type";
          SalePOS.Validate("Customer No.",POSQuoteEntry."Customer No.");
          SalePOS."Contact No." := POSQuoteEntry.Attention;
          SalePOS.Reference := POSQuoteEntry.Reference;
        end;

        if POSQuoteEntry."Customer Price Group" <> '' then
          SalePOS.Validate("Customer Price Group",POSQuoteEntry."Customer Price Group");
        if POSQuoteEntry."Customer Disc. Group" <> '' then
          SalePOS.Validate("Customer Disc. Group",POSQuoteEntry."Customer Disc. Group");

        if PrevRec <> Format(SalePOS) then
          SalePOS.Modify(true);
        //+NPR5.48 [336498]
    end;

    local procedure InsertPOSSaleLine(POSQuoteLine: Record "POS Quote Line";POSSaleLine: Codeunit "POS Sale Line")
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        POSSaleLine.GetNewSaleLine(SaleLinePOS);

        SaleLinePOS.Validate(Type,POSQuoteLine.Type);
        SaleLinePOS.Validate("No.",POSQuoteLine."No.");
        SaleLinePOS.Validate("Variant Code",POSQuoteLine."Variant Code");
        SaleLinePOS.Description := POSQuoteLine.Description;
        SaleLinePOS.Validate("Unit of Measure Code",POSQuoteLine."Unit of Measure Code");
        //-NPR5.48 [336498]
        SaleLinePOS.Validate("Customer Price Group",POSQuoteLine."Customer Price Group");
        //+NPR5.48 [336498]
        SaleLinePOS.Validate(Quantity,POSQuoteLine.Quantity);
        SaleLinePOS."Price Includes VAT" := POSQuoteLine."Price Includes VAT";
        SaleLinePOS.Validate("Currency Code",POSQuoteLine."Currency Code");
        SaleLinePOS.Validate("Unit Price",POSQuoteLine."Unit Price");
        SaleLinePOS.Validate(Amount,POSQuoteLine.Amount);
        SaleLinePOS.Validate("Amount Including VAT",POSQuoteLine."Amount Including VAT");
        SaleLinePOS."Discount Type" := POSQuoteLine."Discount Type";
        SaleLinePOS."Discount %" := POSQuoteLine."Discount %";
        SaleLinePOS."Discount Amount" := POSQuoteLine."Discount Amount";
        SaleLinePOS."Discount Code" := POSQuoteLine."Discount Code";
        SaleLinePOS."Discount Authorised by" := POSQuoteLine."Discount Authorised by";
        SaleLinePOS.Insert(true);
        POSSaleLine.InvokeOnAfterInsertSaleLineWorkflow(SaleLinePOS);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterLoadFromQuote(POSQuoteEntry: Record "POS Quote Entry";var SalePOS: Record "Sale POS")
    begin
        //-NPR5.48 [338537]
        //+NPR5.48 [338537]
    end;

    local procedure UpdateDates(var XmlDoc: DotNet npNetXmlDocument;SalePOS: Record "Sale POS")
    var
        SaleLinePOS: Record "Sale Line POS";
        XmlElement: DotNet npNetXmlElement;
    begin
        //-NPR5.51
        XmlElement := XmlDoc.SelectSingleNode('/pos_sale/fields/field[@field_no=' + Format(SalePOS.FieldNo(Date)) + ']');
        XmlElement.InnerText := Format(SalePOS.Date,0,9);
        XmlElement := XmlDoc.SelectSingleNode('/pos_sale/fields/field[@field_no=' + Format(SalePOS.FieldNo("Start Time")) + ']');
        XmlElement.InnerText := Format(SalePOS."Start Time",0,9);
        foreach XmlElement in XmlDoc.SelectNodes('pos_sale/pos_sale_lines/pos_sale_line/fields/field[@field_no=' + Format(SaleLinePOS.FieldNo(Date)) + ']') do
          XmlElement.InnerText := Format(SalePOS.Date,0,9);
        //+NPR5.51
    end;
}

