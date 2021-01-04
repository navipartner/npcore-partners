page 6060109 "NPR TM Ticket Particpt. Wks."
{
    // TM1.16/TSA/20160816  CASE 245004 Transport TM1.16 - 19 July 2016

    Caption = 'Ticket Participant Wks.';
    DataCaptionFields = "Admission Code", "Notification Type", "Notification Address";
    PageType = List;
    SourceTable = "NPR TM Ticket Particpt. Wks.";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Applies To Schedule Entry No."; "Applies To Schedule Entry No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Applies To Schedule Entry No. field';
                }
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field("Notification Type"; "Notification Type")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Type field';
                }
                field("Ticket No."; "Ticket No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket No. field';
                }
                field("Notification Address"; "Notification Address")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Address field';
                }
                field("Notifcation Created At"; "Notifcation Created At")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Notifcation Created At field';
                }
                field("Notification Send Status"; "Notification Send Status")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Send Status field';
                }
                field("Notification Sent At"; "Notification Sent At")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Notification Sent At field';
                }
                field("Notification Sent By User"; "Notification Sent By User")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Notification Sent By User field';
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field("Blocked At"; "Blocked At")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Blocked At field';
                }
                field("Blocked By User"; "Blocked By User")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Blocked By User field';
                }
                field("Admission Description"; "Admission Description")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Admission Description field';
                }
                field("Det. Ticket Access Entry No."; "Det. Ticket Access Entry No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Det. Ticket Access Entry No. field';
                }
                field("Text 1"; "Text 1")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Text 1 field';
                }
                field("Text 2"; "Text 2")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Text 2 field';
                }
                field("Original Schedule Entry No."; "Original Schedule Entry No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Original Schedule Entry No. field';
                }
                field("Original Start Date"; "Original Start Date")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Original Start Date field';
                }
                field("Original Start Time"; "Original Start Time")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Original Start Time field';
                }
                field("Original End Date"; "Original End Date")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Original End Date field';
                }
                field("Original End Time"; "Original End Time")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Original End Time field';
                }
                field("New Schedule Entry No."; "New Schedule Entry No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the New Schedule Entry No. field';
                }
                field("New Start Date"; "New Start Date")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the New Start Date field';
                }
                field("New Start Time"; "New Start Time")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the New Start Time field';
                }
                field("New End Date"; "New End Date")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the New End Date field';
                }
                field("New End Time"; "New End Time")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the New End Time field';
                }
                field("Notification Method"; "Notification Method")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Method field';
                }
                field("Failed With Message"; "Failed With Message")
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

