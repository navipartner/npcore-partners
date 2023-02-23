page 6059904 "NPR Value Entries Sales"
{
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;
    SourceTable = "NPR Value Entries Sales";
    SourceTableTemporary = true;
    Caption = 'Value Entry Sales';
    Extensible = False;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field("Item Ledger Entry Type"; Rec."Item Ledger Entry Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Item Ledger Entry Type field.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Posting Date field.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Item No. field.';
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Source No. field.';
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field.';
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Location Code field.';
                }
                field("Salespers./Purch. Code"; Rec."Salespers./Purch. Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Salesperson Code field.';
                }
                field("Sales Amount (Actual)"; Rec."Sales Amount (Actual)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Sales Amount (Actual) field.';
                }
                field("Cost Amount (Actual)"; Rec."Cost Amount (Actual)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Cost Amount (Actual) field.';
                }
                field("Invoiced Quantity"; Rec."Invoiced Quantity")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Invoiced Quantity field.';
                }

            }
        }
    }


    trigger OnOpenPage()
    var
        LineNo: Integer;
    begin
        LineNo := 1;
        AddValueEntries(LineNo);

    end;

    local procedure AddValueEntries(var LineNo: Integer)
    var
        ValueEntrywithVendor: Query "NPR Value Entry With Vendor";
    begin
        ValueEntrywithVendor.SetRange(Filter_Entry_Type, ValueEntrywithVendor.Item_Ledger_Entry_Type::Sale);
        if Dim1FilterL <> '' then
            ValueEntrywithVendor.SetRange(Filter_Dim_1_Code, Dim1FilterL);
        if Dim2FilterL <> '' then
            ValueEntrywithVendor.SetRange(Filter_Dim_2_Code, Dim2FilterL);
        if ItemCategoryFilterL <> '' then
            ValueEntryWithVendor.SetRange(Filter_Item_Category_Code, ItemCategoryFilterL);
        ValueEntryWithVendor.SetRange(Filter_Vendor_No, VendorNoL);
        if not LastYearL then
            ValueEntryWithVendor.SetFilter(Filter_DateTime, '%1..%2', PeriodstartL, PeriodendL)
        else
            ValueEntryWithVendor.SetFilter(Filter_DateTime, '%1..%2', CalcDate('<-1Y>', PeriodstartL), CalcDate('<-1Y>', PeriodendL));
        if ValueEntrywithVendor.Open() then begin
            while ValueEntrywithVendor.Read() do begin
                Rec.Init();
                Rec."Line No." := LineNo;
                LineNo += 1;
                Rec.Insert();
                Rec."Item Ledger Entry Type" := ValueEntrywithVendor.Item_Ledger_Entry_Type;
                Rec."Posting Date" := ValueEntrywithVendor.Posting_Date;
                Rec."Item No." := ValueEntrywithVendor.Item_No_;
                Rec."Source No." := ValueEntrywithVendor.Source_No_;
                Rec."Global Dimension 1 Code" := ValueEntrywithVendor.Global_Dimension_1_Code;
                Rec."Global Dimension 2 Code" := ValueEntrywithVendor.Global_Dimension_2_Code;
                Rec."Location Code" := ValueEntrywithVendor.Location_Code;
                Rec."Salespers./Purch. Code" := ValueEntrywithVendor.Salespers__Purch__Code;
                Rec."Cost Amount (Actual)" := ValueEntrywithVendor.Cost_Amount__Actual_;
                Rec."Sales Amount (Actual)" := ValueEntrywithVendor.Sales_Amount__Actual_;
                Rec."Invoiced Quantity" := ValueEntrywithVendor.Invoiced_Quantity;
                Rec.Modify();
            end;
        end;
    end;

    procedure InitFilters(Dim1Filter: Code[20]; Dim2Filter: Code[20]; PeriodEnd: Date; PeriodStart: Date; LastYear: Boolean; ItemCategoryFilter: Code[20]; VendorNo: Code[20])

    begin
        Dim1FilterL := Dim1Filter;
        Dim2FilterL := Dim2Filter;
        PeriodEndL := PeriodEnd;
        PeriodStartL := PeriodStart;
        LastYearL := LastYear;
        
        ItemCategoryFilterL := ItemCategoryFilter;
        VendorNoL := VendorNo;
    end;

    var
        Dim1FilterL: Code[20];
        Dim2FilterL: Code[20];
        PeriodEndL: Date;
        PeriodStartL: Date;
        LastYearL: Boolean;       
        ItemCategoryFilterL : Code[20];
        VendorNoL : Code[20];
}
