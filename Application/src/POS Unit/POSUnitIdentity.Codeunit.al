codeunit 6150718 "NPR POS Unit Identity"
{
    // #Transcendence/TSA/20170221 CASE Trancendence Login
    // NPR5.32.10/TSA/20170614  CASE 280829 Assigning default POS Unit when a new device is discovered
    // NPR5.37/TSA /20170718 CASE 284356 HardwareId (HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography\machineGUID) is not unique when ghosting machines. Added Hostname to filter
    // NPR5.37/TSA /20171024 CASE 293113 Default and _initial_ register is selected from USER SETUP


    trigger OnRun()
    begin
    end;

    var
        NewDevice: Label 'Welcome to NP Retail!\\It seems to be the first time this device is used as a POS for NP Retail. Please take a moment and give this POS a good description and assign the register to use.\\Thank-you.';

    [EventSubscriber(ObjectType::Codeunit, 6150700, 'OnFrontEndId', '', false, false)]
    local procedure OnFrontEndId(HardwareId: Text; SessionName: Text; HostName: Text; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        DeviceEntryNo: Integer;
        POSSetup: Codeunit "NPR POS Setup";
        POSUnitIdentity: Record "NPR POS Unit Identity";
    begin
        Clear(POSUnitIdentity);
        ConfigurePersistentDevice(HardwareId, SessionName, HostName, POSUnitIdentity);

        POSSession.GetSetup(POSSetup);
        POSSetup.InitializeUsingPosUnitIdentity(POSUnitIdentity);
    end;

    procedure ConfigurePersistentDevice(HardwareId: Text; SessionName: Text; HostName: Text; var POSUnitIdentityOut: Record "NPR POS Unit Identity")
    begin

        ConfigureDeviceInternal(HardwareId, SessionName, HostName, true, '', POSUnitIdentityOut);
    end;

    procedure ConfigureTemporaryDevice(DefaultRegister: Code[10]; var POSUnitIdentityOut: Record "NPR POS Unit Identity")
    begin

        ConfigureDeviceInternal(Format(CreateGuid()), '', '', false, DefaultRegister, POSUnitIdentityOut);
    end;

    local procedure ConfigureDeviceInternal(HardwareId: Text; SessionName: Text; HostName: Text; Persistent: Boolean; DefaultUnitNo: Code[10]; var POSUnitIdentityOut: Record "NPR POS Unit Identity")
    var
        POSUnitIdentity: Record "NPR POS Unit Identity";
    begin

        POSUnitIdentity.SetFilter("Device ID", '=%1', HardwareId);
        POSUnitIdentity.SetFilter("Host Name", '=%1', HostName);

        if (StrLen(SessionName) >= 3) then begin
            case UpperCase(CopyStr(SessionName, 1, 3)) of
                'RDP',
              'ICA':
                    POSUnitIdentity.SetFilter("User ID", '=%1', UpperCase(UserId));
            end;
        end;

        if (not POSUnitIdentity.FindFirst()) then begin
            // Create a new entry
            POSUnitIdentity."Entry No." := 0;
            POSUnitIdentity."Device ID" := HardwareId;
            POSUnitIdentity."Host Name" := HostName;

            if (StrLen(SessionName) >= 3) then begin
                POSUnitIdentity."Select POS Using" := POSUnitIdentity."Select POS Using"::UserID;
                case (UpperCase(CopyStr(SessionName, 1, 3))) of
                    'RDP':
                        POSUnitIdentity."Session Type" := POSUnitIdentity."Session Type"::RemoteDesktop;
                    'ICA':
                        POSUnitIdentity."Session Type" := POSUnitIdentity."Session Type"::Citrix;
                    else begin
                            POSUnitIdentity."Session Type" := POSUnitIdentity."Session Type"::"Local";
                            POSUnitIdentity."Select POS Using" := POSUnitIdentity."Select POS Using"::DeviceID;
                        end;
                end;
            end;

            POSUnitIdentity."User ID" := UpperCase(UserId);
            POSUnitIdentity."Created At" := CurrentDateTime;
            POSUnitIdentity."Last Session At" := CurrentDateTime();

            // In case the POS is running in a web browser (without Major Tom), this setup will be invoked from the POS Login rather than the framework.
            if (DefaultUnitNo <> '') then begin
                POSUnitIdentity."Default POS Unit No." := DefaultUnitNo;
            end;

            if (Persistent) then
                POSUnitIdentity.Insert();

        end;

        POSUnitIdentity."Last Session At" := CurrentDateTime;
        POSUnitIdentity."User ID" := UpperCase(UserId);

        if (Persistent) then begin
            POSUnitIdentity.Modify();

            PromptForConfigurationInternal(POSUnitIdentity."Entry No.");
            POSUnitIdentity.Get(POSUnitIdentity."Entry No.");
        end;

        POSUnitIdentityOut := POSUnitIdentity;
    end;

    local procedure PromptForConfigurationInternal(UnitIdentityEntryNo: Integer)
    var
        POSUnitIdentity: Record "NPR POS Unit Identity";
        POSUnitIdentity2: Record "NPR POS Unit Identity";
        RequireSetupChange: Boolean;
        POSUnit: Record "NPR POS Unit";
        UserSetup: Record "User Setup";
    begin

        POSUnitIdentity.Get(UnitIdentityEntryNo);
        RequireSetupChange := (POSUnitIdentity."Default POS Unit No." = '');

        //-NPR5.37 [293113]
        if (RequireSetupChange) then begin
            if (UserSetup.Get(UpperCase(UserId))) then begin
                POSUnitIdentity."Default POS Unit No." := UserSetup."NPR Backoffice Register No.";
                POSUnitIdentity.Modify();
            end;
            RequireSetupChange := (POSUnitIdentity."Default POS Unit No." = '');
        end;
        //+NPR5.37 [293113]

        //-NPR5.32.10 [280829]
        if (RequireSetupChange) then begin
            // Pick first unassigned POS Unit
            if (POSUnit.FindSet()) then begin
                repeat
                    POSUnitIdentity2.SetFilter("Default POS Unit No.", '=%1', POSUnit."No.");
                    if (POSUnitIdentity2.IsEmpty()) then begin
                        POSUnitIdentity."Default POS Unit No." := POSUnit."No.";
                        POSUnitIdentity.Modify();
                        RequireSetupChange := false;
                    end;
                until ((POSUnit.Next() = 0) or (not RequireSetupChange));
            end;

            // All POS Units have been assigned already
            if (RequireSetupChange) then begin
                if (POSUnit.FindFirst()) then begin
                    POSUnitIdentity."Default POS Unit No." := POSUnit."No.";
                    POSUnitIdentity.Modify();
                    RequireSetupChange := false;
                end;
            end;
        end;
        //-NPR5.32.10 [280829]

        repeat

            if (RequireSetupChange) then
                POSUnitIdentity.Get(SetupPosUnitIdentiy(UnitIdentityEntryNo));

            RequireSetupChange := (POSUnitIdentity."Default POS Unit No." = '');

        until (not RequireSetupChange);
    end;

    local procedure SetupPosUnitIdentiy(UnitIdentityEntryNo: Integer): Integer
    var
        POSUnitIdentity: Record "NPR POS Unit Identity";
        POSUnitIdentityCard: Page "NPR POS Unit Identity Card";
    begin

        POSUnitIdentity.Get(UnitIdentityEntryNo);

        if (Confirm(NewDevice, true)) then begin
            Commit;
            POSUnitIdentityCard.SetRecord(POSUnitIdentity);
            POSUnitIdentityCard.RunModal();
            POSUnitIdentityCard.GetRecord(POSUnitIdentity);
        end;

        exit(UnitIdentityEntryNo);
    end;

    procedure SwitchToPosUnit(POSession: Codeunit "NPR POS Session"; PosUnitNo: Code[10]; var POSUnitIdentityOut: Record "NPR POS Unit Identity")
    var
        HardwareId: Text;
        SessionName: Text;
        HostName: Text;
        POSUnitIdentity: Record "NPR POS Unit Identity";
    begin

        POSession.GetSessionId(HardwareId, SessionName, HostName);

        POSUnitIdentity.SetFilter("Device ID", '=%1', HardwareId);
        if (StrLen(SessionName) >= 3) then begin
            case UpperCase(CopyStr(SessionName, 1, 3)) of
                'RDP',
              'ICA':
                    POSUnitIdentity.SetFilter("User ID", '=%1', UpperCase(UserId));
            end;
        end;

        POSUnitIdentity."Default POS Unit No." := PosUnitNo;

        if (POSUnitIdentity.FindFirst()) then begin
            POSUnitIdentity."Default POS Unit No." := PosUnitNo;
            POSUnitIdentity.Modify();
            Commit;
        end;


        POSUnitIdentityOut := POSUnitIdentity;
    end;
}

