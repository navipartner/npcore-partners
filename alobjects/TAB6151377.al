table 6151377 "CS Stock-Take Handling"
{
    // NPR5.41/NPKNAV/20180427  CASE 306407 Transport NPR5.41 - 27 April 2018
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018

    Caption = 'CS Stock-Take Handling';

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
        field(10;Barcode;Text[30])
        {
            Caption = 'Barcode';
        }
        field(11;Qty;Decimal)
        {
            Caption = 'Qty';
            InitValue = 1;
        }
        field(12;"Stock-Take Config Code";Code[10])
        {
            Caption = 'Stock-Take Conf. Code';
            TableRelation = "Stock-Take Configuration".Code;
        }
        field(13;"Worksheet Name";Code[10])
        {
            Caption = 'Worksheet Name';
            TableRelation = "Stock-Take Worksheet".Name WHERE ("Stock-Take Config Code"=FIELD("Stock-Take Config Code"));
        }
        field(14;"Shelf  No.";Code[10])
        {
            Caption = 'Shelf  No.';
        }
        field(15;"Item No.";Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item."No.";

            trigger OnValidate()
            begin
                Validate ("Variant Code", '');
            end;
        }
        field(16;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE ("Item No."=FIELD("Item No."));
        }
        field(17;"Item Description";Text[50])
        {
            CalcFormula = Lookup(Item.Description WHERE ("No."=FIELD("Item No.")));
            Caption = 'Item Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(18;"Variant Description";Text[50])
        {
            CalcFormula = Lookup("Item Variant".Description WHERE (Code=FIELD("Variant Code"),
                                                                   "Item No."=FIELD("Item No.")));
            Caption = 'Variant Description';
            Editable = false;
            FieldClass = FlowField;
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
        field(105;"Transferred to Worksheet";Boolean)
        {
            Caption = 'Transferred to Worksheet';
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

