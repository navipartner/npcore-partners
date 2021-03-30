page 6060109 "NPR TM Ticket Particpt. Wks."
{

    Caption = 'Ticket Participant Wks.';
    DataCaptionFields = "Admission Code", "Notification Type", "Notification Address";
    PageType = List;
    SourceTable = "NPR TM Ticket Particpt. Wks.";
    UsageCategory = None;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Applies To Schedule Entry No."; Rec."Applies To Schedule Entry No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Applies To Schedule Entry No. field';
                }
                field("Admission Code"; Rec."Admission Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field("Notification Type"; Rec."Notification Type")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Type field';
                }
                field("Ticket No."; Rec."Ticket No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket No. field';
                }
                field("Notification Address"; Rec."Notification Address")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Address field';
                }
                field("Notifcation Created At"; Rec."Notifcation Created At")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Notifcation Created At field';
                }
                field("Notification Send Status"; Rec."Notification Send Status")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Send Status field';
                }
                field("Notification Sent At"; Rec."Notification Sent At")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Notification Sent At field';
                }
                field("Notification Sent By User"; Rec."Notification Sent By User")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Notification Sent By User field';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field("Blocked At"; Rec."Blocked At")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Blocked At field';
                }
                field("Blocked By User"; Rec."Blocked By User")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Blocked By User field';
                }
                field("Admission Description"; Rec."Admission Description")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Admission Description field';
                }
                field("Det. Ticket Access Entry No."; Rec."Det. Ticket Access Entry No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Det. Ticket Access Entry No. field';
                }
                field("Text 1"; Rec."Text 1")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Text 1 field';
                }
                field("Text 2"; Rec."Text 2")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Text 2 field';
                }
                field("Original Schedule Entry No."; Rec."Original Schedule Entry No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Original Schedule Entry No. field';
                }
                field("Original Start Date"; Rec."Original Start Date")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Original Start Date field';
                }
                field("Original Start Time"; Rec."Original Start Time")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Original Start Time field';
                }
                field("Original End Date"; Rec."Original End Date")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Original End Date field';
                }
                field("Original End Time"; Rec."Original End Time")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Original End Time field';
                }
                field("New Schedule Entry No."; Rec."New Schedule Entry No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the New Schedule Entry No. field';
                }
                field("New Start Date"; Rec."New Start Date")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the New Start Date field';
                }
                field("New Start Time"; Rec."New Start Time")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the New Start Time field';
                }
                field("New End Date"; Rec."New End Date")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the New End Date field';
                }
                field("New End Time"; Rec."New End Time")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the New End Time field';
                }
                field("Notification Method"; Rec."Notification Method")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Method field';
                }
                field("Failed With Message"; Rec."Failed With Message")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Failed With Message field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Send Notification")
            {
                ToolTip = 'Send notification to ticket holder.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Send Notification';
                Image = SendTo;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;


                trigger OnAction()
                begin

                    SendNotifications();
                end;
            }
        }
    }

    local procedure SendNotifications()
    var
        TicketParticipantWks: Record "NPR TM Ticket Particpt. Wks.";
        TicketNotifyParticipant: Codeunit "NPR TM Ticket Notify Particpt.";
    begin

        CurrPage.SetSelectionFilter(TicketParticipantWks);
        TicketNotifyParticipant.NotifyRecipients(TicketParticipantWks);
    end;
}

