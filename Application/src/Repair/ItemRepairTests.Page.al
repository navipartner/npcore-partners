page 6059992 "NPR Item Repair Tests"
{
    // VRT1.20/JDH /20170106 CASE 251896 TestTool to analyse and fix Variants
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

    Caption = 'Item Repair Tests';
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Item Repair Tests";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Test No."; "Test No.")
                {
                    ApplicationArea = All;
                }
                field("Test Group"; "Test Group")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Success; Success)
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

