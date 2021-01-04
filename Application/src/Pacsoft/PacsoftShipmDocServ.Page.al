page 6014414 "NPR Pacsoft Shipm. Doc. Serv."
{
    // PS1.00/LS/20141021  CASE  188056 : PacSoft Module Integration Created Page

    Caption = 'Pacsoft Shipment Document Services';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "NPR Pacsoft Shipm. Doc. Serv.";
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
                    ToolTip = 'Specifies the value of the Shipping Agent Service Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
        }
    }

    actions
    {
    }
}

