page 6014606 "NPR Attribute Translations"
{
    // NPR4.11/TSA/20150422 CASE209946 - Entity and Shortcut Attributes

    Caption = 'Client Attribute Translations';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Attribute Translation";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Attribute Code"; "Attribute Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Language ID"; "Language ID")
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field("Code Caption"; "Code Caption")
                {
                    ApplicationArea = All;
                }
                field("Filter Caption"; "Filter Caption")
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

