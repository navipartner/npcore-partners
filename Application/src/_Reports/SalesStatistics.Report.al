report 6060065 "NPR Sales Statistics"
{
    Caption = 'Sales Statistic';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    dataset
    {
        dataitem("Catalog Supplier"; "NPR Catalog Supplier")
        {
            DataItemTableView = WHERE("Send Sales Statistics" = CONST(true));

            trigger OnAfterGetRecord()
            var
                Item: Record Item;
                AuditRoll: Record "NPR Audit Roll";
                FieldArray: array[200] of Text[200];
            begin
                Item.SetCurrentKey("Vendor No.");
                Item.SetRange("Vendor No.", "Catalog Supplier"."Vendor No.");
                if Item.FindSet() then
                    repeat
                        AuditRoll.SetCurrentKey("Register No.", "Sales Ticket No.", "Sale Date", "Sale Type", Type, "No.");
                        AuditRoll.SetRange("Sale Date", StartDate, EndDate);
                        AuditRoll.SetRange(Type, AuditRoll.Type::Item);
                        AuditRoll.SetRange("No.", Item."No.");
                        if AuditRoll.FindSet() then
                            repeat
                                if AuditRoll.Quantity <> 0 then begin
                                    Clear(FieldArray);
                                    FillArray(FieldArray, AuditRoll, "Catalog Supplier");
                                    OutputText += WriteLine(FieldArray) + LF;
                                end;
                            until AuditRoll.Next() = 0;
                    until Item.Next() = 0;
            end;

            trigger OnPreDataItem()
            begin
                FieldSep := ';';
                LF[1] := 10;
            end;
        }
    }

    var
        Character: Char;
        FieldSep: Char;
        EndDate: Date;
        StartDate: Date;
        AttributeSetID: Integer;
        Host: Text;
        LF: Text;
        OutputText: Text;
        PassWord: Text;
        RemoteDir: Text;
        UserName: Text;

    local procedure FillArray(var FieldArray: array[200] of Text; AuditRoll: Record "NPR Audit Roll"; CatalogSupplier: Record "NPR Catalog Supplier")
    var
        Day: Text[2];
        Month: Text[2];
        TransactionCode: Text[2];
        Year: Text[4];
    begin
        if AuditRoll.Quantity > 0 then
            TransactionCode := '14'
        else
            TransactionCode := '15';

        Day := Format(Date2DMY(AuditRoll."Sale Date", 1));
        if StrLen(Day) < 2 then
            Day := '0' + Day;
        Month := Format(Date2DMY(AuditRoll."Sale Date", 2));
        if StrLen(Month) < 2 then
            Month := '0' + Month;
        Year := Format(Date2DMY(AuditRoll."Sale Date", 3));

        FieldArray[1] := TransactionCode;
        FieldArray[2] := CatalogSupplier."Trade Number";
        FieldArray[3] := AuditRoll."Sales Ticket No.";
        FieldArray[4] := Format(AuditRoll."Line No.");
        FieldArray[5] := CatalogSupplier.Code;
        FieldArray[6] := GetBarcode(AuditRoll."No.", AuditRoll."Variant Code");
        FieldArray[7] := ConvertStr(Format(AuditRoll."Unit Price", 0, 1), ',', '.');
        FieldArray[8] := Day + Month + Year;
        FieldArray[9] := Format(Abs(AuditRoll.Quantity));
        FieldArray[10] := '';
    end;

    local procedure WriteLine(var FieldArray: array[200] of Text) LineText: Text[1024]
    var
        FieldNumber: Integer;
    begin
        LineText := '';
        FieldNumber := 0;
        repeat
            FieldNumber := FieldNumber + 1;
            LineText := LineText + FieldArray[FieldNumber];
            LineText := LineText + Format(FieldSep);
        until FieldNumber > 9;
    end;

    local procedure GetBarcode(ItemNo: Code[20]; VariantCode: Code[10]): Text
    var
        AlternativeNo: Record "NPR Alternative No.";
        ItemReference: Record "Item Reference";
        NonstockItem: Record "Nonstock Item";
        EANPrefixByCountry: Record "NPR EAN Prefix per Country";
        Vendor: Record Vendor;
    begin
        with AlternativeNo do begin
            SetRange(Type, Type::Item);
            SetRange(Code, ItemNo);
            SetRange("Variant Code", VariantCode);
            SetRange("Blocked Reason Code", '');
            if FindFirst then
                if StrLen(AlternativeNo."Alt. No.") = 13 then
                    exit("Alt. No.");
        end;

        ItemReference.SetRange("Item No.", ItemNo);
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
        ItemReference.SetRange("Variant Code", VariantCode);
        ItemReference.SetRange("Discontinue Bar Code", false);
        case true of
            (ItemReference.Count() = 1):
                begin
                    ItemReference.FindFirst();
                    exit(ItemReference."Reference No.");
                end;
            (ItemReference.Count() > 1):
                begin
                    ItemReference.FindSet();
                    repeat
                        NonstockItem.SetRange("Bar Code", ItemReference."Reference No.");
                        if not NonstockItem.IsEmpty then
                            exit(ItemReference."Reference No.");
                    until ItemReference.Next = 0;
                    if Vendor.Get("Catalog Supplier"."Vendor No.") and (Vendor."Country/Region Code" <> '') then begin
                        EANPrefixByCountry.SetRange("Country Code", Vendor."Country/Region Code");
                        if EANPrefixByCountry.FindSet then
                            repeat
                                ItemReference.SetFilter("Reference No.", StrSubstNo('%1*', EANPrefixByCountry.Prefix));
                                if ItemReference.FindFirst then
                                    exit(ItemReference."Reference No.");
                            until EANPrefixByCountry.Next = 0;
                        ItemReference.SetRange("Reference No.");
                    end;
                    //if not in country prefix setup, fallback to original solution
                    ItemReference.FindFirst;
                    exit(ItemReference."Reference No.");
                end;
        end;

        exit('');

    end;

    procedure SetParameter(InStartDate: Date; InEndDate: Date; InHost: Text; InUserName: Text; InPassWord: Text; InRemoteDir: Text)
    begin
        StartDate := InStartDate;
        EndDate := InEndDate;
        Host := InHost;
        UserName := InUserName;
        PassWord := InPassWord;
        RemoteDir := InRemoteDir;
    end;
}

