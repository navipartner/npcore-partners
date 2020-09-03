page 6151369 "NPR CS Stock-Takes Data"
{
    // NPR5.50/CLVA/20190515 CASE 350696 Object created - NP Capture Service
    // NPR5.51/CLVA/20190902 CASE 365659 Added captions
    // NPR5.52/CLVA/20190917 CASE 368484 Added field Area

    Caption = 'CS Stock-Takes Data';
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR CS Stock-Takes Data";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Stock-Take Id"; "Stock-Take Id")
                {
                    ApplicationArea = All;
                }
                field("Worksheet Name"; "Worksheet Name")
                {
                    ApplicationArea = All;
                }
                field("Tag Id"; "Tag Id")
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
                field("Item Group Code"; "Item Group Code")
                {
                    ApplicationArea = All;
                }
                field("Item Description"; "Item Description")
                {
                    ApplicationArea = All;
                }
                field("Variant Description"; "Variant Description")
                {
                    ApplicationArea = All;
                }
                field("Item Group Description"; "Item Group Description")
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
                field(Approved; Approved)
                {
                    ApplicationArea = All;
                }
                field("Approved By"; "Approved By")
                {
                    ApplicationArea = All;
                }
                field("Transferred To Worksheet"; "Transferred To Worksheet")
                {
                    ApplicationArea = All;
                }
                field("Combined key"; "Combined key")
                {
                    ApplicationArea = All;
                }
                field("Stock-Take Config Code"; "Stock-Take Config Code")
                {
                    ApplicationArea = All;
                }
                field("Area"; Area)
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

