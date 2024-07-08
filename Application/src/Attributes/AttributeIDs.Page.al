page 6014607 "NPR Attribute IDs"
{
    Extensible = False;
    // NPR4.11/TSA/20150422 CASE209946 - Entity and Shortcut Attributes

    Caption = 'Client Attribute IDs';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Attribute ID";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table ID"; Rec."Table ID")
                {

                    ToolTip = 'Specifies the value of the Table ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Attribute Code"; Rec."Attribute Code")
                {

                    ToolTip = 'Specifies the value of the Attribute Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Shortcut Attribute ID"; Rec."Shortcut Attribute ID")
                {

                    ToolTip = 'Specifies the value of the Shortcut Attribute ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Entity Attribute ID"; Rec."Entity Attribute ID")
                {

                    ToolTip = 'Specifies the value of the Entity Attribute ID field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

