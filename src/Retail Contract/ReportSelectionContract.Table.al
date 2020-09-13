table 6014520 "NPR Report Selection: Contract"
{
    // NPR5.26/TS/20160809 CASE 248289 Changed Option Caption Values from Danish to English
    // NPR5.30/MHA /20170201  CASE 264918 Object renamed from Report Selection - Photo to Report Selection - Contract and Np Photo removed
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.30/BHR /20170203  CASE 262923  Add Field "Print Template". Add option "Repair Label" to repair type.
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj fields 3,4,5,6,8,9
    // NPR5.48/JDH /20181108 CASE 334560 Changed Data port fields to XML Port fields, and fixed reference to Object table. Fixed option Caption for "Report Type"

    Caption = 'Report Selection - Contract';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Report Type"; Option)
        {
            Caption = 'Report Type';
            Description = 'NPR5.30';
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

            trigger OnValidate()
            begin
                CalcFields("Report Name");
            end;
        }
        field(4; "Report Name"; Text[30])
        {
            CalcFormula = Lookup (AllObj."Object Name" WHERE("Object Type" = CONST(Report),
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

            trigger OnValidate()
            begin
                CalcFields("XML Port Name");
            end;
        }
        field(6; "XML Port Name"; Text[30])
        {
            CalcFormula = Lookup (AllObj."Object Name" WHERE("Object Type" = CONST(XMLport),
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
            CalcFormula = Lookup (AllObj."Object Name" WHERE("Object Type" = CONST(Codeunit),
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

    var
        RapportValg2: Record "NPR Report Selection: Contract";

    procedure NyRecord()
    begin
        RapportValg2.SetRange("Report Type", "Report Type");
        //-NPR5.26
        //IF RapportValg2.FIND('+') AND (RapportValg2.Sequence <> '') THEN
        if RapportValg2.FindLast and (RapportValg2.Sequence <> '') then
            //+NPR5.26
            Sequence := IncStr(RapportValg2.Sequence)
        else
            Sequence := '1';
    end;
}

