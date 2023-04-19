﻿page 6059898 "NPR Data Log Records"
{
    Extensible = False;
    Caption = 'Data Log Records';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Data Log Record";
    SourceTableView = sorting("Entry No.") order(descending);
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Log Date"; Rec."Log Date")
                {
                    ToolTip = 'Specifies the value of the Log Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Table ID"; Rec."Table ID")
                {
                    ToolTip = 'Specifies the value of the Table ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Table Name"; Rec."Table Name")
                {
                    ToolTip = 'Specifies the value of the Table Name field';
                    ApplicationArea = NPRRetail;
                }
                field("RecordId"; Format(Rec."Record ID"))
                {
                    Caption = 'Record ID';
                    ToolTip = 'Specifies the value of the Record ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Old Record ID"; Rec."Old Record ID")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Old Record ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Type of Change"; Rec."Type of Change")
                {
                    ToolTip = 'Specifies the value of the Type of Change field';
                    ApplicationArea = NPRRetail;
                }
                field("User ID"; Rec."User ID")
                {
                    ToolTip = 'Specifies the value of the User ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies an internal entry number assigned by BC when the entry was created.';
                    ApplicationArea = NPRRetail;
                }
            }
            part(Control6150622; "NPR Data Log Records Subform")
            {
                SubPageLink = "Data Log Record Entry No." = FIELD("Entry No.");
                ApplicationArea = NPRRetail;
            }
        }
    }
}
