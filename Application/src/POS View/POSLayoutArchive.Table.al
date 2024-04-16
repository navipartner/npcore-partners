table 6059796 "NPR POS Layout Archive"
{
    Access = Internal;
    Caption = 'POS Layout Archive';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Archived POS Layouts";
    LookupPageID = "NPR Archived POS Layouts";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Frontend Properties"; Blob)
        {
            Caption = 'Frontend Properties';
            DataClassification = CustomerContent;
        }
        field(4; "Template Name"; Text[100])
        {
            Caption = 'Template Name';
            DataClassification = CustomerContent;
        }
        field(100; "Version No."; Integer)
        {
            Caption = 'Version No.';
            DataClassification = CustomerContent;
        }
        field(110; "Archived By"; Code[50])
        {
            Caption = 'Archived By';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(User."User Name" where("User Security ID" = field(SystemCreatedBy)));
        }
    }

    keys
    {
        key(PK; "Code", "Version No.")
        {
            Clustered = true;
        }
    }

    procedure GetLayot() Text: Text
    var
        InStream: InStream;
    begin
        if not "Frontend Properties".HasValue() then
            exit;

        CalcFields("Frontend Properties");
        "Frontend Properties".CreateInStream(InStream, TextEncoding::UTF8);
        InStream.Read(Text);
    end;

    procedure SetLayout(Text: Text)
    var
        OutStream: OutStream;
    begin
        Clear("Frontend Properties");
        "Frontend Properties".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.Write(Text);
    end;

}
