page 6151387 "NPR CS Stock-Takes Data List"
{
    // NPR5.50/CLVA/20190304  CASE 332844 Object created
    // NPR5.51/CLVA/20190902  CASE 365659 Added captions

    Caption = 'CS Stock-Takes Data List';
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR CS Stock-Takes Data";
    SourceTableView = SORTING(Created);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
            }
        }
    }

    actions
    {
    }
}

