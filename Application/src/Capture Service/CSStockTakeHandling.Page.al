page 6151380 "NPR CS Stock-Take Handling"
{
    // NPR5.41/NPKNAV/20180427  CASE 306407 Transport NPR5.41 - 27 April 2018
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018

    Caption = 'CS Stock-Take Handling';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR CS Stock-Take Handling";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Id; Id)
                {
                    ApplicationArea = All;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                }
                field(Barcode; Barcode)
                {
                    ApplicationArea = All;
                }
                field(Qty; Qty)
                {
                    ApplicationArea = All;
                }
                field("Stock-Take Config Code"; "Stock-Take Config Code")
                {
                    ApplicationArea = All;
                }
                field("Worksheet Name"; "Worksheet Name")
                {
                    ApplicationArea = All;
                }
                field("Shelf  No."; "Shelf  No.")
                {
                    ApplicationArea = All;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
                field(Handled; Handled)
                {
                    ApplicationArea = All;
                }
                field("Transferred to Worksheet"; "Transferred to Worksheet")
                {
                    ApplicationArea = All;
                }
                field(Created; Created)
                {
                    ApplicationArea = All;
                }
                field("Created By"; "Created By")
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

