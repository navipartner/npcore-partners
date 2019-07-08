codeunit 6014626 ".NET Assembly Resolver"
{
    // NPR4.17/VB/20151106 CASE 219641 Object created to support automatic assembly deployment
    // NPR5.00/NPKNAV/20160113  CASE 219606 NP Retail 2016
    // NPR5.00.01/VB/20160126  CASE 232615 Fixing issue with memory leak and multi-instance subscriptions to AssemblyResolve event
    // NPR5.00.04/VB/20160205 CASE 233815 Fixing logic.
    // NPR5.01/VB/20160209 CASE 232615 Final changes to assembly resolver
    // NPR5.01/VB/20160223 CASE 234541 Support for storing and using debug information at assembly deployment
    // NPR5.31/MMV /20170421 Upversioned Resolver assembly from 1.0.0.1 to 1.0.0.2 - this was previously done in a NPR5.28 change that apparently never made it out of W1_Dev.
    // NPR5.37/MMV /20171012 CASE 283546 Moved missing resolver warning from "after npdeploy" time to install time.
    // NPR5.37/MMV /20171017 CASE 293066 Updated resolver assembly to 2.4.0.0 and changed AL logic for using it.
    // NPR5.38/MMV /20180119 CASE 300683 Skip subscriber when installing extension
    // NPR5.45/MMV /20180904 CASE 327322 Allow background sessions to initialize assembly resolver if no other session has done it.
    // TM1.39/THRO/20181126 CASE 334644 Replaced Coudeunit 1 by Wrapper Codeunit

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        Text001: Label 'Dynamic .NET assembly resolver was not installed because the corresponding .NET interop add-in is not configured. Please configure it, otherwise you will not be able to use NP Retail solution.';
        Resolver: DotNet AssemblyResolver;
        AssembliesLoaded: Boolean;

    local procedure ResolveAssemblies()
    var
        Asmbl: Record ".NET Assembly";
    begin
        with Asmbl do begin
          SetFilter("User ID",'%1|%2','',UserId);
          if FindSet() then
            repeat
              ResolveAssembly(Asmbl);
            until Next = 0;
        end;
    end;

    local procedure ResolveAssembly(Asmbl: Record ".NET Assembly")
    var
        Asm: DotNet Assembly;
        Bytes: DotNet Array;
        Pdb: DotNet Array;
        Add: Boolean;
        CacheHash: Text;
    begin
        with Asmbl do begin
          if Resolver.TryGetAssemblyHash("Assembly Name", CacheHash) then
            Add := CacheHash <> "MD5 Hash"
          else
            Add := true;
          if Add then begin
            LoadAssemblyBytes(Asmbl, Bytes, Pdb);
            Resolver.AddAssembly("Assembly Name", Bytes, Pdb, "MD5 Hash");
          end;
        end;
    end;

    local procedure LoadAssemblyBytes(Asmbl: Record ".NET Assembly";var Bytes: DotNet Array;var Pdb: DotNet Array)
    var
        MemStr: DotNet MemoryStream;
        MemStrPdb: DotNet MemoryStream;
        InStr: InStream;
        Byte: Byte;
    begin
        with Asmbl do begin
          CalcFields(Assembly,"Debug Information");
          Assembly.CreateInStream(InStr);
          MemStr := MemStr.MemoryStream();
          CopyStream(MemStr,InStr);
          Bytes := MemStr.ToArray();

          Clear(InStr);
          "Debug Information".CreateInStream(InStr);
          MemStrPdb := MemStrPdb.MemoryStream();
          CopyStream(MemStrPdb,InStr);
          Pdb := MemStrPdb.ToArray();
        end;
    end;

    local procedure InstallAssemblyResolver()
    var
        Asm: DotNet Assembly;
        [RunOnClient]
        AsmClient: DotNet Assembly;
        "Object": DotNet Object;
    begin
        if not AssemblyResolverAvailable() then begin
          Message(Text001);
          exit;
        end;

        //-NPR5.45 [327322]
        if CurrentClientType = CLIENTTYPE::Background then
          if Resolver.Enabled then
            exit;
        //+NPR5.45 [327322]

        Resolver.Enabled := true;
        ResolveAssemblies();
    end;

    local procedure AssemblyResolverAvailable(): Boolean
    begin
        exit(CanLoadType(Resolver));
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014427, 'OnAfterCompanyOpen', '', true, true)]
    local procedure OnAfterCompanyOpen()
    var
        NavAppMgt: Codeunit "Nav App Mgt";
    begin
        if NavAppMgt.NavAPP_IsInstalling then
          exit;

        if IsSupportedClientType() then
          InstallAssemblyResolver();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014627, 'OnDependenciesDeployed', '', true, true)]
    local procedure OnDependenciesDeployed()
    begin
        if IsSupportedClientType and AssemblyResolverAvailable then
          InstallAssemblyResolver();
    end;

    local procedure IsSupportedClientType(): Boolean
    begin
        exit(CurrentClientType in [CLIENTTYPE::NAS,
                                   CLIENTTYPE::Desktop,
                                   CLIENTTYPE::Phone,
                                   CLIENTTYPE::Tablet,
                                   CLIENTTYPE::Web,
                                   CLIENTTYPE::Windows,
        //-NPR5.45 [327322]
                                   CLIENTTYPE::Background]);
        //+NPR5.45 [327322]
    end;
}

