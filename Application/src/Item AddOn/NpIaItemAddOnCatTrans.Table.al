table 6151268 "NPR NpIa ItemAddOn Cat. Trans."
{
    Access = Internal;
    Extensible = false;
    Caption = 'Item AddOn Category Translation';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Category Code"; Code[20])
        {
            Caption = 'Category Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpIa Item AddOn Category";
            NotBlank = true;
        }
        field(2; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            DataClassification = CustomerContent;
            TableRelation = Language;
            NotBlank = true;
        }
        field(10; Title; Text[100])
        {
            Caption = 'Title';
            DataClassification = CustomerContent;
        }
        field(11; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Category Code", "Language Code")
        {
            Clustered = true;
        }
    }
}
