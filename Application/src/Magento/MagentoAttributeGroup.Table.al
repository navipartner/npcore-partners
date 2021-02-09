table 6151440 "NPR Magento Attribute Group"
{
    Caption = 'Magento Attribute Group';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Magento Attr. Group List";
    LookupPageID = "NPR Magento Attr. Group List";

    fields
    {
        field(1; "Attribute Group ID"; Integer)
        {
            Caption = 'Attribute Group ID';
            DataClassification = CustomerContent;
        }
        field(5; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "Attribute Set ID"; Integer)
        {
            Caption = 'Attribute Set ID';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Attribute Set";
        }
        field(15; "Sort Order"; Integer)
        {
            Caption = 'Sort Order';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Attribute Group ID")
        {
        }
        key(Key2; "Attribute Set ID")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Attribute Group ID", Description, "Attribute Set ID")
        {
        }
    }
}