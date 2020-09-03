table 6014515 "NPR Retail Contr. Setup"
{
    // //-NPR3.0c
    //   tilf¢jet feltet email på modtager af forsikringsoplysninger
    // NPR5.30/MHA /20170201  CASE 264918 Object renamed from Photo Setup to Retail Contract Setup and Unused fields deleted
    // NPR5.46/JAVA/20180918  CASE 328652 Fix 'DataLength' property of the field 1000 "Warranty No. Series" (20 => 10).

    Caption = 'Foto Setup';

    fields
    {
        field(1; Kode; Code[1])
        {
            Caption = 'Code';
        }
        field(112; "Default Insurance Company"; Code[50])
        {
            Caption = 'Default Insurance Company';
            Description = 'NPR5.30';
            TableRelation = "NPR Insurance Companies".Code;
        }
        field(113; "Insurance Item No."; Code[20])
        {
            Caption = 'Insurance Item No.';
            Description = 'NPR5.30';
            TableRelation = Item;
        }
        field(114; "Used Goods Item Tracking Code"; Code[20])
        {
            Caption = 'Used Goods Item Tracking Code';
            Description = 'NPR5.30';
            TableRelation = "Item Tracking Code";
        }
        field(1000; "Warranty No. Series"; Code[10])
        {
            Caption = 'Warranty No. Series';
            Description = 'NPR5.30';
            TableRelation = "No. Series";
        }
        field(1001; "Repair Item No."; Code[30])
        {
            Caption = 'Repair Item No.';
            Description = 'NPR5.30';
            TableRelation = Item."No.";
        }
        field(1002; "Used Goods Inventory Method"; Option)
        {
            Caption = 'Used Goods Inventory Method';
            Description = 'NPR5.30';
            OptionCaption = 'FIFO,LIFO,Serial No.,Avarage,Standard';
            OptionMembers = FIFO,LIFO,Serienummer,Gennemsnit,Standard;
        }
        field(1003; "Used Goods Serial No. Mgt."; Boolean)
        {
            Caption = 'Used Goods Serial No. Management';
            Description = 'NPR5.30';
        }
        field(1004; "Used Goods Gen. Bus. Post. Gr."; Code[10])
        {
            Caption = 'Used Goods Gen. Bus. Posting Group';
            Description = 'NPR5.30';
            TableRelation = "Gen. Business Posting Group";
        }
        field(1009; "Print Insurance Policy"; Boolean)
        {
            Caption = 'Print Insurance Policy';
            Description = 'NPR5.30';
        }
        field(2000; "Payout pct"; Decimal)
        {
            Caption = 'Payout pct';
            Description = 'Payoutpct ond purchase contracts';
        }
        field(2005; "Purch. Contract - Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            Description = 'Reason code';
            TableRelation = "Reason Code";
        }
        field(2008; "Rental Contract - Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            Description = 'Reason code';
            TableRelation = "Reason Code";
        }
        field(2015; "Rental Contract - Source Code"; Code[10])
        {
            Caption = 'Source Code';
            Description = 'Source code';
            TableRelation = "Source Code";
        }
        field(2016; "Purch. Contract - Source Code"; Code[10])
        {
            Caption = 'Source Code';
            Description = 'Source code';
            TableRelation = "Source Code";
        }
        field(2017; "Contract No. by"; Option)
        {
            Caption = 'Contract no. by';
            OptionCaption = 'Standard,Customer No.';
            OptionMembers = Standard,"Customer No.";
        }
        field(2018; "Check Serial No."; Boolean)
        {
            Caption = 'Check Serial No.';
            Description = 'NPR5.30';
        }
        field(2019; "Check Customer No."; Boolean)
        {
            Caption = 'Check Customer No.';
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

