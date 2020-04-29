page 6059993 "Item Repair Log"
{
    // VRT1.20/JDH /20170106 CASE 251896 TestTool to analyse and fix Variants
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

    Caption = 'Item Repair Log';
    PageType = List;
    SourceTable = "Item Repair Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                }
                field("Item No.";"Item No.")
                {
                }
                field("Variant Code";"Variant Code")
                {
                }
                field(Description;Description)
                {
                }
                field("From value";"From value")
                {
                }
                field("To Value";"To Value")
                {
                }
                field("Changed By";"Changed By")
                {
                }
            }
        }
    }

    actions
    {
    }
}

