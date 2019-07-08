page 6060057 "Item Worksheet Field Mapping"
{
    // NPR5.25\BR  \20160729  CASE 246088 Object Created
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to Object

    Caption = 'Item Worksheet Field Mapping';
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "Item Worksheet Field Mapping";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Matching;Matching)
                {
                }
                field("Case Sensitive";"Case Sensitive")
                {
                }
                field("Source Value";"Source Value")
                {
                }
                field("Target Value";"Target Value")
                {
                }
            }
        }
    }

    actions
    {
    }
}

