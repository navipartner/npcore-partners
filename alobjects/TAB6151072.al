table 6151072 "GDPR Anonymization Request"
{
    // NPR5.54/TSA /20200324 CASE 389817 Initial Version

    Caption = 'GDPR Anonymization Request';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(10;"Customer No.";Code[20])
        {
            Caption = 'Customer No.';
        }
        field(15;"Contact No.";Code[20])
        {
            Caption = 'Contact No.';
        }
        field(16;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Company,Person';
            OptionMembers = COMPANY,PERSON;
        }
        field(20;Status;Option)
        {
            Caption = 'Status';
            OptionCaption = 'New,Pending,Anonymized';
            OptionMembers = NEW,PENDING,ANONYMIZED;
        }
        field(25;"Request Received";DateTime)
        {
            Caption = 'Request Received';
        }
        field(30;"Processed At";DateTime)
        {
            Caption = 'Processed At';
        }
        field(35;"Log Count";Integer)
        {
            CalcFormula = Count("Customer GDPR Log Entries" WHERE ("Customer No"=FIELD("Customer No.")));
            Caption = 'Log Count';
            Editable = false;
            FieldClass = FlowField;
        }
        field(40;Reason;Text[200])
        {
            Caption = 'Reason';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

