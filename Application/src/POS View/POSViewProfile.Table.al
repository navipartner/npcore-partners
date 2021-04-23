table 6150651 "NPR POS View Profile"
{
    Caption = 'POS View Profile';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS View Profiles";
    LookupPageID = "NPR POS View Profiles";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "Client Formatting Culture ID"; Text[30])
        {
            Caption = 'Client Formatting Culture ID';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Client Formatting Culture ID" <> xRec."Client Formatting Culture ID" then begin
                    "Client Decimal Separator" := '';
                    "Client Thousands Separator" := '';
                    DetectDecimalThousandsSeparator();
                end;
            end;
        }
        field(11; "Client Decimal Separator"; Text[1])
        {
            Caption = 'Client Decimal Separator';
            DataClassification = CustomerContent;
        }
        field(12; "Client Thousands Separator"; Text[1])
        {
            Caption = 'Client Thousands Separator';
            DataClassification = CustomerContent;
        }
        field(13; "Client Date Separator"; Text[1])
        {
            Caption = 'Client Date Separator';
            DataClassification = CustomerContent;
        }
        field(14; "Culture Info (Serialized)"; Blob)
        {
            Caption = 'Culture Info (Serialized)';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Use Media instead of Blob type. "NPR POS View Profile"."Culture Info (Serialized)" -> "NPR POS View Profile"."Culture Info (Serializ.)"';
        }
        field(15; "Culture Info (Serializ.)"; Media)
        {
            Caption = 'Culture Info (Serialized)';
            DataClassification = CustomerContent;
        }
        field(20; Picture; Blob)
        {
            Caption = 'Picture';
            DataClassification = CustomerContent;
            SubType = Bitmap;
            ObsoleteState = Removed;
            ObsoleteReason = 'Use Media instead of Blob type. "NPR POS View Profile".Picture -> "NPR POS View Profile".Image';
        }
        field(21; Image; Media)
        {
            Caption = 'Picture';
            DataClassification = CustomerContent;
        }
        field(30; "POS Theme Code"; Code[10])
        {
            Caption = 'POS Theme Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Theme";
        }
        field(40; "Line Order on Screen"; Option)
        {
            Caption = 'Line Order on Screen';
            DataClassification = CustomerContent;
            OptionCaption = 'Normal (new at the end),Reverse (new on top),After Selected Line';
            OptionMembers = Normal,Reverse,AutoSplitKey;
        }
        field(50; "Initial Sales View"; Option)
        {
            Caption = 'Initial Sales View';
            DataClassification = CustomerContent;
            OptionCaption = 'Sales View,Restaurant View';
            OptionMembers = SALES_VIEW,RESTAURANT_VIEW;
        }
        field(55; "After End-of-Sale View"; Option)
        {
            Caption = 'After End-of-Sale View';
            DataClassification = CustomerContent;
            OptionCaption = 'Initial Sales View,Login View';
            OptionMembers = INITIAL_SALE_VIEW,LOGIN_VIEW;
        }
        field(60; "Lock Timeout"; Enum "NPR POS View LockTimeout")
        {
            Caption = 'Lock Timeout';
            DataClassification = CustomerContent;
        }
        field(70; "Tax Type"; Option)
        {
            Caption = 'Tax Type';
            DataClassification = CustomerContent;
            OptionMembers = VAT,"Sales Tax";
            OptionCaption = 'VAT,Sales Tax';
        }
        field(6232; "POS - Show discount fields"; Boolean)
        {
            Caption = 'Show Discount';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    trigger OnInsert()
    begin
        DetectDecimalThousandsSeparator();
    end;

    local procedure ToCamelCase(String: Text): Text;
    var
        Builder: TextBuilder;
    begin
        // Some well-known properties that won't camel-case automatically
        case String of
            'amDesignator':
                exit('AMDesignator');
            'pmDesignator':
                exit('PMDesignator');
        end;

        Builder.Append(String.Substring(1, 1).ToUpper());
        if (StrLen(String)) > 1 then
            Builder.Append(String.Substring(2));
        exit(Builder.ToText());
    end;

    local procedure ConvertPropertyNamesToCamelCase(Object: JsonObject);
    var
        Property: Text;
        Token: JsonToken;
        Element: JsonToken;
    begin
        foreach Property in Object.Keys do begin
            Object.Get(Property, Token);
            Object.Remove(Property);
            Object.Add(ToCamelCase(Property), Token);
            if (Token.IsObject()) then
                ConvertPropertyNamesToCamelCase(Token.AsObject());
            if (Token.IsArray()) then
                foreach Element in Token.AsArray() do begin
                    if Element.IsObject() then
                        ConvertPropertyNamesToCamelCase(Element.AsObject());
                end;
        end;
    end;

    [TryFunction]
    local procedure GetLocaleFormatsFromAzure(var Formats: JsonObject);
    var
        Http: HttpClient;
        Response: HttpResponseMessage;
        CouldNotRetrieve: Label 'We could not retrieve the culture info due to an error.\\%1';
        ResponseText: Text;
    begin
        //Error('TODO: This function requires an API url.');
        // TODO: We need to sort-out the URL below. Right now, it's a local function api on my machine. No good.

        if not Http.Get(StrSubstNo('https://navipartner-af-dotnet-1-0-0.azurewebsites.net/api/GetLocaleFormats?code=GaBaj0Iepwn2nIizkdMO%2FuozjcRPEg%2FwClLNl49cI4MU%2FoZYFQegww%3D%3D&locale=%1', "Client Formatting Culture ID"), Response) then begin
            // We need to see the message unconditionally. Simply doing Error would not show anything, and would exit with false.
            Message(CouldNotRetrieve, GetLastErrorText);
            Error('');
        end;

        Response.Content.ReadAs(ResponseText);
        if not Response.IsSuccessStatusCode() then begin
            // We need to see the message unconditionally. Simply doing Error would not show anything, and would exit with false.
            Message(CouldNotRetrieve, StrSubstNo('%1 %2', Response.HttpStatusCode, ResponseText));
            Error('');
        end;

        Formats.ReadFrom(ResponseText);
        ConvertPropertyNamesToCamelCase(Formats);

        exit(true);
    end;

    [TryFunction]
    local procedure GetLocaleFormatsFromAzureAndCacheThem(var CultureJson: JsonObject);
    var
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
    begin
        GetLocaleFormatsFromAzure(CultureJson);

        TempBlob.CreateOutStream(OutStr);
        "Culture Info (Serializ.)".ExportStream(OutStr);
        CultureJson.WriteTo(OutStr);
    end;

    procedure DetectDecimalThousandsSeparator()
    var
        Culture: Codeunit DotNet_CultureInfo;
        CultureJson: JsonObject;
        JsonMgt: Codeunit "NPR POS JSON Management";
    begin
        if "Client Formatting Culture ID" = '' then
            "Client Formatting Culture ID" := Culture.CurrentCultureName();

        GetLocaleFormatsFromAzureAndCacheThem(CultureJson);

        if ("Client Decimal Separator" = '') or ("Client Thousands Separator" = '') or ("Client Date Separator" = '') then begin
            if "Client Decimal Separator" = '' then
                "Client Decimal Separator" := JsonMgt.GetTokenFromPath(CultureJson, 'NumberFormat.NumberDecimalSeparator').AsValue().AsText();
            if "Client Thousands Separator" = '' then
                "Client Thousands Separator" := JsonMgt.GetTokenFromPath(CultureJson, 'NumberFormat.NumberGroupSeparator').AsValue().AsText();
            if "Client Date Separator" = '' then
                "Client Date Separator" := JsonMgt.GetTokenFromPath(CultureJson, 'DateFormat.DateSeparator').AsValue().AsText();
        end;
    end;

    // Fallback, when web service is unavailable, default format information for da-DK is used
    local procedure GetDefaultFormats() Formats: JsonObject;
    var
        NumberFormat: JsonObject;
        DateFormat: JsonObject;
        DayNames: JsonArray;
    begin
        Formats.Add('NumberFormat', NumberFormat);
        Formats.Add('DateFormat', DateFormat);

        NumberFormat.Add('NumberGroupSeparator', '.');
        NumberFormat.Add('NumberDecimalSeparator', ',');
        NumberFormat.Add('CurrencySymbol', 'kr.');
        NumberFormat.Add('NumberDecimalDigits', 2);

        DateFormat.Add('ShortTimePattern', 'HH:mm');
        DateFormat.Add('ShortDatePattern', 'dd-MM-yyyy');
        DayNames.ReadFrom('["søndag", "mandag", "tirsdag", "onsdag", "torsdag", "fredag", "lørdag"]');
        DateFormat.Add('DayNames', DayNames);
    end;

    procedure GetLocaleFormats() Formats: JsonObject;
    var
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
    begin
        TestField("Client Formatting Culture ID");

        if not "Culture Info (Serializ.)".HasValue() then begin
            if not GetLocaleFormatsFromAzureAndCacheThem(Formats) then begin
                exit(GetDefaultFormats());
            end;

            Modify();
            exit(Formats);
        end;

        TempBlob.CreateInStream(InStr);
        Rec."Culture Info (Serializ.)".ImportStream(InStr, Rec.FieldName("Culture Info (Serializ.)"));
        Formats.ReadFrom(InStr);
        exit(Formats);
    end;

    procedure GetImageContent(var TenantMedia: Record "Tenant Media")
    begin
        TenantMedia.Init();
        if not Image.HasValue() then
            exit;
        if TenantMedia.Get(Image.MediaId()) then
            TenantMedia.CalcFields(Content);
    end;

    procedure GetDefaultMediaDescription(): Text
    var
        MediaDescription: Text;
    begin
        MediaDescription := StrSubstNo('%1 %2.%3', Rec.Code, Rec.Description, GetDefaultExtension());
        exit(MediaDescription);
    end;

    procedure GetDefaultExtension(): Text
    begin
        exit('png');
    end;
}