#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
table 6151271 "NPR NPRE Menu Item Translation"
{
    Access = Internal;
    Extensible = false;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "External System Id"; Guid)
        {
            Caption = 'External System Id';
        }
        field(4; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            TableRelation = Language;
            NotBlank = true;
        }
        field(5; Title; Text[50])
        {
            Caption = 'Title';
        }
        field(6; "Description Markdown"; BLOB)
        {
            Caption = 'Description';
        }
        field(7; "Nutritional Info Markdown"; BLOB)
        {
            Caption = 'Nutritional Info';
        }
    }

    keys
    {
        key(pk; "External System Id", "Language Code")
        {
            Clustered = true;
        }
    }

    procedure GetItemDescription(): Text
    var
        InStr: InStream;
        Result: Text;
        Line: Text;
        NewLine: Char;
    begin
        CalcFields("Description Markdown");
        if not "Description Markdown".HasValue() then
            exit('');
        NewLine := 10; // Line Feed character
        "Description Markdown".CreateInStream(InStr, TextEncoding::UTF8);
        while not InStr.EOS() do begin
            InStr.ReadText(Line);
            if Result <> '' then
                Result += NewLine + Line
            else
                Result := Line;
        end;
        exit(Result);
    end;

    procedure SetItemDescription(NewValue: Text)
    var
        OutStr: OutStream;
    begin
        Clear("Description Markdown");
        "Description Markdown".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(NewValue);
    end;

    procedure GetNutritionalInfo(): Text
    var
        InStr: InStream;
        Result: Text;
        Line: Text;
        NewLine: Char;
    begin
        CalcFields("Nutritional Info Markdown");
        if not "Nutritional Info Markdown".HasValue() then
            exit('');
        NewLine := 10; // Line Feed character
        "Nutritional Info Markdown".CreateInStream(InStr, TextEncoding::UTF8);
        while not InStr.EOS() do begin
            InStr.ReadText(Line);
            if Result <> '' then
                Result += NewLine + Line
            else
                Result := Line;
        end;
        exit(Result);
    end;

    procedure SetNutritionalInfo(NewValue: Text)
    var
        OutStr: OutStream;
    begin
        Clear("Nutritional Info Markdown");
        "Nutritional Info Markdown".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(NewValue);
    end;
}
#endif
