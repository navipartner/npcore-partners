table 6151052 "Item Hierarchy Line"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj -fields 10,11

    Caption = 'Item Hierarchy Lines';

    fields
    {
        field(1;"Item Hierarchy Code";Code[20])
        {
            Caption = 'Item Hierarchy ID';
        }
        field(2;"Item Hierarchy Line No.";Integer)
        {
            Caption = 'Item Hierarchy Line No.';
        }
        field(3;"Item Hierarchy Level";Integer)
        {
            Caption = 'Item Hierarchy Level';
        }
        field(4;"Item Hierachy Description";Text[80])
        {
            Caption = 'Item Hierachy Description';
        }
        field(10;"Related Table No.";Integer)
        {
            Caption = 'Related Table No.';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Table));
        }
        field(11;"Related Table Name";Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE ("Object Type"=CONST(Table),
                                                             "Object ID"=FIELD("Related Table No.")));
            Caption = 'Related Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(12;"Related Table Key Field";Integer)
        {
            Caption = 'Related Table Key Field';
            TableRelation = Field."No." WHERE (TableNo=FIELD("Related Table No."));
        }
        field(13;"Related Table Key Field Name";Text[30])
        {
            Caption = 'Related Table Key Field Name';
        }
        field(14;"Related Table Key Field Value";Text[80])
        {
            Caption = 'Related Table Key Field Value';
        }
        field(15;"Related Table Desc. Field";Integer)
        {
            Caption = 'Related Table Desc. Field';
            TableRelation = Field."No." WHERE (TableNo=FIELD("Related Table No."));
        }
        field(16;"Related Table Desc. Field Name";Text[30])
        {
            Caption = 'Related Table Desc. Field Name';
        }
        field(17;"Related Table Desc Field Value";Text[80])
        {
            Caption = 'Related Table Desc Field Value';
        }
        field(19;"Linked Table No.";Integer)
        {
            Caption = 'Linked Table No.';
        }
        field(20;"Linked Table Key Value";Text[30])
        {
            Caption = 'Linked Table Key Value';

            trigger OnLookup()
            var
                RecRef: RecordRef;
                RecVar: Variant;
                Text: Text[80];
            begin
                RecRef.Open("Related Table No.");
                RecVar := RecRef;
                if PAGE.RunModal(0,RecVar) = ACTION::LookupOK then begin
                  Text := RecVar;
                end;
            end;
        }
        field(21;"Linked Table Value Desc.";Text[80])
        {
            Caption = 'Linked Table Value Desc.';
        }
        field(22;"Item No.";Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                Item.Get("Item No.");
                "Item Desc." := Item.Description;
            end;
        }
        field(23;"Item Desc.";Text[80])
        {
            Caption = 'Item Desciption';
        }
        field(24;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE ("Item No."=FIELD("Item No."));
        }
        field(5000;"Retail Campaign Disc. Code";Code[20])
        {
            Caption = 'Retail Campaign Disc. Code';
        }
        field(5001;"Retail Campaign Disc. Type";Option)
        {
            Caption = 'Retail Campaign Disc. Type';
            OptionCaption = 'Period,Mix';
            OptionMembers = Period,Mix;
        }
    }

    keys
    {
        key(Key1;"Item Hierarchy Code","Item Hierarchy Line No.")
        {
        }
        key(Key2;"Linked Table Key Value")
        {
        }
    }

    fieldgroups
    {
    }
}

