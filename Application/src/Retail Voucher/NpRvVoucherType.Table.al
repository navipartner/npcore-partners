table 6151012 "NPR NpRv Voucher Type"
{
    Caption = 'Retail Voucher Type';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpRv Voucher Types";
    LookupPageID = "NPR NpRv Voucher Types";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(5; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            TableRelation = "No. Series";
        }
        field(15; "Arch. No. Series"; Code[20])
        {
            Caption = 'Archivation No. Series';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            TableRelation = "No. Series";
        }
        field(20; "Reference No. Type"; Option)
        {
            Caption = 'Reference No. Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Pattern,EAN13';
            OptionMembers = Pattern,EAN13;
        }
        field(25; "Reference No. Pattern"; Code[20])
        {
            Caption = 'Reference No. Pattern';
            DataClassification = CustomerContent;
        }
        field(40; "Valid Period"; DateFormula)
        {
            Caption = 'Valid Period';
            DataClassification = CustomerContent;
        }
        field(45; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(55; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" WHERE("Account Type" = CONST(Posting),
                                                 "Direct Posting" = CONST(true));
        }
        field(60; "Partner Code"; Code[20])
        {
            Caption = 'Partner Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.49';
            TableRelation = "NPR NpRv Partner";
        }
        field(62; "Allow Top-up"; Boolean)
        {
            Caption = 'Allow Top-up';
            DataClassification = CustomerContent;
            Description = 'NPR5.50';
        }
        field(65; "Print Template Code"; Code[20])
        {
            Caption = 'Print Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR RP Template Header" WHERE("Table ID" = CONST(6151013));
        }
        field(70; "Payment Type"; Code[10])
        {
            Caption = 'Payment Type';
            DataClassification = CustomerContent;
            TableRelation = "NPR Payment Type POS";
        }
        field(72; "Minimum Amount Issue"; Decimal)
        {
            Caption = 'Minimum Amount Issue';
            DataClassification = CustomerContent;
        }
        field(75; "E-mail Template Code"; Code[20])
        {
            Caption = 'E-mail Template Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            TableRelation = "NPR E-mail Template Header" WHERE("Table No." = CONST(6151013));
        }
        field(80; "SMS Template Code"; Code[10])
        {
            Caption = 'SMS Template Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            TableRelation = "NPR SMS Template Header" WHERE("Table No." = CONST(6151013));
        }
        field(100; "Send Voucher Module"; Code[20])
        {
            Caption = 'Send Voucher Module';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpRv Voucher Module".Code WHERE(Type = CONST("Send Voucher"));
        }
        field(105; "Send Method via POS"; Option)
        {
            Caption = 'Send Method via POS';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            OptionCaption = 'Print,E-mail,SMS,Ask';
            OptionMembers = Print,"E-mail",SMS,Ask;
        }
        field(110; "Validate Voucher Module"; Code[20])
        {
            Caption = 'Validate Voucher Module';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpRv Voucher Module".Code WHERE(Type = CONST("Validate Voucher"));
        }
        field(120; "Apply Payment Module"; Code[20])
        {
            Caption = 'Apply Payment Module';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpRv Voucher Module".Code WHERE(Type = CONST("Apply Payment"));
        }
        field(300; "Voucher Message"; Text[250])
        {
            Caption = 'Voucher Message';
            DataClassification = CustomerContent;
        }
        field(1000; "Voucher Qty. (Open)"; Integer)
        {
            CalcFormula = Count("NPR NpRv Voucher" WHERE("Voucher Type" = FIELD(Code),
                                                      Open = CONST(true)));
            Caption = 'Voucher Qty. (Open)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1010; "Voucher Qty. (Closed)"; Integer)
        {
            CalcFormula = Count("NPR NpRv Voucher" WHERE("Voucher Type" = FIELD(Code),
                                                      Open = CONST(false)));
            Caption = 'Voucher Qty. (Closed)';
            Description = 'NPR5.55';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1020; "Arch. Voucher Qty."; Integer)
        {
            CalcFormula = Count("NPR NpRv Arch. Voucher" WHERE("Voucher Type" = FIELD(Code)));
            Caption = 'Archived Voucher Qty.';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }
}

