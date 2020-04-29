page 6014606 "NPR Attribute Translations"
{
    // NPR4.11/TSA/20150422 CASE209946 - Entity and Shortcut Attributes

    Caption = 'Client Attribute Translations';
    PageType = List;
    SourceTable = "NPR Attribute Translation";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Attribute Code";"Attribute Code")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Language ID";"Language ID")
                {
                }
                field(Name;Name)
                {
                }
                field("Code Caption";"Code Caption")
                {
                }
                field("Filter Caption";"Filter Caption")
                {
                }
            }
        }
    }

    actions
    {
    }
}

