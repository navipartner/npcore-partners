page 6151368 "NPR CS RFID Lines Subpage"
{
    Caption = 'RFID Tags';
    Editable = false;
    PageType = ListPart;
    SourceTable = "NPR CS Rfid Lines";

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
                field(Match; Match)
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
                field("Item Group Code"; "Item Group Code")
                {
                    ApplicationArea = All;
                }
                field("Item Group Description"; "Item Group Description")
                {
                    ApplicationArea = All;
                }
                field("Transferred to Whse. Receipt"; "Transferred to Whse. Receipt")
                {
                    ApplicationArea = All;
                }
                field("Tag Shipped"; "Tag Shipped")
                {
                    ApplicationArea = All;
                }
                field("Tag Received"; "Tag Received")
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