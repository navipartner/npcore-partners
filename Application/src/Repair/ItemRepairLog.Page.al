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
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("From value"; "From value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the From value field';
                }
                field("To Value"; "To Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To Value field';
                }
                field("Changed By"; "Changed By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Changed By field';
                }
            }
        }
    }

    actions
    {
    }
}

