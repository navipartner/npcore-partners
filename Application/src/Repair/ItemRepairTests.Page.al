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
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field("Test No."; "Test No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Test No. field';
                }
                field("Test Group"; "Test Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Test Group field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Success; Success)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Success field';
                }
            }
        }
    }

    actions
    {
    }
}

