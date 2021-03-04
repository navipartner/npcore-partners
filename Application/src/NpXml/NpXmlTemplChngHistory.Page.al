page 6151563 "NPR NpXml Templ. Chng. History"
{
    Caption = 'NpXml Template Change History';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR NpXml Template History";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Version Description"; "Version Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Version Description field';
                }
                field("Template Version No."; "Template Version No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Template Version No. field';
                }
                field("Event Type"; "Event Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Event Type field';
                }
                field("Changed by"; "Changed by")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Changed by field';
                }
                field("Change at"; "Change at")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Change at field';
                }
            }
        }
    }
}

