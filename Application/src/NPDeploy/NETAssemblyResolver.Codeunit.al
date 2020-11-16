codeunit 6014626 "NPR .NET Assembly Resolver"
{
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        Text001: Label 'Dynamic .NET assembly resolver was not installed because the corresponding .NET interop add-in is not configured. Please configure it, otherwise you will not be able to use NP Retail solution.';
        Resolver: DotNet NPRNetAssemblyResolver;
        AssembliesLoaded: Boolean;

    local procedure ResolveAssemblies()
    var
        Asmbl: Record "NPR .NET Assembly";
    begin
        with Asmbl do begin
            SetFilter("User ID", '%1|%2', '', UserId);
            if FindSet() then
                repeat
                    ResolveAssembly(Asmbl);
                until Next = 0;
        end;
    end;

    local procedure ResolveAssembly(Asmbl: Record "NPR .NET Assembly")
    var
        Asm: DotNet NPRNetAssembly;
        Bytes: DotNet NPRNetArray;
        Pdb: DotNet NPRNetArray;
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

    local procedure LoadAssemblyBytes(Asmbl: Record "NPR .NET Assembly"; var Bytes: DotNet NPRNetArray; var Pdb: DotNet NPRNetArray)
    var
        MemStr: DotNet NPRNetMemoryStream;
        MemStrPdb: DotNet NPRNetMemoryStream;
        InStr: InStream;
        Byte: Byte;
    begin
        with Asmbl do begin
            CalcFields(Assembly, "Debug Information");
            Assembly.CreateInStream(InStr);
            MemStr := MemStr.MemoryStream();
            CopyStream(MemStr, InStr);
            Bytes := MemStr.ToArray();

            Clear(InStr);
            "Debug Information".CreateInStream(InStr);
            MemStrPdb := MemStrPdb.MemoryStream();
            CopyStream(MemStrPdb, InStr);
            Pdb := MemStrPdb.ToArray();
        end;
    end;

    local procedure InstallAssemblyResolver()
    var
        Asm: DotNet NPRNetAssembly;
        [RunOnClient]
        AsmClient: DotNet NPRNetAssembly;
        "Object": DotNet NPRNetObject;
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnAfterInitialization', '', true, true)]
    local procedure OnAfterInitialization()
    begin
        if NavApp.IsInstalling() then
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

