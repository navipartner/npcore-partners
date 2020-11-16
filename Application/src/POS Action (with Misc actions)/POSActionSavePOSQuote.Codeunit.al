codeunit 6151004 "NPR POS Action: SavePOSQuote"
{
    // NPR5.47/MHA /20181011  CASE 302636 Object created - POS Quote (Saved POS Sale)
    // NPR5.48/MHA /20181129  CASE 336498 Added Customer Info
    // NPR5.48/MHA /20181130  CASE 338208 Added POS Sales Data (.xml) functionality to fully back/restore POS Sale
    // NPR5.48/MHA /20181206  CASE 338537 Added Publisher OnBeforeSaveAsQuote() in OnActionSaveAsQuote()
    // NPR5.50/MHA /20190520  CASE 354507 Some Sale Line POS fields should be reset before delete is possible
    // NPR5.51/MMV /20190820  CASE 364694 Handle EFT approvals
    // NPR5.54/ALPO/20200203  CASE 364658 Part of the code moved from OnActionSaveAsQuote() to a separate global function CreatePOSQuote() to be able to call it from outside of the object
    // NPR5.54/MMV /20200320 CASE 364340 Added explicit "Retail ID" fields
    // NPR5.55/ALPO/20200720 CASE 391678 Record a cancelled sales ticket to POS Entry on Sale POS park


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Save POS Sale as POS Quote';
        Text001: Label 'POS Quote';
        Text002: Label 'Save current Sale as POS Quote?';
        SaleWasParkedTxt: Label 'Sale was saved as POS Quote (parked) at %1';
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
            Sender.RegisterWorkflowStep('save_as_quote', 'respond();');
            Sender.RegisterWorkflow(false);
            Sender.RegisterDataSourceBinding('BUILTIN_SALELINE');

            Sender.RegisterBooleanParameter('ConfirmBeforeSave', true);
            Sender.RegisterTextParameter('ConfirmText', Text002);
            Sender.RegisterBooleanParameter('PrintAfterSave', false);
            Sender.RegisterTextParameter('PrintTemplate', '');
            //-NPR5.48 [338208]
            Sender.RegisterBooleanParameter('FullBackup', false);
            //+NPR5.48 [338208]
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

        RPTemplateHeader.SetRange("Table ID", DATABASE::"NPR POS Quote Entry");
        if PAGE.RunModal(0, RPTemplateHeader) = ACTION::LookupOK then
            POSParameterValue.Value := RPTemplateHeader.Code;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
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
            'save_as_quote':
                OnActionSaveAsQuote(JSON, POSSession, FrontEnd);
        end;
    end;

    local procedure OnActionSaveAsQuote(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        SalePOS: Record "NPR Sale POS";
        POSQuoteEntry: Record "NPR POS Quote Entry";
        POSActionCancelSale: Codeunit "NPR POSAction: Cancel Sale";
        POSSale: Codeunit "NPR POS Sale";
        RPTemplateHeader: Record "NPR RP Template Header";
        RPTemplateMgt: Codeunit "NPR RP Template Mgt.";
        PrintAfterSave: Boolean;
        PrintTemplateCode: Code[20];
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find;

        //-NPR5.54 [364658]-revoked
        /*
        //-NPR5.48 [338537]
        OnBeforeSaveAsQuote(SalePOS);
        //+NPR5.48 [338537]
        InsertPOSQuoteEntry(SalePOS,POSQuoteEntry);
        
        SaleLinePOS.SETRANGE("Register No.",SalePOS."Register No.");
        SaleLinePOS.SETRANGE("Sales Ticket No.",SalePOS."Sales Ticket No.");
        IF SaleLinePOS.FINDSET THEN
          REPEAT
            InsertPOSQuoteLine(SaleLinePOS,POSQuoteEntry,LineNo);
            //-NPR5.50 [354507]
            IF SaleLinePOS."EFT Approved" OR SaleLinePOS."From Selection" THEN BEGIN
              SaleLinePOS."EFT Approved" := FALSE;
              SaleLinePOS."From Selection" := FALSE;
              SaleLinePOS.MODIFY;
            END;
            //+NPR5.50 [354507]
            SaleLinePOS.DELETE(TRUE);
          UNTIL SaleLinePOS.NEXT = 0;
        
        SalePOS.DELETE(TRUE);
        */
        //+NPR5.54 [364658]-revoked
        CreatePOSQuote(SalePOS, POSQuoteEntry);  //NPR5.54 [364658]

        //-NPR5.55 [391678]
        Commit;
        Clear(POSActionCancelSale);
        POSActionCancelSale.SetAlternativeDescription(StrSubstNo(SaleWasParkedTxt, CurrentDateTime));
        if not POSActionCancelSale.CancelSale(POSSession) then
            Error(ErrorCancelling);
        //+NPR5.55 [391678]

        Commit;
        POSSale.SelectViewForEndOfSale(POSSession);

        PrintAfterSave := JSON.GetBooleanParameter('PrintAfterSave', false);
        if not PrintAfterSave then
            exit;

        PrintTemplateCode := JSON.GetStringParameter('PrintTemplate', false);
        if not RPTemplateHeader.Get(PrintTemplateCode) then
            exit;
        RPTemplateHeader.CalcFields("Table ID");
        if RPTemplateHeader."Table ID" <> DATABASE::"NPR POS Quote Entry" then
            exit;

        POSQuoteEntry.SetRecFilter;
        RPTemplateMgt.PrintTemplate(RPTemplateHeader.Code, POSQuoteEntry, 0);

    end;

    procedure CreatePOSQuote(SalePOS: Record "NPR Sale POS"; var POSQuoteEntry: Record "NPR POS Quote Entry")
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        LineNo: Integer;
    begin
        //-NPR5.54 [364658]
        OnBeforeSaveAsQuote(SalePOS);

        InsertPOSQuoteEntry(SalePOS, POSQuoteEntry);

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindSet then
            repeat
                InsertPOSQuoteLine(SaleLinePOS, POSQuoteEntry, LineNo);
                if SaleLinePOS."EFT Approved" or SaleLinePOS."From Selection" then begin
                    SaleLinePOS."EFT Approved" := false;
                    SaleLinePOS."From Selection" := false;
                    SaleLinePOS.Modify;
                end;
                SaleLinePOS.Delete(true);
            until SaleLinePOS.Next = 0;

        //SalePOS.DELETE(TRUE);  //NPR5.55 [391678]-revoked
        //+NPR5.54 [364658]
    end;

    local procedure InsertPOSQuoteEntry(SalePOS: Record "NPR Sale POS"; var POSQuoteEntry: Record "NPR POS Quote Entry")
    var
        POSQuoteMgt: Codeunit "NPR POS Quote Mgt.";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlDoc: DotNet "NPRNetXmlDocument";
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
        //-NPR5.54 [364340]
        POSQuoteEntry."Retail ID" := SalePOS."Retail ID";
        //+NPR5.54 [364340]
        //+NPR5.48 [336498]
        //-NPR5.48 [338208]
        POSQuoteMgt.POSSale2Xml(SalePOS, XmlDoc);
        POSQuoteEntry."POS Sales Data".CreateOutStream(OutStr, TEXTENCODING::UTF8);
        XmlDoc.Save(OutStr);
        //+NPR5.48 [338208]
        POSQuoteEntry.Insert(true);
    end;

    local procedure InsertPOSQuoteLine(SaleLinePOS: Record "NPR Sale Line POS"; POSQuoteEntry: Record "NPR POS Quote Entry"; var LineNo: Integer)
    var
        POSQuoteLine: Record "NPR POS Quote Line";
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
        //-NPR5.51 [364694]
        POSQuoteLine."EFT Approved" := SaleLinePOS."EFT Approved";
        //+NPR5.51 [364694]
        //-NPR5.54 [364340]
        POSQuoteLine."Line Retail ID" := SaleLinePOS."Retail ID";
        //+NPR5.54 [364340]
        POSQuoteLine.Insert(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSaveAsQuote(var SalePOS: Record "NPR Sale POS")
    begin
        //-NPR5.48 [338537]
        //+NPR5.48 [338537]
    end;
}

