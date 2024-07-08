page 6184673 "NPR AT Enable Fiscal Step"
{
    Caption = 'AT Enable Fiscal Setup';
    Extensible = false;
    PageType = CardPart;
    SourceTable = "NPR AT Fiscalization Setup";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(Enabling)
            {
                Caption = 'Enable Fiscalization';

                field("AT Fiscal Enabled"; Rec."AT Fiscal Enabled")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the Austrian fiscalization is enabled.';
                }
                field(Training; Rec.Training)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the fiscalization is in training mode or not.';
                }
            }
            group(Endpoints)
            {
                Caption = 'Endpoints';

                field("Fiskaly API URL"; Rec."Fiskaly API URL")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the URL for the Fiskaly API.';
                }
            }
            group(FONCredentials)
            {
                Caption = 'FinanzOnline Credentials';

                field(FONParticipantId; FONParticipantIdValue)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'FinanzOnline Participant Id';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the "Teilnehmer-Identifikation" part of the FinanzOnline Cash Register Web Service User ("Registrierkassen-Webservice-Benutzer") credential triplet.';

                    trigger OnValidate()
                    var
                        FONParticipantIdLbl: Label 'FinanzOnline Participant Id';
                    begin
                        ConfirmChangeFieldValue(FONParticipantIdLbl);
                        ClearAuthenticationFields();
                    end;

                    trigger OnAssistEdit()
                    var
                        FONParticipantIdLbl: Label 'FinanzOnline Participant Id: %1';
                    begin
                        Message(FONParticipantIdLbl, FONParticipantIdValue);
                    end;
                }
                field(FONUserId; FONUserIdValue)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'FinanzOnline User Id';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the "Benutzer-Identifikation" part of the FinanzOnline Cash Register Web Service User ("Registrierkassen-Webservice-Benutzer") credential triplet.';

                    trigger OnValidate()
                    var
                        FinanzOnlineUserIdLbl: Label 'FinanzOnline User Id';
                    begin
                        ConfirmChangeFieldValue(FinanzOnlineUserIdLbl);
                        ClearAuthenticationFields();
                    end;

                    trigger OnAssistEdit()
                    var
                        FONUserIdLbl: Label 'FinanzOnline User Id: %1', Comment = '%1 - FinanzOnline User Id value';
                    begin
                        Message(FONUserIdLbl, FONUserIdValue);
                    end;
                }
                field(FONUserPIN; FONUserPINValue)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'FinanzOnline User PIN';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the "PIN" part of the FinanzOnline Cash Register Web Service User ("Registrierkassen-Webservice-Benutzer") credential triplet.';

                    trigger OnValidate()
                    var
                        FinanzOnlineUserPINLbl: Label 'FinanzOnline User PIN';
                    begin
                        ConfirmChangeFieldValue(FinanzOnlineUserPINLbl);
                        ClearAuthenticationFields();
                    end;

                    trigger OnAssistEdit()
                    var
                        FONUserPINLbl: Label 'FinanzOnline User PIN: %1', Comment = '%1 - FinanzOnline User PIN value';
                    begin
                        Message(FONUserPINLbl, FONUserPINValue);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            if Rec."Fiskaly API URL" = '' then
                Rec."Fiskaly API URL" := FiskalyAPIURLLbl;
            Rec.Insert();
        end;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        ClearSecretValues();
        GetSecretValues();
    end;

    var
        ATSecretMgt: Codeunit "NPR AT Secret Mgt.";
        FiskalyAPIURLLbl: Label 'https://rksv.fiskaly.com/api/v1/', Locked = true;
        FONParticipantIdValue: Text[12];
        FONUserIdValue: Text[12];
        FONUserPINValue: Text[128];

    local procedure ClearSecretValues()
    begin
        Clear(FONParticipantIdValue);
        Clear(FONUserIdValue);
        Clear(FONUserPINValue);
    end;

    local procedure GetSecretValues()
    begin
        FONParticipantIdValue := CopyStr(ATSecretMgt.GetSecretKey(Rec.GetFONParticipantId()), 1, MaxStrLen(FONParticipantIdValue));
        FONUserIdValue := CopyStr(ATSecretMgt.GetSecretKey(Rec.GetFONUserId()), 1, MaxStrLen(FONUserIdValue));
        FONUserPINValue := CopyStr(ATSecretMgt.GetSecretKey(Rec.GetFONUserPIN()), 1, MaxStrLen(FONUserPINValue));
    end;

    local procedure ConfirmChangeFieldValue(ChangedFieldCaption: Text)
    var
        ATOrganization: Record "NPR AT Organization";
        ConfirmChangeFieldValueQst: Label 'Are you sure that you want to change the value of field %1, since it would require new FinanzOnline authentication of all related %2 records, because their FinanzOnline authentication status will be reset?', Comment = '%1 - Field Caption value, %2 - AT Organization table caption';
    begin
        ATOrganization.SetRange("FON Authentication Status", ATOrganization."FON Authentication Status"::AUTHENTICATED);
        if ATOrganization.IsEmpty() then
            exit;

        if not Confirm(StrSubstNo(ConfirmChangeFieldValueQst, ChangedFieldCaption, ATOrganization.TableCaption), false) then
            Error('');
    end;

    local procedure ClearAuthenticationFields()
    var
        ATOrganization: Record "NPR AT Organization";
    begin
        if ATOrganization.IsEmpty() then
            exit;

        ATOrganization.FindSet(true);

        repeat
            Clear(ATOrganization."FON Authentication Status");
            Clear(ATOrganization."FON Authenticated At");
            ATOrganization.Modify(true);
        until ATOrganization.Next() = 0
    end;

    internal procedure CopyToTemp()
    var
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
    begin
        if not ATFiscalizationSetup.Get() then
            exit;

        Rec.TransferFields(ATFiscalizationSetup);
        Rec.SystemId := ATFiscalizationSetup.SystemId;
        if not Rec.Insert() then
            Rec.Modify();
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        exit(Rec."AT Fiscal Enabled" and (FONParticipantIdValue <> '') and (FONUserIdValue <> '') and (FONUserPINValue <> ''));
    end;

    internal procedure CreateFiscalSetupData()
    var
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
    begin
        if not Rec.Get() then
            exit;

        if not ATFiscalizationSetup.Get() then
            ATFiscalizationSetup.Init();

        ATFiscalizationSetup."AT Fiscal Enabled" := Rec."AT Fiscal Enabled";
        ATFiscalizationSetup."Fiskaly API URL" := Rec."Fiskaly API URL";
        ATFiscalizationSetup.Training := Rec.Training;

        if not ATFiscalizationSetup.Insert() then
            ATFiscalizationSetup.Modify();

        if FONParticipantIdValue = '' then
            ATSecretMgt.RemoveSecretKey(ATFiscalizationSetup.GetFONParticipantId())
        else
            ATSecretMgt.SetSecretKey(ATFiscalizationSetup.GetFONParticipantId(), FONParticipantIdValue);

        if FONUserIdValue = '' then
            ATSecretMgt.RemoveSecretKey(ATFiscalizationSetup.GetFONUserId())
        else
            ATSecretMgt.SetSecretKey(ATFiscalizationSetup.GetFONUserId(), FONUserIdValue);

        if FONUserPINValue = '' then
            ATSecretMgt.RemoveSecretKey(ATFiscalizationSetup.GetFONUserPIN())
        else
            ATSecretMgt.SetSecretKey(ATFiscalizationSetup.GetFONUserPIN(), FONUserPINValue);

        EnableApplicationArea();
    end;

    local procedure EnableApplicationArea()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if Rec."AT Fiscal Enabled" then
            ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;
}
