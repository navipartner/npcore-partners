page 6184578 "NPR AT Fiscalization Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'AT Fiscalization Setup';
    ContextSensitiveHelpPage = 'docs/fiscalization/austria/how-to/setup/';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR AT Fiscalization Setup";
    UsageCategory = Administration;

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
                    trigger OnValidate()
                    begin
                        if xRec."AT Fiscal Enabled" <> Rec."AT Fiscal Enabled" then begin
                            EnabledValueChanged := true;
                            Clear(Rec.Training);
                        end;
                    end;
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

                        if FONParticipantIdValue = '' then
                            ATSecretMgt.RemoveSecretKey(Rec.GetFONParticipantId())
                        else
                            ATSecretMgt.SetSecretKey(Rec.GetFONParticipantId(), FONParticipantIdValue);

                        ClearAuthenticationFields();
                    end;

                    trigger OnAssistEdit()
                    var
                        FONParticipantIdLbl: Label 'FinanzOnline Participant Id: %1';
                    begin
                        Message(FONParticipantIdLbl, ATSecretMgt.GetSecretKey(Rec.GetFONParticipantId()));
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

                        if FONUserIdValue = '' then
                            ATSecretMgt.RemoveSecretKey(Rec.GetFONUserId())
                        else
                            ATSecretMgt.SetSecretKey(Rec.GetFONUserId(), FONUserIdValue);

                        ClearAuthenticationFields();
                    end;

                    trigger OnAssistEdit()
                    var
                        FONUserIdLbl: Label 'FinanzOnline User Id: %1', Comment = '%1 - FinanzOnline User Id value';
                    begin
                        Message(FONUserIdLbl, ATSecretMgt.GetSecretKey(Rec.GetFONUserId()));
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

                        if FONUserPINValue = '' then
                            ATSecretMgt.RemoveSecretKey(Rec.GetFONUserPIN())
                        else
                            ATSecretMgt.SetSecretKey(Rec.GetFONUserPIN(), FONUserPINValue);

                        ClearAuthenticationFields();
                    end;

                    trigger OnAssistEdit()
                    var
                        FONUserPINLbl: Label 'FinanzOnline User PIN: %1', Comment = '%1 - FinanzOnline User PIN value';
                    begin
                        Message(FONUserPINLbl, ATSecretMgt.GetSecretKey(Rec.GetFONUserPIN()));
                    end;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(ATOrganizations)
            {
                ApplicationArea = NPRATFiscal;
                Caption = 'AT Organizations';
                Image = SetupList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = page "NPR AT Organization List";
                ToolTip = 'Opens AT Organizations page.';
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

    trigger OnClosePage()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if EnabledValueChanged then
            ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;

    var
        ATSecretMgt: Codeunit "NPR AT Secret Mgt.";

        EnabledValueChanged: Boolean;
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
}