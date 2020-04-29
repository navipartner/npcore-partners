page 6014508 "Used Goods Link List"
{
    // NPR5.35/TJ  /20170824 CASE 286283 Renamed variables/function into english and into proper naming terminology

    Caption = 'Used Items Link List';
    Editable = false;
    PageType = List;
    SourceTable = "Used Goods Registration";

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field("No.";"No.")
                {
                }
                field(Subject;Subject)
                {
                }
                field("Unit Cost";"Unit Cost")
                {
                }
                field(Blocked;Blocked)
                {
                }
            }
            group(Control6150621)
            {
                ShowCaption = false;
                field(CostAmount;CostAmount)
                {
                    Caption = 'Total costprice';
                }
                field(Name;Name)
                {
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

