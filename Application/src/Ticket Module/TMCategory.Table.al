table 6150850 "NPR TM Category"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Categories';

    fields
    {
        field(1; CategoryCode; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Category Code';
        }
        field(10; CategoryName; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Category Name';
        }
    }

    keys
    {
        key(Key1; CategoryCode)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; CategoryCode, CategoryName) { }
    }
}