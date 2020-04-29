page 6059992 "Item Repair Tests"
{
    // VRT1.20/JDH /20170106 CASE 251896 TestTool to analyse and fix Variants
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

    Caption = 'Item Repair Tests';
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Item Repair Tests";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No.";"Item No.")
                {
                }
                field("Variant Code";"Variant Code")
                {
                }
                field("Test No.";"Test No.")
                {
                }
                field("Test Group";"Test Group")
                {
                }
                field(Description;Description)
                {
                }
                field(Success;Success)
                {
                }
            }
        }
    }

    actions
    {
    }
}

