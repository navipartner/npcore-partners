codeunit 6150652 "NPR Restaurant Welcome Vid."
{
    Access = Internal;

    trigger OnRun()
    begin
        PlayVideoForCertainLanguage();
    end;

    local procedure PlayVideoForCertainLanguage()
    var
        Video: Codeunit Video;
    begin
        Video.Play(WelcomeVideoENLinkTxt);
    end;

    var
        WelcomeVideoENLinkTxt: Label 'https://share.synthesia.io/embeds/videos/ff1bec9e-473c-410a-bb23-cbf5185d5b25', Locked = true;
}
