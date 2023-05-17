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
#if not BC17
        GuidedExperience: Codeunit "Guided Experience";
#endif
    begin
        case GlobalLanguage() of
            1036, 2060, 3084, 4108: //French
                Video.Play(WelcomeVideoFRLinkTxt);
            1034, 2058, 3082: //Spanish
                Video.Play(WelcomeVideoESLinkTxt);
            1031, 2055, 3079: //German
                Video.Play(WelcomeVideoDELinkTxt);
            9242, 1050: //Serbian, Croatian
                Video.Play(WelcomeVideoSRPHRVLinkTxt);
            1040, 2064: //Italian
                Video.Play(WelcomeVideoITLinkTxt);
            1053: //Swedish
                Video.Play(WelcomeVideoSVLinkTxt);
            1030: //Danish
                Video.Play(WelcomeVideoDALinkTxt);
            1043: //Dutch (NL)
                Video.Play(WelcomeVideoNLLinkTxt);
            else
                Video.Play(WelcomeVideoENLinkTxt);
        end;
#if not BC17
        GuidedExperience.CompleteAssistedSetup(ObjectType::Codeunit, Codeunit::"NPR Welcome Video");
#endif
    end;

    var
        WelcomeVideoENLinkTxt: Label 'https://share.synthesia.io/embeds/videos/d500f2a7-72ec-43fb-8c54-175326038b55', Locked = true;
        WelcomeVideoNLLinkTxt: Label 'https://www.youtube.com/embed/lGXBHhRE6Q4', Locked = true;
        WelcomeVideoFRLinkTxt: Label 'https://www.youtube.com/embed/w43FyjgNIss', Locked = true;
        WelcomeVideoESLinkTxt: Label '', Locked = true;
        WelcomeVideoDELinkTxt: Label '', Locked = true;
        WelcomeVideoSRPHRVLinkTxt: Label '', Locked = true;
        WelcomeVideoITLinkTxt: Label '', Locked = true;
        WelcomeVideoSVLinkTxt: Label '', Locked = true;
        WelcomeVideoDALinkTxt: Label '', Locked = true;
}
