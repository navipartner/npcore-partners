#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6248410 "NPR NP Email Try Send"
{
    Access = Internal;

    var
        _TemplateId: Code[20];
        _RecVariant: Variant;
        _RecipientAddress: Text[250];
        _PreferredLanguage: Code[10];

    trigger OnRun()
    var
        NPEmail: Codeunit "NPR NP Email";
    begin
        NPEmail.SendEmail(_TemplateId, _RecVariant, _RecipientAddress, _PreferredLanguage);
    end;

    internal procedure SetParameters(TemplateId: Code[20]; RecordVariant: Variant; RecipientAddress: Text[250]; PreferredLanguage: Code[10])
    begin
        _TemplateId := TemplateId;
        _RecVariant := RecordVariant;
        _RecipientAddress := RecipientAddress;
        _PreferredLanguage := PreferredLanguage;
    end;
}
#endif