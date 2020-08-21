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
                field("Table ID"; "Table ID")
                {
                    ApplicationArea = All;
                }
                field("Attribute Code"; "Attribute Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Attribute ID"; "Shortcut Attribute ID")
                {
                    ApplicationArea = All;
                }
                field("Entity Attribute ID"; "Entity Attribute ID")
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

