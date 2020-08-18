table 6151012 "NpRv Voucher Type"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.48/MHA /20190123  CASE 341711 Added fields 75 "E-mail Template Code", 80 "SMS Template Code", 105 "Send Method via POS"
    // NPR5.48/MHA /20190213  CASE 345739 No. Series length has been increased from 10 to 20 in NAV2018 and newer
    // NPR5.49/MHA /20190228  CASE 342811 Added field 60 "Partner Code"
    // NPR5.50/MHA /20190426  CASE 353079 Added field 62 "Allow Top-up"
    // NPR5.53/THRO/20191216  CASE 382232 Added field 72 "Minimum Amount Issue"
    // NPR5.55/MHA /20200525  CASE 400120 Added field 1010 "Voucher Qty. (Closed)"

    Caption = 'Retail Voucher Type';
    DrillDownPageID = "NpRv Voucher Types";
    LookupPageID = "NpRv Voucher Types";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(5;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(10;"No. Series";Code[20])
        {
            Caption = 'No. Series';
            Description = 'NPR5.48';
            TableRelation = "No. Series";
        }
        field(15;"Arch. No. Series";Code[20])
        {
            Caption = 'Archivation No. Series';
            Description = 'NPR5.48';
            TableRelation = "No. Series";
        }
        field(20;"Reference No. Type";Option)
        {
            Caption = 'Reference No. Type';
            OptionCaption = 'Pattern,EAN13';
            OptionMembers = Pattern,EAN13;
        }
        field(25;"Reference No. Pattern";Code[20])
        {
            Caption = 'Reference No. Pattern';
        }
        field(40;"Valid Period";DateFormula)
        {
            Caption = 'Valid Period';
        }
        field(45;"Date Filter";Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(55;"Account No.";Code[20])
        {
            Caption = 'Account No.';
            TableRelation = "G/L Account" WHERE ("Account Type"=CONST(Posting),
                                                 "Direct Posting"=CONST(true));
        }
        field(60;"Partner Code";Code[20])
        {
            Caption = 'Partner Code';
            Description = 'NPR5.49';
            TableRelation = "NpRv Partner";
        }
        field(62;"Allow Top-up";Boolean)
        {
            Caption = 'Allow Top-up';
            Description = 'NPR5.50';
        }
        field(65;"Print Template Code";Code[20])
        {
            Caption = 'Print Template Code';
            TableRelation = "RP Template Header" WHERE ("Table ID"=CONST(6151013));
        }
        field(70;"Payment Type";Code[10])
        {
            Caption = 'Payment Type';
            TableRelation = "Payment Type POS";
        }
        field(72;"Minimum Amount Issue";Decimal)
        {
            Caption = 'Minimum Amount Issue';
        }
        field(75;"E-mail Template Code";Code[20])
        {
            Caption = 'E-mail Template Code';
            Description = 'NPR5.48';
            TableRelation = "E-mail Template Header" WHERE ("Table No."=CONST(6151013));
        }
        field(80;"SMS Template Code";Code[10])
        {
            Caption = 'SMS Template Code';
            Description = 'NPR5.48';
            TableRelation = "SMS Template Header" WHERE ("Table No."=CONST(6151013));
        }
        field(100;"Send Voucher Module";Code[20])
        {
            Caption = 'Send Voucher Module';
            TableRelation = "NpRv Voucher Module".Code WHERE (Type=CONST("Send Voucher"));
        }
        field(105;"Send Method via POS";Option)
        {
            Caption = 'Send Method via POS';
            Description = 'NPR5.48';
            OptionCaption = 'Print,E-mail,SMS,Ask';
            OptionMembers = Print,"E-mail",SMS,Ask;
        }
        field(110;"Validate Voucher Module";Code[20])
        {
            Caption = 'Validate Voucher Module';
            TableRelation = "NpRv Voucher Module".Code WHERE (Type=CONST("Validate Voucher"));
        }
        field(120;"Apply Payment Module";Code[20])
        {
            Caption = 'Apply Payment Module';
            TableRelation = "NpRv Voucher Module".Code WHERE (Type=CONST("Apply Payment"));
        }
        field(300;"Voucher Message";Text[250])
        {
            Caption = 'Voucher Message';
        }
        field(1000;"Voucher Qty. (Open)";Integer)
        {
            CalcFormula = Count("NpRv Voucher" WHERE ("Voucher Type"=FIELD(Code),
                                                      Open=CONST(true)));
            Caption = 'Voucher Qty. (Open)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1010;"Voucher Qty. (Closed)";Integer)
        {
            CalcFormula = Count("NpRv Voucher" WHERE ("Voucher Type"=FIELD(Code),
                                                      Open=CONST(false)));
            Caption = 'Voucher Qty. (Closed)';
            Description = 'NPR5.55';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1020;"Arch. Voucher Qty.";Integer)
        {
            CalcFormula = Count("NpRv Arch. Voucher" WHERE ("Voucher Type"=FIELD(Code)));
            Caption = 'Archived Voucher Qty.';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }
}

