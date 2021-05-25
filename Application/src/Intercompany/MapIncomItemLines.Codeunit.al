codeunit 6060071 "NPR Map Incom. Item Lines"
{
    // NPR5.27/BR /20160924 CASE 252817 New Object created based on Codeunit 1218
    // NPR5.29/BR /20161124 CASE 259274 Updated to reflect upgrade to NAV 2017 in Codeunit 1218
    // NPR5.50/ZESO/20190430 CASE 353383 Rename function GetValue to GetValue2 to avoid compilation issue in BC

    Permissions = TableData "Data Exch." = rimd,
                  TableData "Data Exch. Field" = rimd;
    TableNo = "Data Exch.";

    trigger OnRun()
    var
        ErrorMessage: Record "Error Message";
        IncomingDocument: Record "Incoming Document";
    begin
        IncomingDocument.Get("Incoming Entry No.");

        ErrorMessage.SetContext(IncomingDocument);
        if ErrorMessage.HasErrors(false) then
            exit;

        if IncomingDocument."Document Type" = IncomingDocument."Document Type"::Journal then
            CODEUNIT.Run(CODEUNIT::"Map Incoming Doc to Gen. Line", IncomingDocument)
        else
            ProcessIntermediateData(Rec);

        DeleteIntermediateData(Rec);
    end;

    var
        TempProcessedHdrFldId: Record "Integer" temporary;
        TempProcessedLineFldId: Record "Integer" temporary;
        NotFoundErr: Label 'Cannot find a value for field %1 of table %2 in table %3.', Comment = '%1 - field caption, %2 - table caption, %3 - table caption';
        TotalsMismatchErr: Label 'The total amount %1 on the created document is different than the total amount %2 in the incoming document.', Comment = '%1 total amount, %2 expected total amount';
        TotalsMismatchWithHintErr: Label 'The total amount %1 on the created document is different than the expected value %2. The incoming document has a prepaid amount of %3. You must handle prepayments manually.', Comment = '%1 total amount, %2 expected total amount,%3 total charge amount,%4 prepaid amount';
        TempNameValueBufferPurchHdr: Record "Name/Value Buffer" temporary;
        TotalsMismatchDocNotCreatedErr: Label 'The total amount %1 on the created document is different than the total amount %2 in the incoming document. To retry the document creation manually, open the Incoming Document window and choose the action Create Document.', Comment = '%1 total amount, %2 expected total amount';
        InvoiceChargeHasNoReasonErr: Label 'Invoice charge on the incoming document has no reason code.';
        VATMismatchErr: Label '%1 %2 on line number %3  has %4 %5, which is different than %4 %6 in the incoming document.', Comment = ' %1 is type value, %2 is the No.,  %3 is the line no , %4 field caption VAT%, %5 VAT pct on the line,%6 is the VAT pct in the incoming doc';
        TempNameValueBufferPurchLine: Record "Name/Value Buffer" temporary;
        UnableToApplyDiscountErr: Label 'The invoice discount of %1 cannot be applied. Invoice discount must be allowed on at least one invoice line and invoice total must not be 0.', Comment = '%1 - a decimal number';

    procedure ProcessIntermediateData(DataExch: Record "Data Exch.")
    begin
        ProcessHeaders(DataExch);
        ApplyInvoiceDiscounts(DataExch);
        ApplyInvoiceCharges(DataExch);
        VerifyTotals(DataExch);
    end;

    local procedure ProcessHeaders(DataExch: Record "Data Exch.")
    var
        PurchaseHeader: Record "Purchase Header";
        IntermediateDataImport: Record "Intermediate Data Import";
        RecRef: RecordRef;
        CurrRecordNo: Integer;
    begin
        CurrRecordNo := -1;

        IntermediateDataImport.SetRange("Data Exch. No.", DataExch."Entry No.");
        IntermediateDataImport.SetRange("Table ID", DATABASE::"Purchase Header");
        IntermediateDataImport.SetRange("Parent Record No.", 0);
        IntermediateDataImport.SetCurrentKey("Record No.");

        if not IntermediateDataImport.FindSet() then
            exit;

        //REPEAT
        if CurrRecordNo <> IntermediateDataImport."Record No." then begin // new record
            if CurrRecordNo <> -1 then begin// if not start of loop then add lines - for current record
                RecRef.Modify(true);
                ProcessLines(PurchaseHeader, DataExch, CurrRecordNo);
                RecRef.Close();
            end;

            CurrRecordNo := IntermediateDataImport."Record No.";
            RecRef.Open(DATABASE::"Purchase Header");
            CreateNewPurchHdr(RecRef, DataExch, CurrRecordNo);
            RecRef.SetTable(PurchaseHeader);
        end;

        if not IntermediateDataImport."Validate Only" then
            if not IsFieldProcessed(TempProcessedHdrFldId, IntermediateDataImport."Field ID") then
                if IntermediateDataImport.Value <> '' then
                    ProcessField(TempProcessedHdrFldId, RecRef, IntermediateDataImport."Field ID", IntermediateDataImport.Value);
        //UNTIL Next() = 0;

        // process the last rec in DB
        if CurrRecordNo <> -1 then begin
            RecRef.Modify(true);
            ProcessLines(PurchaseHeader, DataExch, CurrRecordNo);
            RecRef.Close();
        end;
    end;

    local procedure ProcessLines(PurchaseHeader: Record "Purchase Header"; DataExch: Record "Data Exch."; ParentRecordNo: Integer)
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        RecRef: RecordRef;
        CurrRecordNo: Integer;
    begin
        CurrRecordNo := -1;

        IntermediateDataImport.SetRange("Data Exch. No.", DataExch."Entry No.");
        IntermediateDataImport.SetRange("Table ID", DATABASE::"Purchase Line");
        //Process all lines
        //SETRANGE("Parent Record No.",ParentRecordNo);
        IntermediateDataImport.SetCurrentKey("Record No.");

        if not IntermediateDataImport.FindSet() then
            exit;

        repeat
            if CurrRecordNo <> IntermediateDataImport."Record No." then begin // new record
                if CurrRecordNo <> -1 then // if not start of loop then save current rec
                    RecRef.Modify(true);

                CurrRecordNo := IntermediateDataImport."Record No.";
                CreateNewPurchLine(PurchaseHeader, RecRef, DataExch."Entry No.", ParentRecordNo, CurrRecordNo);
            end;

            if not IntermediateDataImport."Validate Only" then
                if not IsFieldProcessed(TempProcessedLineFldId, IntermediateDataImport."Field ID") then
                    if IntermediateDataImport.Value <> '' then
                        ProcessField(TempProcessedLineFldId, RecRef, IntermediateDataImport."Field ID", IntermediateDataImport.Value);
        until IntermediateDataImport.Next() = 0;

        // Save the last rec
        if CurrRecordNo <> -1 then
            RecRef.Modify(true);
    end;

    local procedure ApplyInvoiceDiscounts(DataExch: Record "Data Exch.")
    var
        PurchaseHeader: Record "Purchase Header";
        IntermediateDataImport: Record "Intermediate Data Import";
        PurchLine: Record "Purchase Line";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        ErrorMessage: Record "Error Message";
        PurchCalcDiscByType: Codeunit "Purch - Calc Disc. By Type";
        InvoiceDiscountAmount: Decimal;
        InvDiscBaseAmount: Decimal;
    begin
        IntermediateDataImport.SetRange("Data Exch. No.", DataExch."Entry No.");
        IntermediateDataImport.SetRange("Table ID", DATABASE::"Purchase Header");
        IntermediateDataImport.SetRange("Field ID", PurchaseHeader.FieldNo("Invoice Discount Value"));
        IntermediateDataImport.SetRange("Parent Record No.", 0);
        IntermediateDataImport.SetFilter(Value, '<>%1', '');

        if not IntermediateDataImport.FindSet() then
            exit;

        repeat
            Evaluate(InvoiceDiscountAmount, IntermediateDataImport.Value, 9);

            if InvoiceDiscountAmount > 0 then begin
                GetRelatedPurchaseHeader(PurchaseHeader, IntermediateDataImport."Record No.");
                PurchLine.SetRange("Document No.", PurchaseHeader."No.");
                PurchLine.SetRange("Document Type", PurchaseHeader."Document Type");
                PurchLine.CalcVATAmountLines(0, PurchaseHeader, PurchLine, TempVATAmountLine);
                InvDiscBaseAmount := TempVATAmountLine.GetTotalInvDiscBaseAmount(false, PurchaseHeader."Currency Code");

                if PurchCalcDiscByType.InvoiceDiscIsAllowed(PurchaseHeader."Invoice Disc. Code") and (InvDiscBaseAmount <> 0) then
                    PurchCalcDiscByType.ApplyInvDiscBasedOnAmt(InvoiceDiscountAmount, PurchaseHeader)
                else
                    LogMessage(DataExch."Entry No.", PurchaseHeader, PurchaseHeader.FieldNo("No."),
                      ErrorMessage."Message Type"::Warning, StrSubstNo(UnableToApplyDiscountErr, InvoiceDiscountAmount));
            end;
        until IntermediateDataImport.Next() = 0;
    end;

    local procedure ApplyInvoiceCharges(DataExch: Record "Data Exch.")
    var
        PurchaseHeader: Record "Purchase Header";
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        IntermediateDataImport: Record "Intermediate Data Import";
        InvoiceChargeAmount: Decimal;
        InvoiceChargeReason: Text[50];
    begin
        IntermediateDataImport.SetRange("Data Exch. No.", DataExch."Entry No.");
        IntermediateDataImport.SetRange("Table ID", DATABASE::"Item Charge Assignment (Purch)");
        IntermediateDataImport.SetRange("Field ID", ItemChargeAssignmentPurch.FieldNo("Amount to Assign"));
        IntermediateDataImport.SetRange("Parent Record No.", 0);
        IntermediateDataImport.SetFilter(Value, '<>%1', '');

        if not IntermediateDataImport.FindSet() then
            exit;

        repeat
            Evaluate(InvoiceChargeAmount, IntermediateDataImport.Value, 9);
            InvoiceChargeReason := GetInvoiceChargeReason(IntermediateDataImport);
            GetRelatedPurchaseHeader(PurchaseHeader, IntermediateDataImport."Record No.");
            CreateInvoiceChargePurchaseLine(DataExch."Entry No.", IntermediateDataImport."Record No.", PurchaseHeader, InvoiceChargeReason, InvoiceChargeAmount);
        until IntermediateDataImport.Next() = 0;
    end;

    local procedure VerifyTotals(DataExch: Record "Data Exch.")
    var
        PurchaseHeader: Record "Purchase Header";
        IntermediateDataImport: Record "Intermediate Data Import";
        TempTotalPurchaseLine: Record "Purchase Line" temporary;
        CurrentPurchaseLine: Record "Purchase Line";
        ErrorMessage: Record "Error Message";
        IncomingDocument: Record "Incoming Document";
        DocumentTotals: Codeunit "Document Totals";
        AmountIncludingVATFromFile: Decimal;
        VATAmount: Decimal;
        PrepaidAmount: Decimal;
        ProcessingMsg: Text[250];
    begin
        IntermediateDataImport.SetRange("Data Exch. No.", DataExch."Entry No.");
        IntermediateDataImport.SetRange("Table ID", DATABASE::"Purchase Header");
        IntermediateDataImport.SetRange("Field ID", PurchaseHeader.FieldNo("Amount Including VAT"));
        IntermediateDataImport.SetRange("Parent Record No.", 0);
        IntermediateDataImport.SetFilter(Value, '<>%1', '');

        if not IntermediateDataImport.FindSet() then
            exit;

        repeat
            PrepaidAmount := GetPrepaidAmount(DataExch, IntermediateDataImport."Record No.");
            Evaluate(AmountIncludingVATFromFile, IntermediateDataImport.Value, 9);
            GetRelatedPurchaseHeader(PurchaseHeader, IntermediateDataImport."Record No.");

            VerifyLineVATs(DataExch, PurchaseHeader, IntermediateDataImport."Record No.");

            // prepare variables needed for calculation of totals
            VATAmount := 0;
            TempTotalPurchaseLine.Init();
            CurrentPurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
            CurrentPurchaseLine.SetRange("Document No.", PurchaseHeader."No.");

            // calculate totals and compare them with values from the incoming document
            IncomingDocument.Get(DataExch."Incoming Entry No.");
            if CurrentPurchaseLine.FindFirst() then begin
                DocumentTotals.PurchaseCalculateTotalsWithInvoiceRounding(CurrentPurchaseLine, VATAmount, TempTotalPurchaseLine);
                if AmountIncludingVATFromFile <> TempTotalPurchaseLine."Amount Including VAT" then begin
                    ProcessingMsg := StrSubstNo(TotalsMismatchErr, TempTotalPurchaseLine."Amount Including VAT", AmountIncludingVATFromFile);
                    if PrepaidAmount <> 0 then
                        ProcessingMsg :=
                          StrSubstNo(TotalsMismatchWithHintErr, TempTotalPurchaseLine."Amount Including VAT",
                            AmountIncludingVATFromFile, PrepaidAmount);
                    if IncomingDocument."Created Doc. Error Msg. Type" = IncomingDocument."Created Doc. Error Msg. Type"::Error then begin
                        ProcessingMsg :=
                          StrSubstNo(TotalsMismatchDocNotCreatedErr, TempTotalPurchaseLine."Amount Including VAT", AmountIncludingVATFromFile);
                        LogMessage(DataExch."Entry No.", IncomingDocument, IncomingDocument.FieldNo("Entry No."),
                          ErrorMessage."Message Type"::Error, ProcessingMsg);
                    end else
                        LogMessage(DataExch."Entry No.", PurchaseHeader, PurchaseHeader.FieldNo("No."),
                          ErrorMessage."Message Type"::Warning, ProcessingMsg);
                end;
            end;
        until IntermediateDataImport.Next() = 0;
    end;

    local procedure VerifyLineVATs(DataExch: Record "Data Exch."; PurchaseHeader: Record "Purchase Header"; ParentRecordNo: Integer)
    var
        PurchaseLine: Record "Purchase Line";
        IntermediateDataImport: Record "Intermediate Data Import";
        ErrorMessage: Record "Error Message";
        VATPctFromFile: Decimal;
    begin
        IntermediateDataImport.SetRange("Data Exch. No.", DataExch."Entry No.");
        IntermediateDataImport.SetRange("Table ID", DATABASE::"Purchase Line");
        IntermediateDataImport.SetRange("Field ID", PurchaseLine.FieldNo("VAT %"));
        IntermediateDataImport.SetRange("Parent Record No.", ParentRecordNo);
        IntermediateDataImport.SetFilter(Value, '<>%1', '');
        IntermediateDataImport.SetCurrentKey("Record No.");

        if not IntermediateDataImport.FindSet() then
            exit;

        repeat
            Evaluate(VATPctFromFile, IntermediateDataImport.Value, 9);
            GetRelatedPurchaseLine(PurchaseLine, ComposeKeyForCreatedPurchLine(ParentRecordNo, IntermediateDataImport."Record No."));
            if VATPctFromFile <> PurchaseLine."VAT %" then
                LogMessage(DataExch."Entry No.", PurchaseHeader, PurchaseHeader.FieldNo("No."), ErrorMessage."Message Type"::Warning,
                  StrSubstNo(VATMismatchErr, PurchaseLine.Type, PurchaseLine."No.", PurchaseLine."Line No.",
                    PurchaseLine.FieldCaption("VAT %"), PurchaseLine."VAT %", VATPctFromFile));
        until IntermediateDataImport.Next() = 0;
    end;

    local procedure SetFieldValue(var FieldRef: FieldRef; Value: Text[250])
    var
        ConfigValidateManagement: Codeunit "Config. Validate Management";
        ErrorText: Text;
    begin
        TruncateValueToFieldLength(FieldRef, Value);
        ErrorText := ConfigValidateManagement.EvaluateValueWithValidate(FieldRef, Value, true);
        if ErrorText <> '' then
            Error(ErrorText);
    end;

    local procedure TruncateValueToFieldLength(FieldRef: FieldRef; var Value: Text[250])
    var
        "Field": Record "Field";
    begin
        Evaluate(Field.Type, Format(FieldRef.Type));
        if Field.Type in [Field.Type::Code, Field.Type::Text] then
            Value := CopyStr(Value, 1, FieldRef.Length);
    end;

    local procedure CreateNewPurchHdr(var RecRef: RecordRef; DataExch: Record "Data Exch."; RecordNo: Integer)
    var
        PurchaseHeader: Record "Purchase Header";
        IntermediateDataImport: Record "Intermediate Data Import";
        FldNo: Integer;
    begin
        TempProcessedHdrFldId.Reset();
        TempProcessedHdrFldId.DeleteAll();

        IntermediateDataImport.SetRange("Data Exch. No.", DataExch."Entry No.");
        IntermediateDataImport.SetRange("Table ID", DATABASE::"Purchase Header");
        IntermediateDataImport.SetRange("Record No.", RecordNo);

        // Set PK and insert
        FldNo := PurchaseHeader.FieldNo("Document Type");
        ProcessField(TempProcessedHdrFldId, RecRef, FldNo,
          //-NPR5.50 [353383]
          //GetValue(IntermediateDataImport,RecRef,FldNo,PurchaseHeader.FIELDCAPTION("Document Type")));
          GetValue2(IntermediateDataImport, RecRef, FldNo, PurchaseHeader.FieldCaption("Document Type")));
        //+NPR5.50 [353383]
        RecRef.Insert(true);

        // Vendor No.
        FldNo := PurchaseHeader.FieldNo("Buy-from Vendor No.");
        ProcessField(TempProcessedHdrFldId, RecRef, FldNo,
          //-NPR5.50 [353383]
          //GetValue(IntermediateDataImport,RecRef,FldNo,PurchaseHeader.FIELDCAPTION("Buy-from Vendor No.")));
          GetValue2(IntermediateDataImport, RecRef, FldNo, PurchaseHeader.FieldCaption("Buy-from Vendor No.")));
        //+NPR5.50 [353383]

        //-NPR5.29 [259274]
        // Buy-from Vendor Name
        FldNo := PurchaseHeader.FieldNo("Buy-from Vendor Name");
        if TryGetValue(IntermediateDataImport, RecRef, FldNo, PurchaseHeader.FieldCaption("Buy-from Vendor Name"), IntermediateDataImport.Value) then
            ProcessFieldNoValidate(TempProcessedHdrFldId, RecRef, FldNo,
              //-NPR5.50 [353383]
              //GetValue(IntermediateDataImport,RecRef,FldNo,PurchaseHeader.FIELDCAPTION("Buy-from Vendor Name")));
              GetValue2(IntermediateDataImport, RecRef, FldNo, PurchaseHeader.FieldCaption("Buy-from Vendor Name")));
        //+NPR5.50 [353383]
        //+NPR5.29 [259274]

        RecRef.Modify(true);
        SetHeaderConfirmGeneratorFields(IntermediateDataImport, RecRef);
        //-NPR5.29 [259274]

        // Pay-to Name
        FldNo := PurchaseHeader.FieldNo("Pay-to Name");
        if TryGetValue(IntermediateDataImport, RecRef, FldNo, PurchaseHeader.FieldCaption("Pay-to Name"), IntermediateDataImport.Value) then
            if not IsFieldProcessed(TempProcessedHdrFldId, FldNo) then
                ProcessFieldNoValidate(TempProcessedHdrFldId, RecRef, FldNo,
                  //-NPR5.50 [353383]
                  //GetValue(IntermediateDataImport,RecRef,FldNo,PurchaseHeader.FIELDCAPTION("Pay-to Name")));
                  GetValue2(IntermediateDataImport, RecRef, FldNo, PurchaseHeader.FieldCaption("Pay-to Name")));
        //+NPR5.50 [353383]
        //+NPR5.29 [259274]
        // Currency
        FldNo := PurchaseHeader.FieldNo("Currency Code");
        ProcessField(TempProcessedHdrFldId, RecRef, FldNo,
          //-NPR5.50 [353383]
          //GetValue(IntermediateDataImport,RecRef,FldNo,PurchaseHeader.FIELDCAPTION("Currency Code")));
          GetValue2(IntermediateDataImport, RecRef, FldNo, PurchaseHeader.FieldCaption("Currency Code")));
        //+NPR5.50 [353383]

        // Incoming Doc Entry No
        FldNo := PurchaseHeader.FieldNo("Incoming Document Entry No.");
        ProcessField(TempProcessedHdrFldId, RecRef, FldNo, Format(DataExch."Incoming Entry No."));

        // New: Document Date
        FldNo := PurchaseHeader.FieldNo("Document Date");
        ProcessField(TempProcessedHdrFldId, RecRef, FldNo,
          //-NPR5.50 [353383]
          //GetValue(IntermediateDataImport,RecRef,FldNo,PurchaseHeader.FIELDCAPTION("Document Date")));
          GetValue2(IntermediateDataImport, RecRef, FldNo, PurchaseHeader.FieldCaption("Document Date")));
        //+NPR5.50 [353383]
        RecRef.Modify(true);

        CorrelateCreatedDocumentWithRecordNo(RecRef, RecordNo);
    end;

    local procedure SetHeaderConfirmGeneratorFields(var IntermediateDataImport: Record "Intermediate Data Import"; var RecRef: RecordRef)
    var
        PurchaseHeader: Record "Purchase Header";
        FldNo: Integer;
        Value: Text[250];
        DecimalValue: Decimal;
    begin
        RecRef.SetTable(PurchaseHeader);
        PurchaseHeader.SetHideValidationDialog(true);

        // Pay-to Vendor
        FldNo := PurchaseHeader.FieldNo("Pay-to Vendor No.");
        if TryGetValue(IntermediateDataImport, RecRef, FldNo, PurchaseHeader.FieldCaption("Pay-to Vendor No."), Value) then begin
            PurchaseHeader.Validate("Pay-to Vendor No.", CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Pay-to Vendor No.")));
            SetFieldProcessed(TempProcessedHdrFldId, FldNo);
            //-NPR5.29 [259274]
            SetFieldProcessed(TempProcessedHdrFldId, PurchaseHeader.FieldNo("Pay-to Name"));
            //+NPR5.29 [259274]
        end;

        // Buy-from Contact No.
        FldNo := PurchaseHeader.FieldNo("Buy-from Contact No.");
        if TryGetValue(IntermediateDataImport, RecRef, FldNo, PurchaseHeader.FieldCaption("Buy-from Contact No."), Value) then begin
            PurchaseHeader.Validate("Buy-from Contact No.", CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Buy-from Contact No.")));
            SetFieldProcessed(TempProcessedHdrFldId, FldNo);
        end;

        // Pay-to Contact No.
        FldNo := PurchaseHeader.FieldNo("Pay-to Contact No.");
        if TryGetValue(IntermediateDataImport, RecRef, FldNo, PurchaseHeader.FieldCaption("Pay-to Contact No."), Value) then begin
            PurchaseHeader.Validate("Pay-to Contact No.", CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Pay-to Contact No.")));
            SetFieldProcessed(TempProcessedHdrFldId, FldNo);
        end;

        // VAT Base Discount %
        FldNo := PurchaseHeader.FieldNo("VAT Base Discount %");
        if TryGetValue(IntermediateDataImport, RecRef, FldNo, PurchaseHeader.FieldCaption("VAT Base Discount %"), Value) then begin
            Evaluate(DecimalValue, Value, 9);
            PurchaseHeader.Validate("VAT Base Discount %", DecimalValue);
            SetFieldProcessed(TempProcessedHdrFldId, FldNo);
        end;

        PurchaseHeader.Modify(true);
        RecRef.GetTable(PurchaseHeader);
    end;

    local procedure CreateNewPurchLine(PurchaseHeader: Record "Purchase Header"; var RecRef: RecordRef; DataExchNo: Integer; ParentRecNo: Integer; RecordNo: Integer)
    var
        PurchaseLine: Record "Purchase Line";
    begin
        TempProcessedLineFldId.Reset();
        TempProcessedLineFldId.DeleteAll();

        InsertEmptyPurchaseLine(PurchaseHeader, PurchaseLine);
        RecRef.GetTable(PurchaseLine);

        SetLineMandatoryFields(RecRef, DataExchNo, RecordNo);

        CorrelateCreatedPurchLineWithRecordNo(RecRef, ComposeKeyForCreatedPurchLine(ParentRecNo, RecordNo));
    end;

    local procedure CreateInvoiceChargePurchaseLine(EntryNo: Integer; RecordNo: Integer; var PurchaseHeader: Record "Purchase Header"; InvoiceChargeReason: Text[50]; InvoiceChargeAmount: Decimal)
    var
        PurchaseLine: Record "Purchase Line";
        PreMapIncomingPurchDoc: Codeunit "Pre-map Incoming Purch. Doc";
        GLAccountNo: Code[20];
    begin
        //-259274 [259274]
        //GLAccountNo := PreMapIncomingPurchDoc.FindAppropriateGLAccount(EntryNo,RecordNo,InvoiceChargeReason,InvoiceChargeAmount);
        GLAccountNo :=
          PreMapIncomingPurchDoc.FindAppropriateGLAccount(
            EntryNo, RecordNo, InvoiceChargeReason, InvoiceChargeAmount, PurchaseHeader."Buy-from Vendor No.");
        //+259274 [259274]
        InsertEmptyPurchaseLine(PurchaseHeader, PurchaseLine);

        PurchaseLine.Validate(Type, PurchaseLine.Type::"G/L Account");
        PurchaseLine.Validate("No.", GLAccountNo);
        PurchaseLine.Validate(Description, InvoiceChargeReason);
        PurchaseLine.Validate("Description 2", InvoiceChargeReason);
        PurchaseLine.Validate(Quantity, 1);
        PurchaseLine.Validate("Direct Unit Cost", InvoiceChargeAmount);
        PurchaseLine.Modify(true);
    end;

    local procedure SetLineMandatoryFields(var RecRef: RecordRef; DataExchNo: Integer; RecordNo: Integer)
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        PurchaseLine: Record "Purchase Line";
        FldNo: Integer;
        Type: Enum "Purchase Line Type";
    begin
        IntermediateDataImport.SetRange("Data Exch. No.", DataExchNo);
        IntermediateDataImport.SetRange("Table ID", DATABASE::"Purchase Line");
        //SETRANGE("Parent Record No.",ParentRecNo);
        IntermediateDataImport.SetRange("Record No.", RecordNo);

        //ERROR('First line: %1 fields',IntermediateDataImport.Count());
        // Type
        FldNo := PurchaseLine.FieldNo(Type);
        //-NPR5.50 [353383]
        //EVALUATE(Type,GetValue(IntermediateDataImport,RecRef,FldNo,PurchaseLine.FIELDCAPTION(Type)));
        Evaluate(Type, GetValue2(IntermediateDataImport, RecRef, FldNo, PurchaseLine.FieldCaption(Type)));
        //+NPR5.50 [353383]
        ProcessField(TempProcessedLineFldId, RecRef, FldNo, Format(Type));

        if Type <> PurchaseLine.Type::" " then begin
            // No.
            FldNo := PurchaseLine.FieldNo("No.");
            ProcessField(TempProcessedLineFldId, RecRef, FldNo,
              //-NPR5.50 [353383]
              //GetValue(IntermediateDataImport,RecRef,FldNo,PurchaseLine.FIELDCAPTION("No.")));
              GetValue2(IntermediateDataImport, RecRef, FldNo, PurchaseLine.FieldCaption("No.")));
            //+NPR5.50 [353383]


            // Quantity
            FldNo := PurchaseLine.FieldNo(Quantity);
            ProcessField(TempProcessedLineFldId, RecRef, FldNo,
              //-NPR5.50 [353383]
              //GetValue(IntermediateDataImport,RecRef,FldNo,PurchaseLine.FIELDCAPTION(Quantity)));
              GetValue2(IntermediateDataImport, RecRef, FldNo, PurchaseLine.FieldCaption(Quantity)));
            //+NPR5.50 [353383]


            // UOM
            //-NPR5.29 [259274]
            //FldNo := PurchaseLine.FIELDNO("Unit of Measure");
            //IF TryGetValue(IntermediateDataImport,RecRef,FldNo,PurchaseLine.FIELDCAPTION("Unit of Measure"),Value) THEN
            FldNo := PurchaseLine.FieldNo("Unit of Measure Code");
            if TryGetValue(IntermediateDataImport, RecRef, FldNo, PurchaseLine.FieldCaption("Unit of Measure Code"), IntermediateDataImport.Value) then
                //+NPR5.29 [259274]
                ProcessField(TempProcessedLineFldId, RecRef, FldNo, IntermediateDataImport.Value);

            // Direct Unit Cost
            FldNo := PurchaseLine.FieldNo("Direct Unit Cost");
            ProcessField(TempProcessedLineFldId, RecRef, FldNo,
              //-NPR5.50 [353383]
              //GetValue(IntermediateDataImport,RecRef,FldNo,PurchaseLine.FIELDCAPTION("Direct Unit Cost")));
              GetValue2(IntermediateDataImport, RecRef, FldNo, PurchaseLine.FieldCaption("Direct Unit Cost")));
            //+NPR5.50 [353383]
        end;

        RecRef.Modify(true);
    end;

    local procedure GetValue2(var IntermediateDataImport: Record "Intermediate Data Import"; RecRef: RecordRef; FieldID: Integer; FieldName: Text): Text[250]
    var
        Value: Text[250];
    begin
        TryGetValue(IntermediateDataImport, RecRef, FieldID, FieldName, Value);

        exit(Value);
    end;

    [TryFunction]
    local procedure TryGetValue(var IntermediateDataImport: Record "Intermediate Data Import"; RecRef: RecordRef; FieldID: Integer; FieldName: Text; var Value: Text[250])
    begin
        Value := '';
        IntermediateDataImport.SetRange("Field ID", FieldID);

        if not IntermediateDataImport.FindFirst() then
            Error(NotFoundErr, FieldName, RecRef.Caption, IntermediateDataImport.TableCaption);

        Value := IntermediateDataImport.Value;
    end;

    local procedure ProcessField(var TempInt: Record "Integer"; RecRef: RecordRef; FieldNo: Integer; Value: Text[250])
    var
        FieldRef: FieldRef;
    begin
        FieldRef := RecRef.Field(FieldNo);
        SetFieldValue(FieldRef, Value);
        SetFieldProcessed(TempInt, FieldNo);
    end;

    local procedure ProcessFieldNoValidate(var TempInt: Record "Integer"; RecRef: RecordRef; FieldNo: Integer; Value: Text[250])
    var
        FieldRef: FieldRef;
    begin
        //-NPR5.29 [259274]
        FieldRef := RecRef.Field(FieldNo);
        FieldRef.Value(Value);
        SetFieldProcessed(TempInt, FieldNo);
        //+NPR5.29 [259274]
    end;

    local procedure SetFieldProcessed(var TempInt: Record "Integer"; FieldID: Integer)
    begin
        Clear(TempInt);
        TempInt.Number := FieldID;
        TempInt.Insert();
    end;

    local procedure IsFieldProcessed(var TempInt: Record "Integer"; FieldID: Integer): Boolean
    begin
        TempInt.Reset();
        TempInt.SetRange(Number, FieldID);

        exit(TempInt.FindFirst());
    end;

    local procedure CorrelateCreatedDocumentWithRecordNo(RecRef: RecordRef; RecordNo: Integer)
    begin
        TempNameValueBufferPurchHdr.Init();
        TempNameValueBufferPurchHdr.ID := RecordNo;
        TempNameValueBufferPurchHdr.Name := Format(RecordNo);
        TempNameValueBufferPurchHdr.Value := Format(RecRef.RecordId);
        TempNameValueBufferPurchHdr.Insert();
    end;

    local procedure GetRelatedPurchaseHeader(var PurchaseHeader: Record "Purchase Header"; RecordNo: Integer)
    var
        RecId: RecordID;
    begin
        TempNameValueBufferPurchHdr.Get(RecordNo);
        Evaluate(RecId, Format(TempNameValueBufferPurchHdr.Value));
        PurchaseHeader.Get(RecId);
    end;

    local procedure CorrelateCreatedPurchLineWithRecordNo(RecRef: RecordRef; "Key": Text[250])
    var
        ID: Integer;
    begin
        Clear(TempNameValueBufferPurchLine);

        ID := 1;
        if TempNameValueBufferPurchLine.FindLast() then
            ID := TempNameValueBufferPurchLine.ID + 1;

        TempNameValueBufferPurchLine.Init();
        TempNameValueBufferPurchLine.ID := ID;
        TempNameValueBufferPurchLine.Name := Key;
        TempNameValueBufferPurchLine.Value := Format(RecRef.RecordId);
        TempNameValueBufferPurchLine.Insert();
    end;

    local procedure GetRelatedPurchaseLine(var PurchaseLine: Record "Purchase Line"; "Key": Text[250])
    var
        RecId: RecordID;
    begin
        TempNameValueBufferPurchLine.Reset();
        TempNameValueBufferPurchLine.SetRange(Name, Key);
        TempNameValueBufferPurchLine.FindFirst();
        Evaluate(RecId, Format(TempNameValueBufferPurchLine.Value));
        PurchaseLine.Get(RecId);
    end;

    local procedure ComposeKeyForCreatedPurchLine(ParentRecNo: Integer; RecNo: Integer): Text[250]
    begin
        exit(Format(ParentRecNo) + '_' + Format(RecNo));
    end;

    local procedure GetPrepaidAmount(DataExch: Record "Data Exch."; RecordNo: Integer): Decimal
    var
        IntermediateDataImport: Record "Intermediate Data Import";
        PrepaymentInvLineBuffer: Record "Prepayment Inv. Line Buffer";
        Amount: Decimal;
    begin
        Amount := 0;
        IntermediateDataImport.SetRange("Data Exch. No.", DataExch."Entry No.");
        IntermediateDataImport.SetRange("Table ID", DATABASE::"Prepayment Inv. Line Buffer");
        IntermediateDataImport.SetRange("Field ID", PrepaymentInvLineBuffer.FieldNo(Amount));
        IntermediateDataImport.SetRange("Record No.", RecordNo);

        if IntermediateDataImport.FindFirst() then
            Evaluate(Amount, IntermediateDataImport.Value, 9);
        exit(Amount);
    end;

    local procedure GetInvoiceChargeReason(IntermediateDataImport: Record "Intermediate Data Import"): Text[50]
    var
        IntermediateDataImport2: Record "Intermediate Data Import";
        ItemCharge: Record "Item Charge";
        PlaceholderPurchaseLine: Record "Purchase Line";
        ErrorMessage: Record "Error Message";
    begin
        IntermediateDataImport2.SetRange("Data Exch. No.", IntermediateDataImport."Data Exch. No.");
        IntermediateDataImport2.SetRange("Table ID", DATABASE::"Item Charge");
        IntermediateDataImport2.SetRange("Field ID", ItemCharge.FieldNo(Description));
        IntermediateDataImport2.SetRange("Record No.", IntermediateDataImport."Record No.");
        IntermediateDataImport2.SetRange("Parent Record No.", 0);
        IntermediateDataImport2.SetFilter(Value, '<>%1', '');

        if IntermediateDataImport2.FindFirst() then
            exit(CopyStr(IntermediateDataImport2.Value, 1, MaxStrLen(PlaceholderPurchaseLine.Description)));
        LogMessage(
          IntermediateDataImport."Data Exch. No.",
          PlaceholderPurchaseLine,
          PlaceholderPurchaseLine.FieldNo(Description),
          ErrorMessage."Message Type"::Error,
          InvoiceChargeHasNoReasonErr);
    end;

    local procedure LogMessage(EntryNo: Integer; RelatedRec: Variant; FieldNo: Integer; MessageType: Option; ProcessingMessage: Text)
    var
        DataExch: Record "Data Exch.";
        ErrorMessage: Record "Error Message";
        IncomingDocument: Record "Incoming Document";
    begin
        DataExch.Get(EntryNo);
        IncomingDocument.Get(DataExch."Incoming Entry No.");

        if IncomingDocument."Created Doc. Error Msg. Type" = IncomingDocument."Created Doc. Error Msg. Type"::Error then
            MessageType := ErrorMessage."Message Type"::Error;

        ErrorMessage.SetContext(IncomingDocument);
        ErrorMessage.LogMessage(RelatedRec, FieldNo,
          MessageType, CopyStr(ProcessingMessage, 1, MaxStrLen(ErrorMessage.Description)));
    end;

    local procedure DeleteIntermediateData(DataExch: Record "Data Exch.")
    var
        DataExchField: Record "Data Exch. Field";
        IntermediateDataImport: Record "Intermediate Data Import";
    begin
        DataExchField.SetRange("Data Exch. No.", DataExch."Entry No.");
        DataExchField.DeleteAll();
        IntermediateDataImport.SetRange("Data Exch. No.", DataExch."Entry No.");
        IntermediateDataImport.DeleteAll();
    end;

    local procedure InsertEmptyPurchaseLine(PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line")
    var
        LineNo: Integer;
    begin
        Clear(PurchaseLine);
        PurchaseLine.Validate("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.Validate("Document No.", PurchaseHeader."No.");

        LineNo := 10000;
        PurchaseLine.SetRecFilter();
        PurchaseLine.SetRange("Line No.");
        if PurchaseLine.FindLast() then
            LineNo := LineNo + PurchaseLine."Line No.";
        PurchaseLine.Validate("Line No.", LineNo);

        PurchaseLine.Insert(true);
    end;
}

