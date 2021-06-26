table 6014566 "NPR RP Template Media Info"
{
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
        TemplateHeader: Record "NPR RP Template Header";
    begin
        if IsTemporary then
            exit;
        if TemplateHeader.Get(Template) then
            TemplateHeader.Modify(true);
    end;
}

