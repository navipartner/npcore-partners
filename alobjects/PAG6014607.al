page 6014607 "NPR Attribute IDs"
{
    // NPR4.11/TSA/20150422 CASE209946 - Entity and Shortcut Attributes

    Caption = 'Client Attribute IDs';
    PageType = List;
    SourceTable = "NPR Attribute ID";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table ID";"Table ID")
                {
                }
                field("Attribute Code";"Attribute Code")
                {
                }
                field("Shortcut Attribute ID";"Shortcut Attribute ID")
                {
                }
                field("Entity Attribute ID";"Entity Attribute ID")
                {
                }
            }
        }
    }

    actions
    {
    }
}

