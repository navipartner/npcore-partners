codeunit 6060061 "NPR Imp. Vendor Catalog File"
{
    trigger OnRun()
    var
        FileManagement: Codeunit "File Management";
        TempBLOB: Codeunit "Temp Blob";
        Filename: Text;
        VendorNo: Code[20];
    begin
        Filename := FileManagement.BLOBImportWithFilter(TempBLOB, CatalogFile, '', 'CSV files (*.csv)|*.csv|All files (*.*)|*.*', 'csv');

        VendorNo := SelectVendor();
        ReadFile(VendorNo, TempBLOB, true, true);
    end;

    var
        CatalogFile: Label 'Catalog File';
        FieldMissing: Label 'Field in Column %1 is missing in Row %2.', Comment = '%1=CSVBuffer."Field No.";%2=CSVBuffer."Line No."';
        RowNo: Integer;
        ReadingRow: Label 'Reading Row #1######';
        FileDoesNotExistErr: Label 'File could not be found';

    local procedure SelectVendor(): Code[20]
    var
        VendorList: Page "Vendor List";
        Vendor: Record Vendor;
    begin
        Clear(Vendor);
        VendorList.LookupMode := true;
        if VendorList.RunModal() = ACTION::LookupOK then
            VendorList.GetRecord(Vendor);
        exit(Vendor."No.");
    end;

    procedure ReadFile(VendorNo: Code[20]; var TempBlob: Codeunit "Temp Blob"; IsOnClient: Boolean; SkipUnmappedVendors: Boolean)
    var
        TempCSVBuffer: Record "CSV Buffer" temporary;
        InStr: InStream;
        DiaWindow: Dialog;
        FieldSep: Char;
    begin
        FieldSep := ';';
        TempBlob.CreateInStream(InStr);
        TempCSVBuffer.LoadDataFromStream(InStr, FieldSep);
        if TempCSVBuffer.IsEmpty() then
            Error(FileDoesNotExistErr);

        if GuiAllowed then
            DiaWindow.Open(ReadingRow);
        TempCSVBuffer.Findset();
        repeat
            RowNo := RowNo + 1;
            TempCSVBuffer.SetRange("Line No.", RowNo);

            ProcessLine(VendorNo, TempCSVBuffer, SkipUnmappedVendors);

            if TempCSVBuffer.FindLast() then;
            TempCSVBuffer.SetRange("Line No.");

        until TempCSVBuffer.Next() = 0;
        if GuiAllowed then
            DiaWindow.Close();

    end;

    local procedure ProcessLine(VendorNo: Code[20]; var CSVBuffer: Record "CSV Buffer"; SkipUnmappedVendors: Boolean)
    var
        Item: Record Item;
        NonstockItem: Record "Nonstock Item";
    begin
        CheckMandatoryFields(CSVBuffer);
        if VendorNo = '' then
            VendorNo := FindVendor(CSVBuffer, SkipUnmappedVendors);
        if VendorNo = '' then
            exit;
        if IdentifyItem(VendorNo, CSVBuffer, Item) then begin
            //Item Exists
            UpdateItem(CSVBuffer, Item);
        end else begin
            //Item Does not exist
            if IdentifyNonStockItem(VendorNo, CSVBuffer, NonstockItem) then begin
                if NonstockItem."Item No." <> '' then
                    if Item.Get(NonstockItem."Item No.") then
                        UpdateItem(CSVBuffer, Item);
            end else begin
                CreateNonStockItem(VendorNo, CSVBuffer, NonstockItem);
            end;
        end;
    end;

    local procedure CreateNonStockItem(VendorNo: Code[20]; var CSVBuffer2: Record "CSV Buffer"; var NonstockItem: Record "Nonstock Item")
    var
        Manufacturer: Record Manufacturer;
        UnitofMeasure: Record "Unit of Measure";
        ItemCategory: Record "Item Category";
        NonstockItemMaterial: Record "NPR Nonstock Item Material";
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateLine: Record "Config. Template Line";
        TempCSVBuffer: Record "CSV Buffer" temporary;
        TempDec: Decimal;
        NPRAttribute: Record "NPR Attribute";
        CatalogNonstockManagement: Codeunit "NPR Catalog Nonstock Mgt.";
    begin
        TempCSVBuffer.Copy(CSVBuffer2, true);

        NonstockItem.Init();
        NonstockItem."Entry No." := '';
        NonstockItem.Validate("Vendor No.", VendorNo);

        ItemCategory.Code := TempCSVBuffer.GetValue(TempCSVBuffer."Line No.", 38);
        if not ItemCategory.Find() then begin
            ItemCategory.Init();
            ItemCategory.Insert();
        end;

        ConfigTemplateHeader.Code := ItemCategory.Code;
        if not ConfigTemplateHeader.Find() then begin
            ConfigTemplateHeader.Init();
            ConfigTemplateHeader.Description := 'Created from Nordic Item Database';
            ConfigTemplateHeader."Table ID" := 27;
            ConfigTemplateHeader.Enabled := true;
            ConfigTemplateHeader.Insert();
        end;

        ConfigTemplateLine.SetRange("Data Template Code", ItemCategory.Code);
        ConfigTemplateLine.SetRange(Type, ConfigTemplateLine.Type::Field);
        ConfigTemplateLine.SetRange("Field ID", 5702);
        ConfigTemplateLine.SetRange("Table ID", 27);
        ConfigTemplateLine.SetRange("Default Value", ItemCategory.Code);
        if not ConfigTemplateLine.FindFirst() then begin
            ConfigTemplateLine.Init();
            ConfigTemplateLine.Validate("Data Template Code", ItemCategory.Code);
            ConfigTemplateLine."Line No." := GetNextConfigTemplateLineNo(ItemCategory.Code);
            ConfigTemplateLine.Validate("Table ID", 27);
            ConfigTemplateLine.Validate("Field ID", 5702);
            ConfigTemplateLine.Mandatory := true;
            ConfigTemplateLine."Language ID" := 1033;
            ConfigTemplateLine."Default Value" := ItemCategory.Code;
            ConfigTemplateLine.Insert();
        end;
#if BC17
        NonstockItem.Validate("Item Template Code", ItemCategory.Code);
#else
        NonstockItem.Validate("Item Templ. Code", ItemCategory.Code);
#endif
        Manufacturer.Code := TempCSVBuffer.GetValue(TempCSVBuffer."Line No.", 3);
        if not Manufacturer.Find() then begin
            Manufacturer.Init();
            Manufacturer.Insert();
        end;

        NonstockItem.Validate("Manufacturer Code", Manufacturer.Code);
        NonstockItem.Description := CopyStr(TempCSVBuffer.GetValue(TempCSVBuffer."Line No.", 10), 1, MaxStrLen(NonstockItem.Description));

        UnitofMeasure.Code := TempCSVBuffer.GetValue(TempCSVBuffer."Line No.", 11);
        if not UnitofMeasure.Find() then begin
            UnitofMeasure.Init();
            UnitofMeasure.Validate(Code);
            UnitofMeasure.Insert(true);
        end;

        NonstockItem.Validate("Unit of Measure", UnitofMeasure.Code);
        NonstockItem.Validate("Vendor Item No.", TempCSVBuffer.GetValue(TempCSVBuffer."Line No.", 4));
        if Evaluate(TempDec, TempCSVBuffer.GetValue(TempCSVBuffer."Line No.", 20)) then
            if TempDec <> 0 then
                NonstockItem.Validate("Published Cost", TempDec / 10);
        if Evaluate(TempDec, TempCSVBuffer.GetValue(TempCSVBuffer."Line No.", 18)) then
            NonstockItem.Validate("Net Weight", TempDec);
        NonstockItem.Validate("Bar Code", TempCSVBuffer.GetValue(TempCSVBuffer."Line No.", 5));
        if Evaluate(TempDec, TempCSVBuffer.GetValue(TempCSVBuffer."Line No.", 25)) then
            if TempDec <> 0 then
                NonstockItem.Validate("Unit Price", TempDec / 10);

        NonstockItem.Insert(true);
        NPRAttribute.Reset();
        NPRAttribute.SetFilter("Import File Column No.", '>0');
        if NPRAttribute.FindSet() then
            repeat
                CatalogNonstockManagement.UpdateItemAttribute(1, NonstockItem."Entry No.", NPRAttribute.Code, TempCSVBuffer.GetValue(TempCSVBuffer."Line No.", NPRAttribute."Import File Column No."));
            until NPRAttribute.Next() = 0;
        NonstockItemMaterial."Nonstock Item Entry No." := NonstockItem."Entry No.";
        NonstockItemMaterial."Item Material" := TempCSVBuffer.GetValue(TempCSVBuffer."Line No.", 44);
        NonstockItemMaterial."Item Material Density" := TempCSVBuffer.GetValue(TempCSVBuffer."Line No.", 45);
        NonstockItemMaterial.Insert();
    end;

    local procedure UpdateItem(var CSVBuffer2: Record "CSV Buffer"; var Item: Record Item)
    var
        NPRAttribute: Record "NPR Attribute";
        TempCSVBuffer: Record "CSV Buffer" temporary;
        CatalogNonstockManagement: Codeunit "NPR Catalog Nonstock Mgt.";
    begin
        TempCSVBuffer.Copy(CSVBuffer2, true);

        NPRAttribute.Reset();
        NPRAttribute.SetFilter("Import File Column No.", '>0');
        if NPRAttribute.FindSet() then
            repeat
                CatalogNonstockManagement.UpdateItemAttribute(0, Item."No.", NPRAttribute.Code, TempCSVBuffer.GetValue(TempCSVBuffer."Line No.", NPRAttribute."Import File Column No."));
            until NPRAttribute.Next() = 0;

        Item.Modify();
    end;

    local procedure IdentifyItem(VendorNo: Code[20]; var CSVBuffer2: Record "CSV Buffer"; var Item: Record Item): Boolean
    var
        ItemReference: Record "Item Reference";
        TempCSVBuffer: Record "CSV Buffer" temporary;
    begin
        TempCSVBuffer.Copy(CSVBuffer2, true);

        if VendorNo <> '' then
            Item.SetRange("Vendor No.", VendorNo);
        Item.SetFilter("Vendor Item No.", '=%1', TempCSVBuffer.GetValue(TempCSVBuffer."Line No.", 4));
        if Item.FindFirst() then
            exit(true);
        ItemReference.Reset();
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
        ItemReference.SetRange("Reference No.", TempCSVBuffer.GetValue(TempCSVBuffer."Line No.", 5));
        if ItemReference.FindFirst() then begin
            Item.Get(ItemReference."Item No.");
            exit(true);
        end;
        exit(false);
    end;

    local procedure FindVendor(var CSVBuffer2: Record "CSV Buffer"; SkipUnmappedVendors: Boolean): Code[20]
    var
        CatalogSupplier: Record "NPR Catalog Supplier";
        TempCSVBuffer: Record "CSV Buffer" temporary;
    begin
        TempCSVBuffer.COpy(CSVBuffer2, true);

        if SkipUnmappedVendors then begin
            if not CatalogSupplier.Get(UpperCase(TempCSVBuffer.GetValue(TempCSVBuffer."Line No.", 3))) then
                exit('');
        end else
            CatalogSupplier.Get(UpperCase(TempCSVBuffer.GetValue(TempCSVBuffer."Line No.", 3)));
        exit(CatalogSupplier."Vendor No.");
    end;

    local procedure IdentifyNonStockItem(VendorNo: Code[20]; var CSVBuffer2: Record "CSV Buffer"; var NonstockItem: Record "Nonstock Item"): Boolean
    var
        TempCSVBuffer: Record "CSV Buffer" temporary;
    begin
        TempCSVBuffer.Copy(CSVBuffer2, true);

        if VendorNo <> '' then
            NonstockItem.SetRange("Vendor No.", VendorNo);
        NonstockItem.SetFilter("Vendor Item No.", '=%1', TempCSVBuffer.GetValue(TempCSVBuffer."Line No.", 4));
        if NonstockItem.FindFirst() then
            exit(true);
    end;

    local procedure CheckMandatoryFields(var CSVBuffer: Record "CSV Buffer")
    begin
        CheckMandatoryField(CSVBuffer, 5);
        CheckMandatoryField(CSVBuffer, 3);
        CheckMandatoryField(CSVBuffer, 4);
    end;

    local procedure CheckMandatoryField(var CSVBuffer2: Record "CSV Buffer"; FieldNumber: Integer)
    var
        TempCSVBuffer: Record "CSV Buffer" temporary;
    begin
        TempCSVBuffer.Copy(CSVBuffer2, true);

        if TempCSVBuffer.GetValue(TempCSVBuffer."Line No.", FieldNumber) = '' then
            Error(FieldMissing, FieldNumber, RowNo);
    end;

    local procedure GetNextConfigTemplateLineNo(TemplateCode: Code[10]): Integer
    var
        ConfigTemplateLine: Record "Config. Template Line";
    begin
        ConfigTemplateLine.SetRange("Data Template Code", TemplateCode);
        if ConfigTemplateLine.FindLast() then
            exit(ConfigTemplateLine."Line No." + 1000)
        else
            exit(1000);
    end;
}

