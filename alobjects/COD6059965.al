codeunit 6059965 "MPOS Webservice"
{
    // NPR5.34/CLVA/20170703 CASE 280444 Upgrading MPOS functionality to transcendence
    // NPR5.36/CLVA/20170830 CASE 288630 Added register handling
    // NPR5.38/CLVA/20170830 CASE 297273 Added function GetCompanyInfo


    trigger OnRun()
    var
        WebService: Record "Web Service";
    begin
        Clear(WebService);

        if not WebService.Get(WebService."Object Type"::Codeunit,'mpos_service') then begin
          WebService.Init;
          WebService."Object Type" := WebService."Object Type"::Codeunit;
          WebService."Service Name" := 'mpos_service';
          WebService."Object ID" := 6059965;
          WebService.Published := true;
          WebService.Insert;
        end;
    end;

    [Scope('Personalization')]
    procedure GetCompanyLogo() PictureBase64: Text
    var
        CompanyInformation: Record "Company Information";
        BinaryReader: DotNet npNetBinaryReader;
        MemoryStream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
        InStr: InStream;
    begin
        CompanyInformation.Get;

        CompanyInformation.CalcFields(Picture);
        if CompanyInformation.Picture.HasValue then begin
          CompanyInformation.Picture.CreateInStream(InStr);
          MemoryStream := InStr;
          BinaryReader := BinaryReader.BinaryReader(InStr);
          PictureBase64 := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));
          MemoryStream.Dispose;
          Clear(MemoryStream);
        end;

        exit(PictureBase64);
    end;

    [Scope('Personalization')]
    procedure GetRegisterList() RegisterList: Text
    var
        Register: Record Register;
        Counter: Integer;
    begin
        if Register.FindFirst then begin
          repeat
            if Counter = 0 then
              RegisterList += StrSubstNo('%1 - %2',Register."Register No.",Register.Description)
            else
              RegisterList += StrSubstNo(',%1 - %2',Register."Register No.",Register.Description);
            Counter += 1;
          until Register.Next = 0;
        end;

        exit(RegisterList);
    end;

    [Scope('Personalization')]
    procedure SetRegister(CurrentUser: Code[50];RegisterId: Code[10]): Boolean
    var
        Register: Record Register;
        UserSetup: Record "User Setup";
        POSUnitIdentity: Record "POS Unit Identity";
    begin
        if not UserSetup.Get(CurrentUser) then
          exit;

        if not Register.Get(RegisterId) then
          exit;

        if UserSetup."Backoffice Register No." <> RegisterId then begin
          UserSetup.Validate("Backoffice Register No.",RegisterId);
          UserSetup.Modify(true);
        end;

        //NPR5.36-
        POSUnitIdentity.SetRange("Device ID",'WebBrowser');
        if POSUnitIdentity.FindSet then begin
          if POSUnitIdentity."Default POS Unit No." <> RegisterId then begin
            POSUnitIdentity.Validate("Default POS Unit No.",RegisterId);
            POSUnitIdentity.Modify(true);
          end;
        end;
        //NPR5.36+

        exit(true);
    end;

    [Scope('Personalization')]
    procedure GetCompanyInfo(): Text
    var
        CompanyInformation: Record "Company Information";
        BinaryReader: DotNet npNetBinaryReader;
        MemoryStream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
        InStr: InStream;
        JObject: DotNet npNetJObject;
        JTokenWriter: DotNet npNetJTokenWriter;
        Base64String: Text;
        MPOSHelperFunctions: Codeunit "MPOS Helper Functions";
    begin
        CompanyInformation.Get;

        CompanyInformation.CalcFields(Picture);
        if CompanyInformation.Picture.HasValue then begin
          CompanyInformation.Picture.CreateInStream(InStr);
          MemoryStream := InStr;
          BinaryReader := BinaryReader.BinaryReader(InStr);
          Base64String := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));
          MemoryStream.Dispose;
          Clear(MemoryStream);
        end;

        JTokenWriter := JTokenWriter.JTokenWriter;
        with JTokenWriter do begin
          WriteStartObject;
          WritePropertyName('Base64Image');
          WriteValue(Base64String);
          WritePropertyName('Username');
          WriteValue(MPOSHelperFunctions.GetUsername());
          WritePropertyName('DatabaseName');
          WriteValue(MPOSHelperFunctions.GetDatabaseName());
          WritePropertyName('TenantID');
          WriteValue(MPOSHelperFunctions.GetTenantID());
          WritePropertyName('CompanyName');
          WriteValue(CompanyName);
          WriteEndObject;
          JObject := Token;
        end;

        exit(JObject.ToString);
    end;
}

