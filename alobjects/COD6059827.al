codeunit 6059827 "Upgrade NPR5.51"
{
    // [VLOBJUPG] Object may be deleted after upgrade
    // NPR5.51/MMV /20190812 CASE 356076 Created object.
    // NPR5.51/MMV /20190821 CASE 364694 Move from retailsetup to button action parameter.
    // NPR5.51/MMV /20190827 CASE 352248 Made mobilepay setup fields editable for support edge cases.
    // NPR5.51/ALST/20190909 CASE 337539 moved password field to Service password

    Subtype = Upgrade;

    trigger OnRun()
    begin
    end;

    [TableSyncSetup]
    procedure UpgradeTables(var TableSynchSetup: Record "Table Synch. Setup")
    var
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
    begin
        //-NPR5.51 [356076]
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"POS Workshift Checkpoint", 0, TableSynchSetup.Mode::Force); //Removing fields that are hotfixed into retail2018-nl but since refactored.
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"POS Entry", 0, TableSynchSetup.Mode::Force);
        //+NPR5.51 [356076]

        //-NPR5.51 [337539]
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"NpGp POS Sales Setup",DATABASE::"Upgrade NpGp POS Sales Setup",TableSynchSetup.Mode::Copy); //moving the password field to Service password
        //+NPR5.51 [337539]
    end;

    [UpgradePerCompany]
    procedure UpgradeData()
    begin
        MoveLoadSaleFilterSetup(); //-+NPR5.51 [364694]
        MakeGenericMobilepaySetupEditable(); //-+NPR5.51 [352248]

        MovePasswordNpGpPOSSalesSetup; //-+NPR5.51 [337539]
    end;

    procedure MoveLoadSaleFilterSetup()
    var
        RetailSetup: Record "Retail Setup";
        POSMenuButton: Record "POS Menu Button";
        POSAction: Record "POS Action";
        POSParameterValue: Record "POS Parameter Value";
        Int: Integer;
    begin
        //-NPR5.51 [364694]
        if not RetailSetup.Get then
          exit;

        POSMenuButton.SetRange("Action Type", POSMenuButton."Action Type"::Action);
        POSMenuButton.SetRange("Action Code", 'LOAD_FROM_POS_QUOTE');
        if not POSMenuButton.FindSet then
          exit;

        POSAction.DiscoverActions(); //Same as first POS open will do - this will detect new action parameters and add them to any button. We then correct this new parameter.

        repeat
          POSParameterValue.SetRange("Table No.", 6150701);
          POSParameterValue.SetRange(Code, POSMenuButton."Menu Code");
          POSParameterValue.SetRange("Record ID", POSMenuButton.RecordId);
          POSParameterValue.SetRange(ID, POSMenuButton.ID);
          POSParameterValue.SetRange(Name, 'Filter');
          if POSParameterValue.FindFirst then begin
            Int := RetailSetup."Show saved expeditions";
            POSParameterValue.Validate(Value, Format(Int));
            POSParameterValue.Modify;
          end;
        until POSMenuButton.Next = 0;
        //+NPR5.51 [364694]
    end;

    procedure MakeGenericMobilepaySetupEditable()
    var
        EFTTypePOSUnitGenParam: Record "EFT Type POS Unit Gen. Param.";
    begin
        //-NPR5.51 [352248]
        EFTTypePOSUnitGenParam.SetRange("Integration Type", 'MOBILEPAY');

        EFTTypePOSUnitGenParam.SetRange(Name, 'PoS Unit Assigned');
        EFTTypePOSUnitGenParam.ModifyAll("User Configurable", true);

        EFTTypePOSUnitGenParam.SetRange(Name, 'PoS Registered');
        EFTTypePOSUnitGenParam.ModifyAll("User Configurable", true);
        //+NPR5.51 [352248]
    end;

    [Normal]
    procedure MovePasswordNpGpPOSSalesSetup()
    var
        UpgradeNpGpPOSSalesSetup: Record "Upgrade NpGp POS Sales Setup";
        NpGpPOSSalesSetup: Record "NpGp POS Sales Setup";
        ServicePassword: Record "Service Password";
    begin
        //-NPR5.51 [337539]
        with UpgradeNpGpPOSSalesSetup do
          if FindSet then
            repeat
              NpGpPOSSalesSetup.Init;
              NpGpPOSSalesSetup.Code := Code;
              NpGpPOSSalesSetup."Company Name" := "Company Name";
              NpGpPOSSalesSetup."Service Url" := "Service Url";
              NpGpPOSSalesSetup."Service Username" := "Service Username";

              if "Service Password" <> '' then begin
                NpGpPOSSalesSetup."Service Password" := CreateGuid;
                ServicePassword.Key := NpGpPOSSalesSetup."Service Password";
                ServicePassword.Insert;

                ServicePassword.SavePassword("Service Password");
                ServicePassword.Modify;
              end;

              NpGpPOSSalesSetup."Sync POS Sales Immediately" := "Sync POS Sales Immediately";
              NpGpPOSSalesSetup.Insert;

              Delete;
            until Next = 0;
        //+NPR5.51 [337539]
    end;
}

