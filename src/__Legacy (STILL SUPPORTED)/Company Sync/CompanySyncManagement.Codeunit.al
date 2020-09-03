codeunit 6059777 "NPR CompanySyncManagement"
{
    // Company Synchronization Library
    //  Work started by Jerome Cader
    //  This CodeUnit is used together with configuration tables:
    //  T6059777 Company Sync Profiles,         T6059778 Sync Profile Setup,
    //  T6059779 Partial Sync Profiles Profile, T6059780 Companies in Profile
    // 
    //  A setup form F6059777 is also available together with F6059778 Company Sync Profiles,
    //  F6059779 Partial Sync Fields Profile, F6059780 Companies in Profile
    //  Please maintain documentation when adding new functions.
    // 
    //  Current functions and their purpose are listed below.
    // --------------------------------------------------------
    // 
    //  "copyProfiles(fromSynchronizationProfile : Code[20];toSynchronizationProfile : Code[20])"
    //  Copy configuration from one profile to another
    // 
    //  "LookUpSync(VAR CurrentSynchronisationProfile : Code[20];VAR SyncProfileSetup : Record "Sync Profile Setup")"
    //  Lookup Sunchronization Profile
    // 
    //  "OnDelete(VAR recRef : RecordRef)"
    //  Function to call from OnDelete Table Trigger
    // 
    //  "OnInsert(VAR recRef : RecordRef)"
    //   Function to call from OnInsert Table Trigger
    // 
    //  "OnModify(VAR recRef : RecordRef)"
    //  Function to call from OnModify Table Trigger
    // 
    //  "OnSync(VAR recRef : RecordRef;commandCode : Text[30])"
    //  Main function to perform synchronization depending on the commandCode : Delete, Insert, Modify
    // 
    //  "processRemoteRecordRef(commandCode : Text[30];fromRecRef : RecordRef;comp : Text[30];fieldSyncType : Text[30];
    //    VAR partialSyncFieldsReco"
    //  SubFunction to process the record with specific commandCode : Delete, Insert, Modify
    //  Called from OnSync
    // 
    //  "SetSyncSetup(CurrentSynchronisationProfile : Code[20];VAR CompanySyncSetup : Record "Sync Profile Setup")"
    //  Set filter for CompanySyncSetup
    // 
    // NPR5.36/TJ  /20170905  CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                    Removed unused variables
    // NPR5.38/MHA /20180105  CASE 301053 Deleted unused functions CopyProfiles(),LookUpSync(),SyncProfile()


    trigger OnRun()
    begin

        /*
        //Testing copy profile x to profile y
        copyProfiles('100','300');
        MESSAGE('Profile copied/updated');
        */

        /*
        //Testing
        FOR IIndex := 1 TO 500 DO BEGIN
         CLEAR(itemRecord);
         itemRecord.INIT;
         itemRecord.Description := 'SyncTest'+FORMAT(IIndex);
         itemRecord.INSERT(TRUE);
         //IF itemRecord.INSERT(TRUE) THEN ;
         {
         IF itemRecord.INSERT(TRUE) THEN
           MESSAGE('insert with no.' + itemRecord."No.")
         ELSE
           MESSAGE('no insert');
         }
         COMMIT;
         SLEEP(1000);
         //SLEEP(500 + IIndex);
        
        END;
        MESSAGE('Test completed');
        */

        /*
        //Insert all fields from Item table 27 in profile
        rFields.SETRANGE(TableNo, 27);
        
        IF rFields.FIND('-') THEN REPEAT
          partialSyncFieldsRecord.INIT;
          partialSyncFieldsRecord."Synchronisation Profile" := '100';
          partialSyncFieldsRecord."Table No."  := 27;
          partialSyncFieldsRecord."Field No."  := rFields."No.";
          partialSyncFieldsRecord.Description  := rFields."Field Caption";
          partialSyncFieldsRecord.INSERT(TRUE);
        UNTIL rFields.NEXT = 0;
        MESSAGE('completed');
        */

    end;

    var
        DeleteFailError: Label 'Record Delete Failed';
        CompanySyncProfiles: Record "NPR Company Sync Profiles";

    procedure OnDelete(var recRef: RecordRef)
    begin
        OnSync(recRef, 'DELETE');
    end;

    procedure OnInsert(var recRef: RecordRef)
    begin
        OnSync(recRef, 'INSERT');
    end;

    procedure OnModify(var recRef: RecordRef)
    begin
        OnSync(recRef, 'MODIFY');
    end;

    procedure OnSync(var RecRef: RecordRef; CommandCode: Text[30])
    var
        SkipSyncForCurrentComp: Boolean;
        FieldRef: FieldRef;
        SyncType: Option;
        CompaniesInProfile2: Record "NPR Companies in Profile";
        CompaniesInProfile: Record "NPR Companies in Profile";
        RetailSetup: Record "NPR Retail Setup";
        PartialSyncFieldsProfile: Record "NPR Part. Sync Fields Prof.";
        SyncProfileSetup: Record "NPR Sync Profile Setup";
        CompanyName: Text[30];
        FieldSyncType: Text[30];
    begin
        if not RetailSetup.Get then
            exit
        else begin
            if not RetailSetup."Auto Replication" then
                exit;
        end;

        CompaniesInProfile2.SetRange("Company Name", CompanyName);
        if CompaniesInProfile2.Count = 0 then
            exit;

        if CompaniesInProfile2.Find('-') then
            repeat
                CompaniesInProfile.Reset;
                CompaniesInProfile.SetRange("Synchronisation profile", CompaniesInProfile2."Synchronisation profile");
                CompaniesInProfile.SetFilter("Company Name", '<>%1', CompanyName);
                if CompaniesInProfile.Find('-') then
                    repeat
                        CompanyName := CompaniesInProfile."Company Name";
                        if (CompaniesInProfile.ReplicationDirection <> CompaniesInProfile.ReplicationDirection::From)
                            and (CompaniesInProfile2.ReplicationDirection <> CompaniesInProfile2.ReplicationDirection::"To") then begin
                            SyncProfileSetup.SetRange("Synchronisation Profile", CompaniesInProfile."Synchronisation profile");
                            SyncProfileSetup.SetRange("Table No.", RecRef.Number);
                            if SyncProfileSetup.Find('-') then begin
                                if SyncProfileSetup.Enabled then begin
                                    SyncType := SyncProfileSetup."Record Synchronisation Type";
                                    FieldSyncType := UpperCase(Format(SyncProfileSetup."Field Synchronisation Type"));
                                    PartialSyncFieldsProfile.SetRange("Synchronisation Profile", SyncProfileSetup."Synchronisation Profile");
                                    PartialSyncFieldsProfile.SetRange("Table No.", SyncProfileSetup."Table No.");
                                    PartialSyncFieldsProfile.SetRange(FilterType, PartialSyncFieldsProfile.FilterType::CompanyFilter);
                                    if PartialSyncFieldsProfile.Count > 0 then begin
                                        PartialSyncFieldsProfile.SetRange("Company Name", CompanyName);
                                        if PartialSyncFieldsProfile.Find('-') then begin
                                            FieldRef := RecRef.Field(PartialSyncFieldsProfile."Field No.");
                                            PartialSyncFieldsProfile.SetRange(Value, Format(FieldRef));
                                            if PartialSyncFieldsProfile.Count = 0 then
                                                SkipSyncForCurrentComp := true
                                            else
                                                SkipSyncForCurrentComp := false;
                                        end;
                                        //Remove filters on "Company Name", Value
                                        PartialSyncFieldsProfile.SetRange("Company Name");
                                        PartialSyncFieldsProfile.SetRange(Value);
                                    end;
                                    //Remove filter on FilterType
                                    PartialSyncFieldsProfile.SetRange(FilterType);

                                    if SkipSyncForCurrentComp = false then begin
                                        if SyncType = SyncProfileSetup."Record Synchronisation Type"::All then
                                            ProcessRemoteRecordRef(CommandCode, RecRef, CompanyName, FieldSyncType, PartialSyncFieldsProfile, false);
                                        if (CommandCode = 'DELETE') and (SyncType = SyncProfileSetup."Record Synchronisation Type"::Delete) then
                                            ProcessRemoteRecordRef(CommandCode, RecRef, CompanyName, FieldSyncType, PartialSyncFieldsProfile, false);
                                        if (CommandCode = 'INSERT') and (SyncType = SyncProfileSetup."Record Synchronisation Type"::Create) then
                                            ProcessRemoteRecordRef(CommandCode, RecRef, CompanyName, FieldSyncType, PartialSyncFieldsProfile, false);
                                        if (CommandCode = 'MODIFY') and (SyncType = SyncProfileSetup."Record Synchronisation Type"::Modify) then
                                            ProcessRemoteRecordRef(CommandCode, RecRef, CompanyName, FieldSyncType, PartialSyncFieldsProfile, false);
                                    end;
                                end;
                            end;
                        end;
                    until CompaniesInProfile.Next = 0;
            until CompaniesInProfile2.Next = 0;
    end;

    procedure ProcessRemoteRecordRef(CommandCode: Text[30]; FromRecRef: RecordRef; CompanyName: Text[30]; FieldSyncType: Text[30]; var PartialSyncFieldsProfile: Record "NPR Part. Sync Fields Prof."; IsModifyAfterInsert: Boolean)
    var
        FoundRec: Boolean;
        MatchFound: Boolean;
        FromField: FieldRef;
        ToFieldRef: FieldRef;
        "Field": Record "Field";
        ToRecRef: RecordRef;
    begin
        Clear(ToRecRef);
        ToRecRef.Open(FromRecRef.Number, false, CompanyName);
        if ToRecRef.WritePermission then begin
            if (CommandCode = 'DELETE') or (CommandCode = 'MODIFY') then
                ToRecRef.SetPosition(FromRecRef.GetPosition)
            else //IF (commandCode = 'INSERT')
                ToRecRef.Init;

            if CommandCode = 'DELETE' then
                if ToRecRef.Find then
                    if ToRecRef.Delete(false) = false then
                        Message(DeleteFailError);

            if CommandCode = 'MODIFY' then begin
                ToRecRef.LockTable(true);
                FoundRec := ToRecRef.Find;
                PartialSyncFieldsProfile.SetRange(FilterType, PartialSyncFieldsProfile.FilterType::Filter);
                if PartialSyncFieldsProfile.Count > 0 then begin
                    if PartialSyncFieldsProfile.Find('-') then
                        repeat
                            ToFieldRef := ToRecRef.Field(PartialSyncFieldsProfile."Field No.");
                            if (Format(ToFieldRef) = Format(PartialSyncFieldsProfile.Value)) then
                                MatchFound := true;
                        until MatchFound or (PartialSyncFieldsProfile.Next = 0);
                    if MatchFound = false then begin
                        ToRecRef.Close;
                        exit;
                    end;
                end;
            end;

            if CommandCode = 'INSERT' then begin
                PartialSyncFieldsProfile.SetRange(FilterType, PartialSyncFieldsProfile.FilterType::Filter);
                if PartialSyncFieldsProfile.Count > 0 then begin
                    if PartialSyncFieldsProfile.Find('-') then
                        repeat
                            FromField := FromRecRef.Field(PartialSyncFieldsProfile."Field No.");
                            if (Format(FromField) = Format(PartialSyncFieldsProfile.Value)) then
                                MatchFound := true;
                        until MatchFound or (PartialSyncFieldsProfile.Next = 0);
                    if MatchFound = false then
                        exit;
                end;
            end;

            if (CommandCode = 'INSERT') or (CommandCode = 'MODIFY') then begin
                if FieldSyncType = 'PARTIAL' then
                    PartialSyncFieldsProfile.SetRange(FilterType, PartialSyncFieldsProfile.FilterType::Field);

                //Loops trough fields
                Field.SetRange(TableNo, FromRecRef.Number);
                if Field.Find('-') then
                    repeat
                        if FieldSyncType = 'PARTIAL' then
                            PartialSyncFieldsProfile.SetRange("Field No.", Field."No.");
                        if (FieldSyncType = 'FULL') or ((FieldSyncType = 'PARTIAL') and (PartialSyncFieldsProfile.Find('-'))) then begin
                            Clear(ToFieldRef);
                            FromField := FromRecRef.Field(Field."No.");
                            if not ((LowerCase(Format(FromField.Class)) = 'flowfield') or
                                    (LowerCase(Format(FromField.Class)) = 'flowfilter') or
                                    (LowerCase(Format(FromField.Type)) = 'blob')) then begin
                                ToFieldRef := ToRecRef.Field(Field."No.");
                                if FieldSyncType = 'PARTIAL' then
                                    if PartialSyncFieldsProfile."To Field No." <> 0 then
                                        ToFieldRef := ToRecRef.Field(PartialSyncFieldsProfile."To Field No.");
                                ToFieldRef.Value := FromField.Value;
                            end;
                        end;
                    until Field.Next = 0;

                if (CommandCode = 'INSERT') or ((CommandCode = 'MODIFY') and (not FoundRec)) then
                    if (not ToRecRef.Insert(false)) and (not IsModifyAfterInsert) then begin
                        ToRecRef.Close;
                        ProcessRemoteRecordRef('MODIFY', FromRecRef, CompanyName, FieldSyncType, PartialSyncFieldsProfile, true);
                        //MESSAGE(insertFailError);
                    end;

                if (CommandCode = 'MODIFY') and FoundRec then begin
                    if not ToRecRef.Modify(false) then; //MESSAGE(modifyFailError);
                end;
            end;
            ToRecRef.Close;
        end;
    end;

    procedure SetSyncSetup(CurrentSynchronisationProfile: Code[20]; var SyncProfileSetup: Record "NPR Sync Profile Setup")
    begin
        SyncProfileSetup.FilterGroup := 0;
        SyncProfileSetup.SetRange(SyncProfileSetup."Synchronisation Profile", CurrentSynchronisationProfile);
        //CompanySyncSetup.SETFILTER(CompanySyncSetup."Synchronisation Profile", "Company Sync Profiles"."Synchronisation Profile");
        SyncProfileSetup.FilterGroup := 2;
        if SyncProfileSetup.Find('-') then;
    end;
}

