page 88000 "NPR APIV1InstalledApps"
{
    APIGroup = 'bcpt';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    DelayedInsert = true;
    DeleteAllowed = false;
    Editable = false;
    EntityCaption = 'Installed App';
    EntitySetCaption = 'Installed Apps';
    EntityName = 'installedApp';
    EntitySetName = 'installedApps';
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    ODataKeyFields = "App ID";
    PageType = API;
    SourceTableTemporary = true;
    SourceTable = "NAV App Installed App";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(appId; Rec."App ID")
                {
                    Caption = 'appId', Locked = true;
                }
                field(name; Rec.Name)
                {
                    Caption = 'name', Locked = true;
                }
                field(publisher; Rec.Publisher)
                {
                    Caption = 'publisher', Locked = true;
                }

                field(packageId; Rec."Package ID")
                {
                    Caption = 'packageId', Locked = true;
                }
                field(versionMajor; Rec."Version Major")
                {
                    Caption = 'versionMajor', Locked = true;
                }
                field(versionMinor; Rec."Version Minor")
                {
                    Caption = 'versionMinor', Locked = true;
                }
                field(versionBuild; Rec."Version Build")
                {
                    Caption = 'versionBuild', Locked = true;
                }
                field(versionRevision; Rec."Version Revision")
                {
                    Caption = 'versionRevision', Locked = true;
                }
            }
        }
    }

    procedure GetRequiredApps(var Apps: Dictionary of [Guid, Text])
    begin
        Apps.Add('992c2309-cca4-43cb-9e41-911f482ec088', 'NP Retail');
        Apps.Add('ef12bed6-ad9b-4460-b8ee-be8dc0e6fb6c', 'NP Retail Performance Toolkit');
        Apps.Add('75f1590f-55c5-4501-ae63-bada5534e852', 'Performance Toolkit');
    end;

    trigger OnInit()
    var
        TmpAppId: Guid;
        Info: ModuleInfo;
    begin
        if Rec.IsTemporary() then begin
            Rec.DeleteAll();
            GetRequiredApps(RequiredApps);
            foreach TmpAppId in RequiredApps.Keys() do
                if (NavApp.GetModuleInfo(TmpAppId, Info)) then begin
                    Rec.Init();
                    Rec."App ID" := Info.Id;
                    Rec.Name := CopyStr(Info.Name, 1, MaxStrLen(Rec.Name));
                    Rec.Publisher := CopyStr(Info.Publisher, 1, MaxStrLen(Rec.Publisher));
                    Rec."Package ID" := Info.PackageId;
                    Rec."Version Major" := Info.AppVersion.Major;
                    Rec."Version Minor" := Info.AppVersion.Minor;
                    Rec."Version Build" := Info.AppVersion.Build;
                    Rec."Version Revision" := Info.AppVersion.Revision;
                    Rec.Insert();
                end;
        end;
    end;

    var
        RequiredApps: Dictionary of [Guid, Text];
}