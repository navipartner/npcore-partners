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
#if not BC17
        GuidedExperience: Codeunit "Guided Experience";
#endif
    begin
        case GlobalLanguage() of
            1036, 2060, 3084, 4108: //French
                Video.Play(WelcomeVideoENLinkTxt);
            1034, 2058, 3082: //Spanish
                Video.Play(WelcomeVideoENLinkTxt);
            1031, 2055, 3079: //German
                Video.Play(WelcomeVideoENLinkTxt);
            9242, 1050: //Serbian, Croatian
                Video.Play(WelcomeVideoENLinkTxt);
            1040, 2064: //Italian
                Video.Play(WelcomeVideoENLinkTxt);
            1053: //Swedish
                Video.Play(WelcomeVideoENLinkTxt);
            1030: //Danish
                Video.Play(WelcomeVideoENLinkTxt);
            1043: //Dutch (NL)
                Video.Play(WelcomeVideoENLinkTxt);
            else
                Video.Play(WelcomeVideoENLinkTxt);
        end;
#if not BC17
        GuidedExperience.CompleteAssistedSetup(ObjectType::Codeunit, Codeunit::"NPR Welcome Video");
#endif
    end;

    var
        WelcomeVideoENLinkTxt: Label 'https://share.synthesia.io/embeds/videos/ff1bec9e-473c-410a-bb23-cbf5185d5b25', Locked = true;
}
