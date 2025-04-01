table 6150987 "NPR SGEntryLog"
{
    DataClassification = CustomerContent;
    Access = Internal;
    Caption = 'Speedgate Entry Log';
    fields
    {
        field(1; EntryNo; Integer)
        {
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }

        field(2; EntryStatus; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry Status';
            OptionMembers = INITIALIZED,DENIED_BY_GATE,PERMITTED_BY_GATE,ADMITTED,DENIED;
            OptionCaption = ' ,Denied by Gate,Permitted by Gate,Admitted,Denied';
        }

        field(10; Token; GUID)
        {
            DataClassification = CustomerContent;
            Caption = 'Token';
        }

        field(20; ReferenceNo; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Reference No';
        }

        field(30; ScannerId; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Scanner Id';
        }

        field(31; ScannerDescription; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Scanner Description';
        }

        field(40; AdmissionCode; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Admission Code';
        }
        field(50; AdmittedAt; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Admitted At';
        }
        field(55; AdmittedReferenceNo; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Admitted Reference No';
        }
        field(56; AdmittedReferenceId; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Admitted Reference Id';
        }
        field(100; ReferenceNumberType; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry Type';
            OptionMembers = REJECTED,UNKNOWN,TICKET,MEMBER_CARD,WALLET,DOC_LX_CITY_CARD,TICKET_REQUEST;
            OptionCaption = 'Rejected,Unknown,Ticket,Member Card,Wallet,City Card,Ticket Request';
        }

        field(105; MemberCardLogEntryNo; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Member Card Log Entry No';
        }

        field(110; EntityId; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Entity Id';
        }
        field(115; ApiErrorNumber; integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Api Error Number';
        }

        field(117; ApiErrorMessage; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Api Error Message';
        }

        field(120; ExtraEntityTableId; integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Extra Entity Table Id';
        }
        field(125; ExtraEntityId; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Extra Entity Id';
        }

        field(130; ProfileLineId; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Profile Line Id';
        }
    }

    keys
    {
        key(Key1; EntryNo)
        {
            Clustered = true;
        }

        key(Key2; Token)
        {
        }

        key(Key3; ReferenceNo)
        {
        }

        key(Key4; ScannerId)
        {
        }

        key(Key5; AdmittedReferenceNo)
        {
        }
    }


}