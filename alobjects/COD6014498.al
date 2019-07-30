// TODO: CTRLUPGRADE - uses old Standard code; must be removed or refactored
codeunit 6014498 "Exchange Label Management"
{
    // NPR4.10/VB/20150602 CASE 213003 Support for Web Client (JavaScript) client
    // NPR4.10/MMV/20150527 CASE 213635 Moved insert of 'Variant Code' to before 'No' to prevent variant selection window in POS when variant is already known.
    // NPR4.13/MMV/20150715 CASE 215400 Added code to handle new field Register."Exchange Label Exchange Period"
    // NPR4.14/MMV/20150825 CASE 181190 Added support for multiple exchange labels when calling print.
    // NPRx.xx/VB/20160105  CASE 230373 Refactoring due to client-side formatting of decimal and date/time values
    // NPR5.00/NPKNAV/20160113  CASE 230373 NP Retail 2016
    // NPR5.26/MMV /20160810 CASE 248262 Removed support for deprecated fields.
    // NPR5.26/MMV /20160802 CASE 246998 Added support for Quantity & Unit of measure.
    //                                   Removed old NPR comments.
    // NPR5.30/MMV /20170227 CASE 248985 Refactored PrintLabels() for Transcendence: Seperated GUI from business logic.
    // NPR5.32.02/MMV /20170607 CASE 279700 Updated field name.
    // NPR5.36/ANEN /20170910 CASE 289887 Added fcn. BarCodeIsExchangeLabel and IdExchangeLabelSubscriber
    // NPR5.37/MMV /20171006 CASE 292701 Create one quantity lines for everything but packages.
    // NPR5.45/MHA /20180814  CASE 319706 Deleted functions BarCodeIsExchangeLabel(),IdExchangeLabelSubscriber()
    // NPR5.48/JDH /20181206 CASE 335967 Validating Unit of Measure Code
    // NPR5.49/MHA /20190211 CASE 345209 Amount Including Vat should be changed so that Discount is reflected


    trigger OnRun()
    begin
    end;

    var
        Text00001: Label 'The item was not found. Use manual procedure in order to return the item.';
        Text00002: Label 'The function can only be used with a POS Sale.';
        t002: Label 'What date should the exchange label be valid from?';
        ExitOnFindLabel: Boolean;
        Text000: Label 'Exchange Label';

    local procedure CreateExchLabelLineFromRecRef(var RecRef: RecordRef;ValidFromDate: Date;LabelBatchNumber: Integer;PackagedBatch: Boolean): Code[7]
    var
        ExchangeLabel: Record "Exchange Label";
        RetailConfiguration: Record "Retail Setup";
        Register: Record Register;
        String: Codeunit "String Library";
        RetailFormCode: Codeunit "Retail Form Code";
    begin
        RetailConfiguration.Get;
        ExchangeLabel.Init;

        if Register.Get(RetailFormCode.FetchRegisterNumber) then;

        if StrLen(Register."Shop id") <> 3 then
          Register."Shop id" := String.PadStrLeft(Register."Shop id",3,' ', false);

        ExchangeLabel."Store ID"               := Register."Shop id";
        ExchangeLabel."Register No."           := Register."Register No.";

        ExchangeLabel."Company Name"           := CompanyName;
        ExchangeLabel."Table No."              := RecRef.Number;
        ExchangeLabel."Valid From"             := ValidFromDate;
        //-345209 [345209]
        ExchangeLabel."Unit Price" := GetUnitPriceInclVat(RecRef);
        //+NPR5.49 [345209]
        ExchangeLabel."Sales Price Incl. Vat"  := GetSalesPriceInclVat(RecRef);
        if Format(Register."Exchange Label Exchange Period") <> '' then
          ExchangeLabel."Valid To"                   := CalcDate(Register."Exchange Label Exchange Period",ValidFromDate)
        else
          ExchangeLabel."Valid To"                   := CalcDate(RetailConfiguration."Exchange Label Exchange Period",ValidFromDate);
        ExchangeLabel."Batch No."          := LabelBatchNumber;
        ExchangeLabel."Packaged Batch" := PackagedBatch;

        case RecRef.Number of
          DATABASE::"Sales Line" :
            begin
              AssignOptionFieldValue(ExchangeLabel."Sales Header Type", RecRef, 'Document Type');
              AssignCodeFieldValue(ExchangeLabel."Sales Header No.",    RecRef, 'Document No.');
              AssignCodeFieldValue(ExchangeLabel."Unit of Measure",     RecRef, 'Unit of Measure');
            end;
          DATABASE::"Sale Line POS" :
            begin
              AssignCodeFieldValue(ExchangeLabel."Register No.",        RecRef, 'Register No.');
              AssignCodeFieldValue(ExchangeLabel."Sales Ticket No.",    RecRef, 'Sales Ticket No.');
              AssignCodeFieldValue(ExchangeLabel."Unit of Measure",     RecRef, 'Unit of Measure Code');
            end;
        end;

        AssignIntegerFieldValue(ExchangeLabel."Sales Line No.",         RecRef, 'Line No.');
        AssignCodeFieldValue(ExchangeLabel."Item No.",                  RecRef, 'No.');
        AssignCodeFieldValue(ExchangeLabel."Variant Code",              RecRef, 'Variant Code');
        //-NPR5.37 [292701]
        if PackagedBatch then
          AssignDecimalFieldValue(ExchangeLabel.Quantity,                 RecRef, 'Quantity')
        else
          ExchangeLabel.Quantity := 1;
        //AssignDecimalFieldValue(ExchangeLabel.Quantity,                 RecRef, 'Quantity');
        //+NPR5.37 [292701]

        ExchangeLabel.Insert(true);
        exit(ExchangeLabel."No.");
    end;

    procedure GetLabelBarcode(var ExchangeLabel: Record "Exchange Label"): Code[13]
    var
        RetailConfiguration: Record "Retail Setup";
        String: Codeunit "String Library";
        Utility: Codeunit Utility;
        StoreCode: Code[3];
        LabelCode: Code[7];
    begin
        RetailConfiguration.Get;

        with ExchangeLabel do begin
          LabelCode := String.PadStrLeft("No.", 7, '0',false);
          exit(Utility.CreateEAN(StoreCode + LabelCode, RetailConfiguration."EAN Prefix Exhange Label"));
        end;
    end;

    local procedure GetLabelFromLabelNo(LabelNo: Code[7];var ExchangeLabel: Record "Exchange Label")
    begin
        ExchangeLabel.SetCurrentKey("No.");
        ExchangeLabel.SetRange("No.",LabelNo);
        ExchangeLabel.FindFirst;
    end;

    local procedure PrintLabels(PrintType: Option Single,LineQuantity,All,Selection,Package;var LineRef: RecordRef;ValidFromDate: Date): Boolean
    var
        ExchangeLabel: Record "Exchange Label";
        SaleLinePOS: Record "Sale Line POS";
        SaleLinePOSSelected: Record "Sale Line POS";
        SalePOS: Record "Sale POS";
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
          PrintType::Single :
            begin
              PrintLabelFromRecRef(LineRef,ValidFromDate,0);
            end;
          PrintType::LineQuantity :
            begin
              AssignIntegerFieldValue(LineCount,LineRef,'Quantity');
              while LineCount > 0 do begin
                PrintLabelFromRecRef(LineRef,ValidFromDate,0);
                LineCount -= 1;
              end;
            end;
          PrintType::All :
            begin
              FieldRef := LineRef.Field(GetFieldNo(LineRef,'Line No.'));
              FieldRef.SetRange();
              FieldRef := LineRef.Field(GetFieldNo(LineRef,'Sale Type'));
              FieldRef.SetRange();
              if LineRef.FindSet then repeat
                AssignIntegerFieldValue(LineCount,LineRef,'Quantity');
                while LineCount > 0 do begin
                  PrintLabelFromRecRef(LineRef,ValidFromDate,0);
                  LineCount -= 1;
                end;
              until LineRef.Next = 0;
            end;
          PrintType::Selection, PrintType::Package:
            begin
              LineRef.SetTable(SaleLinePOS);
              LabelBatchNumber := GetLabelGroupBatchNo(SaleLinePOS);

              if LineRef.FindSet then repeat
                CreateExchLabelLineFromRecRef(LineRef, ValidFromDate, LabelBatchNumber, (PrintType = PrintType::Package));
              until LineRef.Next = 0;

              ExchangeLabel.SetCurrentKey("Register No.","Sales Ticket No.","Batch No.");
              ExchangeLabel.SetRange("Register No.", SaleLinePOS."Register No.");
              ExchangeLabel.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
              ExchangeLabel.SetRange("Batch No.", LabelBatchNumber);
              ExchangeLabel.FindSet;
              PrintLabel(ExchangeLabel);
            end;
        end;
    end;

    procedure PrintLabelsFromPOS(PrintType: Option Single,LineQuantity,All,Selection,Package;var SaleLinePOS: Record "Sale Line POS";var ValidFromDate: Date)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(SaleLinePOS);

        if not PromptInput(PrintType, RecRef, ValidFromDate) then
          exit;

        PrintLabels(PrintType,RecRef,ValidFromDate);
    end;

    procedure PrintLabelsFromPOSWithoutPrompts(PrintType: Option Single,LineQuantity,All,Selection,Package;var SaleLinePOS: Record "Sale Line POS";var ValidFromDate: Date)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(SaleLinePOS);
        PrintLabels(PrintType, RecRef, ValidFromDate);
    end;

    procedure PrintLabelsFromSale(PrintType: Option Single,LineQuantity,All,Selection,Package;var SalesLine: Record "Sales Line")
    var
        RecRef: RecordRef;
        ValidFromDate: Date;
    begin
        RecRef.GetTable(SalesLine);

        if not PromptInput(PrintType, RecRef, ValidFromDate) then
          exit;

        PrintLabels(PrintType,RecRef,ValidFromDate);
    end;

    local procedure PrintLabelFromRecRef(var RecRef: RecordRef;ValidFromDate: Date;LabelBatchNumber: Integer)
    var
        ExchangeLabel: Record "Exchange Label";
        LabelNo: Code[10];
    begin
        if not IsItemLine(RecRef) then exit;

        LabelNo := CreateExchLabelLineFromRecRef(RecRef,ValidFromDate,LabelBatchNumber,false);
        GetLabelFromLabelNo(LabelNo, ExchangeLabel);
        Commit;
        PrintLabel(ExchangeLabel);
    end;

    local procedure PrintLabel(var ExchangeLabel: Record "Exchange Label"): Boolean
    var
        RetailReportSelectionMgt: Codeunit "Retail Report Selection Mgt.";
        ReportSelectionRetail: Record "Report Selection Retail";
        RecRef: RecordRef;
        RetailFormCode: Codeunit "Retail Form Code";
        ExchangeLabelRec: Record "Exchange Label";
    begin

        RetailReportSelectionMgt.SetRegisterNo(RetailFormCode.FetchRegisterNumber());

        ExchangeLabel.SetRange("Packaged Batch", false);
        if ExchangeLabel.FindSet then repeat
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

    local procedure PromptInput(PrintType: Option Single,LineQuantity,All,Selection,Package;var RecRef: RecordRef;var ValidFromDate: Date): Boolean
    var
        SaleLinePOS: Record "Sale Line POS";
        Cancelled: Boolean;
        RetailSetup: Record "Retail Setup";
        FieldRef: FieldRef;
        Marshaller: Codeunit "POS Event Marshaller";
        RecRef2: RecordRef;
    begin

        RetailSetup.Get;
        if not (Evaluate(ValidFromDate, RetailSetup."Exchange label default date") and (StrLen(RetailSetup."Exchange label default date") > 0)) then
          ValidFromDate := Today;

        RecRef.SetRecFilter;

        if PrintType in [PrintType::Single, PrintType::LineQuantity, PrintType::All] then begin
          exit(Marshaller.NumPadDate(t002,ValidFromDate,false,false));
        end else begin
          FieldRef := RecRef.Field(GetFieldNo(RecRef,'Line No.'));
          FieldRef.SetRange();
          FieldRef := RecRef.Field(GetFieldNo(RecRef,'Sale Type'));
          FieldRef.SetRange();
          if (RecRef.Number <> DATABASE::"Sale Line POS") then
            Error(Text00002);

          SaleLinePOS.SetView(RecRef.GetView);
          SaleLinePOS.SetFilter(Quantity,'>%1',0);
          SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Sale);
          SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
          if SaleLinePOS.FindSet then repeat
            SaleLinePOS.Mark(true);
          until SaleLinePOS.Next = 0;
          ValidFromDate := Marshaller.CalendarGrid('',ValidFromDate,SaleLinePOS,Cancelled);
          if not Cancelled then begin
            Clear(RecRef);
            RecRef.GetTable(SaleLinePOS);
          end;
          exit(not Cancelled);
        end;
    end;

    procedure "-- Sale POS"()
    begin
    end;

    procedure ScanExchangeLabel(var SalePOS: Record "Sale POS";var Validering: Code[20];var CopyValidering: Code[20]) Found: Boolean
    var
        ExchangeLabel: Record "Exchange Label";
        IComm: Record "I-Comm";
        Item: Record Item;
        RetailConfiguration: Record "Retail Setup";
        SaleLinePOS: Record "Sale Line POS";
        LineNo: Integer;
    begin
        RetailConfiguration.Get;

        if CopyStr(CopyValidering, 1, 2) = RetailConfiguration."EAN Prefix Exhange Label" then begin
          ExchangeLabel.SetCurrentKey(Barcode);
          ExchangeLabel.SetRange(Barcode, CopyValidering);

          if not ExchangeLabel.FindFirst and RetailConfiguration."Use I-Comm" and IComm.Get
            and (IComm."Exchange Label Center Company" <> '') then
          begin
            ExchangeLabel.ChangeCompany(IComm."Company - Clearing");
          end;

          if ExchangeLabel.FindFirst then begin
            if ExchangeLabel."Packaged Batch" then begin
              ExchangeLabel.SetRange(Barcode);
              ExchangeLabel.SetRange("Batch No.", ExchangeLabel."Batch No.");
              ExchangeLabel.SetRange("Store ID", ExchangeLabel."Store ID");
              ExchangeLabel.SetRange("Register No.", ExchangeLabel."Register No.");
              ExchangeLabel.SetRange("Sales Ticket No.", ExchangeLabel."Sales Ticket No.");
              ExchangeLabel.SetCurrentKey("Register No.","Sales Ticket No.","Batch No.");
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
              SaleLinePOS."Register No."     := SalePOS."Register No.";
              SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
              SaleLinePOS."Line No."         := LineNo;
              SaleLinePOS.Date               := SalePOS.Date;
              SaleLinePOS.Type               := SaleLinePOS.Type::Item;
              SaleLinePOS."Sale Type"        := SaleLinePOS."Sale Type"::Sale;
              SaleLinePOS."Eksp. Salgspris"  := true;
              SaleLinePOS."Custom Price"     := true;
              SaleLinePOS."Discount Type"    := SaleLinePOS."Discount Type"::Manual;
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
              SaleLinePOS."Price Includes VAT" := true;
              //-NPR5.49 [345209]
              //SaleLinePOS.VALIDATE("Unit Price", ExchangeLabel."Sales Price Incl. Vat");
              if ExchangeLabel."Unit Price" <> 0 then
                SaleLinePOS.Validate("Unit Price",ExchangeLabel."Unit Price");
              if SaleLinePOS."Unit Price" < ExchangeLabel."Sales Price Incl. Vat" then
                SaleLinePOS.Validate("Unit Price", ExchangeLabel."Sales Price Incl. Vat")
              else
                SaleLinePOS.Validate("Amount Including VAT",ExchangeLabel."Sales Price Incl. Vat" * SaleLinePOS.Quantity);
              //+NPR5.49 [345209]
              SaleLinePOS.Modify;
              Validering := '';
              Found      := true;
            until ExchangeLabel.Next = 0;
          end;
        end;
    end;

    local procedure GetFieldNo(var RecRef: RecordRef;Name: Text[50]) FieldNo: Integer
    var
        "Field": Record "Field";
    begin
        Field.SetRange(TableNo,RecRef.Number);
        Field.SetRange(FieldName,Name);
        if Field.FindFirst then
          FieldNo := Field."No.";
        exit(FieldNo)
    end;

    procedure GetUnitPriceInclVat(RecRef: RecordRef) UnitPrice: Decimal
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalePOS: Record "Sale POS";
        SaleLinePOS: Record "Sale Line POS";
    begin
        //-NPR5.49 [345209]
        case RecRef.Number of
          DATABASE::"Sales Line" :
            begin
              RecRef.SetTable(SalesLine);
              UnitPrice := SalesLine."Unit Price";

              if SalesHeader.Get(SalesLine."Document Type",SalesLine."Document No.") and (not SalesHeader."Prices Including VAT") then
                UnitPrice *= (1 + (SalesLine."VAT %" / 100));
            end;
          DATABASE::"Sale Line POS" :
            begin
              RecRef.SetTable(SaleLinePOS);
              UnitPrice := SaleLinePOS."Unit Price";

              if SalePOS.Get(SaleLinePOS."Register No.",SaleLinePOS."Sales Ticket No.") and (not SalePOS."Price including VAT") then
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
          DATABASE::"Sales Line" :
            begin
              AssignIntegerFieldValue(DocumentType, RecRef, 'Document Type');
              AssignCodeFieldValue(DocumentNo,      RecRef, 'Document No.');
              AssignDecimalFieldValue(UnitPrice,    RecRef, 'Unit Price');
              AssignDecimalFieldValue(VATPct,       RecRef, 'VAT %');

              SalesHeader.Get(DocumentType,DocumentNo);
              if not SalesHeader."Prices Including VAT" then
                SalesPrice := UnitPrice * (1 + (VATPct / 100))
              else
                SalesPrice := UnitPrice;
            end;
          DATABASE::"Sale Line POS" :
            begin
              AssignDecimalFieldValue(UnitPrice,  RecRef, 'Amount Including VAT');
              AssignDecimalFieldValue(Quantity,   RecRef, 'Quantity');
              SalesPrice := UnitPrice / Quantity;
            end;
        end;
    end;

    procedure GetLabelGroupBatchNo(SaleLinePOS: Record "Sale Line POS") NextGroupNo: Integer
    var
        ExchangeLabel: Record "Exchange Label";
    begin
        ExchangeLabel.SetCurrentKey("Register No.","Sales Ticket No.","Batch No.");
        ExchangeLabel.SetRange("Register No.", SaleLinePOS."Register No.");
        ExchangeLabel.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        if ExchangeLabel.FindLast then
          exit(ExchangeLabel."Batch No." + 1)
        else
          exit(1);
    end;

    procedure IsItemLine(RecRef: RecordRef): Boolean
    var
        SaleLinePOS: Record "Sale Line POS";
        SalesLine: Record "Sales Line";
        Type: Integer;
    begin
        case RecRef.Number of
          DATABASE::"Sales Line" :
            begin
              AssignIntegerFieldValue(Type,  RecRef, 'Type');
              exit(Type = SalesLine.Type::Item)
            end;
          DATABASE::"Sale Line POS" :
            begin
              AssignIntegerFieldValue(Type,  RecRef, 'Type');
              exit(Type = SaleLinePOS.Type::Item)
            end;
        end;
    end;

    local procedure AssignOptionFieldValue(var OptionVal: Option "1","2","3","4","5","6","7","8","9";RecordRef: RecordRef;FieldName: Text[50])
    var
        FieldRef: FieldRef;
        FieldNo: Integer;
    begin
        FieldNo     := GetFieldNo(RecordRef,FieldName);
        FieldRef    := RecordRef.Field(FieldNo);
        OptionVal   := FieldRef.Value;
    end;

    local procedure AssignIntegerFieldValue(var IntegerVal: Integer;RecordRef: RecordRef;FieldName: Text[50])
    var
        FieldRef: FieldRef;
        FieldNo: Integer;
    begin
        FieldNo     := GetFieldNo(RecordRef,FieldName);
        FieldRef    := RecordRef.Field(FieldNo);
        IntegerVal  := FieldRef.Value;
    end;

    local procedure AssignCodeFieldValue(var CodeVal: Code[20];RecordRef: RecordRef;FieldName: Text[50])
    var
        FieldRef: FieldRef;
        FieldNo: Integer;
    begin
        FieldNo    := GetFieldNo(RecordRef,FieldName);
        FieldRef   := RecordRef.Field(FieldNo);
        CodeVal    := FieldRef.Value;
    end;

    local procedure AssignDecimalFieldValue(var DecimalVal: Decimal;RecordRef: RecordRef;FieldName: Text[50])
    var
        FieldRef: FieldRef;
        FieldNo: Integer;
    begin
        FieldNo    := GetFieldNo(RecordRef,FieldName);
        FieldRef   := RecordRef.Field(FieldNo);
        DecimalVal := FieldRef.Value;
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

    procedure ScanExchangeLabelRetailJnl(var RetailJnlLine: Record "Retail Journal Line";var Validering: Code[20]) Found: Boolean
    var
        ExchangeLabel: Record "Exchange Label";
        IComm: Record "I-Comm";
        Item: Record Item;
        RetailConfiguration: Record "Retail Setup";
        RetailJnlLine2: Record "Retail Journal Line";
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
            ExchangeLabel.SetCurrentKey("Register No.","Sales Ticket No.","Batch No.");
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

              Validate("Item No." , ExchangeLabel."Item No.");
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

