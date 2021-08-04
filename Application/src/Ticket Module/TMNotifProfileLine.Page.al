page 6014563 "NPR TM Notif. Profile Line"
{
    Caption = 'Ticket Notification Profile Line';
    PageType = ListPart;
    RefreshOnActivate = true;
    SourceTable = "NPR TM Notif. Profile Line";
    ShowFilter = false;
    UsageCategory = None;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Profile Code"; Rec."Profile Code")
                {
                    ToolTip = 'Specifies the value of the Profile Code field';
                    ApplicationArea = NRTTicketAdvanced;
                    Visible = false;
                }
                field("Line No."; Rec."Line No.")
                {
                    ToolTip = 'Specifies the value of the Line No. field';
                    ApplicationArea = NRTTicketAdvanced;
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NRTTicketAdvanced;
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NRTTicketAdvanced;
                }
                field("Notification Trigger"; Rec."Notification Trigger")
                {
                    ToolTip = 'Specifies the value of the Notification Trigger field';
                    ApplicationArea = NRTTicketAdvanced;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ToolTip = 'Specifies the value of the Unit of Measure field';
                    ApplicationArea = NRTTicketAdvanced;
                }
                field(Units; Rec.Units)
                {
                    ToolTip = 'Specifies the value of the Units field';
                    ApplicationArea = NRTTicketAdvanced;
                }
                field("Template Code"; Rec."Template Code")
                {
                    ToolTip = 'Specifies the value of the Template Code field';
                    ApplicationArea = NRTTicketAdvanced;
                }
                field("Notification Engine"; Rec."Notification Engine")
                {
                    ToolTip = 'Specifies the value of the Notification Engine field';
                    ApplicationArea = NRTTicketAdvanced;
                }
                field("Notification Extra Text"; Rec."Notification Extra Text")
                {
                    ToolTip = 'Specifies the value of the Notification Extra Text field';
                    ApplicationArea = NRTTicketAdvanced;
                }
            }
        }

    }

}