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
                    ToolTip = 'Specifies the value of the Attribute Code field';
                }
                field("Text Value"; "Text Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Text Value field';
                }
                field("Datetime Value"; "Datetime Value")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Datetime Value field';
                }
                field("Numeric Value"; "Numeric Value")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Numeric Value field';
                }
                field("Boolean Value"; "Boolean Value")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Boolean Value field';
                }
            }
        }
    }

    actions
    {
    }
}

