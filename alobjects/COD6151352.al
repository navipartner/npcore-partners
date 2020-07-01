codeunit 6151352 "CS Wrapper Functions"
{
    // NPR5.53/CLVA/20191029  CASE 374331 Object created - NP Capture Service


    trigger OnRun()
    begin
    end;

    var
        headerlabel: Label 'STOCK';
        footerlabel: Label 'DELIVERY';

    procedure GetItemPicture(Barcode: Code[20]) PictureBase64: Text
    var
        Item: Record Item;
        BarcodeLibrary: Codeunit "Barcode Library";
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        TempBlob: Codeunit "Temp Blob";
        MediaGuid: Guid;
        TenantMedia: Record "Tenant Media";
        ItemCrossReference: Record "Item Cross Reference";
        CSRfidTagModels: Record "CS Rfid Tag Models";
        CSRfidData: Record "CS Rfid Data";
        TagFamily: Code[10];
        TagModel: Code[10];
        TagId: Code[20];
        CSSetup: Record "CS Setup";
        BinaryReader: DotNet npNetBinaryReader;
        MemoryStream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
        InStr: InStream;
        MagentoPicture: Record "Magento Picture";
        MagentoPictureLink: Record "Magento Picture Link";
        TempMagentoPicture: Record "Magento Picture" temporary;
        Base64Convert: Codeunit "Base64 Convert";
    begin
        if (StrLen(Barcode) <= MaxStrLen(CSRfidData.Key)) and (StrLen(Barcode) > MaxStrLen(CSRfidTagModels.Family)) then begin

            TagFamily := CopyStr(Barcode, 1, 4);
            TagModel := CopyStr(Barcode, 5, 4);
            TagId := CopyStr(Barcode, 5);

            if CSRfidTagModels.Get(TagFamily, TagModel) then
                if (StrLen(TagId) <= MaxStrLen(ItemCrossReference."Cross-Reference No.")) then
                    Barcode := TagId;

        end;

        if not BarcodeLibrary.TranslateBarcodeToItemVariant(Barcode, ItemNo, VariantCode, ResolvingTable, true) then
            exit('');

        if not Item.Get(ItemNo) then
            exit('');

        if VariantCode <> '' then
            Item.SetFilter("Variant Filter", VariantCode);

        CSSetup.Get;
        case CSSetup."Media Library" of
            CSSetup."Media Library"::"Dynamics NAV":
                begin
                    if Item.Picture.Count >= 1 then begin
                        Clear(PictureBase64);
                        Clear(TempBlob);
                        MediaGuid := Item.Picture.Item(1);
                        TenantMedia.Get(MediaGuid);
                        TenantMedia.CalcFields(Content);
                        TempBlob.FromRecord(TenantMedia, TenantMedia.FieldNo(Content));

                        TempBlob.CreateInStream(InStr);
                        PictureBase64 := Base64Convert.ToBase64(Instr);
                    end;
                end;
            CSSetup."Media Library"::Magento:
                begin
                    MagentoPictureLink.SetRange("Item No.", Item."No.");
                    MagentoPictureLink.SetRange("Base Image", true);
                    if MagentoPictureLink.FindFirst then begin
                        if MagentoPicture.Get(MagentoPicture.Type::Item, MagentoPictureLink."Picture Name") then begin
                            TempMagentoPicture := MagentoPicture;
                            if TempMagentoPicture.DownloadPicture(TempMagentoPicture) then begin
                                TempMagentoPicture.Picture.CreateInStream(InStr);
                                MemoryStream := InStr;
                                BinaryReader := BinaryReader.BinaryReader(InStr);
                                PictureBase64 := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));
                                MemoryStream.Dispose;
                                Clear(MemoryStream);
                            end;
                        end;
                    end;
                end;
        end;


        exit(PictureBase64);
    end;

    procedure GetItemObject(Barcode: Code[20]): Text
    var
        Item: Record Item;
        Item2: Record Item;
        BarcodeLibrary: Codeunit "Barcode Library";
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        PurchaseLine: Record "Purchase Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        JObject: DotNet npNetJObject;
        JTokenWriter: DotNet npNetJTokenWriter;
        Result: Text;
        Var01: Text;
        Var02: Text;
        Var03: Text;
        Var04: Text;
        Var05: Text;
        Var06: Text;
        Var07: Text;
        Var08: Text;
        Var09: Text;
        Var10: Text;
        Var11: Text;
        TempBlob: Codeunit "Temp Blob";
        MediaGuid: Guid;
        TenantMedia: Record "Tenant Media";
        Base64Convert: Codeunit "Base64 Convert";
        InStr: InStream;
    begin
        if Barcode = '' then
            exit('');

        if not BarcodeLibrary.TranslateBarcodeToItemVariant(Barcode, ItemNo, VariantCode, ResolvingTable, true) then
            exit('');

        if not Item.Get(ItemNo) then
            exit('');

        Var01 := '-';
        Var02 := '-';
        Var03 := '0';
        Var04 := '-';
        Var05 := '-';
        Var06 := '-';
        Var07 := '-';
        Var08 := '0';
        Var09 := '0';
        Var10 := '0';
        Var11 := '';

        if VariantCode <> '' then
            Item.SetFilter("Variant Filter", VariantCode);
        Item.CalcFields(Inventory, "Qty. on Purch. Order");

        Var01 := Item."No.";
        Var02 := Item.Description;
        Var03 := Format(Item.Inventory);
        Var04 := Item."Base Unit of Measure";
        Var05 := VariantCode;

        if Item."Qty. on Purch. Order" > 0 then begin
            Clear(PurchaseLine);
            PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
            PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
            PurchaseLine.SetRange("No.", Item."No.");
            if VariantCode <> '' then
                PurchaseLine.SetRange("Variant Code", VariantCode);
            if PurchaseLine.FindLast then
                Var06 := Format(PurchaseLine."Expected Receipt Date");
        end;

        Clear(ItemLedgerEntry);
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
        ItemLedgerEntry.SetRange("Item No.", Item."No.");
        if VariantCode <> '' then
            ItemLedgerEntry.SetRange("Variant Code", VariantCode);
        if ItemLedgerEntry.FindLast then
            Var07 := Format(ItemLedgerEntry."Posting Date");

        Clear(Item2);
        Item2.Get(Item."No.");
        if VariantCode <> '' then
            Item2.SetFilter("Variant Filter", VariantCode);
        Item2.SetFilter("Date Filter", '%1..%2', 0D, Today);
        Item2.CalcFields("Sales (Qty.)");
        Var08 := Format(Item2."Sales (Qty.)");

        Clear(Item2);
        Item2.Get(Item."No.");
        if VariantCode <> '' then
            Item2.SetFilter("Variant Filter", VariantCode);
        Item2.SetRange("Date Filter", CalcDate('<-CY>', WorkDate), CalcDate('<CY>', WorkDate));
        Item2.CalcFields("Sales (Qty.)");
        Var09 := Format(Item2."Sales (Qty.)");

        Clear(Item2);
        Item2.Get(Item."No.");
        if VariantCode <> '' then
            Item2.SetFilter("Variant Filter", VariantCode);
        Item2.SetRange("Date Filter", CalcDate('<CY-2Y+1D>', WorkDate), CalcDate('<CY-1Y>', WorkDate));
        Item2.CalcFields("Sales (Qty.)");
        Var10 := Format(Item2."Sales (Qty.)");

        if Item.Picture.Count >= 1 then begin
            Clear(TempBlob);
            MediaGuid := Item.Picture.Item(1);
            TenantMedia.Get(MediaGuid);
            TenantMedia.CalcFields(Content);
            TempBlob.FromRecord(TenantMedia, TenantMedia.FieldNo(Content));

            TempBlob.CreateInStream(InStr);
            Var11 := Base64Convert.ToBase64(Instr);
        end;

        JTokenWriter := JTokenWriter.JTokenWriter;
        with JTokenWriter do begin
            WriteStartObject;

            WritePropertyName('item');
            WriteStartArray;

            WriteStartObject;
            WritePropertyName('1');
            WriteValue(Var01);
            WritePropertyName('2');
            WriteValue(Var02);

            WritePropertyName('headerlabel');
            WriteValue(headerlabel + ' : ' + Var03);
            WritePropertyName('3');
            //WriteValue(Var03);
            WriteValue('');
            WritePropertyName('linelabel1');
            //WriteValue(FORMAT(CALCDATE('<CY>', WORKDATE),0,'<Year4>-<Month,2>-<Day,2>'));
            WriteValue(Var01);
            WritePropertyName('8');
            WriteValue(Var08);
            WritePropertyName('linelabel2');
            //WriteValue(FORMAT(CALCDATE('<CY-1Y>', WORKDATE),0,'<Year4>-<Month,2>-<Day,2>'));
            WriteValue(CopyStr(Var02, 16, 8));
            WritePropertyName('9');
            WriteValue(Var09);
            WritePropertyName('linelabel3');
            //WriteValue(FORMAT(CALCDATE('<CY-2Y>', WORKDATE),0,'<Year4>-<Month,2>-<Day,2>'));
            WriteValue(Var04);
            WritePropertyName('10');
            WriteValue(Var10);
            WritePropertyName('footerlabel');
            WriteValue(footerlabel);
            WritePropertyName('6');
            WriteValue(Var06);

            WritePropertyName('4');
            WriteValue(Var04);
            WritePropertyName('5');
            WriteValue(Var05);
            WritePropertyName('7');
            WriteValue(Var07);
            WritePropertyName('11');
            WriteValue(Var11);

            WriteEndObject;

            WriteEndArray;

            WriteEndObject;
            JObject := Token;
            Result := JObject.ToString();

        end;

        exit(Result);
    end;
}

