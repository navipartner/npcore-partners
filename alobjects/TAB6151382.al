table 6151382 "CS Price Check Handling"
{
    // NPR5.43/CLVA/20180605 CASE 304872 Object created - NP Capture Service
    // NPR5.48/CLVA/20181109 CASE 335606 Added "Unit of Measure"

    Caption = 'CS Price Check Handling';

    fields
    {
        field(1;Id;Code[10])
        {
            Caption = 'Id';
        }
        field(2;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(3;"Unit of Measure";Code[10])
        {
            Caption = 'Unit of Measure';
            TableRelation = "Item Unit of Measure".Code WHERE ("Item No."=FIELD("Item No."));
        }
        field(10;Barcode;Text[30])
        {
            Caption = 'Barcode';
        }
        field(11;Qty;Decimal)
        {
            Caption = 'Qty';
            InitValue = 1;
        }
        field(16;"Currency Code";Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(17;"Unit Cost incl. VAT";Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost incl. VAT';
        }
        field(18;"Unit Price incl. VAT";Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price incl. VAT';
        }
        field(19;"Customer Unit Price incl. VAT";Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Customer Unit Price incl. VAT';
        }
        field(21;"No.";Code[20])
        {
            Caption = 'No.';
            Editable = false;
        }
        field(22;"Location Filter";Code[100])
        {
            Caption = 'Location Code';
            Editable = false;
            TableRelation = Location;
        }
        field(50;"Item No.";Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item."No.";

            trigger OnValidate()
            begin
                Validate("Variant Code", '');
            end;
        }
        field(51;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE ("Item No."=FIELD("Item No."));
        }
        field(52;"Item Description";Text[50])
        {
            CalcFormula = Lookup(Item.Description WHERE ("No."=FIELD("Item No.")));
            Caption = 'Item Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(53;"Variant Description";Text[50])
        {
            CalcFormula = Lookup("Item Variant".Description WHERE (Code=FIELD("Variant Code"),
                                                                   "Item No."=FIELD("Item No.")));
            Caption = 'Variant Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(54;"Unit Cost ex. VAT";Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost ex. VAT';
        }
        field(55;"Unit Price ex. VAT";Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price ex. VAT';
        }
        field(56;"Customer Unit Price ex. VAT";Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Customer Unit Price ex. VAT';
        }
        field(57;"Total Cost incl. VAT";Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Total Cost incl. VAT';
        }
        field(58;"Total Price incl. VAT";Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Total Price incl. VAT';
        }
        field(59;"Total Customer Price incl. VAT";Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Total Customer Price incl. VAT';
        }
        field(60;"Total Cost ex. VAT";Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Total Cost ex. VAT';
        }
        field(61;"Total Price ex. VAT";Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Total Price ex. VAT';
        }
        field(62;"Total Customer Price ex. VAT";Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Total Customer Price ex. VAT';
        }
        field(100;"Table No.";Integer)
        {
            Caption = 'Table No.';
        }
        field(101;"Record Id";RecordID)
        {
            Caption = 'Record Id';
        }
        field(102;Handled;Boolean)
        {
            Caption = 'Handled';
        }
        field(103;Created;DateTime)
        {
            Caption = 'Created';
        }
        field(104;"Created By";Code[20])
        {
            Caption = 'Created By';
        }
    }

    keys
    {
        key(Key1;Id,"Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        Created := CurrentDateTime;
        "Created By" := UserId;
    end;
}

