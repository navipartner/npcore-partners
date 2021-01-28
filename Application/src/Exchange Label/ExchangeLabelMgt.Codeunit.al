codeunit 6014498 "NPR Exchange Label Mgt."
{

    // NPR5.51/ALST/20190624 CASE 337539 "Retail Cross Reference No." gets a value if global exchange is set up
    // NPR5.53/ALST/20191028 CASE 372948 check EAN prefix in range instead of single value
    // NPR5.55/ALPO/20200731 CASE 412253 Correct unit price calclulation with prices set to be VAT-excluding

    var
        Text00001: Label 'The item was not found. Use manual procedure in order to return the item.';
        Text00002: Label 'The function can only be used with a POS Sale.';
        t002: Label 'What date should the exchange label be valid from?';
        ExitOnFindLabel: Boolean;
        Text000: Label 'Exchange Label';

    local procedure CreateExchLabelLineFromRecRef(var RecRef: RecordRef; ValidFromDate: Date; LabelBatchNumber: Integer; PackagedBatch: Boolean): Code[7]
    var
        ExchangeLabel: Record "NPR Exchange Label";
        RetailConfiguration: Record "NPR Retail Setup";
        Register: Record "NPR Register";
        String: Codeunit "NPR String Library";
        RetailFormCode: Codeunit "NPR Retail Form Code";
    begin
        RetailConfiguration.Get;
        ExchangeLabel.Init;

        if Register.Get(RetailFormCode.FetchRegisterNumber) then;

        if StrLen(Register."Shop id") <> 3 then
            Register."Shop id" := String.PadStrLeft(Register."Shop id", 3, ' ', false);

        ExchangeLabel."Store ID" := Register."Shop id";
        ExchangeLabel."Register No." := Register."Register No.";

        ExchangeLabel."Company Name" := CompanyName;
        ExchangeLabel."Table No." := RecRef.Number;
        ExchangeLabel."Valid From" := ValidFromDate;
        //-NPR5.49 [345209]
        ExchangeLabel."Unit Price" := GetUnitPriceInclVat(RecRef);
        //+NPR5.49 [345209]
        ExchangeLabel."Sales Price Incl. Vat" := GetSalesPriceInclVat(RecRef);
        ExchangeLabel."Valid To" := CalcDate(RetailConfiguration."Exchange Label Exchange Period", ValidFromDate);
        ExchangeLabel."Batch No." := LabelBatchNumber;
        ExchangeLabel."Packaged Batch" := PackagedBatch;

        case RecRef.Number of
            DATABASE::"Sales Line":
                begin
                    AssignOptionFieldValue(ExchangeLabel."Sales Header Type", RecRef, 'Document Type');
                    AssignCodeFieldValue(ExchangeLabel."Sales Header No.", RecRef, 'Document No.');
                    AssignCodeFieldValue(ExchangeLabel."Unit of Measure", RecRef, 'Unit of Measure');
                end;
            DATABASE::"NPR Sale Line POS":
                begin
                    AssignCodeFieldValue(ExchangeLabel."Register No.", RecRef, 'Register No.');
                    AssignCodeFieldValue(ExchangeLabel."Sales Ticket No.", RecRef, 'Sales Ticket No.');
                    AssignCodeFieldValue(ExchangeLabel."Unit of Measure", RecRef, 'Unit of Measure Code');
                end;
        end;

        AssignIntegerFieldValue(ExchangeLabel."Sales Line No.", RecRef, 'Line No.');
        AssignCodeFieldValue(ExchangeLabel."Item No.", RecRef, 'No.');
        AssignCodeFieldValue(ExchangeLabel."Variant Code", RecRef, 'Variant Code');
        //-NPR5.37 [292701]
        if PackagedBatch then
            AssignDecimalFieldValue(ExchangeLabel.Quantity, RecRef, 'Quantity')
        else
            ExchangeLabel.Quantity := 1;
        //AssignDecimalFieldValue(ExchangeLabel.Quantity,                 RecRef, 'Quantity');
        //+NPR5.37 [292701]

        //-NPR5.51
        ExchangeLabel."Retail Cross Reference No." := InitRetailReference(RecRef);
        //+NPR5.51

        ExchangeLabel.Insert(true);
        exit(ExchangeLabel."No.");
    end;

    procedure GetLabelBarcode(var ExchangeLabel: Record "NPR Exchange Label"): Code[13]
    var
        RetailConfiguration: Record "NPR Retail Setup";
        String: Codeunit "NPR String Library";
        Utility: Codeunit "NPR Utility";
        StoreCode: Code[3];
        LabelCode: Code[7];
    begin
        RetailConfiguration.Get;

        with ExchangeLabel do begin
            LabelCode := String.PadStrLeft("No.", 7, '0', false);
            exit(Utility.CreateEAN(StoreCode + LabelCode, RetailConfiguration."EAN Prefix Exhange Label"));
        end;
    end;

    local procedure GetLabelFromLabelNo(LabelNo: Code[7]; var ExchangeLabel: Record "NPR Exchange Label")
    begin
        ExchangeLabel.SetCurrentKey("No.");
        ExchangeLabel.SetRange("No.", LabelNo);
        ExchangeLabel.FindFirst;
    end;

    local procedure PrintLabels(PrintType: Option Single,LineQuantity,All,Selection,Package; var LineRef: RecordRef; ValidFromDate: Date): Boolean
    var
        ExchangeLabel: Record "NPR Exchange Label";
        SaleLinePOS: Record "NPR Sale Line POS";
        SaleLinePOSSelected: Record "NPR Sale Line POS";
        SalePOS: Record "NPR Sale POS";
        t001: Label 'No lines to print exchange labels from';
        FieldRef: FieldRef;
        Dialog: Dialog;
        Validering: Text[30];
        ID: Integer;
        LabelBatchNumber: Integer;
        LineCount: Integer;
        FieldNo: Integer;
        "-- temp": Integer;
        reccount: Integer;
        Cancelled: Boolean;
        Date1: Date;
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
                    FieldRef := LineRef.Field(GetFieldNo(LineRef, 'Sale Type'));
                    FieldRef.SetRange();
                    if LineRef.FindSet then
                        repeat
                            AssignIntegerFieldValue(LineCount, LineRef, 'Quantity');
                            while LineCount > 0 do begin
                                PrintLabelFromRecRef(LineRef, ValidFromDate, 0);
                                LineCount -= 1;
                            end;
                        until LineRef.Next = 0;
                end;
            PrintType::Selection, PrintType::Package:
                begin
                    LineRef.SetTable(SaleLinePOS);
                    LabelBatchNumber := GetLabelGroupBatchNo(SaleLinePOS);

                    if LineRef.FindSet then
                        repeat
                            CreateExchLabelLineFromRecRef(LineRef, ValidFromDate, LabelBatchNumber, (PrintType = PrintType::Package));
                        until LineRef.Next = 0;

                    ExchangeLabel.SetCurrentKey("Register No.", "Sales Ticket No.", "Batch No.");
                    ExchangeLabel.SetRange("Register No.", SaleLinePOS."Register No.");
                    ExchangeLabel.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
                    ExchangeLabel.SetRange("Batch No.", LabelBatchNumber);
                    ExchangeLabel.FindSet;
                    PrintLabel(ExchangeLabel);
                end;
        end;
    end;

    procedure PrintLabelsFromPOSWithoutPrompts(PrintType: Option Single,LineQuantity,All,Selection,Package; var SaleLinePOS: Record "NPR Sale Line POS"; var ValidFromDate: Date)
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
        GetLabelFromLabelNo(LabelNo, ExchangeLabel);
        Commit;
        PrintLabel(ExchangeLabel);
    end;

    local procedure PrintLabel(var ExchangeLabel: Record "NPR Exchange Label"): Boolean
    var
        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        RecRef: RecordRef;
        RetailFormCode: Codeunit "NPR Retail Form Code";
        ExchangeLabelRec: Record "NPR Exchange Label";
    begin

        RetailReportSelectionMgt.SetRegisterNo(RetailFormCode.FetchRegisterNumber());

        ExchangeLabel.SetRange("Packaged Batch", false);
        if ExchangeLabel.FindSet then
            repeat
                ExchangeLabelRec := ExchangeLabel;
                ExchangeLabelRec.SetRecFilter;
                RecRef.GetTable(ExchangeLabelRec);
                RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Exchange Label");
                Clear(RecRef);
            until ExchangeLabel.Next = 0;

        ExchangeLabel.SetRange("Packaged Batch", true);
        if ExchangeLabel.FindSet then begin
            RecRef.GetTable(ExchangeLabel);
            RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Exchange Label");
        end;
    end;

    procedure ScanExchangeLabel(var SalePOS: Record "NPR Sale POS"; var Validering: Code[20]; var CopyValidering: Code[20]) Found: Boolean
    var
        ExchangeLabel: Record "NPR Exchange Label";
        IComm: Record "NPR I-Comm";
        Item: Record Item;
        RetailConfiguration: Record "NPR Retail Setup";
        SaleLinePOS: Record "NPR Sale Line POS";
        LineNo: Integer;
        SalesPrice: Decimal;
    begin
        RetailConfiguration.Get;

        //-NPR5.53 [372948]
        //IF COPYSTR(CopyValidering, 1, 2) = RetailConfiguration."EAN Prefix Exhange Label" THEN BEGIN
        if CheckPrefix(CopyValidering, RetailConfiguration."EAN Prefix Exhange Label") then begin
            //+NPR5.53 [372948]
            ExchangeLabel.SetCurrentKey(Barcode);
            ExchangeLabel.SetRange(Barcode, CopyValidering);

            if not ExchangeLabel.FindFirst and RetailConfiguration."Use I-Comm" and IComm.Get
              and (IComm."Exchange Label Center Company" <> '') then begin
                ExchangeLabel.ChangeCompany(IComm."Company - Clearing");
            end;

            if ExchangeLabel.FindFirst then begin
                if ExchangeLabel."Packaged Batch" then begin
                    ExchangeLabel.SetRange(Barcode);
                    ExchangeLabel.SetRange("Batch No.", ExchangeLabel."Batch No.");
                    ExchangeLabel.SetRange("Store ID", ExchangeLabel."Store ID");
                    ExchangeLabel.SetRange("Register No.", ExchangeLabel."Register No.");
                    ExchangeLabel.SetRange("Sales Ticket No.", ExchangeLabel."Sales Ticket No.");
                    ExchangeLabel.SetCurrentKey("Register No.", "Sales Ticket No.", "Batch No.");
                    ExchangeLabel.FindSet;
                end;
                repeat
                    SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
                    SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
                    if SaleLinePOS.FindLast then
                        LineNo := SaleLinePOS."Line No." + 10000
                    else
                        LineNo := 10000;

                    if not Item.Get(ExchangeLabel."Item No.") then
                        Error(Text00001);

                    SaleLinePOS.Init;
                    SaleLinePOS."Register No." := SalePOS."Register No.";
                    SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
                    SaleLinePOS."Line No." := LineNo;
                    SaleLinePOS.Date := SalePOS.Date;
                    SaleLinePOS.Type := SaleLinePOS.Type::Item;
                    SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Sale;
                    SaleLinePOS."Eksp. Salgspris" := true;
                    SaleLinePOS."Custom Price" := true;
                    SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::Manual;
                    if ExchangeLabel."Variant Code" <> '' then
                        SaleLinePOS."Variant Code" := ExchangeLabel."Variant Code";
                    SaleLinePOS.Validate("No.", ExchangeLabel."Item No.");

                    //-NPR5.48 [335967]
                    //SaleLinePOS."Unit of Measure Code" := ExchangeLabel."Unit of Measure";
                    SaleLinePOS.Validate("Unit of Measure Code", ExchangeLabel."Unit of Measure");
                    //+NPR5.48 [335967]

                    if ExchangeLabel.Quantity > 0 then
                        SaleLinePOS.Validate(Quantity, ExchangeLabel.Quantity * -1)
                    else
                        SaleLinePOS.Validate(Quantity, -1);
                    SaleLinePOS.Insert(true);
                    //SaleLinePOS."Price Includes VAT" := TRUE;  //NPR5.55 [412253]-revoked
                    //-NPR5.55 [412253]
                    if not SaleLinePOS."Price Includes VAT" and (SaleLinePOS."VAT %" <> 0) then begin
                        ExchangeLabel."Unit Price" := Round(ExchangeLabel."Unit Price" / (1 + SaleLinePOS."VAT %" / 100), 0.00001);
                        SalesPrice := Round(ExchangeLabel."Sales Price Incl. Vat" / (1 + SaleLinePOS."VAT %" / 100), 0.00001);
                    end else
                        SalesPrice := ExchangeLabel."Sales Price Incl. Vat";
                    //+NPR5.55 [412253]
                    //-NPR5.49 [345209]
                    //SaleLinePOS.VALIDATE("Unit Price", ExchangeLabel."Sales Price Incl. Vat");
                    if ExchangeLabel."Unit Price" <> 0 then
                        SaleLinePOS.Validate("Unit Price", ExchangeLabel."Unit Price");
                    //-NPR5.55 [412253]-revoked
                    //IF SaleLinePOS."Unit Price" < ExchangeLabel."Sales Price Incl. Vat" THEN
                    //  SaleLinePOS.VALIDATE("Unit Price", ExchangeLabel."Sales Price Incl. Vat")
                    //+NPR5.55 [412253]-revoked
                    //-NPR5.55 [412253]
                    if SaleLinePOS."Unit Price" < SalesPrice then
                        SaleLinePOS.Validate("Unit Price", SalesPrice)
                    //+NPR5.55 [412253]
                    else
                        SaleLinePOS.Validate("Amount Including VAT", ExchangeLabel."Sales Price Incl. Vat" * SaleLinePOS.Quantity);
                    //+NPR5.49 [345209]
                    SaleLinePOS.Modify;
                    Validering := '';
                    Found := true;
                until ExchangeLabel.Next = 0;
            end;
        end;
    end;

    local procedure GetFieldNo(var RecRef: RecordRef; Name: Text[50]) FieldNo: Integer
    var
        "Field": Record "Field";
    begin
        Field.SetRange(TableNo, RecRef.Number);
        Field.SetRange(FieldName, Name);
        if Field.FindFirst then
            FieldNo := Field."No.";
        exit(FieldNo)
    end;

    procedure GetUnitPriceInclVat(RecRef: RecordRef) UnitPrice: Decimal
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
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
            DATABASE::"NPR Sale Line POS":
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
                    AssignCodeFieldValue(DocumentNo, RecRef, 'Document No.');
                    AssignDecimalFieldValue(UnitPrice, RecRef, 'Unit Price');
                    AssignDecimalFieldValue(VATPct, RecRef, 'VAT %');

                    SalesHeader.Get(DocumentType, DocumentNo);
                    if not SalesHeader."Prices Including VAT" then
                        SalesPrice := UnitPrice * (1 + (VATPct / 100))
                    else
                        SalesPrice := UnitPrice;
                end;
            DATABASE::"NPR Sale Line POS":
                begin
                    AssignDecimalFieldValue(UnitPrice, RecRef, 'Amount Including VAT');
                    AssignDecimalFieldValue(Quantity, RecRef, 'Quantity');
                    SalesPrice := UnitPrice / Quantity;
                end;
        end;
    end;

    procedure GetLabelGroupBatchNo(SaleLinePOS: Record "NPR Sale Line POS") NextGroupNo: Integer
    var
        ExchangeLabel: Record "NPR Exchange Label";
    begin
        ExchangeLabel.SetCurrentKey("Register No.", "Sales Ticket No.", "Batch No.");
        ExchangeLabel.SetRange("Register No.", SaleLinePOS."Register No.");
        ExchangeLabel.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        if ExchangeLabel.FindLast then
            exit(ExchangeLabel."Batch No." + 1)
        else
            exit(1);
    end;

    procedure IsItemLine(RecRef: RecordRef): Boolean
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        SalesLine: Record "Sales Line";
        Type: Integer;
    begin
        case RecRef.Number of
            DATABASE::"Sales Line":
                begin
                    AssignIntegerFieldValue(Type, RecRef, 'Type');
                    exit(Type = SalesLine.Type::Item.AsInteger())
                end;
            DATABASE::"NPR Sale Line POS":
                begin
                    AssignIntegerFieldValue(Type, RecRef, 'Type');
                    exit(Type = SaleLinePOS.Type::Item)
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

    local procedure AssignCodeFieldValue(var CodeVal: Code[20]; RecordRef: RecordRef; FieldName: Text[50])
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
        SaleLinePOS: Record "NPR Sale Line POS";
        NpGpPOSSalesInitMgt: Codeunit "NPR NpGp POS Sales Init Mgt.";
    begin
        //-NPR5.51
        if LineRef.Number <> DATABASE::"NPR Sale Line POS" then
            exit;

        LineRef.SetTable(SaleLinePOS);
        ReferenceNo := NpGpPOSSalesInitMgt.InitReferenceNoSaleLinePOS(SaleLinePOS);
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

    procedure "-- Enums"()
    begin
    end;

    procedure PrintTypeLine(): Integer
    var
        PrintType: Option Single,LineQuantity,All;
    begin
        exit(PrintType::Single)
    end;

    procedure PrintTypeLineQuantity(): Integer
    var
        PrintType: Option Single,LineQuantity,All;
    begin
        exit(PrintType::LineQuantity)
    end;

    procedure PrintTypeLineAll(): Integer
    var
        PrintType: Option Single,LineQuantity,All;
    begin
        exit(PrintType::All)
    end;

    procedure ScanExchangeLabelRetailJnl(var RetailJnlLine: Record "NPR Retail Journal Line"; var Validering: Code[20]) Found: Boolean
    var
        ExchangeLabel: Record "NPR Exchange Label";
        IComm: Record "NPR I-Comm";
        Item: Record Item;
        RetailConfiguration: Record "NPR Retail Setup";
        RetailJnlLine2: Record "NPR Retail Journal Line";
        LineNo: Integer;
    begin
        RetailConfiguration.Get;

        if CopyStr(Validering, 1, 2) <> RetailConfiguration."EAN Prefix Exhange Label" then
            exit(false);

        ExchangeLabel.SetCurrentKey(Barcode);
        ExchangeLabel.SetRange(Barcode, Validering);

        if not ExchangeLabel.FindFirst and RetailConfiguration."Use I-Comm" and
           IComm.Get and (IComm."Exchange Label Center Company" <> '') then
            ExchangeLabel.ChangeCompany(IComm."Company - Clearing");

        if ExchangeLabel.FindFirst then begin
            if ExchangeLabel."Packaged Batch" then begin
                ExchangeLabel.SetRange(Barcode);
                ExchangeLabel.SetRange("Batch No.", ExchangeLabel."Batch No.");
                ExchangeLabel.SetRange("Store ID", ExchangeLabel."Store ID");
                ExchangeLabel.SetRange("Register No.", ExchangeLabel."Register No.");
                ExchangeLabel.SetRange("Sales Ticket No.", ExchangeLabel."Sales Ticket No.");
                ExchangeLabel.SetCurrentKey("Register No.", "Sales Ticket No.", "Batch No.");
                ExchangeLabel.FindSet;
            end;

            repeat
                with RetailJnlLine do begin
                    if not Item.Get(ExchangeLabel."Item No.") then
                        Error(Text00001);

                    RetailJnlLine2.SetRange("No.", "No.");
                    if RetailJnlLine2.FindLast then;

                    Init;
                    "Line No." := RetailJnlLine2."Line No." + 10000;

                    Validate("Item No.", ExchangeLabel."Item No.");
                    "Sales Unit of measure" := ExchangeLabel."Unit of Measure";
                    Validate("Quantity to Print", ExchangeLabel.Quantity);
                    if ExchangeLabel."Variant Code" <> '' then
                        Validate("Variant Code", ExchangeLabel."Variant Code");
                    Insert;
                end;
            until ExchangeLabel.Next = 0;
            exit(true);
        end;
        exit(false);
    end;
}

