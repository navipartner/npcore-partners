codeunit 6151005 "NPR POS Action: Load POS Quote"
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
    // NPR5.53/MHA /20200113  CASE 384104 Removed SetLast in the event that there are no lines in selected view
    // NPR5.53/ALPO/20200129  CASE 388112 The sub-total on the POS Sales screen was not updated after retrieving POS Quote onto sale screen
    // NPR5.54/ALPO/20200203  CASE 364658 Part of the code moved from OnActionLoadFromQuote() to a separate global function LoadFromQuote() to be able to call it from outside of the object
    // NPR5.54/ALST/20200305  CASE 385040 no reason to get location or department code (shortcut dim 1) from POS Quote for a POS Sale
    // NPR5.55/ALPO/20200615  CASE 399170 Added publisher OnBeforeLoadFromPOSQuote(); POS Sale header was not refreshed properly
    // NPR5.55/ALPO/20200720  CASE 391678 Log parked sale retrieval to POS Entry
    // NPR5.55/ALPO/20200722  CASE 392042 Removed legacy functionality with load from hardcoded fields


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Load POS Sale from POS Quote';
        Text001: Label 'POS Quote';
        CannotLoad: Label 'The POS Quote is missing essential data and cannot be loaded.';
        ObsoleteFunctionCalledMsg: Label 'Obsolete function called: %1.\This is a programming bug, not a user error. Please contact system vendor.';

    local procedure ActionCode(): Text
    begin
        exit('LOAD_FROM_POS_QUOTE');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.4'); //-+NPR5.51 [364694]
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
            //-NPR5.51 [364694]
            Sender.RegisterOptionParameter('Filter', 'All,Register,Salesperson,Register+Salesperson', 'Register');
            //+NPR5.51 [364694]
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
        //-NPR5.51 [364694]
        //POSQuoteMgt.SetSalePOSFilter(SalePOS,POSQuoteEntry);
        Filter := JSON.GetIntegerParameter('Filter', true);
        POSQuoteMgt.SetSalePOSFilter(SalePOS, POSQuoteEntry, Filter);
        //+NPR5.51 [364694]

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
        POSQuoteLine: Record "NPR POS Quote Line";
        PageMgt: Codeunit "Page Management";
        QuoteEntryNo: BigInteger;
    begin
        QuoteEntryNo := JSON.GetInteger('quote_entry_no', false);
        if QuoteEntryNo = 0 then
            exit;

        if not POSQuoteEntry.Get(QuoteEntryNo) then
            exit;

        POSQuoteLine.SetRange("Quote Entry No.", QuoteEntryNo);
        if PAGE.RunModal(0, POSQuoteLine) <> ACTION::LookupOK then begin
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

        if LoadFromQuote(POSQuoteEntry, SalePOS) then begin  //NPR5.54 [364658]
                                                             //-NPR5.54 [364658]-revoked
                                                             /*
                                                             //-NPR5.51 [364694]
                                                             POSQuoteEntry.SkipLineDeleteTrigger(TRUE);
                                                             //+NPR5.51 [364694]

                                                             //-NPR5.48 [338208]
                                                             IF POSQuoteMgt.LoadPOSSaleData(POSQuoteEntry,XmlDoc) THEN BEGIN
                                                               DeletePOSSalesLines(SalePOS);
                                                               //-NPR5.51
                                                               UpdateDates(XmlDoc,SalePOS);
                                                               //+NPR5.51
                                                               POSQuoteMgt.Xml2POSSale(XmlDoc,SalePOS);
                                                               //-NPR5.49 [331208]
                                                               OnAfterLoadFromQuote(POSQuoteEntry,SalePOS);
                                                               //+NPR5.49 [331208]
                                                               POSQuoteEntry.DELETE(TRUE);
                                                             */
                                                             //+NPR5.54 [364658]-revoked

            //-NPR5.54 [385040]
            Register.Get(SalePOS."Register No.");
            SalePOS."Location Code" := Register."Location Code";

            // reload proper dimensions
            POSSale.GetCurrentSale(SalePOS2);

            SalePOS.Validate("POS Store Code", SalePOS2."POS Store Code");
            SalePOS.Modify;
            //+NPR5.54 [385040]

            POSSale.Refresh(SalePOS);
            POSSale.SetModified();  //NPR5.55 [399170]

            //-NPR5.50
            POSSession.GetSaleLine(POSSaleLine);
            //POSSaleLine.GetCurrentSaleLine(SaleLinePOS);  //NPR5.53 [388112]-revoked
            //-NPR5.53 [384104]
            //POSSaleLine.SetLast();
            //+NPR5.53 [384104]
            //+NPR5.50
            //-NPR5.53 [388112]
            SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
            SaleLinePOS.SetFilter(Type, '<>%1', SaleLinePOS.Type::Payment);
            if not SaleLinePOS.IsEmpty then
                POSSaleLine.SetLast();
            //+NPR5.53 [388112]

            //-NPR5.55 [391678]
            POSCreateEntry.InsertParkedSaleRetrievalEntry(
              SalePOS."Register No.", SalePOS."Salesperson Code", POSQuoteEntry."Sales Ticket No.", SalePOS."Sales Ticket No.");
            //+NPR5.55 [391678]
            POSSession.RequestRefreshData();
            exit;
        end;
        //+NPR5.48 [338208]

        Error(CannotLoad);  //NPR5.55 [392042]
        //-NPR5.55 [392042]-revoked
        /*
        //-NPR5.48 [336498]
        UpdatePOSSale(POSQuoteEntry,SalePOS);
        //+NPR5.48 [336498]
        POSSession.GetSaleLine(POSSaleLine);
        
        POSQuoteLine.SETRANGE("Quote Entry No.",POSQuoteEntry."Entry No.");
        IF POSQuoteLine.FINDSET THEN
          REPEAT
            //-NPR5.48 [336498]
            //InsertPOSSaleLinePOS(POSQuoteLine,POSSaleLine);
            InsertPOSSaleLine(POSQuoteLine,POSSaleLine);
            //+NPR5.48 [336498]
          UNTIL POSQuoteLine.NEXT = 0;
        
        //-NPR5.48 [338537]
        OnAfterLoadFromQuote(POSQuoteEntry,SalePOS);
        //+NPR5.48 [338537]
        
        POSQuoteEntry.DELETE(TRUE);
        //-NPR5.48 [336498]
        POSSale.Refresh(SalePOS);
        //+NPR5.48 [336498]
        POSSession.RequestRefreshData();
        */
        //+NPR5.55 [392042]-revoked

    end;

    local procedure DeletePOSSalesLines(SalePOS: Record "NPR Sale POS")
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        //-NPR5.48 [338208]
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindFirst then
            SaleLinePOS.DeleteAll(true);
        //+NPR5.48 [338208]
    end;

    local procedure "[Obsolete]UpdatePOSSale"(POSQuoteEntry: Record "NPR POS Quote Entry"; var SalePOS: Record "NPR Sale POS")
    var
        PrevRec: Text;
    begin
        Error(ObsoleteFunctionCalledMsg, '6151005.[Obsolete]UpdatePOSSale');  //NPR5.55 [392042]
        //-NPR5.55 [392042]-revoked
        /*
        //-NPR5.48 [336498]
        PrevRec := FORMAT(SalePOS);
        
        IF POSQuoteEntry."Customer No." <> '' THEN BEGIN
          SalePOS."Customer Type" := POSQuoteEntry."Customer Type";
          SalePOS.VALIDATE("Customer No.",POSQuoteEntry."Customer No.");
          SalePOS."Contact No." := POSQuoteEntry.Attention;
          SalePOS.Reference := POSQuoteEntry.Reference;
        END;
        
        IF POSQuoteEntry."Customer Price Group" <> '' THEN
          SalePOS.VALIDATE("Customer Price Group",POSQuoteEntry."Customer Price Group");
        IF POSQuoteEntry."Customer Disc. Group" <> '' THEN
          SalePOS.VALIDATE("Customer Disc. Group",POSQuoteEntry."Customer Disc. Group");
        
        IF PrevRec <> FORMAT(SalePOS) THEN
          SalePOS.MODIFY(TRUE);
        //+NPR5.48 [336498]
        */
        //+NPR5.55 [392042]-revoked

    end;

    local procedure "[Obsolete]InsertPOSSaleLine"(POSQuoteLine: Record "NPR POS Quote Line"; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        Error(ObsoleteFunctionCalledMsg, '6151005.[Obsolete]InsertPOSSaleLine');  //NPR5.55 [392042]
        //-NPR5.55 [392042]-revoked
        /*
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        
        SaleLinePOS.VALIDATE(Type,POSQuoteLine.Type);
        SaleLinePOS.VALIDATE("No.",POSQuoteLine."No.");
        SaleLinePOS.VALIDATE("Variant Code",POSQuoteLine."Variant Code");
        SaleLinePOS.Description := POSQuoteLine.Description;
        SaleLinePOS.VALIDATE("Unit of Measure Code",POSQuoteLine."Unit of Measure Code");
        //-NPR5.48 [336498]
        SaleLinePOS.VALIDATE("Customer Price Group",POSQuoteLine."Customer Price Group");
        //+NPR5.48 [336498]
        SaleLinePOS.VALIDATE(Quantity,POSQuoteLine.Quantity);
        SaleLinePOS."Price Includes VAT" := POSQuoteLine."Price Includes VAT";
        SaleLinePOS.VALIDATE("Currency Code",POSQuoteLine."Currency Code");
        SaleLinePOS.VALIDATE("Unit Price",POSQuoteLine."Unit Price");
        SaleLinePOS.VALIDATE(Amount,POSQuoteLine.Amount);
        SaleLinePOS.VALIDATE("Amount Including VAT",POSQuoteLine."Amount Including VAT");
        SaleLinePOS."Discount Type" := POSQuoteLine."Discount Type";
        SaleLinePOS."Discount %" := POSQuoteLine."Discount %";
        SaleLinePOS."Discount Amount" := POSQuoteLine."Discount Amount";
        SaleLinePOS."Discount Code" := POSQuoteLine."Discount Code";
        SaleLinePOS."Discount Authorised by" := POSQuoteLine."Discount Authorised by";
        SaleLinePOS.INSERT(TRUE);
        POSSaleLine.InvokeOnAfterInsertSaleLineWorkflow(SaleLinePOS);
        */
        //+NPR5.55 [392042]-revoked

    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLoadFromPOSQuote(var SalePOS: Record "NPR Sale POS"; var POSQuoteEntry: Record "NPR POS Quote Entry"; var XmlDoc: DotNet "NPRNetXmlDocument")
    begin
        //-NPR5.55 [399170]
        //+NPR5.55 [399170]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterLoadFromQuote(POSQuoteEntry: Record "NPR POS Quote Entry"; var SalePOS: Record "NPR Sale POS")
    begin
        //-NPR5.48 [338537]
        //+NPR5.48 [338537]
    end;

    local procedure UpdateDates(var XmlDoc: DotNet "NPRNetXmlDocument"; SalePOS: Record "NPR Sale POS")
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        XmlElement: DotNet NPRNetXmlElement;
    begin
        //-NPR5.51
        XmlElement := XmlDoc.SelectSingleNode('/pos_sale/fields/field[@field_no=' + Format(SalePOS.FieldNo(Date)) + ']');
        XmlElement.InnerText := Format(SalePOS.Date, 0, 9);
        XmlElement := XmlDoc.SelectSingleNode('/pos_sale/fields/field[@field_no=' + Format(SalePOS.FieldNo("Start Time")) + ']');
        XmlElement.InnerText := Format(SalePOS."Start Time", 0, 9);
        foreach XmlElement in XmlDoc.SelectNodes('pos_sale/pos_sale_lines/pos_sale_line/fields/field[@field_no=' + Format(SaleLinePOS.FieldNo(Date)) + ']') do
            XmlElement.InnerText := Format(SalePOS.Date, 0, 9);
        //+NPR5.51
    end;

    procedure LoadFromQuote(var POSQuoteEntry: Record "NPR POS Quote Entry"; var SalePOS: Record "NPR Sale POS"): Boolean
    var
        POSQuoteMgt: Codeunit "NPR POS Quote Mgt.";
        XmlDoc: DotNet "NPRNetXmlDocument";
    begin
        //-NPR5.54 [364658]
        POSQuoteEntry.SkipLineDeleteTrigger(true);

        if not POSQuoteMgt.LoadPOSSaleData(POSQuoteEntry, XmlDoc) then
            exit(false);

        OnBeforeLoadFromPOSQuote(SalePOS, POSQuoteEntry, XmlDoc);  //NPR5.55 [399170]
        DeletePOSSalesLines(SalePOS);
        UpdateDates(XmlDoc, SalePOS);
        POSQuoteMgt.Xml2POSSale(XmlDoc, SalePOS);
        OnAfterLoadFromQuote(POSQuoteEntry, SalePOS);
        POSQuoteEntry.Delete(true);

        exit(true);
        //+NPR5.54 [364658]
    end;
}

