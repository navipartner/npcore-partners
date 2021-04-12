page 6014607 "NPR Attribute IDs"
{
    // NPR4.11/TSA/20150422 CASE209946 - Entity and Shortcut Attributes

    Caption = 'Client Attribute IDs';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Attribute ID";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table ID field';
                }
                field("Attribute Code"; Rec."Attribute Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Attribute Code field';
                }
                field("Shortcut Attribute ID"; Rec."Shortcut Attribute ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Attribute ID field';
                }
                field("Entity Attribute ID"; Rec."Entity Attribute ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entity Attribute ID field';
                }
            }
        }
    }

    actions
    {
    }
}

