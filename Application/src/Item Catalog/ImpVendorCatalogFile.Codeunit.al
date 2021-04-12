codeunit 6060061 "NPR Imp. Vendor Catalog File"
{
    trigger OnRun()
    var
        FileManagement: Codeunit "File Management";
        Filename: Text;
        VendorNo: Code[20];
    begin
        Filename := FileManagement.OpenFileDialog(CatalogFile, '', 'CSV files (*.csv)|*.csv|All files (*.*)|*.*');
        VendorNo := SelectVendor;
        ReadFile(VendorNo, Filename, true, true);
    end;

    var
        CatalogFile: Label 'Catalog File';
        TooManyFields: Label 'Cannot import the file. There are more than %1 fields on a row.';
        FieldMissing: Label 'Field in Column %1 is missing in Row %2.';
        RowNo: Integer;
        ReadingRow: Label 'Reading Row #1######';
        FileDoesNotExist: Label 'File could not be found on the server: %1';

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

    procedure ReadFile(VendorNo: Code[20]; Filename: Text; IsOnClient: Boolean; SkipUnmappedVendors: Boolean)
    var
        EOF: Boolean;
        FileToImport: File;
        FileManagement: Codeunit "File Management";
        ServerFileName: Text;
        FieldArray: array[200] of Text;
        DiaWindow: Dialog;
    begin
        if IsOnClient then
            ServerFileName := FileManagement.UploadFileSilent(Filename)
        else
            ServerFileName := Filename;
        FileToImport.TextMode(false);
        if not Exists(ServerFileName) then
            Error(FileDoesNotExist, ServerFileName);
        FileToImport.Open(ServerFileName);

        EOF := false;
        RowNo := 0;
        if GuiAllowed then
            DiaWindow.Open(ReadingRow);
        repeat
            RowNo := RowNo + 1;
            EOF := ReadLine(FileToImport, FieldArray);  // Read into array
            if GuiAllowed then
                if (RowNo mod 100) = 0 then
                    DiaWindow.Update(1, RowNo);
            if not EOF then
                ProcessLine(VendorNo, FieldArray, SkipUnmappedVendors);
        until (EOF = true);
        FileToImport.Close();
        if GuiAllowed then
            DiaWindow.Close();
        if not IsOnClient then
            FileManagement.DeleteServerFile(ServerFileName);
    end;

    local procedure ReadLine(var FileToImport: File; var FieldArray: array[200] of Text): Boolean
    var
        FieldNo: Integer;
        CharsRead: Integer;
        FieldSep: Char;
        LF: Char;
        CR: Char;
        Character: Char;
        StringConversionMgt: Codeunit StringConversionManagement;
    begin
        FieldNo := 1;
        Clear(FieldArray);  // Delete Array

        FieldSep := ';';
        LF := 10;
        CR := 13;

        repeat
            CharsRead := FileToImport.Read(Character);  // Read 1 char
            if CharsRead = 0 then
                exit(true);  // EOF reached
            if Character = FieldSep then begin
                FieldNo := FieldNo + 1;  // Next field
                if FieldNo > ArrayLen(FieldArray) then
                    Error(StrSubstNo(TooManyFields, ArrayLen(FieldArray)));
            end else begin
                if not (Character in [CR, LF]) then
                    FieldArray[FieldNo] := FieldArray[FieldNo] + StringConversionMgt.WindowsToAscii(Format(Character));
            end;
        until Character = LF;  // End of rec
        exit(false);
    end;

    local procedure ProcessLine(VendorNo: Code[20]; var FieldArray: array[200] of Text; SkipUnmappedVendors: Boolean)
    var
        Item: Record Item;
        NonstockItem: Record "Nonstock Item";
    begin
        CheckMandatoryFields(FieldArray);
        if VendorNo = '' then
            VendorNo := FindVendor(FieldArray, SkipUnmappedVendors);
        if VendorNo = '' then
            exit;
        if IdentifyItem(VendorNo, FieldArray, Item) then begin
            //Item Exists
            UpdateItem(FieldArray, Item);
        end else begin
            //Item Does not exist
            if IdentifyNonStockItem(VendorNo, FieldArray, NonstockItem) then begin
                if NonstockItem."Item No." <> '' then
                    if Item.Get(NonstockItem."Item No.") then
                        UpdateItem(FieldArray, Item);
            end else begin
                CreateNonStockItem(VendorNo, FieldArray, NonstockItem);
            end;
        end;
    end;

    local procedure CreateNonStockItem(VendorNo: Code[20]; var FieldArray: array[200] of Text; var NonstockItem: Record "Nonstock Item")
    var
        Manufacturer: Record Manufacturer;
        UnitofMeasure: Record "Unit of Measure";
        ItemCategory: Record "Item Category";
        NonstockItemMaterial: Record "NPR Nonstock Item Material";
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateLine: Record "Config. Template Line";
        TempDec: Decimal;
        NPRAttribute: Record "NPR Attribute";
        CatalogNonstockManagement: Codeunit "NPR Catalog Nonstock Mgt.";
    begin
        NonstockItem.Init();
        NonstockItem."Entry No." := '';
        NonstockItem.Validate("Vendor No.", VendorNo);
        //-NPR5.42
        /*
        IF NOT ItemCategory.GET(FieldArray[40]) THEN BEGIN
          ItemCategory.Init();
          ItemCategory.Code := FieldArray[40];
          ItemCategory.Insert();
        END;
        VALIDATE("Item Template Code",FieldArray[40]); //NAV2018
        IF NOT Manufacturer.GET(FieldArray[5]) THEN BEGIN
          Manufacturer.Init();
          Manufacturer.Code := FieldArray[5];
          Manufacturer.Insert();
        END;
        VALIDATE("Manufacturer Code",Manufacturer.Code);
        Description := COPYSTR(FieldArray[12],1,MAXSTRLEN(Description));
        IF NOT UnitofMeasure.GET(FieldArray[13]) THEN BEGIN
          UnitofMeasure.Init();
          UnitofMeasure.VALIDATE(Code,FieldArray[13]);
          UnitofMeasure.INSERT(TRUE);
        END;
        VALIDATE("Unit of Measure",UnitofMeasure.Code);
        VALIDATE("Vendor Item No.",FieldArray[6]);
        IF EVALUATE(TempDec,FieldArray[22]) THEN
          VALIDATE("Published Cost",TempDec);
        IF EVALUATE(TempDec,FieldArray[21]) THEN
          VALIDATE("Net Weight",TempDec);
        VALIDATE("Bar Code",FieldArray[7]);
        */
        if not ItemCategory.Get(FieldArray[38]) then begin
            ItemCategory.Init();
            ItemCategory.Code := FieldArray[38];
            ItemCategory.Insert();
        end;

        //-NPR5.48
        if not ConfigTemplateHeader.Get(FieldArray[38]) then begin
            ConfigTemplateHeader.Init();
            ConfigTemplateHeader.Code := FieldArray[38];
            ConfigTemplateHeader.Description := 'Created from Nordic Item Database';
            ConfigTemplateHeader."Table ID" := 27;
            ConfigTemplateHeader.Enabled := true;
            ConfigTemplateHeader.Insert();
        end;

        ConfigTemplateLine.SetRange("Data Template Code", FieldArray[38]);
        ConfigTemplateLine.SetRange(Type, ConfigTemplateLine.Type::Field);
        ConfigTemplateLine.SetRange("Field ID", 5702);
        ConfigTemplateLine.SetRange("Table ID", 27);
        ConfigTemplateLine.SetRange("Default Value", FieldArray[38]);
        if not ConfigTemplateLine.FindFirst() then begin
            ConfigTemplateLine.Init();
            ConfigTemplateLine.Validate("Data Template Code", FieldArray[38]);
            ConfigTemplateLine."Line No." := GetNextConfigTemplateLineNo(FieldArray[38]);
            ConfigTemplateLine.Validate("Table ID", 27);
            ConfigTemplateLine.Validate("Field ID", 5702);
            ConfigTemplateLine.Mandatory := true;
            ConfigTemplateLine."Language ID" := 1033;
            ConfigTemplateLine."Default Value" := FieldArray[38];
            ConfigTemplateLine.Insert();
        end;
        //VALIDATE("Item Category Code",FieldArray[38]);
        NonstockItem.Validate("Item Template Code", FieldArray[38]);
        //+NPR5.48

        if not Manufacturer.Get(FieldArray[3]) then begin
            Manufacturer.Init();
            Manufacturer.Code := FieldArray[3];
            Manufacturer.Insert();
        end;
        NonstockItem.Validate("Manufacturer Code", Manufacturer.Code);
        NonstockItem.Description := CopyStr(FieldArray[10], 1, MaxStrLen(NonstockItem.Description));
        if not UnitofMeasure.Get(FieldArray[11]) then begin
            UnitofMeasure.Init();
            UnitofMeasure.Validate(Code, FieldArray[11]);
            UnitofMeasure.Insert(true);
        end;
        NonstockItem.Validate("Unit of Measure", UnitofMeasure.Code);
        NonstockItem.Validate("Vendor Item No.", FieldArray[4]);
        if Evaluate(TempDec, FieldArray[20]) then
            //-NPR5.45
            //VALIDATE("Published Cost",TempDec);
            if TempDec <> 0 then
                NonstockItem.Validate("Published Cost", TempDec / 10);
        //+NPR5.45
        if Evaluate(TempDec, FieldArray[18]) then
            NonstockItem.Validate("Net Weight", TempDec);
        NonstockItem.Validate("Bar Code", FieldArray[5]);
        if Evaluate(TempDec, FieldArray[25]) then
            //-NPR5.45
            //VALIDATE("Unit Price", TempDec);
            if TempDec <> 0 then
                NonstockItem.Validate("Unit Price", TempDec / 10);
        //+NPR5.45

        //+NPR5.42
        NonstockItem.Insert(true);
        NPRAttribute.Reset();
        NPRAttribute.SetFilter("Import File Column No.", '>0');
        if NPRAttribute.FindSet() then
            repeat
                CatalogNonstockManagement.UpdateItemAttribute(1, NonstockItem."Entry No.", NPRAttribute.Code, FieldArray[NPRAttribute."Import File Column No."]);
            until NPRAttribute.Next() = 0;
        //-NPR5.45
        NonstockItemMaterial."Nonstock Item Entry No." := NonstockItem."Entry No.";
        NonstockItemMaterial."Item Material" := FieldArray[44];
        //-NPR5.45
        NonstockItemMaterial."Item Material Density" := FieldArray[45];
        //+NPR5.45
        NonstockItemMaterial.Insert();
        //+NPR5.45

    end;

    local procedure UpdateItem(var FieldArray: array[200] of Text; var Item: Record Item)
    var
        NPRAttribute: Record "NPR Attribute";
        CatalogNonstockManagement: Codeunit "NPR Catalog Nonstock Mgt.";
    begin
        NPRAttribute.Reset();
        NPRAttribute.SetFilter("Import File Column No.", '>0');
        if NPRAttribute.FindSet() then
            repeat
                CatalogNonstockManagement.UpdateItemAttribute(0, Item."No.", NPRAttribute.Code, FieldArray[NPRAttribute."Import File Column No."]);
            until NPRAttribute.Next() = 0;

        Item.Modify();
    end;

    local procedure IdentifyItem(VendorNo: Code[20]; var FieldArray: array[200] of Text; var Item: Record Item): Boolean
    var
        ItemReference: Record "Item Reference";
    begin
        if VendorNo <> '' then
            Item.SetRange("Vendor No.", VendorNo);
        Item.SetFilter("Vendor Item No.", '=%1', FieldArray[4]);
        if Item.FindFirst() then
            exit(true);
        ItemReference.Reset();
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
        ItemReference.SetRange("Reference No.", FieldArray[5]);
        if ItemReference.FindFirst() then begin
            Item.Get(ItemReference."Item No.");
            exit(true);
        end;
        exit(false);
    end;

    local procedure FindVendor(var FieldArray: array[200] of Text; SkipUnmappedVendors: Boolean): Code[20]
    var
        CatalogSupplier: Record "NPR Catalog Supplier";
    begin
        if SkipUnmappedVendors then begin
            if not CatalogSupplier.Get(UpperCase(FieldArray[3])) then
                exit('');
        end else
            CatalogSupplier.Get(UpperCase(FieldArray[3]));
        exit(CatalogSupplier."Vendor No.");
    end;

    local procedure IdentifyNonStockItem(VendorNo: Code[20]; var FieldArray: array[200] of Text; var NonstockItem: Record "Nonstock Item"): Boolean
    begin
        if VendorNo <> '' then
            NonstockItem.SetRange("Vendor No.", VendorNo);
        NonstockItem.SetFilter("Vendor Item No.", '=%1', FieldArray[4]);
        if NonstockItem.FindFirst() then
            exit(true);
    end;

    local procedure CheckMandatoryFields(FieldArray: array[200] of Text)
    begin
        CheckMandatoryField(FieldArray, 5);
        CheckMandatoryField(FieldArray, 3);
        CheckMandatoryField(FieldArray, 4);
    end;

    local procedure CheckMandatoryField(FieldArray: array[200] of Text; FieldNumber: Integer)
    begin
        if FieldArray[FieldNumber] = '' then
            Error(FieldMissing, FieldNumber, RowNo);
    end;

    local procedure GetNextConfigTemplateLineNo(TemplateCode: Code[10]): Integer
    var
        ConfigTemplateLine: Record "Config. Template Line";
    begin
        //-NPR5.48
        ConfigTemplateLine.SetRange("Data Template Code", TemplateCode);
        if ConfigTemplateLine.FindLast() then
            exit(ConfigTemplateLine."Line No." + 1000)
        else
            exit(1000);
        //+NPR5.48
    end;
}

