codeunit 6060099 "NPR Import Playwright NPR Data"
{
    Access = Internal;

    trigger OnRun()
    var
        AllObj: Record AllObj;
        Attempts: Integer;
        UserPosUnitMapping: Dictionary of [Code[50], Code[10]];
    begin
        //We've had problems that invoking this codeunit on a container programmatically right after publishing npretail give errors on missing npretail tables. 
        //This shouldn't be possible NST behaviour, so we try to workaround what appears to be a race condition in MS end by delaying up to 100 seconds:        

        while (not AllObj.Get(AllObj."Object Type"::Table, 6014404) and (Attempts < 10)) do begin
            Attempts += 1;
            Sleep(1000 * 10);
        end;

        // User to PosUnit mapping
        UserPosUnitMapping.Add('RESTUSER', '04');
        UserPosUnitMapping.Add('MPOSUSER', '03');
        UserPosUnitMapping.Add('E2EWORKER1', '01');
        UserPosUnitMapping.Add('E2EWORKER2', '');
        UserPosUnitMapping.Add('E2EWORKER3', '');
        UserPosUnitMapping.Add('E2EWORKER4', '');
        UserPosUnitMapping.Add('E2EWORKER5', '');
        UserPosUnitMapping.Add('E2EWORKER6', '');

        //ImportRapidPackageFromFeed('MINIMAL-NPR.rapidstart');

        AssignPosUnitsToUsers(UserPosUnitMapping, '01');
    end;

    [NonDebuggable]
    procedure ImportRapidPackageFromFeed(package: Text)
    var
        autoRapidstartImportLog: Record "NPR Auto Rapidstart Import Log";
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        rapidStartBaseDataMgt: Codeunit "NPR RapidStart Base Data Mgt.";
        BaseUri: Text;
        packageName: Text;
        Secret: Text;
    begin
        packageName := package.Replace('.rapidstart', '');

        //Can be invoked in crane environment to auto import test data. Prevent multiple invocations on container re-creation.        
        if autoRapidstartImportLog.Get(packageName) then
            exit;

        BaseUri := 'https://npretailbasedata.blob.core.windows.net';
        Secret := AzureKeyVaultMgt.GetAzureKeyVaultSecret('NpRetailBaseDataSecret');

        BindSubscription(rapidStartBaseDataMgt);
        rapidStartBaseDataMgt.ImportPackage(
                        BaseUri + '/pos-test-data/' + package + '?sv=2019-10-10&ss=b&srt=co&sp=rlx&se=2050-06-23T00:45:22Z&st=2020-06-22T16:45:22Z&spr=https&sig=' + Secret, packageName, false);

        autoRapidstartImportLog."Package Name" := CopyStr(packageName, 1, MaxStrLen(autoRapidstartImportLog."Package Name"));
        autoRapidstartImportLog.Insert();
    end;

    procedure AssignPosUnitsToUsers(UserPosUnitMapping: Dictionary of [Code[50], Code[10]]; FromPosUnitCode: Code[10])
    var
        User: Record User;
        PosUnit: Record "NPR POS Unit";
        UserName: Code[50];
        PosUnitCode: Code[10];
    begin
        foreach UserName in UserPosUnitMapping.Keys() do begin
            Clear(PosUnit);
            Clear(User);
            User.SetRange("User Name", UserName);
            if (User.FindFirst()) then begin
                // Get PosUnit
                PosUnitCode := UserPosUnitMapping.Get(UserName);
                if PosUnitCode = '' then
                    CreatePosUnitFromTemplate(PosUnit, FromPosUnitCode)
                else
                    GetPosUnit(PosUnit, PosUnitCode);

                // Assign
                if not AssignPosUnitToUser(PosUnit, User) then
                    Error('Unable to assign %1 to %2', PosUnit."No.", User."User Name");

            end else
                Error('Unable to find user %1', UserName);
        end;
    end;

    internal procedure CreatePosUnitFromTemplate(var PosUnit: Record "NPR POS Unit"; FromPosUnitCode: Code[10]): Boolean
    var
        POSPaymentBin: Record "NPR POS Payment Bin";
        PosUnitTemplate: Record "NPR POS Unit";
        PosUnitNewNo: Code[10];
    begin
        if not PosUnitTemplate.Get(FromPosUnitCode) then
            Error('Unable to find POS Unit %1', FromPosUnitCode);

        PosUnitNewNo := GeneratePosUnitNo();

        PosUnit.Init();
        PosUnit.Copy(PosUnitTemplate);
        PosUnit.Validate("No.", PosUnitNewNo);
        PosUnit.Insert(true);

        CreatePOSPaymentBin(POSPaymentBin, PosUnitNewNo);

        POSUnit."Default POS Payment Bin" := POSPaymentBin."No.";
        POSUnit.Modify();
    end;

    internal procedure GetPosUnit(var PosUnit: Record "NPR POS Unit"; PosUnitCode: Code[10])
    var
        POSPaymentBin: Record "NPR POS Payment Bin";
    begin
        PosUnit.Get(PosUnitCode);

        if not POSPaymentBin.Get(PosUnitCode) then begin
            CreatePOSPaymentBin(POSPaymentBin, PosUnitCode);
            POSUnit."Default POS Payment Bin" := POSPaymentBin."No.";
            POSUnit.Modify();
        end;
    end;

    local procedure CreatePOSPaymentBin(var POSPaymentBin: Record "NPR POS Payment Bin"; PosUnitNewNo: Code[10])
    begin
        POSPaymentBin.Init();
        POSPaymentBin.Validate("No.", PosUnitNewNo);
        POSPaymentBin.Insert();
    end;

    internal procedure AssignPosUnitToUser(var PosUnit: Record "NPR POS Unit"; var User: Record User): Boolean
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.Get(User."User Name") then begin
            UserSetup.Validate("NPR POS Unit No.", POSUnit."No.");
            exit(UserSetup.Modify(true));
        end else begin
            UserSetup.Init();
            UserSetup.Validate("User ID", User."User Name");
            UserSetup.Validate("NPR POS Unit No.", POSUnit."No.");
            exit(UserSetup.Insert(true));
        end;
    end;

    internal procedure GeneratePosUnitNo() TempCode: Code[10]
    var
        PosUnit: Record "NPR POS Unit";
        TempText: Text;
    begin
        TempText := Format(System.CreateGuid()).Replace('{', '').Replace('}', '').Replace('-', '').Substring(1, 10);
        if PosUnit.Get(TempText) then
            exit(GeneratePosUnitNo())
        else begin
            TempCode := CopyStr(TempText, 1, 10);
            exit(TempCode);
        end;
    end;

}
