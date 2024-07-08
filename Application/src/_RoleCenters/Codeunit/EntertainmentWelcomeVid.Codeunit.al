codeunit 6060002 "NPR Entertainment Welcome Vid."
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
        WelcomeVideoENLinkTxt: Label 'https://share.synthesia.io/embeds/videos/246a0e21-d35c-4d7a-bb75-58fa982ec61c', Locked = true;
}
