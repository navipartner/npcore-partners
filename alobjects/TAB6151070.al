table 6151070 "Customer GDPR Log Entries"
{
    // NPR5.52/ZESO/20190925 CASE 358656 Object Created
    // NPR5.55/ZESO/20200427 CASE 401981 Added field 10 Open Journal Entries/Statement

    Caption = 'Customer GDPR Log Entries';

    fields
    {
        field(1;"Entry No";Integer)
        {
            Caption = 'Entry No';
        }
        field(2;"Customer No";Code[20])
        {
            Caption = 'Customer No';
        }
        field(3;Status;Option)
        {
            Caption = 'Status';
            OptionCaption = 'Anonymised,Could Not be anonymised';
            OptionMembers = Anonymised,"Could Not be anonymised";
        }
        field(4;"Open Sales Documents";Boolean)
        {
            Caption = 'Open Sales Documents';
        }
        field(5;"Open Cust. Ledger Entry";Boolean)
        {
            Caption = 'Open Cust. Ledger Entry';
        }
        field(6;"Has transactions";Boolean)
        {
            Caption = 'Has transactions';
        }
        field(7;"Customer is a Member";Boolean)
        {
            Caption = 'Customer is a Member';
        }
        field(8;"Log Entry Date Time";DateTime)
        {
            Caption = 'Log Entry Date Time';
        }
        field(9;"Anonymized By";Code[50])
        {
            Caption = 'Anonymized By';
        }
        field(10;"Open Journal Entries/Statement";Boolean)
        {
            Caption = 'Open Journal Entries/Statement';
        }
    }

    keys
    {
        key(Key1;"Entry No")
        {
        }
    }

    fieldgroups
    {
    }
}

