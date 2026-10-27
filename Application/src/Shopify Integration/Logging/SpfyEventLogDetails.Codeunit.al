codeunit 6151569 "NPR Spfy Event Log Details"
{
    Access = Internal;

    internal procedure BuildDetails(var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry") Details: JsonObject
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        EcomDocFound: Boolean;
        EcomError: Text;
    begin
        EcomDocFound := SpfyEventLogDocProcessr.GetCreatedEcommerceDoc(SpfyEventLogEntry, EcomSalesHeader);
        if EcomDocFound then
            EcomError := EcomDocumentError(EcomSalesHeader);

        Details.Add('entryNo', SpfyEventLogEntry."Entry No.");
        Details.Add('processingStatus', Format(SpfyEventLogEntry."Processing Status"));
        Details.Add('hasError', SpfyEventLogEntry."Processing Status" = SpfyEventLogEntry."Processing Status"::Error);
        Details.Add('isPostponed', SpfyEventLogEntry."Processing Status" = SpfyEventLogEntry."Processing Status"::Postponed);
        Details.Add('errorMessage', SpfyEventLogEntry."Last Error Message");
        Details.Add('errorAt', Format(SpfyEventLogEntry."Last Error Date"));
        Details.Add('retries', SpfyEventLogEntry."Process Retry Count");
        Details.Add('maxRetries', SpfyIntegrationMgt.GetMaxDocRetryCount());
        Details.Add('ecomError', EcomError);

        Details.Add('documentName', SpfyEventLogEntry."Document Name");
        Details.Add('storeCode', SpfyEventLogEntry."Store Code");
        Details.Add('externalNo', SpfyEventLogEntry."Shopify ID");
        Details.Add('eventDate', Format(DT2Date(SpfyEventLogEntry."Event Date-Time")));
        Details.Add('closedAt', Format(SpfyEventLogEntry."Closed Date-Time"));
        Details.Add('cancelledAt', Format(SpfyEventLogEntry."Cancelled Date"));
        Details.Add('amountSCY', AmountText(SpfyEventLogEntry."Amount (SCY)", SpfyEventLogEntry."Store Currency Code"));
        Details.Add('amountLCY', AmountText(SpfyEventLogEntry."Amount (LCY)", ''));
        AddOrderHistory(Details, SpfyEventLogEntry);

        Details.Add('steps', PipelineSteps(SpfyEventLogEntry, EcomSalesHeader, EcomDocFound));
    end;

    internal procedure BuildLabels() Labels: JsonObject
    var
        SpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
        PanelTitleLbl: Label 'Details — Entry %1', Comment = '%1 = Entry No.';
        EmptyPanelLbl: Label 'Select an entry to see its details.';
        LoadErrorLbl: Label 'Could not read entry details.';
        DocumentSectionLbl: Label 'Document';
        PipelineSectionLbl: Label 'Pipeline';
        ExternalNoLbl: Label 'External No.';
        EventDateLbl: Label 'Event Date';
        ErrorCardTitleLbl: Label 'Processing Error';
        PostponedCardTitleLbl: Label 'Processing Postponed';
        EcomErrorCardTitleLbl: Label 'Ecommerce Document Error';
        OpenEcomDocumentLbl: Label 'Open ecommerce document';
        LastErrorLbl: Label 'Last error: %1', Comment = '%1 = date of the last error';
        RetriesLbl: Label 'Retries %1 / %2', Comment = '%1 = retries so far, %2 = maximum number of retries';
        RetryButtonLbl: Label 'Retry now';
        ShowErrorButtonLbl: Label 'Show error';
        VirtualTagLbl: Label 'virtual';
        OrderHistoryLbl: Label 'Order history';
        OrderEventPositionLbl: Label 'Event %1 of %2', Comment = '%1 = position of this entry among the entries of the same Shopify document, %2 = number of those entries';
    begin
        Labels.Add('panelTitle', PanelTitleLbl);
        Labels.Add('emptyPanel', EmptyPanelLbl);
        Labels.Add('loadError', LoadErrorLbl);
        Labels.Add('documentSection', DocumentSectionLbl);
        Labels.Add('pipelineSection', PipelineSectionLbl);
        Labels.Add('documentName', SpfyEventLogEntry.FieldCaption("Document Name"));
        Labels.Add('storeCode', SpfyEventLogEntry.FieldCaption("Store Code"));
        Labels.Add('externalNo', ExternalNoLbl);
        Labels.Add('eventDate', EventDateLbl);
        Labels.Add('closedAt', SpfyEventLogEntry.FieldCaption("Closed Date-Time"));
        Labels.Add('cancelledAt', SpfyEventLogEntry.FieldCaption("Cancelled Date"));
        Labels.Add('amountSCY', SpfyEventLogEntry.FieldCaption("Amount (SCY)"));
        Labels.Add('amountLCY', SpfyEventLogEntry.FieldCaption("Amount (LCY)"));
        Labels.Add('errorCardTitle', ErrorCardTitleLbl);
        Labels.Add('postponedCardTitle', PostponedCardTitleLbl);
        Labels.Add('ecomErrorCardTitle', EcomErrorCardTitleLbl);
        Labels.Add('openEcomDocument', OpenEcomDocumentLbl);
        Labels.Add('lastError', LastErrorLbl);
        Labels.Add('retries', RetriesLbl);
        Labels.Add('retryButton', RetryButtonLbl);
        Labels.Add('showErrorButton', ShowErrorButtonLbl);
        Labels.Add('tagVirtual', VirtualTagLbl);
        Labels.Add('orderHistory', OrderHistoryLbl);
        Labels.Add('orderEventPosition', OrderEventPositionLbl);
    end;

    local procedure AddOrderHistory(var Details: JsonObject; SpfyEventLogEntry: Record "NPR Spfy Event Log Entry")
    var
        OrderEvents: Record "NPR Spfy Event Log Entry";
        SpfyEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
        EventCount: Integer;
        EventIndex: Integer;
    begin
        if SpfyEventLogEntry."Shopify ID" <> '' then begin
            SpfyEventLogMgt.SetOrderHistoryFilter(SpfyEventLogEntry, OrderEvents);
            OrderEvents.SetLoadFields("Entry No.");
            if OrderEvents.FindSet() then
                repeat
                    EventCount += 1;
                    if OrderEvents."Entry No." = SpfyEventLogEntry."Entry No." then
                        EventIndex := EventCount;
                until OrderEvents.Next() = 0;
        end;

        Details.Add('orderEventCount', EventCount);
        Details.Add('orderEventIndex', EventIndex);
    end;

    local procedure PipelineSteps(SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"; EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomDocFound: Boolean) Steps: JsonArray
    var
        NoEcomDocLbl: Label 'Completed without an ecommerce document';
    begin
        if not EcomDocFound and (SpfyEventLogEntry."Processing Status" = SpfyEventLogEntry."Processing Status"::Processed) then begin
            AddStep(Steps, 'noEcomDoc', 'done', NoEcomDocLbl, '', '');
            exit;
        end;
        AddEcomDocStep(Steps, SpfyEventLogEntry, EcomDocFound);
        if EcomDocFound and EcomSalesHeader."Virtual Items Exist" then begin
            AddCaptureStep(Steps, EcomSalesHeader);
            AddVirtualItemsStep(Steps, EcomSalesHeader);
        end;
        AddSalesDocStep(Steps, EcomSalesHeader);
        AddPostedStep(Steps, EcomSalesHeader);
        AddCompletedStep(Steps, SpfyEventLogEntry, EcomDocFound);
    end;

    local procedure AddEcomDocStep(var Steps: JsonArray; SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"; EcomDocFound: Boolean)
    var
        DoneLbl: Label 'Ecommerce document created';
        FailedLbl: Label 'Processing failed before the ecommerce document was created';
        PendingLbl: Label 'Ecommerce document not created';
    begin
        case true of
            EcomDocFound:
                AddStep(Steps, 'ecomDoc', 'done', DoneLbl, '', '');
            SpfyEventLogEntry."Processing Status" = SpfyEventLogEntry."Processing Status"::Error:
                AddStep(Steps, 'ecomDoc', 'failed', FailedLbl, '', FirstLine(SpfyEventLogEntry."Last Error Message"));
            else
                AddStep(Steps, 'ecomDoc', 'pending', PendingLbl, '', '');
        end;
    end;

    local procedure AddCaptureStep(var Steps: JsonArray; EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        DoneLbl: Label 'Capture processed';
        PartialLbl: Label 'Capture partially processed';
        FailedLbl: Label 'Capture failed';
        PendingLbl: Label 'Capture pending';
    begin
        case EcomSalesHeader."Capture Processing Status" of
            EcomSalesHeader."Capture Processing Status"::Processed:
                AddStep(Steps, 'capture', 'done', DoneLbl, 'virtual', '');
            EcomSalesHeader."Capture Processing Status"::"Partially Processed":
                AddStep(Steps, 'capture', 'partial', PartialLbl, 'virtual', '');
            EcomSalesHeader."Capture Processing Status"::Error:
                AddStep(Steps, 'capture', 'failed', FailedLbl, 'virtual', FirstLine(EcomSalesHeader."Last Capture Error Message"));
            else
                AddStep(Steps, 'capture', 'pending', PendingLbl, 'virtual', '');
        end;
    end;

    local procedure AddVirtualItemsStep(var Steps: JsonArray; EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        DoneLbl: Label 'Virtual items processed';
        PartialLbl: Label 'Virtual items partially processed';
        FailedLbl: Label 'Virtual items failed';
        PendingLbl: Label 'Virtual items pending';
    begin
        case EcomSalesHeader."Virtual Items Process Status" of
            EcomSalesHeader."Virtual Items Process Status"::Processed:
                AddStep(Steps, 'virtualItems', 'done', DoneLbl, 'virtual', '');
            EcomSalesHeader."Virtual Items Process Status"::"Partially Processed":
                AddStep(Steps, 'virtualItems', 'partial', PartialLbl, 'virtual', '');
            EcomSalesHeader."Virtual Items Process Status"::Error:
                AddStep(Steps, 'virtualItems', 'failed', FailedLbl, 'virtual', FirstLine(EcomSalesHeader."Last Error Message"));
            else
                AddStep(Steps, 'virtualItems', 'pending', PendingLbl, 'virtual', '');
        end;
    end;

    local procedure AddSalesDocStep(var Steps: JsonArray; EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        DoneLbl: Label 'Sales document created';
        FailedLbl: Label 'Sales document creation failed';
        CanceledLbl: Label 'Sales document canceled';
        PendingLbl: Label 'Sales document not created';
    begin
        case EcomSalesHeader."Creation Status" of
            EcomSalesHeader."Creation Status"::Created:
                AddStep(Steps, 'salesDoc', 'done', DoneLbl, '', '');
            EcomSalesHeader."Creation Status"::Error:
                AddStep(Steps, 'salesDoc', 'failed', FailedLbl, '', FirstLine(EcomSalesHeader."Last Error Message"));
            EcomSalesHeader."Creation Status"::Canceled:
                AddStep(Steps, 'salesDoc', 'pending', CanceledLbl, '', '');
            else
                AddStep(Steps, 'salesDoc', 'pending', PendingLbl, '', '');
        end;
    end;

    local procedure AddPostedStep(var Steps: JsonArray; EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        DoneLbl: Label 'Sales document posted';
        PartialLbl: Label 'Sales document partially posted';
        PendingLbl: Label 'Sales document not posted';
    begin
        case EcomSalesHeader."Posting Status" of
            EcomSalesHeader."Posting Status"::Invoiced:
                AddStep(Steps, 'posted', 'done', DoneLbl, '', '');
            EcomSalesHeader."Posting Status"::"Partially Invoiced":
                AddStep(Steps, 'posted', 'partial', PartialLbl, '', '');
            else
                AddStep(Steps, 'posted', 'pending', PendingLbl, '', '');
        end;
    end;

    local procedure AddCompletedStep(var Steps: JsonArray; SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"; EcomDocFound: Boolean)
    var
        DoneLbl: Label 'Processing completed';
        FailedLbl: Label 'Processing failed';
        PendingLbl: Label 'Processing not completed';
    begin
        case true of
            SpfyEventLogEntry."Processing Status" = SpfyEventLogEntry."Processing Status"::Processed:
                AddStep(Steps, 'completed', 'done', DoneLbl, '', '');
            (SpfyEventLogEntry."Processing Status" = SpfyEventLogEntry."Processing Status"::Error) and EcomDocFound:
                AddStep(Steps, 'completed', 'failed', FailedLbl, '', FirstLine(SpfyEventLogEntry."Last Error Message"));
            else
                AddStep(Steps, 'completed', 'pending', PendingLbl, '', '');
        end;
    end;

    local procedure AddStep(var Steps: JsonArray; StepKey: Text; State: Text; StepLabel: Text; Tag: Text; Detail: Text)
    var
        Step: JsonObject;
    begin
        Step.Add('key', StepKey);
        Step.Add('label', StepLabel);
        Step.Add('state', State);
        if Tag <> '' then
            Step.Add('tag', Tag);
        if Detail <> '' then
            Step.Add('detail', Detail);
        Steps.Add(Step);
    end;

    local procedure EcomDocumentError(EcomSalesHeader: Record "NPR Ecom Sales Header"): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        if EcomSalesHeader."Last Error Message" = '' then
            exit(EcomSalesHeader."Last Capture Error Message");
        if EcomSalesHeader."Last Capture Error Message" = '' then
            exit(EcomSalesHeader."Last Error Message");
        exit(EcomSalesHeader."Last Error Message" + TypeHelper.LFSeparator() + EcomSalesHeader."Last Capture Error Message");
    end;

    local procedure FirstLine(Value: Text): Text
    var
        LineFeed: Text[1];
        CarriageReturn: Text[1];
        Position: Integer;
    begin
        LineFeed[1] := 10;
        CarriageReturn[1] := 13;
        Position := StrPos(Value, LineFeed);
        if Position > 0 then
            Value := CopyStr(Value, 1, Position - 1);
        exit(Value.TrimEnd(CarriageReturn));
    end;

    local procedure AmountText(Amount: Decimal; CurrencyCode: Code[10]): Text
    var
        AutoFormat: Codeunit "Auto Format";
        AmountFormatted: Text;
    begin
        if Amount = 0 then
            exit('');
        AmountFormatted := Format(Amount, 0, AutoFormat.ResolveAutoFormat(Enum::"Auto Format"::AmountFormatNoSymbol, CurrencyCode));
        if CurrencyCode <> '' then
            exit(AmountFormatted + ' ' + CurrencyCode);
        exit(AmountFormatted);
    end;
}
