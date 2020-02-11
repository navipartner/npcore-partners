table 6151369 "CS Rfid Lines"
{
    // NPR5.53/CLVA  /20191121  CASE 377563 Object created - NP Capture Service

    Caption = 'CS Rfid Lines';

    fields
    {
        field(1;Id;Guid)
        {
            Caption = 'Id';
            Editable = false;
            TableRelation = "CS Rfid Header";
        }
        field(2;"Tag Id";Text[30])
        {
            Caption = 'Tag Id';
            Editable = false;
        }
        field(10;"Item No.";Code[20])
        {
            Caption = 'Item No.';
            Editable = false;
            TableRelation = Item."No.";

            trigger OnValidate()
            begin
                Validate("Variant Code",'');
            end;
        }
        field(11;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            Editable = false;
            TableRelation = "Item Variant".Code WHERE ("Item No."=FIELD("Item No."));
        }
        field(12;"Item Description";Text[50])
        {
            CalcFormula = Lookup(Item.Description WHERE ("No."=FIELD("Item No.")));
            Caption = 'Item Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(13;"Variant Description";Text[50])
        {
            CalcFormula = Lookup("Item Variant".Description WHERE (Code=FIELD("Variant Code"),
                                                                   "Item No."=FIELD("Item No.")));
            Caption = 'Variant Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14;Created;DateTime)
        {
            Caption = 'Created';
            Editable = false;
        }
        field(15;"Created By";Code[20])
        {
            Caption = 'Created By';
            Editable = false;
        }
        field(16;Match;Boolean)
        {
            Caption = 'Match';
            Editable = false;
        }
    }

    keys
    {
        key(Key1;Id,"Tag Id")
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

