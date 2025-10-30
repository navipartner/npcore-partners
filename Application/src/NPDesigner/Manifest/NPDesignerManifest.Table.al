table 6151256 "NPR NPDesignerManifest"
{
    DataClassification = CustomerContent;
    Extensible = false;
    Access = Internal;
    Caption = 'NPDesigner Manifest';

    fields
    {
        field(1; EntryNo; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; ManifestId; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Manifest Id';
        }

        field(10; MasterTemplateId; Text[40])
        {
            DataClassification = CustomerContent;
            Caption = 'Master Template Id';
        }

        field(20; PreferredAssetLanguage; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Preferred Asset Language';
        }

        field(30; ShowTableOfContents; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Show Table Of Contents';
            InitValue = false;
        }
    }

    keys
    {
        key(Key1; EntryNo)
        {
            Clustered = true;
        }
        key(Key2; ManifestId)
        {
            Clustered = false;
            Unique = true;
        }
    }

    trigger OnDelete()
    var
        ManifestLine: Record "NPR NPDesignerManifestLine";
    begin
        ManifestLine.SetFilter(EntryNo, '=%1', EntryNo);
        ManifestLine.DeleteAll();
    end;


}