codeunit 6151004 "NPR POS Action: SavePOSSvSl"
{
    var
        Text000: Label 'Save POS Sale as POS Saved Sale';
        Text001: Label 'POS Saved Sale';
        Text002: Label 'Save current Sale as POS Saved Sale?';
        SaleWasParkedTxt: Label 'Sale was saved as POS Saved Sale (parked) at %1';
        ErrorCancelling: Label 'System was not able to cancel current sale after parking. Please do it manually.';

    local procedure ActionCode(): Text
    begin
        exit('SAVE_AS_POS_QUOTE');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
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
            Sender.RegisterWorkflowStep('save_as_quote', 'respond();');
            Sender.RegisterWorkflow(false);
            Sender.RegisterDataSourceBinding('BUILTIN_SALELINE');

            Sender.RegisterBooleanParameter('ConfirmBeforeSave', true);
            Sender.RegisterTextParameter('ConfirmText', Text002);
            Sender.RegisterBooleanParameter('PrintAfterSave', false);
            Sender.RegisterTextParameter('PrintTemplate', '');
            Sender.RegisterBooleanParameter('FullBackup', false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'ConfirmLabel', Text001);
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', true, true)]
    local procedure OnLookupPrintTemplate(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        RPTemplateHeader: Record "NPR RP Template Header";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'PrintTemplate' then
            exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
            exit;

        Handled := true;

        RPTemplateHeader.SetRange("Table ID", DATABASE::"NPR POS Saved Sale Entry");
        if PAGE.RunModal(0, RPTemplateHeader) = ACTION::LookupOK then
            POSParameterValue.Value := RPTemplateHeader.Code;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        case WorkflowStep of
            'save_as_quote':
                OnActionSaveAsQuote(JSON, POSSession, FrontEnd);
        end;
    end;

    local procedure OnActionSaveAsQuote(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        SalePOS: Record "NPR POS Sale";
        POSQuoteEntry: Record "NPR POS Saved Sale Entry";
        POSActionCancelSale: Codeunit "NPR POSAction: Cancel Sale";
        POSSale: Codeunit "NPR POS Sale";
        RPTemplateHeader: Record "NPR RP Template Header";
        RPTemplateMgt: Codeunit "NPR RP Template Mgt.";
        PrintAfterSave: Boolean;
        PrintTemplateCode: Code[20];
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find();

        CreatePOSQuote(SalePOS, POSQuoteEntry);

        Commit();
        Clear(POSActionCancelSale);
        POSActionCancelSale.SetAlternativeDescription(StrSubstNo(SaleWasParkedTxt, CurrentDateTime));
        if not POSActionCancelSale.CancelSale(POSSession) then
            Error(ErrorCancelling);

        Commit();
        POSSale.SelectViewForEndOfSale(POSSession);

        PrintAfterSave := JSON.GetBooleanParameter('PrintAfterSave');
        if not PrintAfterSave then
            exit;

        PrintTemplateCode := JSON.GetStringParameter('PrintTemplate');
        if not RPTemplateHeader.Get(PrintTemplateCode) then
            exit;
        RPTemplateHeader.CalcFields("Table ID");
        if RPTemplateHeader."Table ID" <> DATABASE::"NPR POS Saved Sale Entry" then
            exit;

        POSQuoteEntry.SetRecFilter();
        RPTemplateMgt.PrintTemplate(RPTemplateHeader.Code, POSQuoteEntry, 0);

    end;

    procedure CreatePOSQuote(SalePOS: Record "NPR POS Sale"; var POSQuoteEntry: Record "NPR POS Saved Sale Entry")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        LineNo: Integer;
    begin
        OnBeforeSaveAsQuote(SalePOS);

        InsertPOSQuoteEntry(SalePOS, POSQuoteEntry);

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindSet() then
            repeat
                InsertPOSQuoteLine(SaleLinePOS, POSQuoteEntry, LineNo);
                if SaleLinePOS."EFT Approved" or SaleLinePOS."From Selection" then begin
                    SaleLinePOS."EFT Approved" := false;
                    SaleLinePOS."From Selection" := false;
                    SaleLinePOS.Modify();
                end;
                SaleLinePOS.Delete(true);
            until SaleLinePOS.Next() = 0;
    end;

    local procedure InsertPOSQuoteEntry(SalePOS: Record "NPR POS Sale"; var POSQuoteEntry: Record "NPR POS Saved Sale Entry")
    var
        POSQuoteMgt: Codeunit "NPR POS Saved Sale Mgt.";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlDoc: XmlDocument;
        OutStr: OutStream;
    begin
        POSQuoteEntry.Init();
        POSQuoteEntry."Entry No." := 0;
        POSQuoteEntry."Created at" := CurrentDateTime;
        POSQuoteEntry."Register No." := SalePOS."Register No.";
        POSQuoteEntry."Sales Ticket No." := SalePOS."Sales Ticket No.";
        POSQuoteEntry."Salesperson Code" := SalePOS."Salesperson Code";
        POSQuoteEntry."Customer Type" := SalePOS."Customer Type";
        POSQuoteEntry."Customer No." := SalePOS."Customer No.";
        POSQuoteEntry."Customer Price Group" := SalePOS."Customer Price Group";
        POSQuoteEntry."Customer Disc. Group" := SalePOS."Customer Disc. Group";
        POSQuoteEntry.Attention := SalePOS."Contact No.";
        POSQuoteEntry.Reference := SalePOS.Reference;
        POSQuoteEntry."Retail ID" := SalePOS."Retail ID";
        POSQuoteMgt.POSSale2Xml(SalePOS, XmlDoc);
        POSQuoteEntry."POS Sales Data".CreateOutStream(OutStr, TEXTENCODING::UTF8);
        XmlDoc.WriteTo(OutStr);
        POSQuoteEntry.Insert(true);
    end;

    local procedure InsertPOSQuoteLine(SaleLinePOS: Record "NPR POS Sale Line"; POSQuoteEntry: Record "NPR POS Saved Sale Entry"; var LineNo: Integer)
    var
        POSQuoteLine: Record "NPR POS Saved Sale Line";
    begin
        LineNo += 10000;

        POSQuoteLine.Init();
        POSQuoteLine."Quote Entry No." := POSQuoteEntry."Entry No.";
        POSQuoteLine."Line No." := LineNo;
        POSQuoteLine."Sale Line No." := SaleLinePOS."Line No.";
        POSQuoteLine."Sale Date" := SaleLinePOS.Date;
        POSQuoteLine."Sale Type" := SaleLinePOS."Sale Type";
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
        POSQuoteLine."Customer Price Group" := SaleLinePOS."Customer Price Group";
        POSQuoteLine."Discount Type" := SaleLinePOS."Discount Type";
        POSQuoteLine."Discount %" := SaleLinePOS."Discount %";
        POSQuoteLine."Discount Amount" := SaleLinePOS."Discount Amount";
        POSQuoteLine."Discount Code" := SaleLinePOS."Discount Code";
        POSQuoteLine."Discount Authorised by" := SaleLinePOS."Discount Authorised by";
        POSQuoteLine."EFT Approved" := SaleLinePOS."EFT Approved";
        POSQuoteLine."Line Retail ID" := SaleLinePOS."Retail ID";
        POSQuoteLine.Insert(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSaveAsQuote(var SalePOS: Record "NPR POS Sale")
    begin
        //-NPR5.48 [338537]
        //+NPR5.48 [338537]
    end;
}

