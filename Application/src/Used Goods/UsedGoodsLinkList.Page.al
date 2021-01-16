page 6014508 "NPR Used Goods Link List"
{
    // NPR5.35/TJ  /20170824 CASE 286283 Renamed variables/function into english and into proper naming terminology

    Caption = 'Used Items Link List';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Subject; Subject)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Subject field';
                }
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Cost field';
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
            }
            group(Control6150621)
            {
                ShowCaption = false;
                field(CostAmount; CostAmount)
                {
                    ApplicationArea = All;
                    Caption = 'Total costprice';
                    ToolTip = 'Specifies the value of the Total costprice field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
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

