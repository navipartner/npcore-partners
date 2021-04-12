page 6150716 "NPR POS Unit Identity Card"
{
    // #Transcendence/TSA/20170221 CASE Trancendence Login

    Caption = 'POS Unit Identity Card';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Unit Identity";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Device ID"; Rec."Device ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Device ID field';
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
            }
            group(User)
            {
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the User ID field';
                }
            }
            group("POS Unit")
            {
                field("Default POS Unit No."; Rec."Default POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default POS Unit No. field';
                }
            }
            group(Device)
            {
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

    actions
    {
    }
}

