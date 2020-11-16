page 6014608 "NPR Attribute Values"
{
    // NPR4.11/TSA/20150422 CASE209946 - Entity and Shortcut Attributes

    Caption = 'Client Attribute Values';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Attribute Value Set";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Attribute Code"; "Attribute Code")
                {
                    ApplicationArea = All;
                }
                field("Text Value"; "Text Value")
                {
                    ApplicationArea = All;
                }
                field("Datetime Value"; "Datetime Value")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Numeric Value"; "Numeric Value")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Boolean Value"; "Boolean Value")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

