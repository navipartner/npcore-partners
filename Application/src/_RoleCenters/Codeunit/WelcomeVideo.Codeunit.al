codeunit 6060011 "NPR Welcome Video"
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
        WelcomeVideoENLinkTxt: Label 'https://share.synthesia.io/embeds/videos/d500f2a7-72ec-43fb-8c54-175326038b55', Locked = true;
}
