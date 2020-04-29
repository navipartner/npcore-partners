table 6151369 "CS Rfid Lines"
{
    // NPR5.53/CLVA  /20191121  CASE 377563 Object created - NP Capture Service
    // NPR5.54/JAKUBV/20200408  CASE 379709 Transport NPR5.54 - 8 April 2020

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
        field(17;"Item Group Code";Code[10])
        {
            Caption = 'Item Group Code';
            TableRelation = "Item Group";
        }
        field(18;"Item Group Description";Text[50])
        {
            CalcFormula = Lookup("Item Group".Description WHERE ("No."=FIELD("Item Group Code")));
            Caption = 'Item Group Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(19;"Transferred To";Option)
        {
            Caption = 'Transferred To';
            OptionCaption = ',Sales Order,Whse. Receipt,Transfer Order';
            OptionMembers = ,"Sales Order","Whse. Receipt","Transfer Order";
        }
        field(20;"Transferred to Doc";Code[20])
        {
            Caption = 'Transferred to Doc';
        }
        field(21;"Transferred Date";DateTime)
        {
            Caption = 'Transferred Date';
        }
        field(22;"Transferred By";Code[20])
        {
            Caption = 'Transferred By';
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

