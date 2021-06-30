page 6059898 "NPR Data Log Records"
{
    // DL1.00/MH/20140801  NP-AddOn: Data Log
    //   - This Page contains Record ID's of logged Record Changes.

    Caption = 'Data Log Records';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Data Log Record";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Log Date"; Rec."Log Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Log Date field';
                }
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table ID field';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Name field';
                }
                field("RecordId"; Format(Rec."Record ID"))
                {
                    ApplicationArea = All;
                    Caption = 'Record ID';
                    ToolTip = 'Specifies the value of the Record ID field';
                }
                field("Old Record ID"; Rec."Old Record ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Old Record ID field';
                }
                field("Type of Change"; Rec."Type of Change")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type of Change field';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
            }
            part(Control6150622; "NPR Data Log Records Subform")
            {
                SubPageLink = "Data Log Record Entry No." = FIELD("Entry No.");
                ApplicationArea = All;
            }
        }
    }

    actions
    {
    }
}

