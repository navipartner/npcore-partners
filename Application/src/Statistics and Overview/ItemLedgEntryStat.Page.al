page 6059905 "NPR Item Ledg Entry Stat."
{
    Extensible = false;
    Caption = 'Item Ledger Entry Statistics';
    PageType = List;
    Editable = false;
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;
    SourceTable = "NPR Item Ledg Entry Stat";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {

                field(RowNo; Rec.RowNo)
                {
                    ApplicationArea = NPRRetail;
                    Tooltip = 'Specifies the RowNo';
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = NPRRetail;
                    Tooltip = 'Specifies the Entry type';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = NPRRetail;
                    Tooltip = 'Specifies the Posting Date';
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = NPRRetail;
                    Tooltip = 'Specifies the Global Dimension 1 Code';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = NPRRetail;
                    Tooltip = 'Specifies the Quantity';
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = NPRRetail;
                    Tooltip = 'Specifies the Global Dimension 2 Code';
                }

                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = NPRRetail;
                    Tooltip = 'Specifies the source no.';
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ApplicationArea = NPRRetail;
                    Tooltip = 'Specifies the Item Category Code';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = NPRRetail;
                    Tooltip = 'Specifies the Vendor No.';
                }

            }
        }
    }

    trigger OnOpenPage()
    var
        ILEByDeptQuery: Query "NPR Sales Statistics By Dept";
    begin
        ILEByDeptQuery.SetRange(Filter_Vendor_No, VendorNoGlobal);
        ILEByDeptQuery.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
        ILEByDeptQuery.SetFilter(Filter_Posting_Date, '%1..%2', PeriodestartGlobal, PeriodeslutGlobal);
        if ItemCategoryFilterGlobal <> '' then
            ILEByDeptQuery.SetRange(Filter_Item_Category_Code, ItemCategoryFilterGlobal)
        else
            ILEByDeptQuery.SetRange(Filter_Item_Category_Code);

        if Dim1FilterGlobal <> '' then
            ILEByDeptQuery.SetRange(Filter_Global_Dimension_1_Code, Dim1FilterGlobal)
        else
            ILEByDeptQuery.SetRange(Filter_Global_Dimension_1_Code);

        if Dim2FilterGlobal <> '' then
            ILEByDeptQuery.SetRange(Filter_Global_Dimension_2_Code, Dim2FilterGlobal)
        else
            ILEByDeptQuery.SetRange(Filter_Global_Dimension_2_Code);
        if ILEByDeptQuery.Open() then begin
            while ILEByDeptQuery.Read() do begin
                Rec.Init();
                Rec.RowNo := Rec.RowNo + 1;
                Rec."Entry Type" := ILEByDeptQuery.Entry_Type;
                Rec."Posting Date" := ILEByDeptQuery.Posting_Date;
                Rec.Quantity := ILEByDeptQuery.Quantity;
                Rec."Global Dimension 1 Code" := ILEByDeptQuery.Global_Dimension_1_Code;
                Rec."Global Dimension 2 Code" := ILEByDeptQuery.Global_Dimension_2_Code;
                Rec."Source No." := ILEByDeptQuery.Source_No_;
                Rec."Item Category Code" := ILEByDeptQuery.Item_Category_Code;
                Rec."Vendor No." := ILEByDeptQuery.Vendor_No;
                Rec.Insert();
            end;
            ILEByDeptQuery.Close();
        end;
    end;


    procedure InitFilters(Dim1Filter: Code[20]; Dim2Filter: Code[20]; Periodestart: Date; Periodeslut: Date; LastYear: Boolean; ItemCategoryFilter: Code[20]; VendorNo: Code[20])
    begin
        VendorNoGlobal := VendorNo;
        Dim1filterGlobal := Dim1Filter;
        Dim2filterGlobal := Dim2Filter;
        PeriodeslutGlobal := Periodeslut;
        PeriodestartGlobal := Periodestart;
        ItemCategoryFilterGlobal := ItemCategoryFilter;
    end;

    var
        VendorNoGlobal: Code[20];
        Dim1filterGlobal: Code[20];
        Dim2filterGlobal: Code[20];
        PeriodeslutGlobal: Date;
        PeriodestartGlobal: Date;
        ItemCategoryFilterGlobal: Code[20];



}