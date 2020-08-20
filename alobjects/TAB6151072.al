table 6151072 "GDPR Anonymization Request"
{
    // NPR5.54/TSA /20200324 CASE 389817 Initial Version
    // NPR5.55/TSA /20200715 CASE 388813 Added status Approved, Declined, Rejected

    Caption = 'GDPR Anonymization Request';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
        }
        field(15; "Contact No."; Code[20])
        {
            Caption = 'Contact No.';
            DataClassification = CustomerContent;
        }
        field(16; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Company,Person';
            OptionMembers = COMPANY,PERSON;
        }
        field(20; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionCaption = 'New,Pending,Anonymized,Approved,Declined,Rejected';
            OptionMembers = NEW,PENDING,ANONYMIZED,APPROVED,DECLINED,REJECTED;
        }
        field(25; "Request Received"; DateTime)
        {
            Caption = 'Request Received';
            DataClassification = CustomerContent;
        }
        field(30; "Processed At"; DateTime)
        {
            Caption = 'Processed At';
            DataClassification = CustomerContent;
        }
        field(35; "Log Count"; Integer)
        {
            CalcFormula = Count ("Customer GDPR Log Entries" WHERE("Customer No" = FIELD("Customer No.")));
            Caption = 'Log Count';
            Editable = false;
            FieldClass = FlowField;
        }
        field(40; Reason; Text[200])
        {
            Caption = 'Reason';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

