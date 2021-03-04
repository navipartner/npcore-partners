codeunit 6150699 "NPR Retail Data Model Upg Mgt."
{
    //this codeunit is changed to Upgrade to handle Obsolete fields and it needs to be called from Powershell when upgrade from older databases is runned
    Subtype = Upgrade;

    trigger OnRun()
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        "Code": Code[10];
    begin
        RunSilent := false;
    end;

    var
        RunSilent: Boolean;
        TxtDefaultPaymentBinDescription: Label 'Cash Drawer %1';
        DataModelUpgInvokedTxt: Label 'Data Model upgrade invoked from Data Upgrade Per Company.';
        InitialExecutionTxt: Label 'Initial execution!, %1 created.', Comment = '%1=NPRetailSetup.TableName()';
        DataModelUpgStartedTxt: Label 'Data model upgrade started. Upgrading from build %1 to %2', Comment = '%1=NPRetailSetup."Data Model Build", %2=GetCurrentDataModelBuild()';
        DataModelUpgEndedTxt: Label 'Data model upgrade ended.';
        DataModelUpgStepTxt: Label 'Data model upgrade build %1 started...', Comment = '%1=BuildStep';
        DataModelUpgStepNotDefinedErr: Label 'Data model upgrade for Buildstep %1 not defined!', Comment = '%1=BuildStep';
        DataModelUpgStepEndedTxt: Label '...data model upgrade build %1 ended', Comment = '%1=BuildStep';

    local procedure GetCurrentDataModelBuild(): Integer
    begin
        exit(4);
    end;


    procedure TestUpgradeFromDataUpgradePerCompany()
    begin
        RunSilent := true;
        CreateLogEntry(DataModelUpgInvokedTxt, 0, 0, -1);
    end;
    local procedure UpgradeDataModel(FromBuild: Integer; ToBuild: Integer): Integer
    var
        BuildStep: Integer;
    begin
        for BuildStep := FromBuild to ToBuild do
            if BuildStep > 0 then begin
                CreateLogEntry(StrSubstNo(DataModelUpgStepTxt, BuildStep), 0, 0, BuildStep);
                case BuildStep of
                    1:
                        UpgradeDataModelBuildStep1();
                    2:
                        UpgradeDataModelBuildStep2();
                    3:
                        ;
                    4:
                        UpgradeDataModelBuildStep4();
                    else begin
                            CreateLogEntry(StrSubstNo(DataModelUpgStepNotDefinedErr, BuildStep), 1, 2, BuildStep);
                            exit(BuildStep);
                        end;
                end;
                CreateLogEntry(StrSubstNo(DataModelUpgStepEndedTxt, BuildStep), 0, 0, BuildStep);
            end;
        exit(BuildStep);
    end;

    local procedure TryOpenTable(var RecRef: RecordRef; TableNo: Integer; TableName: Text[50]): Boolean
    var
        AllObj: Record AllObj;
        AllObjWithCap: Record AllObjWithCaption;
    begin
        if not AllObj.Get(AllObj."Object Type"::Table, TableNo) then
            exit(false);
        Clear(RecRef);
        RecRef.Open(TableNo);
        if TableName <> '' then
            exit(AllObj."Object Name" = TableName)
        else
            exit(true);
    end;

    local procedure TryGetField(var RecRef: RecordRef; var FieldRef: FieldRef; FieldNo: Integer; FieldName: Text): Boolean
    var
        "Field": Record "Field";
    begin
        if not Field.Get(RecRef.Number, FieldNo) then
            exit(false);
        Clear(FieldRef);
        FieldRef := RecRef.Field(FieldNo);
        if FieldName <> '' then
            exit(Field.FieldName = FieldName)
        else
            exit(true);
    end;

    local procedure CreateLogEntry(LogText: Text[100]; LogIndent: Integer; LogType: Option Message,Warning,Error; LogBuildNo: Integer)
    var
        DataModelUpgradeLogEntry: Record "NPR Data Model Upg. Log Entry";
    begin
        if (not RunSilent) and (LogType = LogType::Error) then
            Error(LogText);

        DataModelUpgradeLogEntry.Init;
        DataModelUpgradeLogEntry."Entry No." := 0;
        DataModelUpgradeLogEntry."Data Model Build" := LogBuildNo;
        DataModelUpgradeLogEntry.Text := LogText;
        DataModelUpgradeLogEntry."User ID" := UserId;
        DataModelUpgradeLogEntry."Date and Time" := CurrentDateTime;
        DataModelUpgradeLogEntry.Type := LogType;
        DataModelUpgradeLogEntry.Indent := LogIndent;
        if not RunSilent then
            DataModelUpgradeLogEntry.Insert()
        else
            if DataModelUpgradeLogEntry.Insert() then;
    end;

    procedure ReRunUpgradeBuilds(FromBuildStep: Integer; ToBuildStep: Integer)
    var
        d: Dialog;
    begin
        if FromBuildStep = ToBuildStep then begin
            if not Confirm('Re-run Data Model Upgrade Build Step %1?', false, FromBuildStep, ToBuildStep) then
                exit;
        end else
            if not Confirm('Re-run Data Model Upgrade from Build Step %1 to Build Step %2?', false, FromBuildStep, ToBuildStep) then
                exit;

        CreateLogEntry(StrSubstNo('Data Model upgrade from Build Step %1 to Build Step %2 invoked from Re-Run action', FromBuildStep, ToBuildStep), 0, 0, -1);
        RunSilent := false;
        UpgradeDataModel(FromBuildStep, ToBuildStep);
    end;

    procedure ReRunFromLogEntry(DataModelUpgradeLogEntry: Record "NPR Data Model Upg. Log Entry")
    begin
        if DataModelUpgradeLogEntry."Data Model Build" < 1 then
            Error('Cannot re-run Build Step %1', DataModelUpgradeLogEntry."Data Model Build");
        ReRunUpgradeBuilds(DataModelUpgradeLogEntry."Data Model Build", DataModelUpgradeLogEntry."Data Model Build");
    end;

    local procedure UpgradeDataModelBuildStep1()
    var
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        POSPaymentBin: Record "NPR POS Payment Bin";
        POSStoreCode: Code[10];
        LocationCode: Code[10];
        RecRef: RecordRef;
        FieldRef: FieldRef;
        HasRegistersWithLocationCode: Boolean;
        HasRegistersWithoutLocationCode: Boolean;
    begin
        if TryOpenTable(RecRef, 6014401, 'Register') then begin
            if not RecRef.FindSet then
                CreateLogEntry(StrSubstNo('No existing cash registers found!', POSUnit.TableCaption, POSUnit."No."), 1, 1, 1)
            else
                repeat
                    if TryGetField(RecRef, FieldRef, 8, 'Location Code') then begin
                        if Format(FieldRef.Value) = '' then
                            HasRegistersWithoutLocationCode := true
                        else
                            HasRegistersWithLocationCode := true;
                    end else
                        HasRegistersWithoutLocationCode := true;
                until RecRef.Next = 0;
            if RecRef.FindSet then
                repeat
                    if TryGetField(RecRef, FieldRef, 1, 'Register No.') then begin
                        if not POSUnit.Get(FieldRef.Value) then begin
                            POSUnit.Init;
                            POSUnit."No." := FieldRef.Value;
                            POSUnit."Default POS Payment Bin" := POSUnit."No.";
                            if TryGetField(RecRef, FieldRef, 256, 'Name') then
                                POSUnit.Name := FieldRef.Value;
                            POSUnit.Insert;
                            CreateLogEntry(StrSubstNo('Created %1 %2', POSUnit.TableCaption, POSUnit."No."), 1, 0, 1);
                        end;
                        if not POSPaymentBin.Get(POSUnit."Default POS Payment Bin") then begin
                            POSPaymentBin.Init;
                            POSPaymentBin."No." := POSUnit."Default POS Payment Bin";
                            POSPaymentBin.Description := StrSubstNo(TxtDefaultPaymentBinDescription, POSPaymentBin."No.");
                            POSPaymentBin."Attached to POS Unit No." := POSUnit."No.";
                            POSPaymentBin.Insert;
                            CreateLogEntry(StrSubstNo('Created %1 %2', POSPaymentBin.TableCaption, POSPaymentBin."No."), 1, 0, 1);
                        end;

                        if TryGetField(RecRef, FieldRef, 8, 'Location Code') then
                            LocationCode := FieldRef.Value
                        else
                            LocationCode := '';

                        if (HasRegistersWithoutLocationCode and (not HasRegistersWithLocationCode)) then
                            POSStoreCode := '1'
                        else
                            if ((not HasRegistersWithoutLocationCode) and HasRegistersWithLocationCode) then
                                POSStoreCode := LocationCode
                            else
                                POSStoreCode := POSUnit."No.";

                        if not POSStore.Get(POSStoreCode) then begin
                            POSStore.Init;
                            POSStore.Code := POSStoreCode;
                            POSStore."Location Code" := LocationCode;
                            POSStore.Insert;
                            CreateLogEntry(StrSubstNo('Created %1 %2', POSStore.TableCaption, POSStore.Code), 1, 0, 1);
                        end;

                        if POSStore.Name = '' then
                            if TryGetField(RecRef, FieldRef, 256, 'Name') then
                                POSStore.Name := CopyStr(Format(FieldRef.Value), 1, MaxStrLen(POSStore.Name));
                        if POSStore."Name 2" = '' then
                            if TryGetField(RecRef, FieldRef, 23, 'Name 2') then
                                POSStore."Name 2" := CopyStr(Format(FieldRef.Value), 1, MaxStrLen(POSStore."Name 2"));
                        if POSStore.Address = '' then
                            if TryGetField(RecRef, FieldRef, 257, 'Address') then
                                POSStore.Address := CopyStr(Format(FieldRef.Value), 1, MaxStrLen(POSStore.Address));
                        if POSStore."Post Code" = '' then
                            if TryGetField(RecRef, FieldRef, 259, 'Post Code') then
                                POSStore."Post Code" := CopyStr(Format(FieldRef.Value), 1, MaxStrLen(POSStore."Post Code"));
                        if POSStore.City = '' then
                            if TryGetField(RecRef, FieldRef, 258, 'City') then
                                POSStore.City := CopyStr(Format(FieldRef.Value), 1, MaxStrLen(POSStore.City));
                        if POSStore."Phone No." = '' then
                            if TryGetField(RecRef, FieldRef, 260, 'Telephone') then
                                POSStore."Phone No." := CopyStr(Format(FieldRef.Value), 1, MaxStrLen(POSStore."Phone No."));
                        if POSStore."Fax No." = '' then
                            if TryGetField(RecRef, FieldRef, 261, 'Fax') then
                                POSStore."Fax No." := CopyStr(Format(FieldRef.Value), 1, MaxStrLen(POSStore."Fax No."));
                        if POSStore."E-Mail" = '' then
                            if TryGetField(RecRef, FieldRef, 268, 'E-mail') then
                                POSStore."E-Mail" := CopyStr(Format(FieldRef.Value), 1, MaxStrLen(POSStore."E-Mail"));
                        if POSStore."Home Page" = '' then
                            if TryGetField(RecRef, FieldRef, 274, 'www-address') then
                                POSStore."Home Page" := CopyStr(Format(FieldRef.Value), 1, MaxStrLen(POSStore."Home Page"));
                        if POSStore."VAT Registration No." = '' then
                            if TryGetField(RecRef, FieldRef, 267, 'VAT No.') then
                                POSStore."VAT Registration No." := CopyStr(Format(FieldRef.Value), 1, MaxStrLen(POSStore."VAT Registration No."));
                        if POSStore."Gen. Bus. Posting Group" = '' then
                            if TryGetField(RecRef, FieldRef, 18, 'Gen. Business Posting Group') then
                                POSStore."Gen. Bus. Posting Group" := FieldRef.Value;
                        if POSStore."VAT Bus. Posting Group" = '' then
                            if TryGetField(RecRef, FieldRef, 19, 'VAT Gen. Business Post.Gr') then
                                POSStore."VAT Bus. Posting Group" := FieldRef.Value;
                        POSStore.Modify;

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
        TaxFreeUnit: Record "NPR Tax Free POS Unit";
        TaxFreeVoucher: Record "NPR Tax Free Voucher";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        MerchantID: Text[20];
        VATNumber: Text[20];
        CountryCode: Text[3];
        AmountThreshold: Decimal;
        CheckPrefix: Boolean;
        POSUnitNo: Code[10];
    begin
        TaxFreeVoucher.SetRange("Handler ID", '');
        if not TaxFreeVoucher.IsEmpty then begin
            TaxFreeVoucher.ModifyAll("Handler ID", 'PREMIER_PI');
            CreateLogEntry(StrSubstNo('Updated existing %1 records', TaxFreeVoucher.TableCaption), 1, 0, 2);
        end;

        if not TryOpenTable(RecRef, 6014401, 'Register') then
            exit;

        if not TryGetField(RecRef, FieldRef, 700, 'Tax Free Enabled') then
            exit;

        FieldRef.SetRange(true);
        if RecRef.FindSet then
            repeat
                if TryGetField(RecRef, FieldRef, 1, 'Register No.') then
                    POSUnitNo := FieldRef.Value;
                if not TaxFreeUnit.Get(POSUnitNo) then begin
                    TaxFreeUnit.Init;
                    TaxFreeUnit."POS Unit No." := POSUnitNo;
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


                    TaxFreeUnit."Handler ID Enum" := Enum::"NPR Tax Free Handler ID"::PREMIER_PI;

                    if (CountryCode = '208') and (MerchantID = '999001') and (VATNumber = 'DK0999001') then
                        TaxFreeUnit.Mode := TaxFreeUnit.Mode::TEST;

                    TaxFreeUnit."Check POS Terminal IIN" := CheckPrefix;
                    TaxFreeUnit."Min. Sales Amount Incl. VAT" := AmountThreshold;

                    if Step2_CreateParameterBlob(MerchantID, VATNumber, CountryCode, TaxFreeUnit) then begin
                        TaxFreeUnit.Insert;
                        CreateLogEntry(StrSubstNo('Created %1', TaxFreeUnit.TableCaption), 1, 0, 2);
                    end else
                        Clear(TaxFreeUnit);
                end;
            until RecRef.Next = 0;
    end;

    local procedure UpgradeDataModelBuildStep4()
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        Name: Text;
    begin
        if TryOpenTable(RecRef, 6014561, 'RP Data Items') then
            if RecRef.FindSet(true) then
                repeat
                    if TryGetField(RecRef, FieldRef, 12, 'Name') then begin
                        Name := FieldRef.Value;
                        if (Name[1] = '<') and (Name[StrLen(Name)] = '>') then begin
                            FieldRef.Value := CopyStr(Name, 2, StrLen(Name) - 2);
                            RecRef.Modify;
                        end;
                    end;
                until RecRef.Next = 0;
    end;

    local procedure "-- Auxiliary functions for steps"()
    begin
    end;

    [TryFunction]
    local procedure Step2_CreateParameterBlob(MerchantID: Text; VATNumber: Text; CountryCode: Text; var TaxFreeUnit: Record "NPR Tax Free POS Unit")
    var
        tmpHandlerParameters: Record "NPR Tax Free Handler Param." temporary;
    begin
        tmpHandlerParameters.Parameter := 'Merchant ID';
        tmpHandlerParameters."Data Type" := tmpHandlerParameters."Data Type"::Text;
        tmpHandlerParameters.Validate(Value, MerchantID);
        tmpHandlerParameters.Insert;

        tmpHandlerParameters.Parameter := 'VAT Number';
        tmpHandlerParameters."Data Type" := tmpHandlerParameters."Data Type"::Text;
        tmpHandlerParameters.Validate(Value, VATNumber);
        tmpHandlerParameters.Insert;

        tmpHandlerParameters.Parameter := 'Country Code';
        tmpHandlerParameters."Data Type" := tmpHandlerParameters."Data Type"::Integer;
        tmpHandlerParameters.Validate(Value, CountryCode);
        tmpHandlerParameters.Insert;

        tmpHandlerParameters.SerializeParameterBLOB(TaxFreeUnit);
    end;
}

