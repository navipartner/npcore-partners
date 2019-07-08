page 6014608 "NPR Attribute Values"
{
    // NPR4.11/TSA/20150422 CASE209946 - Entity and Shortcut Attributes

    Caption = 'Client Attribute Values';
    PageType = List;
    SourceTable = "NPR Attribute Value Set";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Attribute Code";"Attribute Code")
                {
                }
                field("Text Value";"Text Value")
                {
                }
                field("Datetime Value";"Datetime Value")
                {
                    Visible = false;
                }
                field("Numeric Value";"Numeric Value")
                {
                    Visible = false;
                }
                field("Boolean Value";"Boolean Value")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

