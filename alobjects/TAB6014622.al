table 6014622 "Proxy Assembly"
{
    // NPR4.15/VB/20150904 CASE 219606 Proxy utility for handling hardware communication
    // NPR5.00/NPKNAV/20160113  CASE 225607 NP Retail 2016
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name

    Caption = 'Proxy Assembly';
    DataPerCompany = false;

    fields
    {
        field(1;"Full Name";Text[250])
        {
            Caption = 'Full Name';
        }
        field(2;Version;Text[30])
        {
            Caption = 'Version';
        }
        field(10;Binary;BLOB)
        {
            Caption = 'Binary';
        }
        field(20;"Register Map";BLOB)
        {
            Caption = 'Cash Register Map';
        }
        field(90;Name;Text[250])
        {
            Caption = 'Name';
        }
        field(98;"Last Modified Time";DateTime)
        {
            Caption = 'Last Modified Time';
        }
        field(99;Guid;Guid)
        {
            Caption = 'Guid';
        }
    }

    keys
    {
        key(Key1;"Full Name",Version)
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text001: Label 'Import New Assembly';
        Text002: Label 'Dynamic Link Libraries';
        Text003: Label 'All Files';
        Text004: Label 'Assembly %1, version %2 already exists. Do you want to re-import the assembly binary?\(This will overwrite existing binary and force reinstallation of the assembly to all registers.)';
        Text005: Label 'Assembly %1 already exists in version %2. If you continue with the import, the existing assembly will be replaced. What do you want to do?';
        Text006: Label 'Keep version %1 (%2),Import version %3 (%4)';
        Text007: Label 'Older,Newer';

    procedure ImportWithDialog(): Boolean
    var
        ProxyAssembly: Record "Proxy Assembly";
        ProxyAssembly2: Record "Proxy Assembly";
        POSDeviceProxyManager: Codeunit "POS Device Proxy Manager";
        FileManagement: Codeunit "File Management";
        Assembly: DotNet Assembly;
        AssemblyName: DotNet AssemblyName;
        DotNetFile: DotNet File;
        FileName: Text;
        Version1OlderNewer: Text;
        Version2OlderNewer: Text;
        KeepReplace: Integer;
    begin
        FileName := FileManagement.UploadFileWithFilter(
          Text001,'',Text002 + ' (*.dll)|*.dll|' + Text003 + ' (*.*)|*.*','*.*');
        if FileName <> '' then begin
          Assembly := Assembly.Load(DotNetFile.ReadAllBytes(FileName));
          AssemblyName := Assembly.GetName();

          ProxyAssembly."Full Name" := AssemblyName.FullName;
          ProxyAssembly.Version := AssemblyName.Version.ToString();
          ProxyAssembly.Name := AssemblyName.Name;

          if ProxyAssembly.Find then begin
            if not Confirm(Text004,false,ProxyAssembly."Full Name",ProxyAssembly.Version) then
              exit;
          end else begin
            ProxyAssembly2.SetRange(Name,ProxyAssembly.Name);
            if ProxyAssembly2.FindFirst() then begin
              if ProxyAssembly2.Version < ProxyAssembly.Version then begin
                Version1OlderNewer := SelectStr(1,Text007);
                Version2OlderNewer := SelectStr(2,Text007);
                KeepReplace := 2;
              end else begin
                Version1OlderNewer := SelectStr(2,Text007);
                Version2OlderNewer := SelectStr(1,Text007);
                KeepReplace := 1;
              end;
              if StrMenu(
                StrSubstNo(Text006,ProxyAssembly2.Version,Version1OlderNewer,ProxyAssembly.Version,Version2OlderNewer),
                KeepReplace,
                StrSubstNo(Text005,ProxyAssembly2.Name,ProxyAssembly2.Version)) < 2
              then
                exit;
              ProxyAssembly2.Delete;
            end;
            ProxyAssembly.Insert();
          end;

          Clear(ProxyAssembly."Register Map");
          ProxyAssembly.Binary.Import(FileName);
          ProxyAssembly."Last Modified Time" := CurrentDateTime;
          ProxyAssembly.Modify();

          POSDeviceProxyManager.ResetInstalledAssemblies();
        end;
    end;
}

