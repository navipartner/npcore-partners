table 6150624 "POS Balancing Line"
{
    // NPR5.29/AP/20170126 CASE 262628 Recreated ENU-captions
    // NPR5.30/AP/20170209 CASE 261728 Renamed field "Store Code" -> "POS Store Code"
    // NPR5.32/AP/20170220 CASE 262628 Renamed field "Receipt No." -> "Document No."
    //                                 Added the fields 160 Orig. POS Sale ID and 161 Orig. POS Line No.
    // NPR5.36/AP/20170717 CASE 262628 Added "POS Ledg. Register No."
    // NPR5.38/BR/20171214 CASE 299888 Renamed from POS Ledg. Register No. to POS Period Register No. (incl. Captions)

    Caption = 'POS Balancing Line';

    fields
    {
        field(1;"POS Entry No.";Integer)
        {
            Caption = 'POS Entry No.';
            TableRelation = "POS Entry";
        }
        field(3;"POS Store Code";Code[10])
        {
            Caption = 'POS Store Code';
            TableRelation = "POS Store";
        }
        field(4;"POS Unit No.";Code[10])
        {
            Caption = 'POS Unit No.';
            TableRelation = "POS Unit";
        }
        field(5;"Document No.";Code[20])
        {
            Caption = 'Document No.';
        }
        field(6;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(7;"POS Period Register No.";Integer)
        {
            Caption = 'POS Period Register No.';
            Description = 'NPR5.36';
            TableRelation = "POS Period Register";
        }
        field(10;"POS Payment Bin Code";Code[10])
        {
            Caption = 'POS Payment Bin Code';
            TableRelation = "POS Payment Bin";
        }
        field(11;"POS Payment Method Code";Code[10])
        {
            Caption = 'POS Payment Method Code';
            TableRelation = "POS Payment Method";
        }
        field(30;"Calculated Amount";Decimal)
        {
            Caption = 'Calculated Amount';
        }
        field(31;"Balanced Amount";Decimal)
        {
            Caption = 'Balanced Amount';
        }
        field(32;"Balanced Diff. Amount";Decimal)
        {
            Caption = 'Balanced Diff. Amount';
        }
        field(34;"New Float Amount";Decimal)
        {
            Caption = 'Closing Amount';
        }
        field(40;"Shortcut Dimension 1 Code";Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(1));
        }
        field(41;"Shortcut Dimension 2 Code";Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(2));
        }
        field(50;"Calculated Quantity";Decimal)
        {
            Caption = 'Calculated Quantity';
        }
        field(51;"Balanced Quantity";Decimal)
        {
            Caption = 'Balanced Quantity';
        }
        field(52;"Balanced Diff. Quantity";Decimal)
        {
            Caption = 'Balanced Diff. Quantity';
        }
        field(53;"Deposited Quantity";Decimal)
        {
            Caption = 'Deposited Quantity';
        }
        field(54;"Closing Quantity";Decimal)
        {
            Caption = 'Closing Quantity';
        }
        field(60;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(70;"Deposit-To Bin Amount";Decimal)
        {
            Caption = 'Deposited Amount';
        }
        field(71;"Deposit-To Bin Code";Code[10])
        {
            Caption = 'Deposit-To Bin Code';
        }
        field(72;"Deposit-To Reference";Text[50])
        {
            Caption = 'Deposit-To Reference';
        }
        field(80;"Move-To Bin Amount";Decimal)
        {
            Caption = 'Move-To Bin Amount';
        }
        field(81;"Move-To Bin Code";Code[10])
        {
            Caption = 'Transfer-To POS Bin Code';
            TableRelation = "POS Payment Bin";
        }
        field(82;"Move-To Reference";Text[50])
        {
            Caption = 'Move-To Reference';
        }
        field(100;"Balancing Details";Text[250])
        {
            Caption = 'Balancing Details';
        }
        field(160;"Orig. POS Sale ID";Integer)
        {
            Caption = 'Orig. POS Sale ID';
            Description = 'NPR5.32';
        }
        field(161;"Orig. POS Line No.";Integer)
        {
            Caption = 'Orig. POS Line No.';
            Description = 'NPR5.32';
        }
        field(200;"POS Bin Checkpoint Entry No.";Integer)
        {
            Caption = 'POS Bin Checkpoint Entry No.';
            TableRelation = "POS Payment Bin Checkpoint";
        }
        field(210;"Currency Code";Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(480;"Dimension Set ID";Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                //ShowDimensions;
            end;
        }
    }

    keys
    {
        key(Key1;"POS Entry No.","Line No.")
        {
        }
        key(Key2;"Document No.","Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

