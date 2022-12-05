#if not BC17
codeunit 6060003 "NPR Entertainment Checklist"
{
    Access = Internal;
#if BC18 or BC19
    [EventSubscriber(ObjectType::Codeunit, Codeunit::LogInManagement, 'OnBeforeLogInStart', '', false, false)]
    local procedure OnBeforeLogInStart();
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnAfterLogin', '', false, false)]
    local procedure OnAfterLogin();
#endif
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not (Session.CurrentClientType() in [ClientType::Web, ClientType::Windows, ClientType::Desktop]) then
            exit;
        if UpgradeTag.HasUpgradeTag(GetUpgradeTag()) then
            exit;

        CreateChecklistItems();

        UpgradeTag.SetUpgradeTag(GetUpgradeTag());
    end;

    local procedure GetUpgradeTag(): Code[250]
    begin
        //For Any change, increase version
        exit('NPR-Checklist-v1.0');
    end;

    local procedure CreateChecklistItems();
    begin
        AddRoleToList(TempAllProfile, Page::"NPR Entertainment RC");

        CreateWelcomeVideoExperience();

        Checklist.MarkChecklistSetupAsDone();
#if not BC18
        Checklist.SetChecklistVisibility(true);
#endif
    end;

    local procedure AddRoleToList(var TempAllProfile: Record "All Profile" temporary; RoleCenterID: Integer)
    var
        AllProfile: Record "All Profile";
    begin
        AllProfile.SetRange("Role Center ID", RoleCenterID);
        AddRoleToList(AllProfile, TempAllProfile);
    end;

    local procedure AddRoleToList(var AllProfile: Record "All Profile"; var TempAllProfile: Record "All Profile" temporary)
    begin
        if AllProfile.FindFirst() then begin
            TempAllProfile.TransferFields(AllProfile);
            TempAllProfile.Insert();
        end;
    end;

    local procedure CreateWelcomeVideoExperience()
    var
        WelcomeVideoENTxt: Label 'Welcome Video', Locked = true;
    begin
        //Global Language
        GuidedExperience.InsertAssistedSetup(WelcomeVideoENTxt, WelcomeVideoENTxt, '', 2, ObjectType::Codeunit, Codeunit::"NPR Entertainment Welcome Vid.", "Assisted Setup Group"::GettingStarted, '', "Video Category"::GettingStarted, '');

        //In case that new language needs to be added, Language ID can be founded in table Windows Language (2000000045), Use just languages with filter "Localization Exist" and "Globally Enabled" set to true
#region Languages
#region English
        if CheckLanguageId(1033) then begin
            GuidedExperience.AddTranslationForSetupObjectTitle("Guided Experience Type"::"Assisted Setup", ObjectType::Codeunit, Codeunit::"NPR Entertainment Welcome Vid.", 1033, WelcomeVideoENTxt);
            GuidedExperience.AddTranslationForSetupObjectDescription("Guided Experience Type"::"Assisted Setup", ObjectType::Codeunit, Codeunit::"NPR Entertainment Welcome Vid.", 1033, '');
        end;
        if CheckLanguageId(2057) then begin
            GuidedExperience.AddTranslationForSetupObjectTitle("Guided Experience Type"::"Assisted Setup", ObjectType::Codeunit, Codeunit::"NPR Entertainment Welcome Vid.", 2057, WelcomeVideoENTxt);
            GuidedExperience.AddTranslationForSetupObjectDescription("Guided Experience Type"::"Assisted Setup", ObjectType::Codeunit, Codeunit::"NPR Entertainment Welcome Vid.", 2057, '');
        end;
        if CheckLanguageId(3081) then begin
            GuidedExperience.AddTranslationForSetupObjectTitle("Guided Experience Type"::"Assisted Setup", ObjectType::Codeunit, Codeunit::"NPR Entertainment Welcome Vid.", 3081, WelcomeVideoENTxt);
            GuidedExperience.AddTranslationForSetupObjectDescription("Guided Experience Type"::"Assisted Setup", ObjectType::Codeunit, Codeunit::"NPR Entertainment Welcome Vid.", 3081, '');
        end;
        if CheckLanguageId(4105) then begin
            GuidedExperience.AddTranslationForSetupObjectTitle("Guided Experience Type"::"Assisted Setup", ObjectType::Codeunit, Codeunit::"NPR Entertainment Welcome Vid.", 4105, WelcomeVideoENTxt);
            GuidedExperience.AddTranslationForSetupObjectDescription("Guided Experience Type"::"Assisted Setup", ObjectType::Codeunit, Codeunit::"NPR Entertainment Welcome Vid.", 4105, '');
        end;
        if CheckLanguageId(5129) then begin
            GuidedExperience.AddTranslationForSetupObjectTitle("Guided Experience Type"::"Assisted Setup", ObjectType::Codeunit, Codeunit::"NPR Entertainment Welcome Vid.", 5129, WelcomeVideoENTxt);
            GuidedExperience.AddTranslationForSetupObjectDescription("Guided Experience Type"::"Assisted Setup", ObjectType::Codeunit, Codeunit::"NPR Entertainment Welcome Vid.", 5129, '');
        end;
        if CheckLanguageId(7177) then begin
            GuidedExperience.AddTranslationForSetupObjectTitle("Guided Experience Type"::"Assisted Setup", ObjectType::Codeunit, Codeunit::"NPR Entertainment Welcome Vid.", 7177, WelcomeVideoENTxt);
            GuidedExperience.AddTranslationForSetupObjectDescription("Guided Experience Type"::"Assisted Setup", ObjectType::Codeunit, Codeunit::"NPR Entertainment Welcome Vid.", 7177, '');
        end;
#endregion
#endregion

        Checklist.Insert("Guided Experience Type"::"Assisted Setup", ObjectType::Codeunit, Codeunit::"NPR Entertainment Welcome Vid.", 1000, TempAllProfile, false);
        Checklist.InitializeGuidedExperienceItems();
    end;

    [TryFunction]
    local procedure CheckLanguageId(LanguageId: Integer)
    var
        Language: Codeunit Language;
    begin
        Language.ValidateWindowsLanguageId(LanguageId);
    end;

    var
        TempAllProfile: Record "All Profile" temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
}
#endif