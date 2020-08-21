page 6014414 "Pacsoft Shipment Doc. Services"
{
    // PS1.00/LS/20141021  CASE  188056 : PacSoft Module Integration Created Page

    Caption = 'Pacsoft Shipment Document Services';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Pacsoft Shipment Doc. Services";
    SourceTableView = SORTING("Entry No.", "Shipping Agent Code", "Shipping Agent Service Code");
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Shipping Agent Service Code"; "Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

