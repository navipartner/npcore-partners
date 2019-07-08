page 6060109 "TM Ticket Participant Wks."
{
    // TM1.16/TSA/20160816  CASE 245004 Transport TM1.16 - 19 July 2016

    Caption = 'Ticket Participant Wks.';
    DataCaptionFields = "Admission Code","Notification Type","Notification Address";
    PageType = List;
    SourceTable = "TM Ticket Participant Wks.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Applies To Schedule Entry No.";"Applies To Schedule Entry No.")
                {
                }
                field("Admission Code";"Admission Code")
                {
                }
                field("Notification Type";"Notification Type")
                {
                }
                field("Ticket No.";"Ticket No.")
                {
                }
                field("Notification Address";"Notification Address")
                {
                }
                field("Notifcation Created At";"Notifcation Created At")
                {
                    Editable = false;
                }
                field("Notification Send Status";"Notification Send Status")
                {
                }
                field("Notification Sent At";"Notification Sent At")
                {
                    Editable = false;
                }
                field("Notification Sent By User";"Notification Sent By User")
                {
                    Editable = false;
                }
                field(Blocked;Blocked)
                {
                }
                field("Blocked At";"Blocked At")
                {
                    Editable = false;
                }
                field("Blocked By User";"Blocked By User")
                {
                    Editable = false;
                }
                field("Admission Description";"Admission Description")
                {
                    Visible = false;
                }
                field("Det. Ticket Access Entry No.";"Det. Ticket Access Entry No.")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Text 1";"Text 1")
                {
                    Visible = false;
                }
                field("Text 2";"Text 2")
                {
                    Visible = false;
                }
                field("Original Schedule Entry No.";"Original Schedule Entry No.")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Original Start Date";"Original Start Date")
                {
                    Editable = false;
                }
                field("Original Start Time";"Original Start Time")
                {
                    Editable = false;
                }
                field("Original End Date";"Original End Date")
                {
                    Editable = false;
                }
                field("Original End Time";"Original End Time")
                {
                    Editable = false;
                }
                field("New Schedule Entry No.";"New Schedule Entry No.")
                {
                    Visible = false;
                }
                field("New Start Date";"New Start Date")
                {
                    Editable = false;
                }
                field("New Start Time";"New Start Time")
                {
                    Editable = false;
                }
                field("New End Date";"New End Date")
                {
                    Editable = false;
                }
                field("New End Time";"New End Time")
                {
                    Editable = false;
                }
                field("Notification Method";"Notification Method")
                {
                }
                field("Failed With Message";"Failed With Message")
                {
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
        TicketParticipantWks: Record "TM Ticket Participant Wks.";
        TicketNotifyParticipant: Codeunit "TM Ticket Notify Participant";
    begin

        CurrPage.SetSelectionFilter (TicketParticipantWks);
        TicketNotifyParticipant.NotifyRecipients (TicketParticipantWks);
    end;
}

