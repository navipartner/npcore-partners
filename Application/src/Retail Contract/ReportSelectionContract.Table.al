table 6014520 "NPR Report Selection: Contract"
{
    Caption = 'Report Selection - Contract';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Repairs are not supported in core anymore.';

    fields
    {
        field(1; "Report Type"; Option)
        {
            Caption = 'Report Type';
            InitValue = "Insurance Offer";
            OptionCaption = ',Insurance Offer,Insurance Voucher,Guarantee Certificate,,,Repair reminder,Delivery note,Customer receipt,Repair guarantee,Repair finished,Repair offer,Rental contract,Purchase contract,Customer letter,Contract financing,Signs,Quote,Repair Label';
            OptionMembers = ,"Insurance Offer",Police,"Guarantee Certificate",,,"Reparation Reminder","Shipment note","Customer receipt","Repair warranty","Repair finished","Repair offer","Rental contract","Purchase contract",CustLetter,"Contract financing",Signs,Quote,"Repair Label";
            DataClassification = CustomerContent;
        }
        field(2; Sequence; Code[10])
        {
            Caption = 'Sequence';
            Numeric = true;
            DataClassification = CustomerContent;
        }
        field(3; "Report ID"; Integer)
        {
            Caption = 'Report ID';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Report));
            DataClassification = CustomerContent;
        }
        field(4; "Report Name"; Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Report),
                                                             "Object ID" = FIELD("Report ID")));
            Caption = 'Report Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; "XML Port ID"; Integer)
        {
            Caption = 'XML Port ID';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(XMLport));
            DataClassification = CustomerContent;
        }
        field(6; "XML Port Name"; Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(XMLport),
                                                             "Object ID" = FIELD("XML Port ID")));
            Caption = 'XML Port Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(7; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            TableRelation = "NPR Register";
            DataClassification = CustomerContent;
        }
        field(8; "Codeunit ID"; Integer)
        {
            Caption = 'Codeunit ID';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit));
            DataClassification = CustomerContent;
        }
        field(9; "Codeunit Name"; Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Codeunit),
                                                             "Object ID" = FIELD("Codeunit ID")));
            Caption = 'Codeunit Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; "Print Template"; Code[20])
        {
            Caption = 'Print Template';
            TableRelation = "NPR RP Template Header".Code;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Report Type")
        {
        }
    }

    fieldgroups
    {
    }
}

