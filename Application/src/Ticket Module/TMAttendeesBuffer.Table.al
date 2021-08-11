table 6014594 "NPR TM Attendees Buffer"
{
    DataClassification = CustomerContent;
    Caption = 'List of Attendees';

    fields
    {
        field(1; EntryNo; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; TicketNumber; Code[20])
        {
            Caption = 'Ticket No.';
            DataClassification = CustomerContent;
        }
        field(20; TicketStatus; Enum "NPR TM Attendee Status")
        {
            Caption = 'Ticket Status';
            DataClassification = CustomerContent;
        }
        field(30; AdmissionCode; Code[20])
        {
            Caption = 'Admission Code';
            DataClassification = CustomerContent;
        }
        field(35; ScheduleCode; Code[20])
        {
            Caption = 'Schedule Code';
            DataClassification = CustomerContent;
        }
        field(40; AdmissionStartDate; Date)
        {
            Caption = 'Admission Start Date';
            DataClassification = CustomerContent;
        }
        field(45; AdmissionStartTime; Time)
        {
            Caption = 'Admission Start Time';
            DataClassification = CustomerContent;
        }
        field(49; ExternalScheduleEntryNumber; Integer)
        {
            Caption = 'External Schedule Entry No.';
            DataClassification = CustomerContent;
        }
        field(50; MemberNumber; Code[20])
        {
            Caption = 'Member No.';
            DataClassification = CustomerContent;
        }
        field(53; CustomerNumber; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
        }
        field(56; OrderNumber; Code[20])
        {
            Caption = 'Order No.';
            DataClassification = CustomerContent;
        }
        field(60; NotificationAddress; Text[100])
        {
            Caption = 'Notification Address';
            DataClassification = CustomerContent;
        }
        field(70; AdmittedDate; Date)
        {
            Caption = 'Admitted Date';
            DataClassification = CustomerContent;
        }
        field(72; AdmittedTime; Time)
        {
            Caption = 'Admitted Time';
            DataClassification = CustomerContent;
        }
        field(80; DisplayName; Text[100])
        {
            Caption = 'Display Name';
            DataClassification = CustomerContent;
        }
        field(81; Address; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(82; Address2; Text[50])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(83; ZipCode; Code[20])
        {
            Caption = 'Zip Code';
            DataClassification = CustomerContent;
        }
        field(84; City; Text[50])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(85; CountryCode; Code[10])
        {
            Caption = 'Country Code';
            DataClassification = CustomerContent;
        }
        field(88; Email; Text[80])
        {
            Caption = 'E-Mail';
            DataClassification = CustomerContent;
        }
        field(89; PhoneNumber; Text[30])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(NPR_PK; EntryNo)
        {
            Clustered = true;
        }
    }

}