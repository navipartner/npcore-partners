codeunit 6151004 "POS Action - Save POS Quote"
{
    // NPR5.47/MHA /20181011  CASE 302636 Object created - POS Quote (Saved POS Sale)
    // NPR5.48/MHA /20181129  CASE 336498 Added Customer Info
    // NPR5.48/MHA /20181130  CASE 338208 Added POS Sales Data (.xml) functionality to fully back/restore POS Sale
    // NPR5.48/MHA /20181206  CASE 338537 Added Publisher OnBeforeSaveAsQuote() in OnActionSaveAsQuote()
    // NPR5.50/MHA /20190520  CASE 354507 Some Sale Line POS fields should be reset before delete is possible


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Save POS Sale as POS Quote';
        Text001: Label 'POS Quote';
        Text002: Label 'Save current Sale as POS Quote?';

    local procedure ActionCode(): Text
    begin
        exit ('SAVE_AS_POS_QUOTE');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
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
          Sender.RegisterWorkflowStep('confirm_save_as_quote',
            'if (param.ConfirmBeforeSave) {' +
              'confirm(labels["ConfirmLabel"], param.ConfirmText, true, true).no(abort);' +
            '}'
          );
          Sender.RegisterWorkflowStep('save_as_quote','respond();');
          Sender.RegisterWorkflow(false);
          Sender.RegisterDataSourceBinding('BUILTIN_SALELINE');

          Sender.RegisterBooleanParameter('ConfirmBeforeSave',true);
          Sender.RegisterTextParameter('ConfirmText',Text002);
          Sender.RegisterBooleanParameter('PrintAfterSave',false);
          Sender.RegisterTextParameter('PrintTemplate','');
          //-NPR5.48 [338208]
          Sender.RegisterBooleanParameter('FullBackup',false);
          //+NPR5.48 [338208]
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(),'ConfirmLabel',Text001);
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', true, true)]
    local procedure OnLookupPrintTemplate(var POSParameterValue: Record "POS Parameter Value";Handled: Boolean)
    var
        RPTemplateHeader: Record "RP Template Header";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
          exit;
        if POSParameterValue.Name <> 'PrintTemplate' then
          exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
          exit;

        Handled := true;

        RPTemplateHeader.SetRange("Table ID",DATABASE::"POS Quote Entry");
        if PAGE.RunModal(0,RPTemplateHeader) = ACTION::LookupOK then
          POSParameterValue.Value := RPTemplateHeader.Code;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
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
          'save_as_quote':
            OnActionSaveAsQuote(JSON,POSSession,FrontEnd);
        end;
    end;

    local procedure OnActionSaveAsQuote(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        SalePOS: Record "Sale POS";
        SaleLinePOS: Record "Sale Line POS";
        POSQuoteEntry: Record "POS Quote Entry";
        POSSale: Codeunit "POS Sale";
        RPTemplateHeader: Record "RP Template Header";
        RPTemplateMgt: Codeunit "RP Template Mgt.";
        LineNo: Integer;
        PrintAfterSave: Boolean;
        PrintTemplateCode: Code[20];
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find;

        //-NPR5.48 [338537]
        OnBeforeSaveAsQuote(SalePOS);
        //+NPR5.48 [338537]
        InsertPOSQuoteEntry(SalePOS,POSQuoteEntry);

        SaleLinePOS.SetRange("Register No.",SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindSet then
          repeat
            InsertPOSQuoteLine(SaleLinePOS,POSQuoteEntry,LineNo);
            //-NPR5.50 [354507]
            if SaleLinePOS."Cash Terminal Approved" or SaleLinePOS."From Selection" then begin
              SaleLinePOS."Cash Terminal Approved" := false;
              SaleLinePOS."From Selection" := false;
              SaleLinePOS.Modify;
            end;
            //+NPR5.50 [354507]
            SaleLinePOS.Delete(true);
          until SaleLinePOS.Next = 0;

        SalePOS.Delete(true);
        Commit;
        POSSale.SelectViewForEndOfSale(POSSession);

        PrintAfterSave := JSON.GetBooleanParameter('PrintAfterSave',false);
        if not PrintAfterSave then
          exit;

        PrintTemplateCode := JSON.GetStringParameter('PrintTemplate',false);
        if not RPTemplateHeader.Get(PrintTemplateCode) then
          exit;
        RPTemplateHeader.CalcFields("Table ID");
        if RPTemplateHeader."Table ID" <> DATABASE::"POS Quote Entry" then
          exit;

        POSQuoteEntry.SetRecFilter;
        RPTemplateMgt.PrintTemplate(RPTemplateHeader.Code,POSQuoteEntry,0);
    end;

    local procedure InsertPOSQuoteEntry(SalePOS: Record "Sale POS";var POSQuoteEntry: Record "POS Quote Entry")
    var
        POSQuoteMgt: Codeunit "POS Quote Mgt.";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlDoc: DotNet XmlDocument;
        OutStr: OutStream;
    begin
        POSQuoteEntry.Init;
        POSQuoteEntry."Entry No." := 0;
        POSQuoteEntry."Created at" := CurrentDateTime;
        POSQuoteEntry."Register No." := SalePOS."Register No.";
        POSQuoteEntry."Sales Ticket No." := SalePOS."Sales Ticket No.";
        POSQuoteEntry."Salesperson Code" := SalePOS."Salesperson Code";
        //-NPR5.48 [336498]
        POSQuoteEntry."Customer Type" := SalePOS."Customer Type";
        POSQuoteEntry."Customer No." := SalePOS."Customer No.";
        POSQuoteEntry."Customer Price Group" := SalePOS."Customer Price Group";
        POSQuoteEntry."Customer Disc. Group" := SalePOS."Customer Disc. Group";
        POSQuoteEntry.Attention := SalePOS."Contact No.";
        POSQuoteEntry.Reference := SalePOS.Reference;
        //+NPR5.48 [336498]
        //-NPR5.48 [338208]
        POSQuoteMgt.POSSale2Xml(SalePOS,XmlDoc);
        POSQuoteEntry."POS Sales Data".CreateOutStream(OutStr,TEXTENCODING::UTF8);
        XmlDoc.Save(OutStr);
        //+NPR5.48 [338208]
        POSQuoteEntry.Insert(true);
    end;

    local procedure InsertPOSQuoteLine(SaleLinePOS: Record "Sale Line POS";POSQuoteEntry: Record "POS Quote Entry";var LineNo: Integer)
    var
        POSQuoteLine: Record "POS Quote Line";
    begin
        LineNo += 10000;

        POSQuoteLine.Init;
        POSQuoteLine."Quote Entry No." := POSQuoteEntry."Entry No.";
        POSQuoteLine."Line No." := LineNo;
        //-NPR5.48 [338208]
        POSQuoteLine."Sale Line No." := SaleLinePOS."Line No.";
        POSQuoteLine."Sale Date" := SaleLinePOS.Date;
        POSQuoteLine."Sale Type" := SaleLinePOS."Sale Type";
        //+NPR5.48 [338208]
        POSQuoteLine.Type := SaleLinePOS.Type;
        POSQuoteLine."No." := SaleLinePOS."No.";
        POSQuoteLine."Variant Code" := SaleLinePOS."Variant Code";
        POSQuoteLine.Description := SaleLinePOS.Description;
        POSQuoteLine."Unit of Measure Code" := SaleLinePOS."Unit of Measure Code";
        POSQuoteLine.Quantity := SaleLinePOS.Quantity;
        POSQuoteLine."Price Includes VAT" := SaleLinePOS."Price Includes VAT";
        POSQuoteLine."Currency Code" := SaleLinePOS."Currency Code";
        POSQuoteLine."Unit Price" := SaleLinePOS."Unit Price";
        POSQuoteLine.Amount := SaleLinePOS.Amount;
        POSQuoteLine."Amount Including VAT" := SaleLinePOS."Amount Including VAT";
        //-NPR5.48 [336498]
        POSQuoteLine."Customer Price Group" := SaleLinePOS."Customer Price Group";
        //+NPR5.48 [336498]
        POSQuoteLine."Discount Type" := SaleLinePOS."Discount Type";
        POSQuoteLine."Discount %" := SaleLinePOS."Discount %";
        POSQuoteLine."Discount Amount" := SaleLinePOS."Discount Amount";
        POSQuoteLine."Discount Code" := SaleLinePOS."Discount Code";
        POSQuoteLine."Discount Authorised by" := SaleLinePOS."Discount Authorised by";
        POSQuoteLine.Insert(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSaveAsQuote(var SalePOS: Record "Sale POS")
    begin
        //-NPR5.48 [338537]
        //+NPR5.48 [338537]
    end;
}

