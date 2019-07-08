table 6151417 "Magento Product Relation"
{
    // MAG1.00/MH/20150113  CASE 199932 Refactored Object from Web Integration
    // MAG1.07/MH/20150309  CASE 208131 Updated captions
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Object

    Caption = 'Magento Product Relation';

    fields
    {
        field(1;"Relation Type";Option)
        {
            BlankZero = true;
            Caption = 'Relation Type';
            InitValue = Relation;
            OptionCaption = ',Relation,,,Up-Sell,Cross-Sell';
            OptionMembers = " ",Relation,Bundle,Super,"Up-Sell","Cross-Sell";
        }
        field(2;"From Item No.";Code[20])
        {
            Caption = 'From Item No.';
            Description = 'MAG1.07';
            NotBlank = true;
            TableRelation = Item WHERE ("Magento Item"=CONST(true));
        }
        field(3;"To Item No.";Code[20])
        {
            Caption = 'To Item No.';
            Description = 'MAG1.07';
            NotBlank = true;
            TableRelation = Item WHERE ("Magento Item"=CONST(true));
        }
        field(4;Position;Integer)
        {
            Caption = 'Position';
        }
        field(10;"To Item Description";Text[50])
        {
            CalcFormula = Lookup(Item.Description WHERE ("No."=FIELD("To Item No.")));
            Caption = 'Description';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Relation Type","From Item No.","To Item No.")
        {
        }
    }

    fieldgroups
    {
    }
}

