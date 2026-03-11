table 6059912 "NPR Item Addon Translation"
{
    Access = Internal;
    Extensible = false;
    DataClassification = CustomerContent;
    Caption = 'Item Addon Translation';

    fields
    {
        field(1; "External Table SystemId"; Guid)
        {
            Caption = 'External Table SystemId';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            DataClassification = CustomerContent;
            TableRelation = Language;
            NotBlank = true;
        }
        field(20; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "External Table SystemId", "Language Code")
        {
            Clustered = true;
        }
    }

    internal procedure DeleteTranslations(ExternalTableSystemId: Guid)
    begin
        SetRange("External Table SystemId", ExternalTableSystemId);
        DeleteAll(true);
    end;
}
