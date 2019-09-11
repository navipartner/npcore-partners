table 6151168 "NpGp POS Sales Line"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales
    // NPR5.51/ALST/20190904  CASE 337539 added field "Global reference"

    Caption = 'Global Pos Sales Line';
    DrillDownPageID = "NpGp POS Sales Lines";
    LookupPageID = "NpGp POS Sales Lines";

    fields
    {
        field(1;"POS Entry No.";BigInteger)
        {
            Caption = 'POS Entry No.';
        }
        field(5;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(15;"Retail ID";Guid)
        {
            Caption = 'Retail ID';
        }
        field(100;"POS Store Code";Code[10])
        {
            Caption = 'POS Store Code';
            TableRelation = "POS Store";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(105;"POS Unit No.";Code[10])
        {
            Caption = 'POS Unit No.';
            TableRelation = "POS Unit";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(110;"Document No.";Code[20])
        {
            Caption = 'Document No.';
        }
        field(200;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,G/L Account,Item,Customer,Voucher,Payout,Rounding';
            OptionMembers = " ","G/L Account",Item,Customer,Voucher,Payout,Rounding;
        }
        field(205;"No.";Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type=CONST(" ")) "Standard Text"
                            ELSE IF (Type=CONST("G/L Account")) "G/L Account"
                            ELSE IF (Type=CONST(Customer)) Customer
                            ELSE IF (Type=CONST(Voucher)) "G/L Account"
                            ELSE IF (Type=CONST(Payout)) "G/L Account"
                            ELSE IF (Type=CONST(Item)) Item
                            ELSE IF (Type=CONST(Rounding)) "G/L Account";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(210;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = IF (Type=CONST(Item)) "Item Variant".Code WHERE (Code=FIELD("No."));
        }
        field(215;"Cross-Reference No.";Code[20])
        {
            AccessByPermission = TableData "Item Cross Reference"=R;
            Caption = 'Cross-Reference No.';

            trigger OnValidate()
            var
                ReturnedCrossRef: Record "Item Cross Reference";
            begin
            end;
        }
        field(220;"BOM Item No.";Code[20])
        {
            Caption = 'BOM Item No.';
            TableRelation = Item;
        }
        field(225;"Location Code";Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(230;Description;Text[80])
        {
            Caption = 'Description';
        }
        field(235;"Description 2";Text[50])
        {
            Caption = 'Description 2';
        }
        field(300;Quantity;Decimal)
        {
            Caption = 'Quantity';
        }
        field(305;"Unit of Measure Code";Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = IF (Type=CONST(Item)) "Item Unit of Measure".Code WHERE ("Item No."=FIELD("No."))
                            ELSE "Unit of Measure";
        }
        field(310;"Qty. per Unit of Measure";Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0:5;
            Editable = false;
            InitValue = 1;
        }
        field(315;"Quantity (Base)";Decimal)
        {
            Caption = 'Quantity (Base)';
        }
        field(400;"Unit Price";Decimal)
        {
            Caption = 'Unit Price';
        }
        field(405;"Currency Code";Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(410;"VAT %";Decimal)
        {
            Caption = 'VAT %';
        }
        field(415;"Line Discount %";Decimal)
        {
            Caption = 'Line Discount %';
        }
        field(420;"Line Discount Amount Excl. VAT";Decimal)
        {
            Caption = 'Line Discount Amount Excl. VAT';
        }
        field(425;"Line Discount Amount Incl. VAT";Decimal)
        {
            Caption = 'Line Discount Amount';
        }
        field(430;"Line Amount";Decimal)
        {
            AutoFormatExpression = "Unit of Measure Code";
            AutoFormatType = 1;
            Caption = 'Line Amount';
        }
        field(435;"Amount Excl. VAT";Decimal)
        {
            Caption = 'Amount Excl. VAT';
        }
        field(440;"Amount Incl. VAT";Decimal)
        {
            Caption = 'Amount Incl. VAT';
        }
        field(445;"Line Dsc. Amt. Excl. VAT (LCY)";Decimal)
        {
            Caption = 'Line Dsc. Amt. Excl. VAT (LCY)';
        }
        field(450;"Line Dsc. Amt. Incl. VAT (LCY)";Decimal)
        {
            Caption = 'Line Dsc. Amt. Incl. VAT (LCY)';
        }
        field(455;"Amount Excl. VAT (LCY)";Decimal)
        {
            Caption = 'Amount Excl. VAT (LCY)';
        }
        field(460;"Amount Incl. VAT (LCY)";Decimal)
        {
            Caption = 'Amount Incl. VAT (LCY)';
        }
        field(465;"Global Reference";Code[50])
        {
            Caption = 'Global Reference Number';
            Description = 'NPR5.51';
        }
    }

    keys
    {
        key(Key1;"POS Entry No.","Line No.")
        {
        }
        key(Key2;"POS Store Code","POS Unit No.","Document No.")
        {
        }
        key(Key3;"Retail ID")
        {
        }
    }

    fieldgroups
    {
    }
}

