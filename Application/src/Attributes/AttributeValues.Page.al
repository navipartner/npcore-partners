page 6014608 "NPR Attribute Values"
{
    Extensible = False;
    // NPR4.11/TSA/20150422 CASE209946 - Entity and Shortcut Attributes

    Caption = 'Client Attribute Values';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Attribute Value Set";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Attribute Code"; Rec."Attribute Code")
                {

                    ToolTip = 'Specifies the value of the Attribute Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Text Value"; Rec."Text Value")
                {

                    ToolTip = 'Specifies the value of the Text Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Datetime Value"; Rec."Datetime Value")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Datetime Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Numeric Value"; Rec."Numeric Value")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Numeric Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Boolean Value"; Rec."Boolean Value")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Boolean Value field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

