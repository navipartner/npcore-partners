table 6151395 "CS Whse. Receipt Data"
{
    // NPR5.51/CLVA/20190610  CASE 356107 Object created

    Caption = 'CS Whse. Receipt Data';

    fields
    {
        field(1;"Doc. No.";Code[20])
        {
            Caption = 'Doc. No.';
        }
        field(2;"Tag Id";Text[30])
        {
            Caption = 'Tag Id';
        }
        field(10;"Item No.";Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item."No.";

            trigger OnValidate()
            begin
                Validate("Variant Code",'');
                Validate("Item Group Code",'');
            end;
        }
        field(11;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE ("Item No."=FIELD("Item No."));
        }
        field(12;"Item Group Code";Code[10])
        {
            Caption = 'Item Group Code';
            TableRelation = "Item Group";
        }
        field(13;"Item Description";Text[50])
        {
            CalcFormula = Lookup(Item.Description WHERE ("No."=FIELD("Item No.")));
            Caption = 'Item Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14;"Variant Description";Text[50])
        {
            CalcFormula = Lookup("Item Variant".Description WHERE (Code=FIELD("Variant Code"),
                                                                   "Item No."=FIELD("Item No.")));
            Caption = 'Variant Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15;"Item Group Description";Text[50])
        {
            CalcFormula = Lookup("Item Group".Description WHERE ("No."=FIELD("Item Group Code")));
            Caption = 'Item Group Description';
            Editable = false;
            FieldClass = FlowField;

            trigger OnValidate()
            var
                Item: Record Item;
            begin
            end;
        }
        field(16;Created;DateTime)
        {
            Caption = 'Created';
        }
        field(17;"Created By";Code[20])
        {
            Caption = 'Created By';
        }
        field(18;"Tag Type";Option)
        {
            Caption = 'Tag Type';
            OptionCaption = 'Document,Not on Document,Unknown';
            OptionMembers = Document,"Not on Document",Unknown;
        }
        field(20;Transferred;DateTime)
        {
            Caption = 'Transferred';
        }
        field(21;"Transferred By";Code[10])
        {
            Caption = 'Transferred By';
        }
        field(22;"Transferred To Doc";Boolean)
        {
            Caption = 'Transferred To Doc';
        }
        field(23;"Combined key";Code[30])
        {
            Caption = 'Combined key';
        }
    }

    keys
    {
        key(Key1;"Doc. No.","Tag Id")
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

