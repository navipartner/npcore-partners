page 6014407 "Discount Priority List"
{
    // NPR5.31/MHA /20170210  CASE 262904 Object created
    // NPR5.44/MMV /20180627  CASE 312154 Added field 30

    Caption = 'Discount Priority List';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Discount Priority";
    SourceTableView = SORTING(Priority);
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Priority; Priority)
                {
                    ApplicationArea = All;
                }
                field("Table ID"; "Table ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                }
                field(Disabled; Disabled)
                {
                    ApplicationArea = All;
                }
                field("Discount Calc. Codeunit ID"; "Discount Calc. Codeunit ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Discount Calc. Codeunit Name"; "Discount Calc. Codeunit Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Cross Line Calculation"; "Cross Line Calculation")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        POSSalesDiscCalcMgt: Codeunit "POS Sales Discount Calc. Mgt.";
    begin
        POSSalesDiscCalcMgt.InitDiscountPriority(Rec);
    end;
}

