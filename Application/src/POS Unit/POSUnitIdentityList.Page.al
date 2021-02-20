page 6150715 "NPR POS Unit Identity List"
{
    Caption = 'POS Unit Identity List';
    CardPageID = "NPR POS Unit Identity Card";
    PageType = List;
    SourceTable = "NPR POS Unit Identity";
    UsageCategory = Administration;
    ApplicationArea = All;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Device ID"; Rec."Device ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Device ID field';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("Default POS Unit No."; Rec."Default POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default POS Unit No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Host Name"; Rec."Host Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Host Name field';
                }
                field("Session Type"; Rec."Session Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Session Type field';
                }
                field("Select POS Using"; Rec."Select POS Using")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Select POS Using field';
                }
                field("Created At"; Rec."Created At")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Created At field';
                }
                field("Last Session At"; Rec."Last Session At")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Session At field';
                }
            }
        }
    }
}

