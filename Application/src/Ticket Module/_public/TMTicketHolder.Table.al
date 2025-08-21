table 6151179 "NPR TM TicketHolder"
{
    Caption = 'Ticket Holder';
    TableType = Temporary;
    Extensible = false;

    fields
    {
        field(1; ReservationToken; Text[100])
        {
            Caption = 'Reservation Token';
            DataClassification = SystemMetadata;
        }
        field(2; TicketHolderName; Text[100])
        {
            Caption = 'Tikcet Holder Name';
            DataClassification = CustomerContent;
        }
        field(3; NotificationMethod; Enum "NPR TM NotificationMethod")
        {
            Caption = 'Notification Method';
            DataClassification = CustomerContent;
        }
        field(4; NotificationAddress; Text[100])
        {
            Caption = 'Notification Address';
            DataClassification = CustomerContent;
        }
        field(5; TicketHolderPreferredLanguage; Code[10])
        {
            Caption = 'Ticket Holder Preferred Language';
            DataClassification = CustomerContent;
            TableRelation = Language.Code;
        }
    }

    keys
    {
        key(PK; ReservationToken)
        {
            Clustered = true;
        }
    }

    internal procedure FromReservationRequest(TicketReservationReq: Record "NPR TM Ticket Reservation Req.")
    begin
        Rec.ReservationToken := TicketReservationReq."Session Token ID";
        Rec.TicketHolderName := TicketReservationReq.TicketHolderName;
        Rec.NotificationMethod := TicketReservationReq."Notification Method";
        Rec.NotificationAddress := TicketReservationReq."Notification Address";
        Rec.TicketHolderPreferredLanguage := TicketReservationReq.TicketHolderPreferredLanguage;
    end;
}