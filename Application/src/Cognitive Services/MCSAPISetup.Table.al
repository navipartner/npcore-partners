table 6059955 "NPR MCS API Setup"
{
    Caption = 'MCS API Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; API; Enum "NPR MCS API Setup API")
        {
            Caption = 'API';
            DataClassification = CustomerContent;
        }
        field(2; BaseURL; Blob)
        {
            Caption = 'Base URL';
            DataClassification = CustomerContent;
        }
        field(11; "Key 1"; Text[50])
        {
            Caption = 'Key 1';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if IsNullGuid("Key 1 GUID") then
                    "Key 1 GUID" := CreateGuid();
                if IsolatedStorage.Contains("Key 1 GUID") then
                    IsolatedStorage.Delete("Key 1 GUID");
                if "Key 1" <> '' then begin
                    IsolatedStorage.Set("Key 1 GUID", "Key 1");
                    "Key 1" := '*';
                end;
            end;
        }
        field(12; "Key 2"; Text[50])
        {
            Caption = 'Key 2';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if IsNullGuid("Key 2 GUID") then
                    "Key 2 GUID" := CreateGuid();
                if IsolatedStorage.Contains("Key 2 GUID") then
                    IsolatedStorage.Delete("Key 2 GUID");
                if "Key 2" <> '' then begin
                    IsolatedStorage.Set("Key 2 GUID", "Key 2");
                    "Key 2" := '*';
                end;
            end;
        }
        field(13; "Image Orientation"; Enum "NPR MCS API Setup Image Orientation")
        {
            Caption = 'Image Orientation';
            DataClassification = CustomerContent;
        }
        field(14; "Use Cognitive Services"; Boolean)
        {
            Caption = 'Use Cognitive Services';
            DataClassification = CustomerContent;
        }
        field(20; "Key 1 GUID"; Guid)
        {
            Caption = 'Key 1 GUID';
            DataClassification = CustomerContent;
        }
        field(21; "Key 2 GUID"; Guid)
        {
            Caption = 'Key 2 GUID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; API)
        {
        }
    }
    procedure GetAPIKey1() Key1: Text
    begin
        TestField("Key 1");
        TestField("Key 1 GUID");
        IsolatedStorage.Get("Key 1 GUID", Key1);
    end;

    procedure GetAPIKey2() Key2: Text
    begin
        TestField("Key 2");
        TestField("Key 2 GUID");
        IsolatedStorage.Get("Key 2 GUID", Key2);
    end;

    procedure GetBaseUrl() Url: Text
    var
        InStr: InStream;
    begin
        CalcFields(BaseURL);
        if BaseURL.HasValue then begin
            BaseURL.CreateInStream(InStr);
            InStr.Read(Url);
        end;
    end;

    procedure SetBaseUrl(Url: Text)
    var
        WebRequestHelper: Codeunit "Web Request Helper";
        OutStr: OutStream;
    begin
        if Url <> '' then begin
            WebRequestHelper.IsValidUri(Url);
            WebRequestHelper.IsHttpUrl(Url);
        end;
        BaseURL.CreateOutStream(OutStr);
        OutStr.Write(Url);
    end;
}

