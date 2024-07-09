tableextension 6014424 "NPR Vendor" extends Vendor
{
    fields
    {
        field(6014400; "NPR Sales (LCY)"; Decimal)
        {
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Aux Value Entry has been removed and this field reimplemented on calculation procedure.';
            Caption = 'Sales (LCY)';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014401; "NPR COGS (LCY)"; Decimal)
        {
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Aux Value Entry has been removed and this field reimplemented on calculation procedure.';
            Caption = 'COGS (LCY)';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014402; "NPR Auto"; Boolean)
        {
            Caption = 'Auto';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(6014403; "NPR Item Category Filter"; Code[20])
        {
            Caption = 'Item Group Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
            TableRelation = "Item Category";
        }
        field(6014404; "NPR Sales (Qty.)"; Decimal)
        {
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Aux Value Entry has been removed and this field reimplemented on calculation procedure.';
            Caption = 'Sales (Qty.)';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014405; "NPR Salesperson Filter"; Code[20])
        {
            Caption = 'Salesperson Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
            TableRelation = "Salesperson/Purchaser";
        }
        field(6014406; "NPR Stock"; Decimal)
        {
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Aux Value Entry has been removed and this field reimplemented on calculation procedure.';
            Caption = 'Stock';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014407; "NPR Primary key length"; Integer)
        {
            Caption = 'Primary Key Length';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(6014408; "NPR Purchase Value (LCY)"; Decimal)
        {
            Caption = 'Purchase Value (LCY)';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(6014409; "NPR Change-to No."; Code[20])
        {
            Caption = 'Change-to No.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(6014415; "NPR Document Processing"; Option)
        {
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Standard field Document Sending Profile is used.';
            Caption = 'Document Processing';
            DataClassification = CustomerContent;
            Description = 'PN1.00';
            OptionCaption = 'Print,E-mail,,Print and E-Mail';
            OptionMembers = Print,Email,OIO,PrintAndEmail;
        }
        field(6151479; "NPR Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
    }

    keys
    {
        key("NPR Key1"; "NPR Replication Counter")
        {
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
#IF NOT (BC17 or BC18 or BC19 or BC20)
        key("NPR Key2"; SystemRowVersion)
        {
        }
#ENDIF
    }

    internal procedure NPRGetVESalesLCYSalesQtyCOGSLCY(var SalesLCY: Decimal; var SalesQty: Decimal; var COGSLCY: Decimal)
    var
        ValueEntryWithVendor: Query "NPR Value Entry With Vendor";
    begin
        SalesLCY := 0;
        SalesQty := 0;
        COGSLCY := 0;
        ValueEntryWithVendor.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
        ValueEntryWithVendor.SetFilter(Filter_Vendor_No, "No.");
        if GetFilter("NPR Item Category Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Item_Category_Code, GetFilter("NPR Item Category Filter"));
        if GetFilter("Global Dimension 1 Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Dim_1_Code, GetFilter("Global Dimension 1 Filter"));
        if GetFilter("Date Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_DateTime, '%1..%2', GetRangeMin("Date Filter"), GetRangeMax("Date Filter"));
        if GetFilter("NPR Salesperson Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Salespers_Purch_Code, GetFilter("NPR Salesperson Filter"));
        ValueEntryWithVendor.Open();
        while ValueEntryWithVendor.Read() do begin
            SalesLCY += ValueEntryWithVendor.Sum_Sales_Amount_Actual;
            SalesQty += -ValueEntryWithVendor.Sum_Invoiced_Quantity;
            COGSLCY += -ValueEntryWithVendor.Sum_Cost_Amount_Actual;
        end;
        ValueEntryWithVendor.Close();
    end;

    internal procedure NPRGetVEStock(var Stock: Decimal)
    var
        ValueEntryWithVendor: Query "NPR Value Entry With Vendor";
    begin
        Stock := 0;
        ValueEntryWithVendor.SetFilter(Filter_Vendor_No, "No.");
        if GetFilter("NPR Item Category Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Item_Category_Code, GetFilter("NPR Item Category Filter"));
        if GetFilter("Global Dimension 1 Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Dim_1_Code, GetFilter("Global Dimension 1 Filter"));
        if GetFilter("Date Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_DateTime, GetFilter("Date Filter"));
        if GetFilter("NPR Salesperson Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Salespers_Purch_Code, GetFilter("NPR Salesperson Filter"));
        ValueEntryWithVendor.Open();
        while ValueEntryWithVendor.Read() do
            Stock += ValueEntryWithVendor.Sum_Sales_Amount_Actual;
        ValueEntryWithVendor.Close();
    end;
}

