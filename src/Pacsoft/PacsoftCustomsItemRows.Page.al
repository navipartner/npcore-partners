page 6014422 "NPR Pacsoft Customs Item Rows"
{
    // PS1.00/LS/20141021  CASE  188056 : PacSoft Module Integration Creation of Page

    Caption = 'Pacsoft Customs Item Rows';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "NPR Pacsoft Customs Item Rows";
    SourceTableView = SORTING("Shipment Document Entry No.", "Entry No.");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Item Code"; "Item Code")
                {
                    ApplicationArea = All;
                }
                field("Line Information"; "Line Information")
                {
                    ApplicationArea = All;
                }
                field(Copies; Copies)
                {
                    ApplicationArea = All;
                }
                field("Customs Value"; "Customs Value")
                {
                    ApplicationArea = All;
                }
                field("Entry Content"; Content)
                {
                    ApplicationArea = All;
                }
                field("Country of Origin"; "Country of Origin")
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

