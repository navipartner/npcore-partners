codeunit 6059931 "NPR SS Action: Insert Item B."
{
    Access = Internal;

    procedure IncreaseQuantity(ItemIdentifier: Text; ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch; IncreaseByQty: Decimal; ItemMaxQty: Decimal): Boolean
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
    begin
        if ItemIdentifierType < 0 then
            ItemIdentifierType := 0;
        if IncreaseByQty = 0 then
            IncreaseByQty := 1;

        GetItem(Item, ItemReference, ItemIdentifier, ItemIdentifierType);
        exit(AddQuantityToItemLine(Item, IncreaseByQty, ItemMaxQty));
    end;

    local procedure AddQuantityToItemLine(Item: Record Item; IncreaseByQty: Decimal; ItemMaxQuantity: Decimal): Boolean
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SSActionQtyIncrease: Codeunit "NPR SS Action - Qty Increase";
        POSSession: Codeunit "NPR POS Session";
        TooBigQtyErr: Label 'Quantity cannot exceed %1 units', Comment = '%1 - number of units';
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetFilter("No.", '=%1', Item."No.");
        if (not SaleLinePOS.FindFirst()) then
            exit(false);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetPosition(SaleLinePOS.GetPosition());
        if (SaleLinePOS.Quantity + IncreaseByQty > ItemMaxQuantity) and (ItemMaxQuantity > 0) then
            Error(TooBigQtyErr, ItemMaxQuantity);

        SSActionQtyIncrease.IncreaseSalelineQuantity(POSSession, IncreaseByQty, POSSaleLine);

        exit(true);
    end;

    procedure DecreaseQuantity(ItemIdentifier: Text; ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch; DecreaseByQty: Decimal; ItemMinQuantity: Decimal)
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
    begin
        if ItemIdentifierType < 0 then
            ItemIdentifierType := 0;
        If DecreaseByQty = 0 then
            DecreaseByQty := 1;

        GetItem(Item, ItemReference, ItemIdentifier, ItemIdentifierType);
        RemoveQuantityFromItemLine(Item, DecreaseByQty, ItemMinQuantity);
    end;

    procedure AddSalesLine(ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch; ItemIdentifier: Text; ItemMinQuantity: Decimal; ItemQuantity: Decimal; PresetUnitPrice: Decimal; UsePresetUnitPrice: Boolean)
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
    begin
        if ItemIdentifierType < 0 then
            ItemIdentifierType := 0;

        GetItem(Item, ItemReference, ItemIdentifier, ItemIdentifierType);

        if (ItemMinQuantity > 0) and (ItemQuantity < ItemMinQuantity) then
            ItemQuantity := ItemMinQuantity;

        AddItemLine(Item, ItemReference, ItemIdentifierType, ItemQuantity, UsePresetUnitPrice, PresetUnitPrice);

    end;

    local procedure RemoveQuantityFromItemLine(Item: Record Item; DecreaseByQty: Decimal; ItemMinQuantity: Decimal)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SSActionDeletePOSLine: Codeunit "NPR SS Action: Delete POSLineB";
        SSActionQtyDecreaseB: Codeunit "NPR SS Action - Qty Decrease B";
        POSSession: Codeunit "NPR POS Session";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetFilter("No.", '=%1', Item."No.");
        if (not SaleLinePOS.FindFirst()) then
            exit;

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetPosition(SaleLinePOS.GetPosition());

        if SaleLinePOS.Quantity - Abs(DecreaseByQty) < ItemMinQuantity then begin
            SSActionDeletePOSLine.DeletePOSLine(POSSaleLine);
        end else begin
            SSActionQtyDecreaseB.DecreaseSalelineQuantity(Abs(DecreaseByQty), POSSaleLine);
        end;

    end;

    local procedure GetItem(var Item: Record Item; var ItemReference: Record "Item Reference"; ItemIdentifier: Text; ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference,ItemGtin)
    var
        FirstRec: Text;
        TagId: Text;
        ERROR_ITEMSEARCH: Label 'Could not find a matching item for input %1';
    begin
        case ItemIdentifierType of
            ItemIdentifierType::ItemNo:
                Item.Get(ItemIdentifier);

            ItemIdentifierType::ItemCrossReference:
                begin
                    ItemReference.SetFilter("Reference No.", '=%1', CopyStr(ItemIdentifier, 1, MaxStrLen(ItemReference."Reference No.")));
                    ItemReference.SetFilter("Reference Type", '=%1', ItemReference."Reference Type"::"Bar Code");
                    ItemReference.FindFirst();
                    FirstRec := Format(ItemReference);
                    ItemReference.FindLast();
                    if FirstRec <> Format(ItemReference) then begin
                        if PAGE.RunModal(0, ItemReference) <> ACTION::LookupOK then
                            Error('');
                    end;
                    Item.Get(ItemReference."Item No.");
                end;

            ItemIdentifierType::ItemSearch:
                if GetItemFromItemSearch(ItemIdentifier) then
                    Item.Get(ItemIdentifier)
                else
                    Error(ERROR_ITEMSEARCH, ItemIdentifier);

            ItemIdentifierType::SerialNoItemCrossReference:
                begin

                    TagId := CopyStr(ItemIdentifier, 5);

                    ItemReference.SetFilter("Reference No.", '=%1', CopyStr(TagId, 1, MaxStrLen(ItemReference."Reference No.")));
                    ItemReference.SetFilter("Reference Type", '=%1', ItemReference."Reference Type"::"NPR Retail Serial No.");
                    ItemReference.FindFirst();
                    FirstRec := Format(ItemReference);
                    ItemReference.FindLast();
                    if FirstRec <> Format(ItemReference) then begin
                        if PAGE.RunModal(0, ItemReference) <> ACTION::LookupOK then
                            Error('');
                    end;

                    Item.Get(ItemReference."Item No.");
                end;
            ItemIdentifierType::ItemGtin:
                begin
                    Item.SetRange(GTIN, ItemIdentifier);
                    Item.FindFirst();
                end;
        end;
    end;

    local procedure AddItemLine(Item: Record Item; ItemReference: Record "Item Reference"; ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference,ItemGtin; ItemQuantity: Decimal; UsePresetUnitPrice: Boolean; PresetUnitPrice: Decimal)
    var
        Line: Record "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLine: Codeunit "NPR POS Sale Line";
        POSSession: Codeunit "NPR POS Session";
        SetUnitPrice: Boolean;
        UnitPrice: Decimal;
    begin

        if UsePresetUnitPrice then begin
            UnitPrice := PresetUnitPrice;
            SetUnitPrice := true;
        end;

        if ItemQuantity = 0 then
            ItemQuantity := 1;

        Line."Line Type" := Line."Line Type"::Item;
        Line.Quantity := ItemQuantity;

        case ItemIdentifierType of
            ItemIdentifierType::ItemSearch,
            ItemIdentifierType::ItemNo,
            ItemIdentifierType::ItemGtin:
                begin
                    Line."No." := Item."No.";
                end;

            ItemIdentifierType::ItemCrossReference:
                begin
                    Line."No." := ItemReference."Item No.";
                    Line."Variant Code" := ItemReference."Variant Code";
                    Line."Unit of Measure Code" := ItemReference."Unit of Measure";
                    if (ItemReference."Reference Type" = ItemReference."Reference Type"::"NPR Retail Serial No.") then
                        Line."Serial No. not Created" := ItemReference."Reference No.";
                end;
            ItemIdentifierType::SerialNoItemCrossReference:
                begin
                    SaleLinePOS.Reset();
                    SaleLinePOS.SetFilter("Line Type", '=%1', SaleLinePOS."Line Type"::Item);
                    SaleLinePOS.SetFilter("Serial No. not Created", '=%1', ItemReference."Reference No.");
                    if not SaleLinePOS.IsEmpty then
                        exit;

                    Line."No." := ItemReference."Item No.";
                    Line."Variant Code" := ItemReference."Variant Code";
                    Line."Unit of Measure Code" := ItemReference."Unit of Measure";
                    if (ItemReference."Reference Type" = ItemReference."Reference Type"::"NPR Retail Serial No.") then
                        Line."Serial No. not Created" := ItemReference."Reference No.";
                end;
        end;

        if SetUnitPrice then begin
            Line."Unit Price" := UnitPrice;

            if (Line."Line Type" = Line."Line Type"::Item) then
                Line."Initial Group Sale Price" := UnitPrice;
        end;

        POSSession.GetSaleLine(SaleLine);
        SaleLine.InsertLine(Line);
        AddAccessories(Item, SaleLine);
        AutoExplodeBOM(Item, SaleLine);
    end;


    local procedure AddAccessories(Item: Record Item; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        AccessorySparePart: Record "NPR Accessory/Spare Part";
    begin
        // This is an adoption of the original function UdpakTilbeh?r in 6014418

        AccessorySparePart.SetFilter(Type, '=%1', AccessorySparePart.Type::Accessory);
        AccessorySparePart.SetFilter(Code, '=%1', Item."No.");
        AccessorySparePart.SetFilter("Add Extra Line Automatically", '=%1', true);
        if (AccessorySparePart.IsEmpty()) then begin
            // Item Group Accessory
            AccessorySparePart.SetFilter(Code, '=%1', Item."Item Category Code");
            if (not AccessorySparePart.IsEmpty()) then
                AddAccessoryForItem(Item, true, POSSaleLine);
        end else
            AddAccessoryForItem(Item, false, POSSaleLine);
    end;

    local procedure AddAccessoryForItem(Item: Record Item; GroupAccessory: Boolean; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        MainSaleLinePOS: Record "NPR POS Sale Line";
        AccessorySaleLinePOS: Record "NPR POS Sale Line";
        AccessorySparePart: Record "NPR Accessory/Spare Part";
    begin
        AccessorySparePart.SetFilter(Type, '=%1', AccessorySparePart.Type::Accessory);
        AccessorySparePart.SetFilter(Code, '=%1', Item."No.");

        if (not AccessorySparePart.FindSet()) then
            exit;

        POSSaleLine.GetCurrentSaleLine(MainSaleLinePOS);

        repeat
            POSSaleLine.GetNewSaleLine(AccessorySaleLinePOS);

            AccessorySaleLinePOS.Accessory := true;
            AccessorySaleLinePOS."Main Item No." := Item."No.";
            AccessorySaleLinePOS."Item group accessory" := GroupAccessory;
            if (GroupAccessory) then
                AccessorySaleLinePOS."Accessories Item Group No." := Item."Item Category Code";

            AccessorySaleLinePOS.Validate("No.", AccessorySparePart."Item No.");

            // This is not support unless we add a commit at this point
            if (AccessorySparePart."Quantity in Dialogue") then
                Error('The possibility to specify quantity per accessory line in a dialogue has been discontinued.');

            if (AccessorySparePart."Per unit") then
                AccessorySaleLinePOS.Validate(Quantity, AccessorySparePart.Quantity * MainSaleLinePOS.Quantity)
            else
                AccessorySaleLinePOS.Validate(Quantity, AccessorySparePart.Quantity);

            POSSaleLine.InsertLine(AccessorySaleLinePOS);

            if AccessorySparePart."Use Alt. Price" then begin
                if (AccessorySaleLinePOS."Price Includes VAT") and (not Item."Price Includes VAT") then
                    AccessorySparePart."Alt. Price" := AccessorySparePart."Alt. Price" * (1 + (AccessorySaleLinePOS."VAT %" / 100))
                else
                    if (not AccessorySaleLinePOS."Price Includes VAT") and (Item."Price Includes VAT") then
                        AccessorySparePart."Alt. Price" := AccessorySparePart."Alt. Price" / (1 + (AccessorySaleLinePOS."VAT %" / 100));

                if AccessorySparePart."Show Discount" then
                    AccessorySaleLinePOS.Validate("Amount Including VAT", AccessorySparePart."Alt. Price")
                else
                    AccessorySaleLinePOS.Validate("Unit Price", AccessorySparePart."Alt. Price");
            end;

            AccessorySaleLinePOS."Item group accessory" := GroupAccessory;
            if (GroupAccessory) then
                AccessorySaleLinePOS."Accessories Item Group No." := Item."Item Category Code";

            AccessorySaleLinePOS.Accessory := true;
            AccessorySaleLinePOS."Main Item No." := Item."No.";
            AccessorySaleLinePOS."Main Line No." := MainSaleLinePOS."Line No.";

            AccessorySaleLinePOS.Modify();
            POSSaleLine.RefreshCurrent();
        until (AccessorySparePart.Next() = 0);
    end;

    local procedure GetItemFromItemSearch(var ItemIdentifierString: Text): Boolean
    var
        Item: Record Item;
        ItemList: Page "Item List";
    begin
        SetItemSearchFilter(ItemIdentifierString, Item);
        if not Item.FindFirst() then
            exit(false);

        ItemIdentifierString := Item."No.";
        Item.FindLast();
        if ItemIdentifierString = Item."No." then
            exit(true);
        ItemList.Editable(true);
        ItemList.LookupMode(true);
        ItemList.SetTableView(Item);
        if ItemList.RunModal() = ACTION::LookupOK then begin
            ItemList.GetRecord(Item);
            ItemIdentifierString := Item."No.";
            exit(true);
        end else begin
            exit(false);
        end;
    end;

    procedure SetItemSearchFilter(ItemIdentifierString: Text; var Item: Record Item)
    var
        SearchFilter: Text;
        SearchString: Text;
        SearchFilterLbl: Label '=%1', Locked = true;
    begin
        Clear(Item);

        SearchString := CopyStr(ItemIdentifierString, 1, MaxStrLen(Item."Search Description"));
        SearchString := UpperCase(SearchString);
        SearchFilter := '*' + SearchString + '*';
        if ItemIdentifierString = '' then
            SearchFilter := StrSubstNo(SearchFilterLbl, '');

        Item.SetCurrentKey("Search Description");
        Item.SetFilter("Search Description", SearchFilter);
        Item.SetRange(Blocked, false);
    end;

    procedure SetQuantity(ItemIdentifier: Text; ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch; ItemQuantity: Decimal): Boolean;
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
    begin
        if ItemIdentifierType < 0 then
            ItemIdentifierType := 0;

        GetItem(Item, ItemReference, ItemIdentifier, ItemIdentifierType);
        exit(SetQuantityToItemLine(Item, ItemReference, ItemIdentifierType, ItemQuantity));
    end;

    procedure SetQuantityToItemLine(Item: Record Item; ItemReference: Record "Item Reference"; ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference,ItemGtin; ItemQuantity: Decimal): Boolean
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSession: Codeunit "NPR POS Session";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetFilter("No.", '=%1', Item."No.");
        SaleLinePOS.SetFilter(Quantity, '>=%1', 1);
        if (not SaleLinePOS.FindFirst()) then
            exit(false);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetPosition(SaleLinePOS.GetPosition());

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        POSSaleLine.SetQuantity(ItemQuantity);

        exit(true);
    end;

    local procedure AutoExplodeBOM(Item: Record Item; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        Level: Integer;
    begin
        if not Item."NPR Explode BOM auto" then
            exit;
        Item.CalcFields("Assembly BOM");
        if not Item."Assembly BOM" then
            exit;

        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLinePOS.Validate("Line Type", SaleLinePOS."Line Type"::"BOM List");
        SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::"BOM List";
        SaleLinePOS."Discount Code" := SaleLinePOS."No.";
        SaleLinePOS."Unit Price" := 0;
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        SaleLinePOS.Modify(true);

        SaleLinePOS.ExplodeBOM(SaleLinePOS."No.", 0, 0, Level, 0, 0);
    end;

}