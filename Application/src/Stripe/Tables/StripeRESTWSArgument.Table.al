table 6014648 "NPR Stripe REST WS Argument"
{
    Access = Internal;
    Caption = 'Stripe REST Web Service Argument';
    TableType = Temporary;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'PrimaryKey';
            DataClassification = CustomerContent;
        }
        field(2; "Rest Method"; Option)
        {
            Caption = 'Rest Method';
            DataClassification = CustomerContent;
            OptionMembers = get,post,delete,patch,put;
        }
        field(3; URL; Text[250])
        {
            Caption = 'URL';
            DataClassification = CustomerContent;
        }
        field(4; Accept; Text[30])
        {
            Caption = 'Accept';
            DataClassification = CustomerContent;
        }
        field(5; ETag; Text[250])
        {
            Caption = 'ETag';
            DataClassification = CustomerContent;
        }
        field(6; Username; Text[250])
        {
            Caption = 'Username';
            DataClassification = CustomerContent;
        }
        field(7; Password; Text[50])
        {
            Caption = 'Password';
            DataClassification = CustomerContent;
        }
        field(8; "Blob"; Blob)
        {
            Caption = 'Blob';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    var
        RequestContentSet: Boolean;
        RequestContent: HttpContent;
        ResponseHeaders: HttpHeaders;

    internal procedure SetRequestContent(var NewContent: HttpContent)
    begin
        RequestContent := NewContent;
        RequestContentSet := true;
    end;

    internal procedure HasRequestContent(): Boolean
    begin
        exit(RequestContentSet);
    end;

    internal procedure GetRequestContent(var Content: HttpContent)
    begin
        Content := RequestContent;
    end;

    internal procedure SetResponseContent(var NewContent: HttpContent)
    var
        InStr: InStream;
        OutStr: OutStream;
    begin
        Blob.CreateInStream(InStr);
        NewContent.ReadAs(InStr);

        Blob.CreateOutStream(OutStr);
        CopyStream(OutStr, InStr);
    end;

    internal procedure HasResponseContent(): Boolean
    begin
        exit(Blob.HasValue());
    end;

    internal procedure GetResponseContent(var Content: HttpContent)
    var
        InStr: InStream;
    begin
        Blob.CreateInStream(InStr);
        Content.Clear();
        Content.WriteFrom(InStr);
    end;

    internal procedure GetResponseContentAsText() ReturnValue: Text
    var
        InStr: InStream;
        Line: Text;
    begin
        if not HasResponseContent() then
            exit;

        Blob.CreateInStream(InStr);
        InStr.ReadText(ReturnValue);

        while not InStr.EOS() do begin
            InStr.ReadText(Line);
            ReturnValue += Line;
        end;
    end;

    internal procedure SetResponseHeaders(var NewHeaders: HttpHeaders)
    begin
        ResponseHeaders := NewHeaders;
    end;

    internal procedure GetResponseHeaders(var Headers: HttpHeaders)
    begin
        Headers := ResponseHeaders;
    end;

    internal procedure GetRestMethod(): Text
    begin
        case "Rest Method" of
            "Rest Method"::get:
                exit('get');
            "Rest Method"::delete:
                exit('delete');
            "Rest Method"::patch:
                exit('patch');
            "Rest Method"::post:
                exit('post');
            "Rest Method"::put:
                exit('put');
        end;
    end;

}