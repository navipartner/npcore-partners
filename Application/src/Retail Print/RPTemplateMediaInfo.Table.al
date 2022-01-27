table 6014566 "NPR RP Template Media Info"
{
    Access = Internal;
    // Keep media information seperate from templates so they are not backed up in archived versions and to prevent the BLOB from impacting print SQL performance.

    Caption = 'Template Media Info';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Template; Code[20])
        {
            Caption = 'Template';
            TableRelation = "NPR RP Template Header".Code;
            DataClassification = CustomerContent;
        }
        field(10; Picture; BLOB)
        {
            Caption = 'Picture';
            SubType = Bitmap;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Use Media instead of Blob type.';
        }
        field(11; URL; Text[250])
        {
            Caption = 'URL';
            DataClassification = CustomerContent;
        }
        field(12; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(13; Image; Media)
        {
            Caption = 'Picture';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Template)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        ModifiedRec();
    end;

    trigger OnInsert()
    begin
        ModifiedRec();
    end;

    trigger OnModify()
    begin
        ModifiedRec();
    end;

    trigger OnRename()
    begin
        ModifiedRec();
    end;

    local procedure ModifiedRec()
    var
        RPTemplateHeader: Record "NPR RP Template Header";
    begin
        if IsTemporary then
            exit;
        if RPTemplateHeader.Get(Template) then
            RPTemplateHeader.Modify(true);
    end;

    procedure GetImageContent(var TenantMedia: Record "Tenant Media")
    begin
        TenantMedia.Init();
        if not Rec.Image.HasValue() then
            exit;
        if TenantMedia.Get(Rec.Image.MediaId()) then
            TenantMedia.CalcFields(Content);
    end;
}

