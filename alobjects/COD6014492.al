codeunit 6014492 "NPR Environment Mgt."
{
    // Codeunit created by Jerome Cader
    // Functions used to replace deprecated ENVIRON function for Navision 2009 onwards
    // //-NPR6.001.000 JC 15-01-2013 Updated function EnvFunc to use .NET
    // NPR5.23/TTH/20160520 Checking for clienttype to allow the web client to Invoke web service to record time to Case system
    // NPR5.23/JDH /20160525 CASE 239435 check if .NET can be executed on all functions


    trigger OnRun()
    var
        RetournValueAsInteger: Integer;
        IpAddress: Text[30];
        PortNo: Text[10];
        PortStatus: Text[100];
        EnvProperty: Text[30];
    begin
    end;

    procedure ClientEnvironment(Property: Text[50]) Value: Text[1024]
    var
        [RunOnClient]
        Environment: DotNet Environment;
    begin
        //-NPR5.23 [239435]
        if not (CurrentClientType in [CLIENTTYPE::Windows, CLIENTTYPE::Desktop])then
          exit;
        //+NPR5.23 [239435]

        Value := Environment.GetEnvironmentVariable(Property);
    end;

    procedure ServerEnvironment(Property: Text[50]) Value: Text
    var
        [RunOnClient]
        Environment: DotNet Environment;
    begin
        //-NPR5.23 [239435]
        if not (CurrentClientType in [CLIENTTYPE::Windows, CLIENTTYPE::Desktop])then
          exit;
        //+NPR5.23 [239435]

        Value := Environment.GetEnvironmentVariable(Property);
    end;

    procedure "-- Client Side Information"()
    begin
    end;

    procedure GetWindowsPrincipalUsername(): Text
    var
        [RunOnClient]
        WindowsIndenty: DotNet WindowsIdentity;
    begin
        //-NPR5.23 [239435]
        if not (CurrentClientType in [CLIENTTYPE::Windows, CLIENTTYPE::Desktop])then
          exit;
        //+NPR5.23 [239435]

        exit(WindowsIndenty.GetCurrent().Name);
    end;

    procedure GetOSVersion(): Text[50]
    var
        [RunOnClient]
        Environment: DotNet Environment;
    begin
        //#-238210
        if (CurrentClientType in [CLIENTTYPE::Windows, CLIENTTYPE::Desktop])then
        //#+238210
          exit(Environment.OSVersion.ToString());
    end;
}

