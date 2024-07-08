table 6150779 "NPR TM DeferRevenueReqDetail"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Ticketing Defer Revenue Request Details';

    fields
    {
        field(1; TokenID; Text[100])
        {
            Caption = 'Session Token ID';
            DataClassification = CustomerContent;
        }
        field(2; ItemNo; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(3; VariantCode; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(4; AdmissionCode; Code[20])
        {
            Caption = 'Admission Code';
            DataClassification = CustomerContent;
        }
        field(5; EntryNo; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; TicketNo; Code[20])
        {
            Caption = 'Ticket No.';
            DataClassification = CustomerContent;
        }
        field(20; TicketAccessEntryNo; Integer)
        {
            Caption = 'Ticket Access Entry No.';
            DataClassification = CustomerContent;
        }
        field(90; DocumentNo; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(95; DocumentLineNo; Integer)
        {
            Caption = 'Document Line No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; TokenID, ItemNo, VariantCode, AdmissionCode, EntryNo)
        {
            Clustered = true;
        }
    }

}