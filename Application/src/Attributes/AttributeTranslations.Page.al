page 6014606 "NPR Attribute Translations"
{
    // NPR4.11/TSA/20150422 CASE209946 - Entity and Shortcut Attributes

    Caption = 'Client Attribute Translations';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Attribute Code field';
                }
                field("Language ID"; "Language ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Language ID field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Code Caption"; "Code Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code Caption field';
                }
                field("Filter Caption"; "Filter Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Filter Caption field';
                }
            }
        }
    }

    actions
    {
    }
}

