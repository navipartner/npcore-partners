codeunit 6151404 "NPR Magento Functions"
{
    trigger OnRun()
    begin
    end;

    procedure "--- UI"()
    begin
    end;

    procedure LookupPicture(PictureType: Option Item,Brand,"Item Group",Attribute; PictureName: Text[250]): Text
    var
        MagentoPicture: Record "NPR Magento Picture";
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        InStr: InStream;
        MemoryStream: DotNet NPRNetMemoryStream;
        Size: Integer;
    begin
        MagentoPicture.FilterGroup(2);
        MagentoPicture.SetRange(Type, PictureType);
        MagentoPicture.FilterGroup(0);
        if MagentoPicture.Get(PictureType, PictureName) then;
        if PAGE.RunModal(PAGE::"NPR Magento Pictures", MagentoPicture) = ACTION::LookupOK then
            exit(MagentoPicture.Name);
        exit('');
    end;

    procedure NaviEditorEditBlob(var FieldRef: FieldRef) NewValue: Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        TextEditorDialog: Page "NPR Text Editor Dialog";
        Encoding: DotNet NPRNetEncoding;
        StreamReader: DotNet NPRNetStreamReader;
        InStr: InStream;
        OutStr: OutStream;
        HtmlText: Text;
    begin
        Clear(TempBlob);
        FieldRef.CalcField;
        TempBlob.FromFieldRef(FieldRef);

        TempBlob.CreateInStream(InStr);
        InStr.ReadText(HtmlText);
        Clear(TextEditorDialog);

        TextEditorDialog.InitTextEditorOptionKeyAndValueBuffer();
        // An example (override the standard toolbar (the first one) to show only specific options - bold, italic):
        // TextEditorDialog.AddTextEditorOptionKeyAndValue('toolbar1', 'bold italic');

        if TextEditorDialog.EditText(HtmlText) then begin
            Clear(TempBlob);
            if not (HtmlText in ['<p></p>', '<p><br data-mce-bogus="1"></p>']) then begin
                TempBlob.CreateOutStream(OutStr);
                OutStr.WriteText(HtmlText);
            end;

            TempBlob.ToFieldRef(FieldRef);
            exit(true);
        end;

        exit(false);
    end;

    procedure "--- Format Text"()
    begin
    end;

    local procedure ReplaceSpecialChar(Input: Text) Output: Text
    var
        i: Integer;
    begin
        Output := '';
        for i := 1 to StrLen(Input) do
            case Input[i] of
                '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
              'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
              'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
              'u', 'v', 'w', 'x', 'y', 'z', 'U', 'V', 'W', 'X', 'Y', 'Z', '-', '.':
                    Output += Format(Input[i]);
                'æ':
                    Output += 'ae';
                'ø', 'ö':
                    Output += 'oe';
                'å', 'ä':
                    Output += 'aa';
                'è', 'é', 'ë', 'ê':
                    Output += 'e';
                'Æ':
                    Output += 'AE';
                'Ø', 'Ö':
                    Output += 'OE';
                'Å', 'Ä':
                    Output += 'AA';
                'É', 'È', 'Ë', 'Ê':
                    Output += 'E';
                else
                    Output += '-';
            end;

        exit(Output);
    end;

    procedure SeoFormat(Input: Text) Output: Text
    var
        Position: Integer;
    begin
        Output := ReplaceSpecialChar(Input);

        Output := ConvertStr(Output, '.', '-');
        Position := StrPos(Output, '--');
        while Position <> 0 do begin
            Output := DelStr(Output, Position, 1);
            Position := StrPos(Output, '--');
        end;

        if StrLen(Output) > 0 then
            if Output[StrLen(Output)] = '-' then
                Output := CopyStr(Output, 1, StrLen(Output) - 1);

        exit(LowerCase(Output));
    end;

    procedure "--- Enum"()
    begin
    end;

    procedure "PictureType.Item"(): Integer
    begin
        exit(0);
    end;

    procedure "PictureType.Brand"(): Integer
    begin
        exit(1);
    end;

    procedure "PictureType.ItemGroup"(): Integer
    begin
        exit(2);
    end;

    procedure "PictureType.Attribute"(): Integer
    begin
        exit(3);
    end;
}

