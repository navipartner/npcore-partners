page 6014414 "NPR Pacsoft Shipm. Doc. Serv."
{
    Extensible = False;
    // PS1.00/LS/20141021  CASE  188056 : PacSoft Module Integration Created Page

    Caption = 'Pacsoft Shipment Document Services';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "NPR Pacsoft Shipm. Doc. Serv.";
    SourceTableView = SORTING("Entry No.", "Shipping Agent Code", "Shipping Agent Service Code");
    UsageCategory = None;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {

                    ToolTip = 'Specifies the value of the Shipping Agent Service Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

