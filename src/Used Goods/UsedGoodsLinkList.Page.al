page 6014508 "NPR Used Goods Link List"
{
    // NPR5.35/TJ  /20170824 CASE 286283 Renamed variables/function into english and into proper naming terminology

    Caption = 'Used Items Link List';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Used Goods Registration";

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Subject; Subject)
                {
                    ApplicationArea = All;
                }
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = All;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                }
            }
            group(Control6150621)
            {
                ShowCaption = false;
                field(CostAmount; CostAmount)
                {
                    ApplicationArea = All;
                    Caption = 'Total costprice';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        CalcSums("Unit Cost");
        CostAmount := "Unit Cost";
    end;

    var
        CostAmount: Decimal;
}

