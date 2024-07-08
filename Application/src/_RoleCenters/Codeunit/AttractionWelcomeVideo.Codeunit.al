codeunit 6060065 "NPR Attraction Welcome Video"
{
    Access = Internal;

    trigger OnRun()
    begin
        PlayVideo();
    end;

    local procedure PlayVideo()
    var
        Video: Codeunit Video;
    begin
        Video.Play(WelcomeVideoENLinkTxt);
    end;

    var
        WelcomeVideoENLinkTxt: Label 'https://www.youtube.com/embed/HcQqvpAnlOQ', Locked = true;
}
