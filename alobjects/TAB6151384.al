table 6151384 "CS Rfid Item Handling"
{
    // NPR5.47/CLVA/20181012 CASE 318296 Object created
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

    Caption = 'CS Rfid Item Handling';

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
        field(11;"Rfid Id";Text[30])
        {
            Caption = 'Rfid Id';
        }
        field(12;"Duplicate Tag Id";Boolean)
        {
            Caption = 'Duplicate Tag Id';
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
        field(105;"Transferred to Item Cross Ref.";Boolean)
        {
            Caption = 'Transferred to Item Cross Ref.';
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
}

