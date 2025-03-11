#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248290 "NPR API Inventory" implements "NPR API Request Handler"
{
    Access = Internal;

    procedure Handle(var Request: Codeunit "NPR API Request"): Codeunit "NPR API Response"
    begin
        case true of
            Request.Match('GET', '/inventory/item/:id'):
                exit(GetItem(Request));
            Request.Match('GET', '/inventory/item'):
                exit(GetItem(Request));
            Request.Match('GET', '/inventory/itemledgerentry'):
                exit(GetItemLedgerEntry(Request));
            Request.Match('GET', '/inventory/itemvariant'):
                exit(GetItemVariant(Request));
            Request.Match('GET', '/inventory/itemcategory'):
                exit(GetItemCategory(Request));
            Request.Match('GET', '/inventory/barcode'):
                exit(GetBarcode(Request));
            Request.Match('GET', '/inventory/itemtranslation'):
                exit(GetTranslation(Request));
        end;
    end;

    procedure GetItem(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Item: Record Item;
        Fields: Dictionary of [Integer, Text];
        Id: Text;
    begin
        if Request.QueryParams().ContainsKey('itemCode') then begin
            Item.SetFilter("No.", '=%1', Request.QueryParams().Get('itemCode'));
        end;

        Fields.Add(Item.FieldNo("No."), 'code');
        Fields.Add(Item.FieldNo(Description), 'description');
        Fields.Add(Item.FieldNo("Description 2"), 'description2');
        Fields.Add(Item.FieldNo("Base Unit of Measure"), 'baseUnitOfMeasure');
        Fields.Add(Item.FieldNo("Item Disc. Group"), 'itemDiscGroup');
        Fields.Add(Item.FieldNo("Item Category Code"), 'itemCategoryCode');
        Fields.Add(Item.FieldNo("VAT Prod. Posting Group"), 'vatProdPostingGroup');

        if Request.Paths().Count > 2 then begin
            Id := Request.Paths().Get(3);

            //only read flowfields when grabbing a single record
            Fields.Add(Item.FieldNo(Inventory), 'inventory');
            Fields.Add(Item.FieldNo("NPR Has Variants"), 'hasVariants');
            exit(Response.RespondOK(Request.GetData(Item, Fields, Id)));
        end else begin
            exit(Response.RespondOK(Request.GetData(Item, Fields)));
        end;
    end;

    procedure GetItemLedgerEntry(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        Fields: Dictionary of [Integer, Text];
    begin
        if Request.QueryParams().ContainsKey('itemCode') then begin
            ItemledgerEntry.SetFilter("Item No.", '=%1', Request.QueryParams().Get('itemCode'));
        end;
        if Request.QueryParams().ContainsKey('documentNo') then begin
            ItemledgerEntry.SetFilter("Document No.", '=%1', Request.QueryParams().Get('documentNo'));
        end;

        Fields.Add(ItemLedgerEntry.FieldNo("Entry No."), 'entryNo');
        Fields.Add(ItemLedgerEntry.FieldNo("Item No."), 'itemCode');
        Fields.Add(ItemLedgerEntry.FieldNo("Posting Date"), 'postingDate');
        Fields.Add(ItemLedgerEntry.FieldNo("Entry Type"), 'entryType');
        Fields.Add(ItemLedgerEntry.FieldNo("Source No."), 'sourceNo');
        Fields.Add(ItemLedgerEntry.FieldNo("Document No."), 'documentNo');
        Fields.Add(ItemLedgerEntry.FieldNo("Global Dimension 1 Code"), 'globalDimension1Code');
        Fields.Add(ItemLedgerEntry.FieldNo("Global Dimension 2 Code"), 'globalDimension2Code');
        Fields.Add(ItemLedgerEntry.FieldNo("Location Code"), 'locationCode');
        Fields.Add(ItemLedgerEntry.FieldNo("Drop Shipment"), 'dropShipment');
        Fields.Add(ItemLedgerEntry.FieldNo("Variant Code"), 'variantCode');
        Fields.Add(ItemLedgerEntry.FieldNo("Lot No."), 'lotNo');
        Fields.Add(ItemLedgerEntry.FieldNo("Serial No."), 'serialNo');
        Fields.Add(ItemLedgerEntry.FieldNo("Unit of Measure Code"), 'unitOfMeasureCode');
        Fields.Add(ItemLedgerEntry.FieldNo("Package No."), 'packageNo');
        Fields.Add(ItemLedgerEntry.FieldNo(Quantity), 'quantity');
        Fields.Add(ItemLedgerEntry.FieldNo(Description), 'description');
        Fields.Add(ItemLedgerEntry.FieldNo("External Document No."), 'externalDocumentNo');
        Fields.Add(ItemLedgerEntry.FieldNo(Open), 'open');

        exit(Response.RespondOK(Request.GetData(ItemLedgerEntry, Fields)));
    end;

    local procedure GetItemVariant(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        ItemVariant: Record "Item Variant";
        Fields: Dictionary of [Integer, Text];
    begin
        if Request.QueryParams().ContainsKey('itemCode') then begin
            ItemVariant.SetFilter("Item No.", '=%1', Request.QueryParams().Get('itemCode'));
        end;

        Fields.Add(ItemVariant.FieldNo(Code), 'variantCode');
        Fields.Add(ItemVariant.FieldNo("Item No."), 'itemCode');
        Fields.Add(ItemVariant.FieldNo(Description), 'description');
        Fields.Add(ItemVariant.FieldNo("Description 2"), 'description2');

        exit(Response.RespondOK(Request.GetData(ItemVariant, Fields)));
    end;

    local procedure GetItemCategory(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        ItemCategory: Record "Item Category";
        Fields: Dictionary of [Integer, Text];
    begin
        Fields.Add(ItemCategory.FieldNo("Code"), 'code');
        Fields.Add(ItemCategory.FieldNo(Description), 'description');
        Fields.Add(ItemCategory.FieldNo("Parent Category"), 'parentCode');
        Fields.Add(ItemCategory.FieldNo("Presentation Order"), 'presentationOrder');
        Fields.Add(ItemCategory.FieldNo("Has Children"), 'hasChildren');
        Fields.Add(ItemCategory.FieldNo("Indentation"), 'indentation');

        exit(Response.RespondOK(Request.GetData(ItemCategory, Fields)));
    end;

    local procedure GetBarcode(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        ItemReference: Record "Item Reference";
        Fields: Dictionary of [Integer, Text];
    begin
        if Request.QueryParams().ContainsKey('value') then begin
            ItemReference.SetFilter("Reference No.", '=%1', Request.QueryParams().Get('value'));
        end;
        if Request.QueryParams().ContainsKey('itemCode') then begin
            ItemReference.SetFilter("Item No.", '=%1', Request.QueryParams().Get('itemCode'));
        end;
        if Request.QueryParams().ContainsKey('variantCode') then begin
            ItemReference.SetFilter("Variant Code", '=%1', Request.QueryParams().Get('variantCode'));
        end;
        if Request.QueryParams().ContainsKey('unitOfMeasure') then begin
            ItemReference.SetFilter("Unit of Measure", '=%1', Request.QueryParams().Get('unitOfMeasure'));
        end;

        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");

        Fields.Add(ItemReference.FieldNo("Item No."), 'itemCode');
        Fields.Add(ItemReference.FieldNo("Variant Code"), 'variantCode');
        Fields.Add(ItemReference.FieldNo("Unit of Measure"), 'unitOfMeasure');
        Fields.Add(ItemReference.FieldNo("Reference No."), 'barcode');
        Fields.Add(ItemReference.FieldNo(Description), 'description');
        Fields.Add(ItemReference.FieldNo("Description 2"), 'description2');

        exit(Response.RespondOK(Request.GetData(ItemReference, Fields)));
    end;

    local procedure GetTranslation(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        ItemTranslation: Record "Item Translation";
        Fields: Dictionary of [Integer, Text];
    begin
        if Request.QueryParams().ContainsKey('itemCode') then begin
            ItemTranslation.SetFilter("Item No.", '=%1', Request.QueryParams().Get('itemCode'));
        end;
        if Request.QueryParams().ContainsKey('languageCode') then begin
            ItemTranslation.SetFilter("Language Code", '=%1', Request.QueryParams().Get('languageCode'));
        end;
        if Request.QueryParams().ContainsKey('variantCode') then begin
            ItemTranslation.SetFilter("Variant Code", '=%1', Request.QueryParams().Get('variantCode'));
        end;

        Fields.Add(ItemTranslation.FieldNo("Item No."), 'itemCode');
        Fields.Add(ItemTranslation.FieldNo("Language Code"), 'languageCode');
        Fields.Add(ItemTranslation.FieldNo("Variant Code"), 'variantCode');
        Fields.Add(ItemTranslation.FieldNo(Description), 'description');
        Fields.Add(ItemTranslation.FieldNo("Description 2"), 'description2');

        exit(Response.RespondOK(Request.GetData(ItemTranslation, Fields)));
    end;
}
#endif