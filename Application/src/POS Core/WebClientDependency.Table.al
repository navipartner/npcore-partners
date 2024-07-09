table 6014624 "NPR Web Client Dependency"
{
    Access = Internal;
    Caption = 'Web Client Dependency';
    DataPerCompany = false;
    DataClassification = CustomerContent;
    ObsoleteState = Pending;
    ObsoleteTag = '2024-02-28';
    ObsoleteReason = 'New POS frontend+editor will no longer support customer specific injected web scripts/styling/html/fonts';

    fields
    {
        field(1; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'JavaScript,CSS,HTML,SVG,DataUri';
            OptionMembers = JavaScript,CSS,HTML,SVG,DataUri;
            DataClassification = CustomerContent;
        }
        field(2; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "BLOB"; BLOB)
        {
            Caption = 'BLOB';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Type, "Code")
        {
        }
    }

    fieldgroups
    {
    }

    local procedure GetBLOB(DependencyType: Integer; DependencyCode: Code[10]) Result: Text
    var
        WebDependency: Record "NPR Web Client Dependency";
        InStr: InStream;
    begin
        if not WebDependency.Get(DependencyType, DependencyCode) then
            exit;

        if not WebDependency.BLOB.HasValue() then
            exit;

        WebDependency.CalcFields(BLOB);
        WebDependency.BLOB.CreateInStream(InStr, TextEncoding::UTF8);
        InStr.Read(Result, WebDependency.BLOB.Length);
    end;

    procedure GetJavaScript(DependencyCode: Code[10]): Text
    begin
        exit(GetBLOB(Type::JavaScript, DependencyCode));
    end;

    procedure GetStyleSheet(DependencyCode: Code[10]): Text
    begin
        exit(GetBLOB(Type::CSS, DependencyCode));
    end;

    procedure GetHtml(DependencyCode: Code[10]): Text
    begin
        exit(GetBLOB(Type::HTML, DependencyCode));
    end;

    procedure GetSvg(DependencyCode: Code[10]): Text
    begin
        exit(GetBLOB(Type::SVG, DependencyCode));
    end;

    procedure GetDataUri(DependencyCode: Code[10]): Text
    begin
        exit(GetBLOB(Type::DataUri, DependencyCode));
    end;
}

