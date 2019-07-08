codeunit 6150699 "Retail Data Model Upgrade Mgt."
{
    // NPR5.30/AP  /20170209 CASE 261728 Initail upgrade build. Create new NPRetailSetup, POS Units, POS Stores and POS Payment Bins with basic parameters.
    // NPR5.30/MMV /20170221 CASE 261964 Initialize new tax free structure.
    //                                   EXIT out based on clienttype or permissions.
    // NPR5.30/TJ  /20170222 CASE 266258 Step 3 skipped
    // NPR5.30/AP  /20170222 CASE 261728 Re-arranged GetCurrentDataModelBuild-function to place it on top (easier to se current Data Model Build)
    //                                   Added seperate entry point for Data Upgrade CU and changed back TestUpgradeDataModel to local scope
    // NPR5.30.01/MMV /20170330 CASE 271098 Fixed errors in step 2.
    // NPR5.32/AP  /20170501 CASE 274285 Possible to re-run Build Steps. Better visibilty for log entries.
    // NPR5.32/MMV /20170507 CASE 241995 Added step 4 - Retail print upgrade.
    // NPR5.38/MMV /20180119 CASE 300683 Skip subscriber when installing extension
    // TM1.39/THRO/20181126 CASE 334644 Replaced Coudeunit 1 by Wrapper Codeunit


    trigger OnRun()
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        "Code": Code[10];
    begin
        RunSilent := false;
        TestUpgradeDataModel;
    end;

    var
        NPRetailSetup: Record "NP Retail Setup";
        RunSilent: Boolean;
        TxtDefaultPaymentBinDescription: Label 'Cash Drawer %1';

    local procedure GetCurrentDataModelBuild(): Integer
    begin
        //EXIT(1); //Initial Data Model Build
        //EXIT(2); //-NPR5.30 [261964]
        //EXIT(3); //-NPR5.30 [266258]
        exit(4); //-NPR5.32 [241995]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014427, 'OnAfterCompanyOpen', '', true, true)]
    local procedure TestUpgradeOnAfterCompanyOpen()
    var
        NavAppMgt: Codeunit "Nav App Mgt";
    begin
        //-NPR5.38 [300683]
        if NavAppMgt.NavAPP_IsInstalling then
          exit;
        //+NPR5.38 [300683]

        if not (CurrentClientType in [CLIENTTYPE::Windows,CLIENTTYPE::Web,CLIENTTYPE::Tablet,CLIENTTYPE::Phone,CLIENTTYPE::Desktop,CLIENTTYPE::NAS]) then
          exit;

        if not NPRetailSetup.WritePermission then
          exit;

        RunSilent := true;
        TestUpgradeDataModel;
        Commit; //Commit changes and release lock.
    end;

    procedure TestUpgradeFromDataUpgradePerCompany()
    begin
        RunSilent := true;
        //-NPR5.32 [274285]
        //CreateLogEntry('Data Model upgrade invoked from Data Upgrade Per Company.',0,0,0);
        CreateLogEntry('Data Model upgrade invoked from Data Upgrade Per Company.',0,0,-1);
        //+NPR5.32 [274285]
        TestUpgradeDataModel;
    end;

    local procedure TestUpgradeDataModel()
    begin
        with NPRetailSetup do begin
          LockTable;
          if not Get then begin
            Init;
            Insert;
            CreateLogEntry(StrSubstNo('Initial execution!, %1 created.',NPRetailSetup.TableName),0,0,0);
          end;

          if "Data Model Build" >= GetCurrentDataModelBuild then
            exit;

          CreateLogEntry(StrSubstNo('Data model upgrade started. Upgrading from build %1 to %2',"Data Model Build",GetCurrentDataModelBuild),0,0,"Data Model Build");

          "Prev. Data Model Build" := "Data Model Build";
          "Data Model Build" := UpgradeDataModel("Prev. Data Model Build" + 1,GetCurrentDataModelBuild);
          "Last Data Model Build Upgrade" := CurrentDateTime;
          "Last Data Model Build User ID" := UserId;
          Modify;

          CreateLogEntry(StrSubstNo('Data model upgrade ended.'),0,0,"Data Model Build");
        end;
    end;

    local procedure UpgradeDataModel(FromBuild: Integer;ToBuild: Integer): Integer
    var
        BuildStep: Integer;
    begin
        for BuildStep := FromBuild to ToBuild do
          if BuildStep > 0 then begin
            CreateLogEntry(StrSubstNo('Data model upgrade build %1 started...',BuildStep),0,0,BuildStep);
            case BuildStep of
              1: UpgradeDataModelBuildStep1;
              //-NPR5.30 [261964]
              2: UpgradeDataModelBuildStep2;
              //+NPR5.30 [261964]
              //-NPR5.30 [266258]
              3:;
              //+NPR5.30 [266258]
              //-NPR5.32 [241995]
              4: UpgradeDataModelBuildStep4;
              //+NPR5.32 [241995]
              else
                begin
                  CreateLogEntry(StrSubstNo('Data model upgrade for Buildstep %1 not defined!',BuildStep),1,2,BuildStep);
                  exit(BuildStep);
                end;
            end;
            CreateLogEntry(StrSubstNo('...data model upgrade build %1 ended',BuildStep),0,0,BuildStep);
          end;
        exit(BuildStep);
    end;

    local procedure TryOpenTable(var RecRef: RecordRef;TableNo: Integer;TableName: Text[50]): Boolean
    var
        AllObj: Record AllObj;
        AllObjWithCap: Record AllObjWithCaption;
    begin
        if not AllObj.Get(AllObj."Object Type"::Table,TableNo) then
          exit(false);
        Clear(RecRef);
        RecRef.Open(TableNo);
        if TableName <> '' then
          exit(AllObj."Object Name" = TableName)
        else
          exit(true);
    end;

    local procedure TryGetField(var RecRef: RecordRef;var FieldRef: FieldRef;FieldNo: Integer;FieldName: Text): Boolean
    var
        "Field": Record "Field";
    begin
        if not Field.Get(RecRef.Number,FieldNo) then
          exit(false);
        Clear(FieldRef);
        FieldRef := RecRef.Field(FieldNo);
        if FieldName <> '' then
          exit(Field.FieldName = FieldName)
        else
          exit(true);
    end;

    local procedure CreateLogEntry(LogText: Text[100];LogIndent: Integer;LogType: Option Message,Warning,Error;LogBuildNo: Integer)
    var
        DataModelUpgradeLogEntry: Record "Data Model Upgrade Log Entry";
    begin
        if (not RunSilent) and (LogType = LogType::Error) then
          Error(LogText);

        with DataModelUpgradeLogEntry do begin
          Init;
          "Entry No." := 0;
          "Data Model Build" := LogBuildNo;
          Text := LogText;
          "User ID" := UserId;
          "Date and Time"  := CurrentDateTime;
          Type := LogType;
          Indent := LogIndent;
          Insert;
        end;
    end;

    procedure ReRunUpgradeBuilds(FromBuildStep: Integer;ToBuildStep: Integer)
    var
        d: Dialog;
    begin
        //-NPR5.32 [274285]
        if FromBuildStep = ToBuildStep then begin
          if not Confirm('Re-run Data Model Upgrade Build Step %1?',false,FromBuildStep,ToBuildStep) then
            exit;
        end else
          if not Confirm('Re-run Data Model Upgrade from Build Step %1 to Build Step %2?',false,FromBuildStep,ToBuildStep) then
            exit;

        NPRetailSetup.LockTable;
        NPRetailSetup.Get;

        CreateLogEntry(StrSubstNo('Data Model upgrade from Build Step %1 to Build Step %2 invoked from Re-Run action',FromBuildStep,ToBuildStep),0,0,-1);
        RunSilent := false;
        UpgradeDataModel(FromBuildStep,ToBuildStep);

        NPRetailSetup."Last Data Model Build Upgrade" := CurrentDateTime;
        NPRetailSetup."Last Data Model Build User ID" := UserId;
        if ToBuildStep > NPRetailSetup."Data Model Build" then
          NPRetailSetup."Data Model Build" := ToBuildStep;
        NPRetailSetup.Modify;
        //+NPR5.32 [274285]
    end;

    procedure ReRunFromLogEntry(DataModelUpgradeLogEntry: Record "Data Model Upgrade Log Entry")
    begin
        //-NPR5.32 [274285]
        if DataModelUpgradeLogEntry."Data Model Build" < 1 then
          Error('Cannot re-run Build Step %1',DataModelUpgradeLogEntry."Data Model Build");
        ReRunUpgradeBuilds(DataModelUpgradeLogEntry."Data Model Build",DataModelUpgradeLogEntry."Data Model Build");
        //+NPR5.32 [274285]
    end;

    local procedure UpgradeDataModelBuildStep1()
    var
        POSUnit: Record "POS Unit";
        POSStore: Record "POS Store";
        POSPaymentBin: Record "POS Payment Bin";
        POSStoreCode: Code[10];
        LocationCode: Code[10];
        RecRef: RecordRef;
        FieldRef: FieldRef;
        HasRegistersWithLocationCode: Boolean;
        HasRegistersWithoutLocationCode: Boolean;
    begin
        //Retail Setup
        if TryOpenTable(RecRef,6014400,'Retail Setup') then begin
          if RecRef.FindFirst then begin
            if TryGetField(RecRef,FieldRef,20,'Posting Source Code') then
              NPRetailSetup."Source Code" := FieldRef.Value;
          end;
        end;

        //Create POS Stores, POS Units and POS Payment Bins from Registers
        if TryOpenTable(RecRef,6014401,'Register') then begin
          if not RecRef.FindSet then
            CreateLogEntry(StrSubstNo('No existing cash registers found!',POSUnit.TableCaption,POSUnit."No."),1,1,1)
          else repeat //Initail test-only run
            if TryGetField(RecRef,FieldRef,8,'Location Code') then begin
              if Format(FieldRef.Value) = '' then
                HasRegistersWithoutLocationCode := true
              else
                HasRegistersWithLocationCode := true;
            end else
              HasRegistersWithoutLocationCode := true;
          until RecRef.Next = 0;
          if RecRef.FindSet then repeat
            if TryGetField(RecRef,FieldRef,1,'Register No.') then begin
              if not POSUnit.Get(FieldRef.Value) then begin
                POSUnit.Init;
                POSUnit."No." := FieldRef.Value;
                POSUnit."Default POS Payment Bin" := POSUnit."No.";
                if TryGetField(RecRef,FieldRef,256,'Name') then
                  POSUnit.Name := FieldRef.Value;
                POSUnit.Insert;
                CreateLogEntry(StrSubstNo('Created %1 %2',POSUnit.TableCaption,POSUnit."No."),1,0,1);
              end;
              if not POSPaymentBin.Get(POSUnit."Default POS Payment Bin") then begin
                POSPaymentBin.Init;
                POSPaymentBin."No." := POSUnit."Default POS Payment Bin";
                POSPaymentBin.Description := StrSubstNo(TxtDefaultPaymentBinDescription,POSPaymentBin."No.");
                POSPaymentBin."Attached to POS Unit No." := POSUnit."No.";
                POSPaymentBin.Insert;
                CreateLogEntry(StrSubstNo('Created %1 %2',POSPaymentBin.TableCaption,POSPaymentBin."No."),1,0,1);
              end;

              //If all registers has location code - then use that as store code.
              //If no registers has location code - then use '1' as store code.
              //Else create store code for each register
              if TryGetField(RecRef,FieldRef,8,'Location Code') then
                LocationCode := FieldRef.Value
              else
                LocationCode := '';

              if (HasRegistersWithoutLocationCode and (not HasRegistersWithLocationCode)) then
                POSStoreCode := '1'
              else if ((not HasRegistersWithoutLocationCode) and HasRegistersWithLocationCode) then
                POSStoreCode := LocationCode
              else
                POSStoreCode := POSUnit."No.";

              if not POSStore.Get(POSStoreCode) then begin
                POSStore.Init;
                POSStore.Code := POSStoreCode;
                POSStore."Location Code" := LocationCode;
                POSStore.Insert;
                CreateLogEntry(StrSubstNo('Created %1 %2',POSStore.TableCaption,POSStore.Code),1,0,1);
              end;
              //Store name and address inherited from Register
              if POSStore.Name = '' then
                if TryGetField(RecRef,FieldRef,256,'Name') then
                  POSStore.Name := CopyStr(Format(FieldRef.Value),1,MaxStrLen(POSStore.Name));
              if POSStore."Name 2" = '' then
                if TryGetField(RecRef,FieldRef,23,'Name 2') then
                  POSStore."Name 2" := CopyStr(Format(FieldRef.Value),1,MaxStrLen(POSStore."Name 2"));
              if POSStore.Address = '' then
                if TryGetField(RecRef,FieldRef,257,'Address') then
                  POSStore.Address := CopyStr(Format(FieldRef.Value),1,MaxStrLen(POSStore.Address));
              if POSStore."Post Code" = '' then
                if TryGetField(RecRef,FieldRef,259,'Post Code') then
                  POSStore."Post Code" := CopyStr(Format(FieldRef.Value),1,MaxStrLen(POSStore."Post Code"));
              if POSStore.City = '' then
                if TryGetField(RecRef,FieldRef,258,'City') then
                  POSStore.City := CopyStr(Format(FieldRef.Value),1,MaxStrLen(POSStore.City));
              if POSStore."Phone No." = '' then
                if TryGetField(RecRef,FieldRef,260,'Telephone') then
                  POSStore."Phone No." := CopyStr(Format(FieldRef.Value),1,MaxStrLen(POSStore."Phone No."));
              if POSStore."Fax No." = '' then
                if TryGetField(RecRef,FieldRef,261,'Fax') then
                  POSStore."Fax No." := CopyStr(Format(FieldRef.Value),1,MaxStrLen(POSStore."Fax No."));
              if POSStore."E-Mail" = '' then
                if TryGetField(RecRef,FieldRef,268,'E-mail') then
                  POSStore."E-Mail" := CopyStr(Format(FieldRef.Value),1,MaxStrLen(POSStore."E-Mail"));
              if POSStore."Home Page" = '' then
                if TryGetField(RecRef,FieldRef,274,'www-address') then
                  POSStore."Home Page" := CopyStr(Format(FieldRef.Value),1,MaxStrLen(POSStore."Home Page"));
              if POSStore."VAT Registration No." = '' then
                if TryGetField(RecRef,FieldRef,267,'VAT No.') then
                  POSStore."VAT Registration No." := CopyStr(Format(FieldRef.Value),1,MaxStrLen(POSStore."VAT Registration No."));
              //Store posting setup
              if POSStore."Gen. Bus. Posting Group" = '' then
                if TryGetField(RecRef,FieldRef,18,'Gen. Business Posting Group') then
                  POSStore."Gen. Bus. Posting Group" := FieldRef.Value;
              if POSStore."VAT Bus. Posting Group" = '' then
                if TryGetField(RecRef,FieldRef,19,'VAT Gen. Business Post.Gr') then
                  POSStore."VAT Bus. Posting Group" := FieldRef.Value;
              POSStore.Modify;

              //Set Store Code on POS Unit if not set already
              if POSUnit."POS Store Code" = '' then begin
                POSUnit."POS Store Code" := POSStore.Code;
                POSUnit.Modify;
              end;
            end;
          until RecRef.Next = 0;
          RecRef.Close;
        end;
    end;

    local procedure UpgradeDataModelBuildStep2()
    var
        TaxFreeUnit: Record "Tax Free POS Unit";
        TaxFreeVoucher: Record "Tax Free Voucher";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        MerchantID: Text[20];
        VATNumber: Text[20];
        CountryCode: Text[3];
        AmountThreshold: Decimal;
        CheckPrefix: Boolean;
        POSUnitNo: Code[10];
    begin
        //-NPR5.30 [261964]
        TaxFreeVoucher.SetRange("Handler ID", '');
        if not TaxFreeVoucher.IsEmpty then begin
          TaxFreeVoucher.ModifyAll("Handler ID", 'PREMIER_PI');
          CreateLogEntry(StrSubstNo('Updated existing %1 records',TaxFreeVoucher.TableCaption),1,0,2);
        end;

        if not TryOpenTable(RecRef,6014401,'Register') then
          exit;

        if not TryGetField(RecRef, FieldRef, 700, 'Tax Free Enabled') then
          exit;

        FieldRef.SetRange(true);
        if RecRef.FindSet then repeat
          if TryGetField(RecRef, FieldRef, 1, 'Register No.') then
            POSUnitNo := FieldRef.Value;
          if not TaxFreeUnit.Get(POSUnitNo) then begin
            TaxFreeUnit.Init;
            //-NPR5.30.01 [271098]
            TaxFreeUnit."POS Unit No." := POSUnitNo;
            //+NPR5.30.01 [271098]
            if TryGetField(RecRef, FieldRef, 701, 'Tax Free Merchant ID') then
              MerchantID := FieldRef.Value;
            if TryGetField(RecRef, FieldRef, 702, 'Tax Free VAT Number') then
              VATNumber := FieldRef.Value;
            if TryGetField(RecRef, FieldRef, 703, 'Tax Free Country Code') then
              CountryCode := FieldRef.Value;
            if TryGetField(RecRef, FieldRef, 704, 'Tax Free Amount Threshold') then
              AmountThreshold := FieldRef.Value;
            if TryGetField(RecRef, FieldRef, 705, 'Tax Free Check Terminal Prefix') then
              CheckPrefix := FieldRef.Value;

            if CountryCode = '234' then
              TaxFreeUnit."Handler ID" := 'PREMIER_OFFLINE'
            else
              TaxFreeUnit."Handler ID" := 'PREMIER_PI';

            if (CountryCode = '208') and (MerchantID = '999001') and (VATNumber = 'DK0999001') then
              TaxFreeUnit.Mode := TaxFreeUnit.Mode::TEST;

            TaxFreeUnit."Check POS Terminal IIN" := CheckPrefix;
            TaxFreeUnit."Min. Sales Amount Incl. VAT" := AmountThreshold;

            if Step2_CreateParameterBlob(MerchantID, VATNumber, CountryCode, TaxFreeUnit) then begin
              TaxFreeUnit.Insert;
              CreateLogEntry(StrSubstNo('Created %1',TaxFreeUnit.TableCaption),1,0,2);
            end else
              Clear(TaxFreeUnit);
          end;
        until RecRef.Next = 0;
        //+NPR5.30 [261964]
    end;

    local procedure UpgradeDataModelBuildStep4()
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        Name: Text;
    begin
        //-NPR5.32 [241995]
        if TryOpenTable(RecRef, 6014561, 'RP Data Items') then
          if RecRef.FindSet(true) then repeat
            if TryGetField(RecRef, FieldRef, 12, 'Name') then begin
              Name := FieldRef.Value;
              if (Name[1] = '<') and (Name[StrLen(Name)] = '>') then begin
                FieldRef.Value := CopyStr(Name, 2, StrLen(Name)-2);
                RecRef.Modify;
              end;
            end;
          until RecRef.Next = 0;
        //+NPR5.32 [241995]
    end;

    local procedure "-- Auxiliary functions for steps"()
    begin
    end;

    [TryFunction]
    local procedure Step2_CreateParameterBlob(MerchantID: Text;VATNumber: Text;CountryCode: Text;var TaxFreeUnit: Record "Tax Free POS Unit")
    var
        tmpHandlerParameters: Record "Tax Free Handler Parameters" temporary;
    begin
        tmpHandlerParameters.Parameter := 'Merchant ID';
        tmpHandlerParameters."Data Type" := tmpHandlerParameters."Data Type"::Text;
        //-NPR5.30.01 [271098]
        //tmpHandlerParameters.Value := MerchantID;
        tmpHandlerParameters.Validate(Value, MerchantID);
        //+NPR5.30.01 [271098]
        tmpHandlerParameters.Insert;

        tmpHandlerParameters.Parameter := 'VAT Number';
        tmpHandlerParameters."Data Type" := tmpHandlerParameters."Data Type"::Text;
        //-NPR5.30.01 [271098]
        //tmpHandlerParameters.Value := VATNumber;
        tmpHandlerParameters.Validate(Value, VATNumber);
        //+NPR5.30.01 [271098]
        tmpHandlerParameters.Insert;

        tmpHandlerParameters.Parameter := 'Country Code';
        tmpHandlerParameters."Data Type" := tmpHandlerParameters."Data Type"::Integer;
        //-NPR5.30.01 [271098]
        //tmpHandlerParameters.Value := CountryCode;
        tmpHandlerParameters.Validate(Value, CountryCode);
        //+NPR5.30.01 [271098]
        tmpHandlerParameters.Insert;

        tmpHandlerParameters.SerializeParameterBLOB(TaxFreeUnit);
    end;
}

