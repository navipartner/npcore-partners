codeunit 6014498 "NPR Exchange Label Mgt."
{
    Access = Internal;

    var
        Text00001: Label 'The item was not found. Use manual procedure in order to return the item.';

    local procedure CreateExchLabelLineFromRecRef(var RecRef: RecordRef; ValidFromDate: Date; LabelBatchNumber: Integer; PackagedBatch: Boolean): Code[7]
    var
        ExchangeLabel: Record "NPR Exchange Label";
        ExchangeLabelSetup: Record "NPR Exchange Label Setup";
        String: Codeunit "NPR String Library";
        POSUnit: Record "NPR POS Unit";
        UserSetup: Record "User Setup";
    begin
        ExchangeLabelSetup.Get();
        ExchangeLabel.Init();

        if UserSetup.Get(UserId) then
            if POSUnit.Get(UserSetup."NPR POS Unit No.") then;

        if StrLen(POSUnit."POS Store Code") <> 3 then
            POSUnit."POS Store Code" := CopyStr(String.PadStrLeft(POSUnit."POS Store Code", 3, ' ', false), 1, MaxStrLen(POSUnit."POS Store Code"));

        ExchangeLabel."Store ID" := CopyStr(POSUnit."POS Store Code", 1, MaxStrLen(ExchangeLabel."Store ID"));
        ExchangeLabel."Register No." := POSUnit."No.";

        ExchangeLabel."Company Name" := CopyStr(CompanyName, 1, MaxStrLen(ExchangeLabel."Company Name"));
        ExchangeLabel."Table No." := RecRef.Number;
        ExchangeLabel."Valid From" := ValidFromDate;
        ExchangeLabel."Unit Price" := GetUnitPriceInclVat(RecRef);
        ExchangeLabel."Sales Price Incl. Vat" := GetSalesPriceInclVat(RecRef);
        ExchangeLabel."Valid To" := CalcDate(ExchangeLabelSetup."Exchange Label Exchange Period", ValidFromDate);
        ExchangeLabel."Batch No." := LabelBatchNumber;
        ExchangeLabel."Packaged Batch" := PackagedBatch;

        case RecRef.Number of
            DATABASE::"Sales Line":
                begin
                    AssignOptionFieldValue(ExchangeLabel."Sales Header Type", RecRef, 'Document Type');
                    AssignCode20FieldValue(ExchangeLabel."Sales Header No.", RecRef, 'Document No.');
                    AssignCode10FieldValue(ExchangeLabel."Unit of Measure", RecRef, 'Unit of Measure');
                end;
            DATABASE::"Sales Invoice Line":
                begin
                    AssignCode20FieldValue(ExchangeLabel."Sales Header No.", RecRef, 'Document No.');
                    AssignCode10FieldValue(ExchangeLabel."Unit of Measure", RecRef, 'Unit of Measure');
                end;
            DATABASE::"NPR POS Sale Line":
                begin
                    AssignCode10FieldValue(ExchangeLabel."Register No.", RecRef, 'Register No.');
                    AssignCode20FieldValue(ExchangeLabel."Sales Ticket No.", RecRef, 'Sales Ticket No.');
                    AssignCode10FieldValue(ExchangeLabel."Unit of Measure", RecRef, 'Unit of Measure Code');
                end;
        end;

        AssignIntegerFieldValue(ExchangeLabel."Sales Line No.", RecRef, 'Line No.');
        AssignCode20FieldValue(ExchangeLabel."Item No.", RecRef, 'No.');
        AssignCode10FieldValue(ExchangeLabel."Variant Code", RecRef, 'Variant Code');
        //-NPR5.37 [292701]
        if PackagedBatch then
            AssignDecimalFieldValue(ExchangeLabel.Quantity, RecRef, 'Quantity')
        else
            ExchangeLabel.Quantity := 1;

        ExchangeLabel."Retail Cross Reference No." := InitRetailReference(RecRef);

        ExchangeLabel.Insert(true);
        exit(ExchangeLabel."No.");
    end;

    procedure GetLabelBarcode(var ExchangeLabel: Record "NPR Exchange Label"): Code[13]
    var
        ExchangeLabelSetup: Record "NPR Exchange Label Setup";
        String: Codeunit "NPR String Library";
        LabelCode: Code[7];
    begin
        ExchangeLabelSetup.Get();
        LabelCode := CopyStr(String.PadStrLeft(ExchangeLabel."No.", 7, '0', false), 1, MaxStrLen(LabelCode));
        exit(CopyStr(CreateEAN(LabelCode, ExchangeLabelSetup."EAN Prefix Exhange Label"), 1, 13));
    end;

    local procedure GetLabelFromLabelNo(LabelNo: Code[7]; var ExchangeLabel: Record "NPR Exchange Label")
    begin
        ExchangeLabel.SetCurrentKey("No.");
        ExchangeLabel.SetRange("No.", LabelNo);
        ExchangeLabel.FindFirst();
    end;

    procedure PrintLabels(PrintType: Option Single,LineQuantity,All,Selection,Package; var LineRef: RecordRef; ValidFromDate: Date): Boolean
    var
        ExchangeLabel: Record "NPR Exchange Label";
        SaleLinePOS: Record "NPR POS Sale Line";
        t001: Label 'No lines to print exchange labels from';
        FieldRef: FieldRef;
        LabelBatchNumber: Integer;
        LineCount: Integer;
    begin
        if LineRef.IsEmpty then
            Error(t001);

        case PrintType of
            PrintType::Single:
                begin
                    PrintLabelFromRecRef(LineRef, ValidFromDate, 0);
                end;
            PrintType::LineQuantity:
                begin
                    AssignIntegerFieldValue(LineCount, LineRef, 'Quantity');
                    while LineCount > 0 do begin
                        PrintLabelFromRecRef(LineRef, ValidFromDate, 0);
                        LineCount -= 1;
                    end;
                end;
            PrintType::All:
                begin
                    FieldRef := LineRef.Field(GetFieldNo(LineRef, 'Line No.'));
                    FieldRef.SetRange();
                    if LineRef.FindSet() then
                        repeat
                            AssignIntegerFieldValue(LineCount, LineRef, 'Quantity');
                            while LineCount > 0 do begin
                                PrintLabelFromRecRef(LineRef, ValidFromDate, 0);
                                LineCount -= 1;
                            end;
                        until LineRef.Next() = 0;
                end;
            PrintType::Selection, PrintType::Package:
                begin
                    LineRef.SetTable(SaleLinePOS);
                    LabelBatchNumber := GetLabelGroupBatchNo(SaleLinePOS);

                    if LineRef.FindSet() then
                        repeat
                            CreateExchLabelLineFromRecRef(LineRef, ValidFromDate, LabelBatchNumber, (PrintType = PrintType::Package));
                        until LineRef.Next() = 0;

                    ExchangeLabel.SetCurrentKey("Register No.", "Sales Ticket No.", "Batch No.");
                    ExchangeLabel.SetRange("Register No.", SaleLinePOS."Register No.");
                    ExchangeLabel.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
                    ExchangeLabel.SetRange("Batch No.", LabelBatchNumber);
                    ExchangeLabel.FindSet();
                    PrintLabel(ExchangeLabel);
                end;
        end;
    end;

    procedure PrintLabelsFromPOSWithoutPrompts(PrintType: Option Single,LineQuantity,All,Selection,Package; var SaleLinePOS: Record "NPR POS Sale Line"; ValidFromDate: Date)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(SaleLinePOS);
        PrintLabels(PrintType, RecRef, ValidFromDate);
    end;

    local procedure PrintLabelFromRecRef(var RecRef: RecordRef; ValidFromDate: Date; LabelBatchNumber: Integer)
    var
        ExchangeLabel: Record "NPR Exchange Label";
        LabelNo: Code[10];
    begin
        if not IsItemLine(RecRef) then exit;

        LabelNo := CreateExchLabelLineFromRecRef(RecRef, ValidFromDate, LabelBatchNumber, false);
        GetLabelFromLabelNo(CopyStr(LabelNo, 1, 7), ExchangeLabel);
        Commit();
        PrintLabel(ExchangeLabel);
    end;

    local procedure PrintLabel(var ExchangeLabel: Record "NPR Exchange Label"): Boolean
    var
        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
        RecRef: RecordRef;
        ExchangeLabelRec: Record "NPR Exchange Label";
        UserSetup: Record "User Setup";
    begin
        UserSetup.Get(UserId);
        RetailReportSelectionMgt.SetRegisterNo(UserSetup."NPR POS Unit No.");

        ExchangeLabel.SetRange("Packaged Batch", false);
        if ExchangeLabel.FindSet() then
            repeat
                ExchangeLabelRec := ExchangeLabel;
                ExchangeLabelRec.SetRecFilter();
                RecRef.GetTable(ExchangeLabelRec);
                RetailReportSelectionMgt.RunObjects(RecRef, "NPR Report Selection Type"::"Exchange Label".AsInteger());
                Clear(RecRef);
            until ExchangeLabel.Next() = 0;

        ExchangeLabel.SetRange("Packaged Batch", true);
        if ExchangeLabel.FindSet() then begin
            RecRef.GetTable(ExchangeLabel);
            RetailReportSelectionMgt.RunObjects(RecRef, "NPR Report Selection Type"::"Exchange Label".AsInteger());
        end;
    end;

    procedure ScanExchangeLabel(var SalePOS: Record "NPR POS Sale"; var Validering: Code[20]; CopyValidering: Code[20]) Found: Boolean
    var
        ExchangeLabel: Record "NPR Exchange Label";
        Item: Record Item;
        ExchangeLabelSetup: record "NPR Exchange Label Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        LineNo: Integer;
        SalesPrice: Decimal;
    begin
        ExchangeLabelSetup.Get();

        if CheckPrefix(CopyValidering, ExchangeLabelSetup."EAN Prefix Exhange Label") then begin
            ExchangeLabel.SetCurrentKey(Barcode);
            ExchangeLabel.SetRange(Barcode, CopyValidering);

            if ExchangeLabel.FindFirst() then begin
                if ExchangeLabel."Packaged Batch" then begin
                    ExchangeLabel.SetRange(Barcode);
                    ExchangeLabel.SetRange("Batch No.", ExchangeLabel."Batch No.");
                    ExchangeLabel.SetRange("Store ID", ExchangeLabel."Store ID");
                    ExchangeLabel.SetRange("Register No.", ExchangeLabel."Register No.");
                    ExchangeLabel.SetRange("Sales Ticket No.", ExchangeLabel."Sales Ticket No.");
                    ExchangeLabel.SetCurrentKey("Register No.", "Sales Ticket No.", "Batch No.");
                    ExchangeLabel.FindSet();
                end;
                repeat
                    SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
                    SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
                    if SaleLinePOS.FindLast() then
                        LineNo := SaleLinePOS."Line No." + 10000
                    else
                        LineNo := 10000;

                    if not Item.Get(ExchangeLabel."Item No.") then
                        Error(Text00001);

                    SaleLinePOS.Init();
                    SaleLinePOS."Register No." := SalePOS."Register No.";
                    SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
                    SaleLinePOS."Line No." := LineNo;
                    SaleLinePOS.Date := SalePOS.Date;
                    SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Item;
                    SaleLinePOS."Eksp. Salgspris" := true;
                    SaleLinePOS."Custom Price" := true;
                    SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::Manual;
                    if ExchangeLabel."Variant Code" <> '' then
                        SaleLinePOS."Variant Code" := ExchangeLabel."Variant Code";
                    SaleLinePOS.Validate("No.", ExchangeLabel."Item No.");

                    SaleLinePOS.Validate("Unit of Measure Code", ExchangeLabel."Unit of Measure");

                    if ExchangeLabel.Quantity > 0 then
                        SaleLinePOS.Validate(Quantity, ExchangeLabel.Quantity * -1)
                    else
                        SaleLinePOS.Validate(Quantity, -1);
                    SaleLinePOS.Insert(true);
                    if not SaleLinePOS."Price Includes VAT" and (SaleLinePOS."VAT %" <> 0) then begin
                        ExchangeLabel."Unit Price" := Round(ExchangeLabel."Unit Price" / (1 + SaleLinePOS."VAT %" / 100), 0.00001);
                        SalesPrice := Round(ExchangeLabel."Sales Price Incl. Vat" / (1 + SaleLinePOS."VAT %" / 100), 0.00001);
                    end else
                        SalesPrice := ExchangeLabel."Sales Price Incl. Vat";
                    if ExchangeLabel."Unit Price" <> 0 then
                        SaleLinePOS.Validate("Unit Price", ExchangeLabel."Unit Price");
                    if SaleLinePOS."Unit Price" < SalesPrice then
                        SaleLinePOS.Validate("Unit Price", SalesPrice)
                    else
                        SaleLinePOS.Validate("Amount Including VAT", ExchangeLabel."Sales Price Incl. Vat" * SaleLinePOS.Quantity);
                    SaleLinePOS.Modify();
                    Validering := '';
                    Found := true;
                until ExchangeLabel.Next() = 0;
            end;
        end;
    end;

    local procedure GetFieldNo(var RecRef: RecordRef; Name: Text[50]) FieldNo: Integer
    var
        "Field": Record "Field";
    begin
        Field.SetRange(TableNo, RecRef.Number);
        Field.SetRange(FieldName, Name);
        if Field.FindFirst() then
            FieldNo := Field."No.";
        exit(FieldNo)
    end;

    procedure GetUnitPriceInclVat(RecRef: RecordRef) UnitPrice: Decimal
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        //-NPR5.49 [345209]
        case RecRef.Number of
            DATABASE::"Sales Line":
                begin
                    RecRef.SetTable(SalesLine);
                    UnitPrice := SalesLine."Unit Price";

                    if SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") and (not SalesHeader."Prices Including VAT") then
                        UnitPrice *= (1 + (SalesLine."VAT %" / 100));
                end;
            DATABASE::"Sales Invoice Line":
                begin
                    RecRef.SetTable(SalesInvLine);
                    UnitPrice := SalesInvLine."Unit Price";

                    if SalesInvHeader.Get(SalesInvLine."Document No.") and (not SalesInvHeader."Prices Including VAT") then
                        UnitPrice *= (1 + (SalesInvLine."VAT %" / 100));
                end;
            DATABASE::"NPR POS Sale Line":
                begin
                    RecRef.SetTable(SaleLinePOS);
                    UnitPrice := SaleLinePOS."Unit Price";

                    if SalePOS.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.") and (not SalePOS."Prices Including VAT") then
                        UnitPrice *= (1 + (SaleLinePOS."VAT %" / 100));
                end;
        end;

        exit(UnitPrice);
        //+NPR5.49 [345209]
    end;

    procedure GetSalesPriceInclVat(RecRef: RecordRef) SalesPrice: Decimal
    var
        SalesHeader: Record "Sales Header";
        DocumentType: Integer;
        DocumentNo: Code[20];
        UnitPrice: Decimal;
        Quantity: Decimal;
        VATPct: Decimal;
    begin
        case RecRef.Number of
            DATABASE::"Sales Line":
                begin
                    AssignIntegerFieldValue(DocumentType, RecRef, 'Document Type');
                    AssignCode20FieldValue(DocumentNo, RecRef, 'Document No.');
                    AssignDecimalFieldValue(UnitPrice, RecRef, 'Unit Price');
                    AssignDecimalFieldValue(VATPct, RecRef, 'VAT %');

                    if SalesHeader.Get(DocumentType, DocumentNo) then
                        if not SalesHeader."Prices Including VAT" then
                            SalesPrice := UnitPrice * (1 + (VATPct / 100))
                        else
                            SalesPrice := UnitPrice;
                end;
            DATABASE::"NPR POS Sale Line":
                begin
                    AssignDecimalFieldValue(UnitPrice, RecRef, 'Amount Including VAT');
                    AssignDecimalFieldValue(Quantity, RecRef, 'Quantity');
                    if Quantity <> 0 then
                        SalesPrice := UnitPrice / Quantity;
                end;
        end;
    end;

    procedure GetLabelGroupBatchNo(SaleLinePOS: Record "NPR POS Sale Line") NextGroupNo: Integer
    var
        ExchangeLabel: Record "NPR Exchange Label";
    begin
        ExchangeLabel.SetCurrentKey("Register No.", "Sales Ticket No.", "Batch No.");
        ExchangeLabel.SetRange("Register No.", SaleLinePOS."Register No.");
        ExchangeLabel.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        if ExchangeLabel.FindLast() then
            exit(ExchangeLabel."Batch No." + 1)
        else
            exit(1);
    end;

    procedure IsItemLine(RecRef: RecordRef): Boolean
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SalesLine: Record "Sales Line";
        SalesInvLine: Record "Sales Invoice Line";
        Type: Integer;
    begin
        case RecRef.Number of
            DATABASE::"Sales Line":
                begin
                    AssignIntegerFieldValue(Type, RecRef, 'Type');
                    exit(Type = SalesLine.Type::Item.AsInteger())
                end;
            DATABASE::"Sales Invoice Line":
                begin
                    AssignIntegerFieldValue(Type, RecRef, 'Type');
                    exit(Type = SalesInvLine.Type::Item.AsInteger())
                end;
            DATABASE::"NPR POS Sale Line":
                begin
                    AssignIntegerFieldValue(Type, RecRef, 'Line Type');
                    exit(Type = SaleLinePOS."Line Type"::Item.AsInteger())
                end;
        end;
    end;

    local procedure AssignOptionFieldValue(var OptionVal: Option "1","2","3","4","5","6","7","8","9"; RecordRef: RecordRef; FieldName: Text[50])
    var
        FieldRef: FieldRef;
        FieldNo: Integer;
    begin
        FieldNo := GetFieldNo(RecordRef, FieldName);
        FieldRef := RecordRef.Field(FieldNo);
        OptionVal := FieldRef.Value;
    end;

    local procedure AssignIntegerFieldValue(var IntegerVal: Integer; RecordRef: RecordRef; FieldName: Text[50])
    var
        FieldRef: FieldRef;
        FieldNo: Integer;
    begin
        FieldNo := GetFieldNo(RecordRef, FieldName);
        FieldRef := RecordRef.Field(FieldNo);
        IntegerVal := FieldRef.Value;
    end;

    local procedure AssignCode20FieldValue(var CodeVal: Code[20]; RecordRef: RecordRef; FieldName: Text[50])
    var
        FieldRef: FieldRef;
        FieldNo: Integer;
    begin
        FieldNo := GetFieldNo(RecordRef, FieldName);
        FieldRef := RecordRef.Field(FieldNo);
        CodeVal := FieldRef.Value;
    end;

    local procedure AssignCode10FieldValue(var CodeVal: Code[10]; RecordRef: RecordRef; FieldName: Text[50])
    var
        FieldRef: FieldRef;
        FieldNo: Integer;
    begin
        FieldNo := GetFieldNo(RecordRef, FieldName);
        FieldRef := RecordRef.Field(FieldNo);
        CodeVal := FieldRef.Value;
    end;

    local procedure AssignDecimalFieldValue(var DecimalVal: Decimal; RecordRef: RecordRef; FieldName: Text[50])
    var
        FieldRef: FieldRef;
        FieldNo: Integer;
    begin
        FieldNo := GetFieldNo(RecordRef, FieldName);
        FieldRef := RecordRef.Field(FieldNo);
        DecimalVal := FieldRef.Value;
    end;

    local procedure InitRetailReference(var LineRef: RecordRef) ReferenceNo: Code[50]
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        NpGpPOSSalesInitMgt: Codeunit "NPR NpGp POS Sales Init Mgt.";
    begin
        //-NPR5.51
        if LineRef.Number <> DATABASE::"NPR POS Sale Line" then
            exit;

        LineRef.SetTable(SaleLinePOS);
        ReferenceNo := CopyStr(NpGpPOSSalesInitMgt.InitReferenceNoSaleLinePOS(SaleLinePOS), 1, MaxStrLen(ReferenceNo));
        //+NPR5.51
    end;

    procedure CheckPrefix(Barcode: Text; Prefix: Code[10]): Boolean
    var
        EAN13Prefix: Integer;
        InternalUseRange: Integer;
    begin
        //-NPR5.53 [372948]
        if (Evaluate(EAN13Prefix, CopyStr(Barcode, 1, 2)) and Evaluate(InternalUseRange, Prefix)) then begin
            InternalUseRange := InternalUseRange div 10;

            // EAN-13 ranges for internal usage are 20 - 29 and 40 - 49
            if (InternalUseRange) in [2, 4] then
                exit((EAN13Prefix >= InternalUseRange * 10) and (EAN13Prefix < (InternalUseRange + 1) * 10));
        end;

        exit(CopyStr(Barcode, 1, 2) = Prefix);
        //+NPR5.53 [372948]
    end;

    procedure CreateEAN(Unique: Code[7]; Prefix: Code[2]) EAN: Code[20]
    var
        POSStore: Record "NPR POS Store";
        VarietySetup: Record "NPR Variety Setup";
        POSUnit: Record "NPR POS Unit";
        UserSetup: Record "User Setup";
        AfterPrefix: Code[10];
        ErrEAN: Label 'Check No. is invalid for EAN-No.';
        ErrLength: Label 'EAN Creation number is too long.(POS Store Code + Exchange Label prefix should be maximum 5 characters)\\Either you decrease POS Store Code or Exchange Label Prefix characters \\ Or you can complete Exchange Label EAN Code in the POS Store Card ';
        InvalidExchNoLbl: Label 'Only digits are allowed when creating EAN: %1\\ Please check No. Series numbers used for Exchange Label!';
        InvalidPrefixLbl: Label 'Only digits are allowed when creating EAN: %1\\ Please check EAN Prefix on Exchange Label Setup';
    begin
        if StrLen(Unique) > 10 then
            Error(ErrLength);

        if StrLen(DelChr(LowerCase(Unique), '=', '1234567890')) <> 0 then
            Error(InvalidExchNoLbl, Unique);

        if StrLen(DelChr(LowerCase(Prefix), '=', '1234567890')) <> 0 then
            Error(InvalidPrefixLbl, Prefix);

        if UserSetup.Get(UserId) then
            if POSUnit.Get(UserSetup."NPR POS Unit No.") then;
        if POSStore.Get(POSUnit."POS Store Code") then;

        if (StrLen(Prefix) + StrLen(POSUnit."POS Store Code") + StrLen(Format(Unique)) > 12)
            or (StrLen(DelChr(LowerCase(POSUnit."POS Store Code"), '=', '1234567890')) <> 0)
         then
            if POSStore."Exchange Label EAN Code" = '' then
                Error(ErrLength);

        if POSStore."Exchange Label EAN Code" <> '' then
            AfterPrefix := POSStore."Exchange Label EAN Code"
        else
            AfterPrefix := POSUnit."POS Store Code";

        VarietySetup.Get();

        case Prefix of
            '':
                begin
                    Prefix := Format(VarietySetup."EAN-Internal");
                    EAN := CopyStr(Format(Prefix) + PadStr('', 10 - StrLen(Format(Unique)), '0') + Format(Unique), 1, MaxStrLen(EAN));
                end;
            else
                EAN := CopyStr(Format(Prefix) + Format(AfterPrefix) +
                           PadStr('', 12 - (StrLen(Prefix) + StrLen(AfterPrefix) + StrLen(Format(Unique))), '0') + Format(Unique), 1, MaxStrLen(EAN));

        end;
        EAN := EAN + Format(StrCheckSum(EAN, '131313131313'));

        if StrCheckSum(EAN, '1313131313131') <> 0 then
            Error(ErrEAN);

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnBeforeEndSale', '', true, true)]
    local procedure CreateExchangeLabelOnSaleLineAllLines(SaleHeader: Record "NPR POS Sale"; sender: Codeunit "NPR POS Sale")
    var
        ExchangeLabelSetup: Record "NPR Exchange Label Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        if not ExchangeLabelSetup.Get() then
            exit;
        if not ExchangeLabelSetup."Insert Cross Ref. Finish Sale" then
            exit;

        POSSession.GetSetup(POSSetup);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        RecRef.GetTable(SaleLinePOS);
        RecRef.Copy(SaleLinePOS);
        FieldRef := RecRef.Field(GetFieldNo(RecRef, 'Line No.'));
        FieldRef.SetRange();
        if RecRef.FindSet() then
            repeat
                CreateExchLabelLineFromRecRef(RecRef, WorkDate(), 0, false);
            until RecRef.Next() = 0;
    end;

}

