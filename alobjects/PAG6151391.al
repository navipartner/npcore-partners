page 6151391 "CS Whse. Receipt Data"
{
    // NPR5.51/JAKUBV/20190903  CASE 356107 Transport NPR5.51 - 3 September 2019

    Caption = 'CS Whse. Receipt Data';
    Editable = false;
    PageType = List;
    SourceTable = "CS Whse. Receipt Data";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Tag Id"; "Tag Id")
                {
                    ApplicationArea = All;
                }
                field("Item Group Code"; "Item Group Code")
                {
                    ApplicationArea = All;
                }
                field("Item Group Description"; "Item Group Description")
                {
                    ApplicationArea = All;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Item Description"; "Item Description")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Variant Description"; "Variant Description")
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
                field("Tag Type"; "Tag Type")
                {
                    ApplicationArea = All;
                }
                field(Transferred; Transferred)
                {
                    ApplicationArea = All;
                }
                field("Transferred By"; "Transferred By")
                {
                    ApplicationArea = All;
                }
                field("Transferred To Doc"; "Transferred To Doc")
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

