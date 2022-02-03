table 6150651 "NPR POS View Profile"
{
    Access = Internal;
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
            NotBlank = true;
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
            ObsoleteState = Removed;
            ObsoleteReason = 'Use Client* fields to prepare culture info.';
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
            ObsoleteState = Removed;
            ObsoleteReason = 'Use Client* fields to prepare culture info.';
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
        field(22; "Client Currency Symbol"; Text[10])
        {
            Caption = 'Client Currency Symbol';
            DataClassification = CustomerContent;
        }
        field(23; "Client Number Decimal Digits"; Integer)
        {
            Caption = 'Client Number Decimal Digits';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(24; "Client Short Date Pattern"; Text[30])
        {
            Caption = 'Client Short Date Pattern';
            DataClassification = CustomerContent;
        }

        field(25; "Client Day Names"; Text[250])
        {
            Caption = 'Client Day Names';
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
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to table 6014601 "NPR POS Security Profile"';
        }
        field(70; "Tax Type"; Option)
        {
            Caption = 'Tax Type';
            DataClassification = CustomerContent;
            OptionMembers = VAT,"Sales Tax";
            OptionCaption = 'VAT,Sales Tax';
            ObsoleteState = Removed;
            ObsoleteReason = 'Use ApplicationAreaMgmt.IsSalesTaxEnabled() to identify whether we are in Sales Tax environment';
        }
        field(80; "Show Prices Including VAT"; Boolean)
        {
            Caption = 'Show Prices Including VAT';
            DataClassification = CustomerContent;
        }
        field(5058; "Open Register Password"; Code[20])
        {
            Caption = 'Open POS Unit Password';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to table 6014601 "NPR POS Security Profile"';
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
        SetFormats(GetDefaultFormats());
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

    procedure SetFormats(CultureJson: JsonObject)
    var
        JsonMgt: Codeunit "NPR POS JSON Management";
        DayNames: JsonArray;
        Day: JsonToken;
        DayNamesString: Text;
    begin
        if "Client Decimal Separator" = '' then
            "Client Decimal Separator" := CopyStr(JsonMgt.GetTokenFromPath(CultureJson, 'NumberFormat.NumberDecimalSeparator').AsValue().AsText(), 1, MaxStrLen("Client Decimal Separator"));
        if "Client Thousands Separator" = '' then
            "Client Thousands Separator" := CopyStr(JsonMgt.GetTokenFromPath(CultureJson, 'NumberFormat.NumberGroupSeparator').AsValue().AsText(), 1, MaxStrLen("Client Thousands Separator"));
        if "Client Currency Symbol" = '' then
            "Client Currency Symbol" := CopyStr(JsonMgt.GetTokenFromPath(CultureJson, 'NumberFormat.CurrencySymbol').AsValue().AsText(), 1, MaxStrLen("Client Currency Symbol"));
        if "Client Number Decimal Digits" = 0 then
            "Client Number Decimal Digits" := JsonMgt.GetTokenFromPath(CultureJson, 'NumberFormat.NumberDecimalDigits').AsValue().AsInteger();

        if "Client Date Separator" = '' then
            "Client Date Separator" := CopyStr(JsonMgt.GetTokenFromPath(CultureJson, 'DateFormat.DateSeparator').AsValue().AsText(), 1, MaxStrLen("Client Date Separator"));
        if "Client Short Date Pattern" = '' then
            "Client Short Date Pattern" := CopyStr(JsonMgt.GetTokenFromPath(CultureJson, 'DateFormat.ShortDatePattern').AsValue().AsText(), 1, MaxStrLen("Client Short Date Pattern"));
        if "Client Day Names" = '' then begin
            DayNames := JsonMgt.GetTokenFromPath(CultureJson, 'DateFormat.DayNames').AsArray();
            DayNamesString := '';
            foreach Day in DayNames do begin
                if DayNamesString <> '' then
                    DayNamesString := DayNamesString + ',';
                DayNamesString += Day.AsValue().AsText();
            end;
            "Client Day Names" := CopyStr(DayNamesString, 1, MaxStrLen("Client Day Names"));
        end;

    end;

    internal procedure GetDefaultFormats() Formats: JsonObject;
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

        DateFormat.Add('ShortDatePattern', 'dd-MM-yyyy');
        DateFormat.Add('DateSeparator', '-');
        DayNames.ReadFrom('["søndag","mandag","tirsdag","onsdag","torsdag","fredag","lørdag"]');
        DateFormat.Add('DayNames', DayNames);
    end;

    local procedure GetClientFormats() Formats: JsonObject;
    var
        NumberFormat, DateFormat : JsonObject;
        DayNames: JsonArray;
        Days: List of [Text];
        Day: Text;
    begin
        Formats.Add('NumberFormat', NumberFormat);
        Formats.Add('DateFormat', DateFormat);

        NumberFormat.Add('NumberGroupSeparator', "Client Thousands Separator");
        NumberFormat.Add('NumberDecimalSeparator', "Client Decimal Separator");
        NumberFormat.Add('CurrencySymbol', "Client Currency Symbol");
        NumberFormat.Add('NumberDecimalDigits', "Client Number Decimal Digits");

        DateFormat.Add('ShortDatePattern', "Client Short Date Pattern");
        DateFormat.Add('DateSeparator', "Client Date Separator");
        if "Client Day Names" <> '' then begin
            Days := "Client Day Names".Split(',');
            foreach Day in Days do begin
                DayNames.Add(Day);
            end;
            DateFormat.Add('DayNames', DayNames);
        end;

    end;

    procedure GetLocalFormats() Formats: JsonObject;
    begin
        SetFormats(GetDefaultFormats());
        exit(GetClientFormats());
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
        FileNameLbl: Label '%1 %2.%3', Locked = true;
    begin
        MediaDescription := StrSubstNo(FileNameLbl, Rec.Code, Rec.Description, GetDefaultExtension());
        exit(MediaDescription);
    end;

    procedure GetDefaultExtension(): Text
    begin
        exit('png');
    end;
}
