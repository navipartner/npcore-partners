codeunit 6014422 "NP Environment Mgt."
{
    // Codeunit that can be polled for the current environment status.
    // Environment is defined as combo of database name, tenant name and company name.
    // 
    // Main purpose of codeunit being:
    // - To automatically block external integrations until someone has manually verified the environment, in case it changes.
    // - To allow for prompts to clear table data that should not be present in company copies unless they are PROD.
    // 
    // Please beware that the unverified status will not be set on environment change before either a NAS or user session enters a
    // company for the first time.
    // 
    // NPR5.31/NPKNAV/20170502  CASE 263473 Transport NPR5.31 - 2 May 2017
    // NPR5.32/MMV /20170509 CASE 275555 Added missing confirm for DC clean.
    //                                   Don't show message for verified demo environment.
    // 
    // NPR5.38/BHR/20171123 CASE 295477 Check if field exists. New version DC 4.50 does not contain field 33
    // NPR5.38/MMV /20171215 CASE 292825 Don't sleep infinitely if assumption that real session will end up in active session table breaks. (ie. NAV2018 extension install).
    // NPR5.38/LS  /20171218 CASE 300124 Set property OnMissingLicense to Skip for OnAfterCompanyOpen
    // NPR5.38/MMV /20180119 CASE 300683 Skip subscriber when installing extension
    // NPR5.40/MMV /20180316 CASE 307183 Removed DC check as they have fixed their problem.
    // NPR5.40/JDH /20180319 CASE 308001 Object moved from 6151300 to clear the object range
    // NPR5.42/MHA /20180525 CASE 314365 Added function DisableNpXmlTransfer()
    // TM1.39/THRO/20181126 CASE 334644 Replaced Coudeunit 1 by Wrapper Codeunit


    trigger OnRun()
    begin
    end;

    var
        Caption_OptionMessage: Label 'The current environment has changed and is no longer verified! \This is caused by a change in database, tenant or company.\Please verify the new company environment type below:';
        Caption_EnvironmentOption: Label 'Production,Demo,Testing,Development';
        Caption_NotProdEnv: Label 'The current environment is not set as production.\Some external integrations are handled differently in this mode. You can change this in page "%1"';
        Caption_UnverifiedWarning: Label 'The current environment has been set to unverified!\Some external integrations are handled differently in this mode. You can change this in page "%1"';
        Caption_CleanTaskQueue: Label 'Disable Task Queue tasks in this new environment?';
        Caption_CleanLessor: Label 'Disable Lessor in this new environment?';
        Caption_CleanDC: Label 'Disable Continia Document Capture in this new environment?';
        Caption_MissingPermissions: Label 'You are missing permissions for table %1. \If data scrub is necessary for this table in the new environment, then you must switch user/permissions and handle it manually.';
        NPRetailSetup: Record "NP Retail Setup";
        NPRetailSetupRead: Boolean;

    local procedure "// Accessors"()
    begin
    end;

    procedure IsProd(): Boolean
    begin
        if GetSetupRec() then
          exit( (NPRetailSetup."Environment Type" = NPRetailSetup."Environment Type"::PROD) and NPRetailSetup."Environment Verified" );
    end;

    procedure IsDemo(): Boolean
    begin
        if GetSetupRec() then
          exit( (NPRetailSetup."Environment Type" = NPRetailSetup."Environment Type"::DEMO) and NPRetailSetup."Environment Verified" );
    end;

    procedure IsTest(): Boolean
    begin
        if GetSetupRec() then
          exit( (NPRetailSetup."Environment Type" = NPRetailSetup."Environment Type"::TEST) and NPRetailSetup."Environment Verified" );
    end;

    procedure IsDev(): Boolean
    begin
        if GetSetupRec() then
          exit( (NPRetailSetup."Environment Type" = NPRetailSetup."Environment Type"::DEV) and NPRetailSetup."Environment Verified" );
    end;

    local procedure "// Event Publishers"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterEnvironmentTypeChange(var xRecTmp: Record "NP Retail Setup" temporary;var Rec: Record "NP Retail Setup")
    begin
    end;

    local procedure "// Event Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014427, 'OnAfterCompanyOpen', '', true, false)]
    local procedure OnAfterCompanyOpen()
    var
        NPRetailSetup: Record "NP Retail Setup";
        ActiveSession: Record "Active Session";
        NPRetailSetupPage: Page "NP Retail Setup";
        Iterations: Integer;
        NavAppMgt: Codeunit "Nav App Mgt";
    begin
        //-NPR5.38 [300683]
        if NavAppMgt.NavAPP_IsInstalling then
          exit;
        //+NPR5.38 [300683]

        if not (CurrentClientType in [CLIENTTYPE::Phone, CLIENTTYPE::Web, CLIENTTYPE::Windows, CLIENTTYPE::Tablet, CLIENTTYPE::Desktop, CLIENTTYPE::NAS]) then
          exit;

        if not NPRetailSetup.WritePermission then
          exit;

        //-NPR5.38 [292825]
        // WHILE (NOT ActiveSession.GET(SERVICEINSTANCEID, SESSIONID)) DO //Still necessary?
        //  SLEEP(10);
        while (not ActiveSession.Get(ServiceInstanceId, SessionId)) do begin
          Sleep(10);
          Iterations += 1;
          if Iterations > 50 then
            exit;
        end;
        //+NPR5.38 [292825]

        if CheckIfEmpty(NPRetailSetup, ActiveSession) then begin
          Commit;
          exit;
        end;

        if CheckIfTemplate(NPRetailSetup, ActiveSession) then begin
          Commit;
          exit;
        end;

        if CheckIfVerified(NPRetailSetup, ActiveSession) then begin
          if GuiAllowed then
            //-NPR5.32 [275555]
            //IF NPRetailSetup."Environment Type" <> NPRetailSetup."Environment Type"::PROD THEN
            if NPRetailSetup."Environment Type" in [NPRetailSetup."Environment Type"::DEV, NPRetailSetup."Environment Type"::TEST] then
            //+NPR5.32 [275555]
              Message(Caption_NotProdEnv, NPRetailSetupPage.Caption);
          exit;
        end;

        HandleEnvironmentChange(NPRetailSetup, ActiveSession);
    end;

    local procedure "// Aux"()
    begin
    end;

    local procedure GetSetupRec(): Boolean
    begin
        if not NPRetailSetupRead then
          NPRetailSetupRead := NPRetailSetup.Get();
        exit(NPRetailSetupRead);
    end;

    local procedure CheckIfEmpty(var NPRetailSetup: Record "NP Retail Setup";var ActiveSession: Record "Active Session"): Boolean
    var
        RecFound: Boolean;
        FirstTime: Boolean;
    begin
        //In a completely new environment, assume it is verified PROD to preserve the status-quo as before this module was created.
        RecFound := NPRetailSetup.Get;
        FirstTime := not RecFound;

        if RecFound then
          FirstTime := (StrLen(NPRetailSetup."Environment Company Name") = 0) and (StrLen(NPRetailSetup."Environment Database Name") = 0) and (StrLen(NPRetailSetup."Environment Tenant Name") = 0);

        if FirstTime then begin
          if not RecFound then
            NPRetailSetup.Init;
          NPRetailSetup."Environment Company Name" := CompanyName;
          NPRetailSetup."Environment Database Name" := ActiveSession."Database Name";
          NPRetailSetup."Environment Tenant Name" := TenantId;
          NPRetailSetup."Environment Type" := NPRetailSetup."Environment Type"::PROD;
          NPRetailSetup."Environment Verified" := true;
          if RecFound then
            NPRetailSetup.Modify
          else
            NPRetailSetup.Insert;
          exit(true);
        end;
    end;

    local procedure CheckIfTemplate(var NPRetailSetup: Record "NP Retail Setup";var ActiveSession: Record "Active Session"): Boolean
    begin
        if NPRetailSetup."Environment Template" and NPRetailSetup."Environment Verified" then begin
          if (NPRetailSetup."Environment Company Name" <> CompanyName) or (NPRetailSetup."Environment Database Name" <> ActiveSession."Database Name") or (NPRetailSetup."Environment Tenant Name" <> TenantId) then begin
            NPRetailSetup."Environment Template" := false;
            NPRetailSetup."Environment Company Name" := CompanyName;
            NPRetailSetup."Environment Database Name" := ActiveSession."Database Name";
            NPRetailSetup."Environment Tenant Name" := TenantId;
            NPRetailSetup.Modify;
          end;
          exit(true);
        end;
    end;

    local procedure CheckIfVerified(var NPRetailSetup: Record "NP Retail Setup";var ActiveSession: Record "Active Session"): Boolean
    begin
        if NPRetailSetup."Environment Verified" then
          if (NPRetailSetup."Environment Company Name" = CompanyName) and (NPRetailSetup."Environment Database Name" = ActiveSession."Database Name") and (NPRetailSetup."Environment Tenant Name" = TenantId) then
            exit(true)
          else begin
            NPRetailSetup."Environment Verified" := false;
            NPRetailSetup.Modify;
          end;
    end;

    local procedure HandleEnvironmentChange(var NPRetailSetup: Record "NP Retail Setup";var ActiveSession: Record "Active Session")
    var
        Type: Integer;
        NPRetailSetupPage: Page "NP Retail Setup";
        xRecTmp: Record "NP Retail Setup" temporary;
    begin
        xRecTmp := NPRetailSetup;
        xRecTmp.Insert;

        if GuiAllowed then begin
          Type := StrMenu(Caption_EnvironmentOption, 3, Caption_OptionMessage);
          if Type > 0 then begin
            NPRetailSetup."Environment Company Name" := CompanyName;
            NPRetailSetup."Environment Database Name" := ActiveSession."Database Name";
            NPRetailSetup."Environment Tenant Name" := TenantId;
            NPRetailSetup."Environment Type" := Type-1;
            NPRetailSetup."Environment Verified" := true;
            NPRetailSetup.Modify;
          end;

          if not NPRetailSetup."Environment Verified" then
            Message(Caption_UnverifiedWarning, NPRetailSetupPage.Caption);

          if (xRecTmp."Environment Type" <> NPRetailSetup."Environment Type") and (NPRetailSetup."Environment Type" <> NPRetailSetup."Environment Type"::PROD) then
            PromptDataScrub;
        end;

        Commit;

        OnAfterEnvironmentTypeChange(xRecTmp, NPRetailSetup);
    end;

    local procedure PromptDataScrub()
    begin
        CheckTaskQueue();
        //-NPR5.40 [307183]
        // CheckDocumentCapture();
        // CheckLessor();
        //+NPR5.40 [307183]
        //-NPR5.42 [314365]
        DisableNpXmlTransfer();
        //+NPR5.42 [314365]
    end;

    local procedure "// Data Scrub Functions"()
    begin
    end;

    local procedure CheckTaskQueue()
    var
        TaskLine: Record "Task Line";
    begin
        if not TaskLine.ReadPermission then begin
          Message(Caption_MissingPermissions, TaskLine.TableCaption);
          exit;
        end;

        TaskLine.SetRange(Enabled, true);
        if TaskLine.IsEmpty then
          exit;

        if not Confirm(Caption_CleanTaskQueue) then
          exit;

        if not TaskLine.WritePermission then begin
          Message(Caption_MissingPermissions, TaskLine.TableCaption);
          exit;
        end;

        TaskLine.ModifyAll(Enabled, false)
    end;

    local procedure DisableNpXmlTransfer()
    var
        NpXmlTemplate: Record "NpXml Template";
    begin
        //-NPR5.42 [314365]
        if not NpXmlTemplate.WritePermission then
          exit;

        NpXmlTemplate.SetRange("File Transfer",true);
        if NpXmlTemplate.FindFirst then
          NpXmlTemplate.ModifyAll("File Transfer",false,false);

        NpXmlTemplate.Reset;
        NpXmlTemplate.SetRange("FTP Transfer",true);
        if NpXmlTemplate.FindFirst then
          NpXmlTemplate.ModifyAll("FTP Transfer",false,false);

        NpXmlTemplate.Reset;
        NpXmlTemplate.SetRange("API Transfer",true);
        if NpXmlTemplate.FindFirst then
          NpXmlTemplate.ModifyAll("API Transfer",false,false);
        //+NPR5.42 [314365]
    end;
}

