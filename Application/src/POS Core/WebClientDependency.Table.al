table 6014624 "NPR Web Client Dependency"
{
    // NPRx.xx/VB/20151130 CASE 226832 Object created to support dynamic Web client objects (scripts, stylesheets, HTML, and image data uris)
    // NPR5.00/NPKNAV/20160113  CASE 226832 NP Retail 2016
    // NPR5.41/MMV /20180403 CASE 300611 Changed DataPerCompany to 'No'.

    Caption = 'Web Client Dependency';
    DataPerCompany = false;
    DataClassification = CustomerContent;

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

    local procedure GetBLOB(DependencyType: Integer; DependencyCode: Code[10]): Text
    var
        WebDependency: Record "NPR Web Client Dependency";
        MemStr: DotNet NPRNetMemoryStream;
        Encoding: DotNet NPRNetEncoding;
        InStr: InStream;
    begin
        if not WebDependency.Get(DependencyType, DependencyCode) then
            exit;

        if not WebDependency.BLOB.HasValue() then
            exit;

        WebDependency.CalcFields(BLOB);
        WebDependency.BLOB.CreateInStream(InStr);
        MemStr := MemStr.MemoryStream();
        CopyStream(MemStr, InStr);

        exit(Encoding.UTF8.GetString(MemStr.ToArray()));
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

