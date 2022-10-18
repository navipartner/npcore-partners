codeunit 6059919 "NPR Videos"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::Video, 'OnRegisterVideo', '', false, false)]
    local procedure OnRegisterVideo(var sender: Codeunit Video)
    var
        VarModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(VarModuleInfo);
        POSUnitSetupGeneralSettings(sender, VarModuleInfo.Id);
        POSUnitSetupViewProfile(sender, VarModuleInfo.Id);
        POSStoreSetup(sender, VarModuleInfo.Id);
    end;

    local procedure POSUnitSetupGeneralSettings(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://share.synthesia.io/embeds/videos/40f96b2f-14c7-4819-998b-33844664def0', locked = true;
        TitleLbl: Label 'POS Unit Setup 01 - General Settings';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure POSUnitSetupViewProfile(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://share.synthesia.io/embeds/videos/4e245403-f49a-4f99-af37-17b9383a129e', locked = true;
        TitleLbl: Label 'POS Unit Setup 03 - View Profile';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;

    local procedure POSStoreSetup(var Video: Codeunit Video; AppID: Guid)
    var
        VideoLbl: Label 'https://share.synthesia.io/embeds/videos/acb03dd9-507e-4ef8-8800-171f16ec8e0a', locked = true;
        TitleLbl: Label 'POS Store Setup';
    begin
        Video.Register(AppID, TitleLbl, VideoLbl, Enum::"Video Category"::NPR);
    end;
}