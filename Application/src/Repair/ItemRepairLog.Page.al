page 6059993 "NPR Item Repair Log"
{
    // VRT1.20/JDH /20170106 CASE 251896 TestTool to analyse and fix Variants
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

    Caption = 'Item Repair Log';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Item Repair Log";

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
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("From value"; "From value")
                {
                    ApplicationArea = All;
                }
                field("To Value"; "To Value")
                {
                    ApplicationArea = All;
                }
                field("Changed By"; "Changed By")
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

