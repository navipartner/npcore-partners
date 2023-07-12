tableextension 6014400 "NPR Item Category" extends "Item Category"
{
    fields
    {
        modify(Description)
        {
            trigger OnAfterValidate()
            var
                Item: Record Item;
            begin
                if Rec.IsTemporary() then
                    exit;

                if xRec.Description = Rec.Description then
                    exit;

                if Item.Get(Rec.Code) then
                    if Item."NPR Group sale" then begin
                        Item.Validate(Description, Rec.Description);
                        Item.Modify(true);
                    end;
            end;
        }
        modify("Parent Category")
        {
            trigger OnAfterValidate()
            var
                ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
            begin
                if Rec.IsTemporary() then
                    exit;

                if (Rec."Parent Category" = xRec."Parent Category") or (Rec."Parent Category" = '') then
                    exit;

                if xRec."Parent Category" <> '' then
                    ItemCategoryMgt.CopySetupFromParent(Rec, false)
                else
                    ItemCategoryMgt.CopySetupFromParent(Rec, true);
            end;
        }
        field(6014400; "NPR Item Template Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Item Template Code';
            TableRelation = "Config. Template Header" where("Table ID" = const(27));
        }
        field(6014406; "NPR Main Category"; Boolean)
        {
            Caption = 'Main Category';
            DataClassification = CustomerContent;
        }
        field(6014407; "NPR Main Category Code"; Code[10])
        {
            Caption = 'Main Category Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Category" where("NPR Main Category" = const(true));
        }
        field(6014408; "NPR Blocked"; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
            begin
                ItemCategoryMgt.SetBlockedOnChildren(Code, "NPR Blocked", false);
            end;
        }
        field(6014409; "NPR Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                NPRValidateShortcutDimCode(1, "NPR Global Dimension 1 Code");
            end;
        }
        field(6014410; "NPR Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                NPRValidateShortcutDimCode(2, "NPR Global Dimension 2 Code");
            end;
        }
        field(6014411; "NPR Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(6014412; "NPR Location Filter"; code[10])
        {
            Caption = 'Location Filter';
            FieldClass = FlowFilter;
            TableRelation = Location;
        }
        field(6014413; "NPR Salesperson/Purch. Filter"; Code[20])
        {
            Caption = 'Salesperson Filter';
            FieldClass = FlowFilter;
            TableRelation = "Salesperson/Purchaser";
        }
        field(6014414; "NPR Vendor Filter"; Code[20])
        {
            Caption = 'Vendor Filter';
            FieldClass = FlowFilter;
            TableRelation = Vendor;
        }
        field(6014415; "NPR Global Dimension 1 Filter"; Code[20])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension 1 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(6014416; "NPR Global Dimension 2 Filter"; Code[20])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension 2 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }

        field(6014417; "NPR Sales (Qty.)"; Decimal)
        {
            Caption = 'Sales (Qty.)';
            FieldClass = FlowField;
            CalcFormula = - Sum("Item Ledger Entry"."Invoiced Quantity"
                                WHERE(
                                    "Entry Type" = CONST(Sale),
                                    "Item Category Code" = FIELD("Code"),
                                    "Posting Date" = FIELD("NPR Date Filter"),
                                    "Item No." = FIELD("NPR Item Filter"),
                                    "Source No." = FIELD("NPR Vendor Filter"),
                                    "Global Dimension 1 Code" = FIELD("NPR Global Dimension 1 Filter"),
                                    "Global Dimension 2 Code" = FIELD("NPR Global Dimension 2 Filter"),
                                    "Location Code" = field("NPR Location Filter")));
        }
        field(6014418; "NPR Sales (LCY)"; Decimal)
        {
            Caption = 'Sales (LCY)';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Aux Value Entry has been removed and this field reimplemented on calculation procedure.';
        }
        field(6014419; "NPR Consumption (Amount)"; Decimal)
        {
            Caption = 'Consumption (Amount)';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Aux Value Entry has been removed and this field reimplemented on calculation procedure.';
        }
        field(6014420; "NPR Movement"; Decimal)
        {
            Caption = 'Movement';
            FieldClass = FlowField;
            CalcFormula = Sum("Item Ledger Entry".Quantity
                            WHERE(
                                "Item Category Code" = FIELD("Code"),
                                "Source Type" = const(Vendor),
                                "Source No." = FIELD("NPR Vendor Filter"),
                                "Posting Date" = FIELD("NPR Date Filter"),
                                "Global Dimension 1 Code" = FIELD("NPR Global Dimension 1 Filter"),
                                "Global Dimension 2 Code" = FIELD("NPR Global Dimension 2 Filter"),
                                "Location Code" = field("NPR Location Filter")));
        }
        field(6014421; "NPR Purchases (Qty.)"; Decimal)
        {
            Caption = 'Purchases (Qty.)';
            FieldClass = FlowField;
            CalcFormula = Sum("Item Ledger Entry".Quantity
                            WHERE(
                                "Entry Type" = CONST(Purchase),
                                "Item Category Code" = FIELD("Code"),
                                "Posting Date" = FIELD("NPR Date Filter"),
                                "Source Type" = const(Vendor),
                                "Source No." = FIELD("NPR Vendor Filter"),
                                "Global Dimension 1 Code" = FIELD("NPR Global Dimension 1 Filter"),
                                "Global Dimension 2 Code" = FIELD("NPR Global Dimension 2 Filter"),
                                "Location Code" = field("NPR Location Filter")));
        }
        field(6014422; "NPR Purchases (LCY)"; Decimal)
        {
            Caption = 'Purchases (LCY)';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Aux Value Entry has been removed and this field reimplemented on calculation procedure.';
        }
        field(6014423; "NPR Inventory Value"; Decimal)
        {
            Caption = 'Inventory Value';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Aux Value Entry has been removed and this field reimplemented on calculation procedure.';
        }

        field(6151479; "NPR Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
        field(6151480; "NPR Item Filter"; Code[20])
        {
            Caption = 'Item Filter';
            FieldClass = FlowFilter;
            TableRelation = Item;
        }
    }

    keys
    {

        key("NPR Key1"; "NPR Replication Counter")
        {
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
#IF NOT (BC17 or BC18 or BC19 or BC20)
        key("NPR Key2"; SystemRowVersion)
        {
        }
#ENDIF
    }

    internal procedure NPRValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        if not IsTemporary() then begin
            DimMgt.SaveDefaultDim(DATABASE::"Item Category", Code, FieldNumber, ShortcutDimCode);
            Modify();
        end;
    end;

    internal procedure NPRGetVESalesQty(var SalesQty: Decimal)
    var
        ValueEntryWithVendor: Query "NPR Value Entry With Vendor";
    begin
        SalesQty := 0;
        ValueEntryWithVendor.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
        ValueEntryWithVendor.SetFilter(Filter_Item_Category_Code, Code);
        ValueEntryWithVendor.SetFilter(Filter_Dim_1_Code, "NPR Global Dimension 1 Code");
        ValueEntryWithVendor.SetFilter(Filter_Dim_2_Code, "NPR Global Dimension 2 Code");
        if GetFilter("NPR Vendor Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Vendor_No, GetFilter("NPR Vendor Filter"));
        if GetFilter("NPR Date Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_DateTime, GetFilter("NPR Date Filter"));
        if GetFilter("NPR Salesperson/Purch. Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Salespers_Purch_Code, GetFilter("NPR Salesperson/Purch. Filter"));
        if GetFilter("NPR Location Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Location_Code, GetFilter("NPR Location Filter"));
        ValueEntryWithVendor.Open();
        while ValueEntryWithVendor.Read() do
            SalesQty += -ValueEntryWithVendor.Sum_Invoiced_Quantity;
        ValueEntryWithVendor.Close();
    end;

    internal procedure NPRGetVESalesLCYAndConsumptionAmount(var SalesLCY: Decimal; var ConsumptionAmount: Decimal)
    var
        ValueEntryWithVendor: Query "NPR Value Entry With Vendor";
    begin
        SalesLCY := 0;
        ConsumptionAmount := 0;
        ValueEntryWithVendor.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
        ValueEntryWithVendor.SetFilter(Filter_Item_Category_Code, Code);
        ValueEntryWithVendor.SetFilter(Filter_Dim_1_Code, "NPR Global Dimension 1 Code");
        ValueEntryWithVendor.SetFilter(Filter_Dim_2_Code, "NPR Global Dimension 2 Code");
        if GetFilter("NPR Vendor Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Vendor_No, GetFilter("NPR Vendor Filter"));
        if GetFilter("NPR Date Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_DateTime, GetFilter("NPR Date Filter"));
        if GetFilter("NPR Salesperson/Purch. Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Salespers_Purch_Code, GetFilter("NPR Salesperson/Purch. Filter"));
        if GetFilter("NPR Location Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Location_Code, GetFilter("NPR Location Filter"));
        ValueEntryWithVendor.Open();
        while ValueEntryWithVendor.Read() do begin
            SalesLCY += ValueEntryWithVendor.Sum_Sales_Amount_Actual;
            ConsumptionAmount += -ValueEntryWithVendor.Sum_Cost_Amount_Actual;
        end;
        ValueEntryWithVendor.Close();
    end;

    internal procedure NPRGetVEPurchasesLCY(var PurchasesLCY: Decimal)
    var
        ValueEntryWithVendor: Query "NPR Value Entry With Vendor";
    begin
        PurchasesLCY := 0;
        ValueEntryWithVendor.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Purchase);
        ValueEntryWithVendor.SetFilter(Filter_Item_Category_Code, Code);
        ValueEntryWithVendor.SetFilter(Filter_Dim_1_Code, "NPR Global Dimension 1 Code");
        ValueEntryWithVendor.SetFilter(Filter_Dim_2_Code, "NPR Global Dimension 2 Code");
        if GetFilter("NPR Vendor Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Vendor_No, GetFilter("NPR Vendor Filter"));
        if GetFilter("NPR Date Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_DateTime, GetFilter("NPR Date Filter"));
        if GetFilter("NPR Salesperson/Purch. Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Salespers_Purch_Code, GetFilter("NPR Salesperson/Purch. Filter"));
        if GetFilter("NPR Location Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Location_Code, GetFilter("NPR Location Filter"));
        ValueEntryWithVendor.Open();
        while ValueEntryWithVendor.Read() do begin
            PurchasesLCY += ValueEntryWithVendor.Sum_Cost_Amount_Actual;
        end;
        ValueEntryWithVendor.Close();
    end;

    internal procedure NPRGetVEInventoryValue(var InventoryValue: Decimal)
    var
        ValueEntryWithVendor: Query "NPR Value Entry With Vendor";
    begin
        InventoryValue := 0;
        ValueEntryWithVendor.SetFilter(Filter_Item_Category_Code, Code);
        ValueEntryWithVendor.SetFilter(Filter_Dim_1_Code, "NPR Global Dimension 1 Code");
        ValueEntryWithVendor.SetFilter(Filter_Dim_2_Code, "NPR Global Dimension 2 Code");
        if GetFilter("NPR Vendor Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Vendor_No, GetFilter("NPR Vendor Filter"));
        if GetFilter("NPR Date Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_DateTime, GetFilter("NPR Date Filter"));
        if GetFilter("NPR Location Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Location_Code, GetFilter("NPR Location Filter"));
        ValueEntryWithVendor.Open();
        while ValueEntryWithVendor.Read() do begin
            InventoryValue += ValueEntryWithVendor.Sum_Cost_Amount_Actual;
        end;
        ValueEntryWithVendor.Close();
    end;
}
