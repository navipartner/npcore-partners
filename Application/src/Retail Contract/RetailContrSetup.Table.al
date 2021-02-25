table 6014515 "NPR Retail Contr. Setup"
{
    // //-NPR3.0c
    //   tilf¢jet feltet email på modtager af forsikringsoplysninger
    // NPR5.30/MHA /20170201  CASE 264918 Object renamed from Photo Setup to Retail Contract Setup and Unused fields deleted
    // NPR5.46/JAVA/20180918  CASE 328652 Fix 'DataLength' property of the field 1000 "Warranty No. Series" (20 => 10).

    Caption = 'Foto Setup';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Repairs are not supported in core anymore.';

    fields
    {
        field(1; Kode; Code[1])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(112; "Default Insurance Company"; Code[50])
        {
            Caption = 'Default Insurance Company';
            Description = 'NPR5.30';
            TableRelation = "NPR Insurance Companies".Code;
            DataClassification = CustomerContent;
        }
        field(113; "Insurance Item No."; Code[20])
        {
            Caption = 'Insurance Item No.';
            Description = 'NPR5.30';
            TableRelation = Item;
            DataClassification = CustomerContent;
        }
        field(114; "Used Goods Item Tracking Code"; Code[20])
        {
            Caption = 'Used Goods Item Tracking Code';
            Description = 'NPR5.30';
            TableRelation = "Item Tracking Code";
            DataClassification = CustomerContent;
        }
        field(1000; "Warranty No. Series"; Code[20])
        {
            Caption = 'Warranty No. Series';
            Description = 'NPR5.30';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(1001; "Repair Item No."; Code[30])
        {
            Caption = 'Repair Item No.';
            Description = 'NPR5.30';
            TableRelation = Item."No.";
            DataClassification = CustomerContent;
        }
        field(1002; "Used Goods Inventory Method"; Option)
        {
            Caption = 'Used Goods Inventory Method';
            Description = 'NPR5.30';
            OptionCaption = 'FIFO,LIFO,Serial No.,Avarage,Standard';
            OptionMembers = FIFO,LIFO,Serienummer,Gennemsnit,Standard;
            DataClassification = CustomerContent;
        }
        field(1003; "Used Goods Serial No. Mgt."; Boolean)
        {
            Caption = 'Used Goods Serial No. Management';
            Description = 'NPR5.30';
            DataClassification = CustomerContent;
        }
        field(1004; "Used Goods Gen. Bus. Post. Gr."; Code[10])
        {
            Caption = 'Used Goods Gen. Bus. Posting Group';
            Description = 'NPR5.30';
            TableRelation = "Gen. Business Posting Group";
            DataClassification = CustomerContent;
        }
        field(1009; "Print Insurance Policy"; Boolean)
        {
            Caption = 'Print Insurance Policy';
            Description = 'NPR5.30';
            DataClassification = CustomerContent;
        }
        field(2000; "Payout pct"; Decimal)
        {
            Caption = 'Payout pct';
            Description = 'Payoutpct ond purchase contracts';
            DataClassification = CustomerContent;
        }
        field(2005; "Purch. Contract - Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            Description = 'Reason code';
            TableRelation = "Reason Code";
            DataClassification = CustomerContent;
        }
        field(2008; "Rental Contract - Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            Description = 'Reason code';
            TableRelation = "Reason Code";
            DataClassification = CustomerContent;
        }
        field(2015; "Rental Contract - Source Code"; Code[10])
        {
            Caption = 'Source Code';
            Description = 'Source code';
            TableRelation = "Source Code";
            DataClassification = CustomerContent;
        }
        field(2016; "Purch. Contract - Source Code"; Code[10])
        {
            Caption = 'Source Code';
            Description = 'Source code';
            TableRelation = "Source Code";
            DataClassification = CustomerContent;
        }
        field(2017; "Contract No. by"; Option)
        {
            Caption = 'Contract no. by';
            OptionCaption = 'Standard,Customer No.';
            OptionMembers = Standard,"Customer No.";
            DataClassification = CustomerContent;
        }
        field(2018; "Check Serial No."; Boolean)
        {
            Caption = 'Check Serial No.';
            Description = 'NPR5.30';
            DataClassification = CustomerContent;
        }
        field(2019; "Check Customer No."; Boolean)
        {
            Caption = 'Check Customer No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Kode)
        {
        }
    }

    fieldgroups
    {
    }
}

