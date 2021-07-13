page 6151563 "NPR NpXml Templ. Chng. History"
{
    Caption = 'NpXml Template Change History';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR NpXml Template History";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Description; Rec.Description)
                {

                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Version Description"; Rec."Version Description")
                {

                    ToolTip = 'Specifies the value of the Version Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Template Version No."; Rec."Template Version No.")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Template Version No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Event Type"; Rec."Event Type")
                {

                    ToolTip = 'Specifies the value of the Event Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Changed by"; Rec."Changed by")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Changed by field';
                    ApplicationArea = NPRRetail;
                }
                field("Change at"; Rec."Change at")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Change at field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

