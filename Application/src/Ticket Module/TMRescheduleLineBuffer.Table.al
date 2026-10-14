table 6059992 "NPR TM Reschedule Line Buffer"
{
    Access = Internal;
    TableType = Temporary;
    Caption = 'Reschedule Line Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; EntryNo; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; OriginalToken; Text[100])
        {
            Caption = 'Original Token';
            DataClassification = CustomerContent;
        }
        field(11; CurrentToken; Text[100])
        {
            Caption = 'Current Token';
            DataClassification = CustomerContent;
        }
        field(12; LineReferenceNo; Integer)
        {
            Caption = 'Line Reference No.';
            DataClassification = CustomerContent;
        }
        field(13; CurrentPrimaryEntryNo; Integer)
        {
            Caption = 'Current Primary Entry No.';
            DataClassification = CustomerContent;
        }
        field(14; CurrentPrimarySystemId; Guid)
        {
            Caption = 'Current Primary System Id';
            DataClassification = CustomerContent;
        }
        field(20; ItemNo; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(21; VariantCode; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(22; Quantity; Integer)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(23; ValidFromDate; Date)
        {
            Caption = 'Valid From Date';
            DataClassification = CustomerContent;
        }
        field(24; ValidToDate; Date)
        {
            Caption = 'Valid To Date';
            DataClassification = CustomerContent;
        }
        field(30; AdmissionCode; Code[20])
        {
            Caption = 'Admission Code';
            DataClassification = CustomerContent;
        }
        field(31; AdmissionDescription; Text[50])
        {
            Caption = 'Admission Description';
            DataClassification = CustomerContent;
        }
        field(32; CurrentExtScheduleEntryNo; Integer)
        {
            Caption = 'Current Ext. Schedule Entry No.';
            DataClassification = CustomerContent;
        }
        field(40; Ambiguous; Boolean)
        {
            Caption = 'Ambiguous';
            DataClassification = CustomerContent;
        }
        field(41; RescheduleAllowed; Boolean)
        {
            Caption = 'Reschedule Allowed';
            DataClassification = CustomerContent;
        }
        field(42; RefusalReason; Enum "NPR TM Reschedule Refusal")
        {
            Caption = 'Refusal Reason';
            DataClassification = CustomerContent;
        }
        field(50; RequestedExtScheduleEntryNo; Integer)
        {
            Caption = 'Requested Ext. Schedule Entry No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; EntryNo)
        {
            Clustered = true;
        }
        key(Key2; CurrentPrimaryEntryNo, AdmissionCode)
        {
        }
    }
}
