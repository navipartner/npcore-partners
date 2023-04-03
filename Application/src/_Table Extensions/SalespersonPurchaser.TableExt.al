tableextension 6014416 "NPR Salesperson/Purchaser" extends "Salesperson/Purchaser"
{
    fields
    {
        field(6014400; "NPR Register Password"; Code[20])
        {
            Caption = 'POS Unit Password';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';

            trigger OnValidate()
            var
                RegisterCodeAlreadyUsedErr: Label 'Pos unit Password %1 is already in use.', Comment = '%1 = POS Unit Password';
            begin
                if Rec."NPR Register Password" = '' then
                    exit;

                Rec.SetRange("NPR Register Password", Rec."NPR Register Password");
                if not Rec.IsEmpty() then
                    Error(RegisterCodeAlreadyUsedErr, Rec."NPR Register Password");
            end;
        }
        field(6014402; "NPR Hide Register Imbalance"; Boolean)
        {
            Caption = 'Hide Register Imbalance';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014403; "NPR Sales (LCY)"; Decimal)
        {
            Caption = 'Sales (LCY)';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014404; "NPR Discount Amount"; Decimal)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Aux Value Entry has been removed and this field reimplemented on calculation procedure.';
            Caption = 'Discount Amount';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014405; "NPR COGS (LCY)"; Decimal)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Aux Value Entry has been removed and this field reimplemented on calculation procedure.';
            Caption = 'COGS (LCY)';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014406; "NPR Item Category Filter"; Code[20])
        {
            Caption = 'Item Category Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
        }
        field(6014407; "NPR Sales (Qty.)"; Decimal)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Aux Value Entry has been removed and this field reimplemented on calculation procedure.';
            Caption = 'Sales (Qty.)';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014408; "NPR Reverse Sales Ticket"; Option)
        {
            Caption = 'Reverse Sales Ticket';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            OptionCaption = 'Yes,No';
            OptionMembers = Yes,No;
            ObsoleteState = Removed;
            ObsoleteReason = 'Won''t be used anymore';
        }
        field(6014410; "NPR Register Filter"; Code[10])
        {
            Caption = 'Register Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
            TableRelation = "NPR POS Unit";
            ObsoleteReason = 'Not used.';
            ObsoleteState = Removed;
        }
        field(6014411; "NPR Global Dimension 1 Filter"; Code[20])
        {
            Caption = 'Global Dimension 1 Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(6014412; "NPR Item Group Sales (LCY)"; Decimal)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Aux Value Entry has been removed and this field reimplemented on calculation procedure.';
            Caption = 'Item Group Sales (LCY)';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014413; "NPR Item Filter"; Code[20])
        {
            Caption = 'Item Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
        }
        field(6014416; "NPR Locked-to Register No."; Code[10])
        {
            Caption = 'Locked-to POS Unit No.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteReason = 'Replaced with POS Unit Group field.';
            ObsoleteState = Pending;
        }
        field(6014417; "NPR POS Unit Group"; Code[20])
        {
            Caption = 'POS Unit Group';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit Group";
            trigger OnValidate()
            begin
                CheckPosUnitGroupLines();
            end;
        }
        field(6014420; "NPR Maximum Cash Returnsale"; Decimal)
        {
            Caption = 'Maximum Cash Returnsale';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014421; "NPR Picture"; BLOB)
        {
            Caption = 'Picture';
            DataClassification = CustomerContent;
            Description = 'NPR5.26';
            SubType = Bitmap;
            ObsoleteState = Removed;
            ObsoleteReason = 'Standard field used instead.';
        }
        field(6014422; "NPR Supervisor POS"; Boolean)
        {
            Caption = 'Supervisor';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
        }

        field(6151479; "NPR Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
    }

    keys
    {
        key("NPR Key1"; "NPR Replication Counter")
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
#IF NOT (BC17 or BC18 or BC19 or BC20)
        key("NPR Key2"; SystemRowVersion)
        {
        }
#ENDIF
        key("NPR Key3"; "NPR Maximum Cash Returnsale")
        {
        }
        key("NPR Key4"; "NPR Sales (LCY)")
        {
        }

    }

    local procedure CheckPosUnitGroupLines()
    var
        POSUnitGroupLine: Record "NPR POS Unit Group Line";
        EmptyLinesErr: Label 'POS Unit Group Lines are empty. Please assign POS Units to Lines before selecting POS Unit Group.';
    begin
        if "NPR POS Unit Group" = '' then
            exit;
        POSUnitGroupLine.SetRange("No.", "NPR POS Unit Group");
        if POSUnitGroupLine.IsEmpty() then
            Error(EmptyLinesErr);
    end;


    internal procedure NPRGetVESalesLCY(var SalesLCY: Decimal)
    var
        ValueEntryWithVendor: Query "NPR Value Entry With Item Cat";
    begin
        SalesLCY := 0;
        ValueEntryWithVendor.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
        ValueEntryWithVendor.SetFilter(Filter_Sales_Person, Code);
        if GetFilter("NPR Global Dimension 1 Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Dim_1_Code, GetFilter("NPR Global Dimension 1 Filter"));
        if GetFilter("Date Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_DateTime, GetFilter("Date Filter"));
        if GetFilter("NPR Item Category Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Item_Category_Code, GetFilter("NPR Item Category Filter"));
        if GetFilter("NPR Item Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Item_No, GetFilter("NPR Item Filter"));
        ValueEntryWithVendor.Open();
        while ValueEntryWithVendor.Read() do
            SalesLCY += ValueEntryWithVendor.Sum_Sales_Amount_Actual;
        ValueEntryWithVendor.Close();
    end;

    internal procedure NPRGetVEDiscountAmount(var DiscountAmount: Decimal)
    var
        ValueEntryWithVendor: Query "NPR Value Entry With Item Cat";
    begin
        DiscountAmount := 0;
        ValueEntryWithVendor.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
        ValueEntryWithVendor.SetFilter(Filter_Sales_Person, Code);
        if GetFilter("NPR Global Dimension 1 Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Dim_1_Code, GetFilter("NPR Global Dimension 1 Filter"));
        if GetFilter("Date Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_DateTime, GetFilter("Date Filter"));
        if GetFilter("NPR Item Category Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Item_Category_Code, GetFilter("NPR Item Category Filter"));
        ValueEntryWithVendor.Open();
        while ValueEntryWithVendor.Read() do
            DiscountAmount += -ValueEntryWithVendor.Sum_Discount_Amount;
        ValueEntryWithVendor.Close();
    end;

    internal procedure NPRGetVECOGSLCY(var COGSLCY: Decimal)
    var
        ValueEntryWithVendor: Query "NPR Value Entry With Item Cat";
    begin
        COGSLCY := 0;
        ValueEntryWithVendor.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
        ValueEntryWithVendor.SetFilter(Filter_Sales_Person, Code);
        if GetFilter("Date Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_DateTime, GetFilter("Date Filter"));
        if GetFilter("NPR Item Category Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Item_Category_Code, GetFilter("NPR Item Category Filter"));
        if GetFilter("NPR Global Dimension 1 Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Dim_1_Code, GetFilter("NPR Global Dimension 1 Filter"));
        ValueEntryWithVendor.Open();
        while ValueEntryWithVendor.Read() do
            COGSLCY += -ValueEntryWithVendor.Sum_Cost_Amount_Actual;
        ValueEntryWithVendor.Close();
    end;

    internal procedure NPRGetVESalesQty(var SalesQty: Decimal)
    var
        ValueEntryWithVendor: Query "NPR Value Entry With Item Cat";
    begin
        SalesQty := 0;
        ValueEntryWithVendor.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
        ValueEntryWithVendor.SetFilter(Filter_Sales_Person, Code);
        if GetFilter("Date Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_DateTime, GetFilter("Date Filter"));
        if GetFilter("NPR Item Category Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Item_Category_Code, GetFilter("NPR Item Category Filter"));
        if GetFilter("NPR Global Dimension 1 Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Dim_1_Code, GetFilter("NPR Global Dimension 1 Filter"));
        if GetFilter("NPR Item Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Item_No, GetFilter("NPR Item Filter"));
        ValueEntryWithVendor.Open();
        while ValueEntryWithVendor.Read() do
            SalesQty += -ValueEntryWithVendor.Sum_Valued_Quantity;
        ValueEntryWithVendor.Close();
    end;

    internal procedure NPRGetVEItemGroupSalesLCY(var ItemGroupSalesLCY: Decimal)
    var
        ValueEntryWithVendor: Query "NPR Value Entry With Item Cat";
    begin
        ItemGroupSalesLCY := 0;
        ValueEntryWithVendor.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
        ValueEntryWithVendor.SetFilter(Filter_Sales_Person, Code);
        if GetFilter("Date Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_DateTime, GetFilter("Date Filter"));
        if GetFilter("NPR Global Dimension 1 Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Dim_1_Code, GetFilter("NPR Global Dimension 1 Filter"));
        if GetFilter("NPR Item Category Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Item_Category_Code, GetFilter("NPR Item Category Filter"));
        if GetFilter("NPR Item Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Item_No, GetFilter("NPR Item Filter"));
        ValueEntryWithVendor.SetFilter(Filter_Group_sale, '%1', true);
        ValueEntryWithVendor.Open();
        while ValueEntryWithVendor.Read() do
            ItemGroupSalesLCY += ValueEntryWithVendor.Sum_Sales_Amount_Actual;
        ValueEntryWithVendor.Close();
    end;

    trigger OnAfterDelete()
    var
        POSEntry: Record "NPR POS Entry";
        SalesPersonDeleteErr: Label 'you cannot delete Salesperson/purchaser %1 before the sale is posted in the POS Entry!', Comment = '%1 = Salesperson/purchaser';
    begin
        POSEntry.SetRange("Salesperson Code", Rec.Code);
        POSEntry.SetFilter("Post Entry Status", '%1|%2', POSEntry."Post Entry Status"::Unposted, POSEntry."Post Entry Status"::"Error while Posting");
        if not POSEntry.IsEmpty() then
            Error(SalesPersonDeleteErr, Rec.Code);
    end;
}