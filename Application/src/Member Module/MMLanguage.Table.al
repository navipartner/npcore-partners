table 6150849 "NPR MM Language"
{
    DataClassification = CustomerContent;
    Access = Internal;
    Caption = 'Language';
    Extensible = false;

    fields
    {
        field(1; LanguageCode; Code[10])
        {
            Caption = 'Language Code';
            DataClassification = CustomerContent;
            TableRelation = "Language";
        }

        field(10; LanguageName; Text[50])
        {
            Caption = 'Name';
            FieldClass = FlowField;
            CalcFormula = Lookup("Language".Name WHERE("Code" = FIELD(LanguageCode)));
            Editable = false;
        }
    }

    keys
    {
        key(Key1; LanguageCode)
        {
            Clustered = true;
        }
    }

}