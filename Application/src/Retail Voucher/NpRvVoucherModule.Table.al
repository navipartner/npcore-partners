table 6151011 "NPR NpRv Voucher Module"
{
    Caption = 'Retail Voucher Module';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpRv Voucher Modules";
    LookupPageID = "NPR NpRv Voucher Modules";

    fields
    {
        field(1; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            NotBlank = true;
            OptionCaption = 'Send Voucher,Validate Voucher,Apply Payment';
            OptionMembers = "Send Voucher","Validate Voucher","Apply Payment";
        }
        field(5; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(50; "Event Codeunit ID"; Integer)
        {
            Caption = 'Event Codeunit ID';
            DataClassification = CustomerContent;
        }
        field(55; "Event Codeunit Name"; Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Codeunit),
                                                             "Object ID" = FIELD("Event Codeunit ID")));
            Caption = 'Event Codeunit Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; Type, "Code")
        {
        }
    }
}

