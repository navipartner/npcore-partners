table 6151440 "Magento Attribute Group"
{
    // MAG2.18/TS  /20180910  CASE 323934 Attribute Group Created

    Caption = 'Magento Attribute Group';
    DrillDownPageID = "Magento Attribute Group List";
    LookupPageID = "Magento Attribute Group List";

    fields
    {
        field(1;"Attribute Group ID";Integer)
        {
            Caption = 'Attribute Group ID';
        }
        field(5;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(10;"Attribute Set ID";Integer)
        {
            Caption = 'Attribute Set ID';
            TableRelation = "Magento Attribute Set";
        }
        field(15;"Sort Order";Integer)
        {
            Caption = 'Sort Order';
        }
    }

    keys
    {
        key(Key1;"Attribute Group ID")
        {
        }
        key(Key2;"Attribute Set ID")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown;"Attribute Group ID",Description,"Attribute Set ID")
        {
        }
    }
}

