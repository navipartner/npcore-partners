#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6248667 "NPR DynTemplateDataProvHelper"
{
    Access = Public;

    procedure FormatToTextFromLanguage(ValueToFormat: Variant; WindowsLanguageCode: Text[10]) FormattedText: Text
    var
        FormatMask: Text;
        OldLanguageId, NewLanguageId : Integer;
        Language: Codeunit Language;
    begin
        OldLanguageId := GlobalLanguage();
        NewLanguageId := Language.GetLanguageId(WindowsLanguageCode);
        if (NewLanguageId <> 0) and (OldLanguageId <> NewLanguageId) then
            GlobalLanguage(NewLanguageId);

        case true of
            ValueToFormat.IsDecimal():
                FormatMask := '<Precision,2><Standard Format,2>';
            ValueToFormat.IsDate(), ValueToFormat.IsDateTime(), ValueToFormat.IsTime():
                FormatMask := '<Standard Format,0>';
            else
                FormatMask := '';
        end;

        if TryFormatText(ValueToFormat, FormatMask, FormattedText) then;

        GlobalLanguage(OldLanguageId);
    end;

    [TryFunction]
    local procedure TryFormatText(ValueToFormat: Variant; FormatMask: Text; var FormattedText: Text)
    begin
        FormattedText := Format(ValueToFormat, 0, FormatMask);
    end;
}
#endif