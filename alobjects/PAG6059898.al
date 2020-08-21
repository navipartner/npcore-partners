page 6059898 "Data Log Records"
{
    // DL1.00/MH/20140801  NP-AddOn: Data Log
    //   - This Page contains Record ID's of logged Record Changes.

    Caption = 'Data Log Records';
    Editable = false;
    PageType = List;
    SourceTable = "Data Log Record";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Log Date"; "Log Date")
                {
                    ApplicationArea = All;
                }
                field("Table ID"; "Table ID")
                {
                    ApplicationArea = All;
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                }
                field("FORMAT(""Record ID"")"; Format("Record ID"))
                {
                    ApplicationArea = All;
                    Caption = 'Record ID';
                }
                field("Old Record ID"; "Old Record ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Type of Change"; "Type of Change")
                {
                    ApplicationArea = All;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
            }
            part(Control6150622; "Data Log Records Subform")
            {
                SubPageLink = "Data Log Record Entry No." = FIELD("Entry No.");
            }
        }
    }

    actions
    {
    }
}

