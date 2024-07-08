codeunit 6059873 "NPR System App. Version Check"
{
    Access = Internal;

    procedure GetVersionFromVersionSegments(MajorVersion: Integer): Version
    begin
        exit(GetVersionFromVersionSegments(MajorVersion, 0));
    end;

    procedure GetVersionFromVersionSegments(MajorVersion: Integer; MinorVersion: Integer) TargetVersion: Version
    begin
        TargetVersion := Version.Create(MajorVersion, MinorVersion);
    end;

    procedure GetSystemAppVersion(): Version
    var
        SystemAppModuleInfo: ModuleInfo;
    begin
        SystemAppModuleInfo := GetSystemApplicationModuleInfo();
        exit(SystemAppModuleInfo.AppVersion());
    end;

    procedure GetSystemApplicationModuleInfo() SystemAppModuleInfo: ModuleInfo
    begin
        NavApp.GetModuleInfo(GetSystemApplicationId(), SystemAppModuleInfo);
        exit(SystemAppModuleInfo);
    end;

    procedure GetSystemApplicationId(): Guid
    begin
        exit('63ca2fa4-4f03-4f2b-a480-172fef340d3f');
    end;
}