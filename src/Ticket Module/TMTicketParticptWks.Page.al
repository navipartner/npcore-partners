page 6060109 "NPR TM Ticket Particpt. Wks."
{
    // TM1.16/TSA/20160816  CASE 245004 Transport TM1.16 - 19 July 2016

    Caption = 'Ticket Participant Wks.';
    DataCaptionFields = "Admission Code", "Notification Type", "Notification Address";
    PageType = List;
    SourceTable = "NPR TM Ticket Particpt. Wks.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Applies To Schedule Entry No."; "Applies To Schedule Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = All;
                }
                field("Notification Type"; "Notification Type")
                {
                    ApplicationArea = All;
                }
                field("Ticket No."; "Ticket No.")
                {
                    ApplicationArea = All;
                }
                field("Notification Address"; "Notification Address")
                {
                    ApplicationArea = All;
                }
                field("Notifcation Created At"; "Notifcation Created At")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Notification Send Status"; "Notification Send Status")
                {
                    ApplicationArea = All;
                }
                field("Notification Sent At"; "Notification Sent At")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Notification Sent By User"; "Notification Sent By User")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                }
                field("Blocked At"; "Blocked At")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Blocked By User"; "Blocked By User")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Admission Description"; "Admission Description")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Det. Ticket Access Entry No."; "Det. Ticket Access Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Text 1"; "Text 1")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Text 2"; "Text 2")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Original Schedule Entry No."; "Original Schedule Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Original Start Date"; "Original Start Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Original Start Time"; "Original Start Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Original End Date"; "Original End Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Original End Time"; "Original End Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("New Schedule Entry No."; "New Schedule Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("New Start Date"; "New Start Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("New Start Time"; "New Start Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("New End Date"; "New End Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("New End Time"; "New End Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Notification Method"; "Notification Method")
                {
                    ApplicationArea = All;
                }
                field("Failed With Message"; "Failed With Message")
                {
                    ApplicationArea = All;
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
                ApplicationArea=All;

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

