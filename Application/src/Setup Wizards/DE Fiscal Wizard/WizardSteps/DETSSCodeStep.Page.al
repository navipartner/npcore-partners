page 6184754 "NPR DE TSS Code Step"
{
    Caption = 'DE TSS Code Setup';
    Extensible = false;
    ObsoleteReason = 'Introduced page NPR DE TSS Step instead.';
    ObsoleteState = Pending;
    ObsoleteTag = '2025-02-09';
    PageType = ListPart;
    SourceTable = "NPR DE TSS";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of Code field.';
                }
                field("Connection Parameter Set Code"; Rec."Connection Parameter Set Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Cash Register Brand field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RefreshTSSList)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Refresh TSS List';
                Image = LinkWeb;
                ToolTip = 'Copies information about all existing Technical Security Systems (TSS) from Fiskaly to BC.';
                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                    Window: Dialog;
                    WorkingLbl: Label 'Retrieving data from Fiskaly...';
                begin
                    Window.Open(WorkingLbl);
                    DEFiskalyCommunication.GetTSSList();
                    Window.Close();
                    CurrPage.Update(false);
                end;
            }
            action("Create TSS")
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Create Fiskaly TSS';
                Image = InsertFromCheckJournal;
                ToolTip = 'Creates Technical Security System (TSS) at Fiskaly for DE fiscalization.';

                trigger OnAction()
                var
                    ConnectionParameters: Record "NPR DE Audit Setup";
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                    AlreadyCreatedErr: Label 'The Technical Security System (TSS) has already been created at Fiskaly. You cannot create it once again.';
                begin
                    Rec.TestField(SystemId);
                    Rec.TestField(Description);
                    ConnectionParameters.GetSetup(Rec);

                    if Rec."Fiskaly TSS Created at" <> 0DT then
                        Error(AlreadyCreatedErr);

                    CurrPage.SaveRecord();
                    DEFiskalyCommunication.CreateTSS(Rec, ConnectionParameters);
                    CurrPage.Update(false);
                end;
            }
            action(SetStatusUninitialized)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Set as Uninitialized';
                Image = UnitConversions;
                ToolTip = 'Change status of selected Technical Security System (TSS) to ''Uninitialized''. Should be run, if current status of TSS is ''Created''.';

                trigger OnAction()
                var
                    ConnectionParameters: Record "NPR DE Audit Setup";
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    Rec.TestField(SystemId);
                    Rec.TestField("Fiskaly TSS State", Rec."Fiskaly TSS State"::CREATED);
                    ConnectionParameters.GetSetup(Rec);

                    CurrPage.SaveRecord();
                    DEFiskalyCommunication.UpdateTSS_State(Rec, Rec."Fiskaly TSS State"::UNINITIALIZED, true, ConnectionParameters);
                    CurrPage.Update(false);
                end;
            }
            action(AssignAdminPIN)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Assign Admin PIN';
                Image = CustomerCode;
                ToolTip = 'Assignes new admin PIN to selected Technical Security System (TSS) at Fiskaly.';

                trigger OnAction()
                var
                    ConnectionParameters: Record "NPR DE Audit Setup";
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                    AlreadyAssignedQst: Label 'An admin PIN has already been assigned to selected Technical Security System (TSS). If you continue, system will assign a new PIN.\Are you sure you want to continue?';
                begin
                    Rec.TestField(SystemId);
                    Rec.testfield("Fiskaly TSS Created at");
                    if DESecretMgt.HasSecretKey(Rec.AdminPINSecretLbl()) then
                        if not Confirm(AlreadyAssignedQst, true) then
                            exit;
                    ConnectionParameters.GetSetup(Rec);

                    CurrPage.SaveRecord();
                    DEFiskalyCommunication.UpdateTSS_AdminPIN(Rec, '', ConnectionParameters);
                    CurrPage.Update(false);
                end;
            }
            action(InitializeTSS)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Initialize TSS';
                Image = Approval;
                ToolTip = 'Initializes selected Technical Security System (TSS) at Fiskaly.';

                trigger OnAction()
                var
                    ConnectionParameters: Record "NPR DE Audit Setup";
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    Rec.TestField(SystemId);
                    Rec.testfield("Fiskaly TSS Created at");
                    Rec.TestField("Fiskaly TSS State", Rec."Fiskaly TSS State"::UNINITIALIZED);
                    DEFiskalyCommunication.CheckAdminPINAssigned(Rec);
                    ConnectionParameters.GetSetup(Rec);

                    CurrPage.SaveRecord();
                    DEFiskalyCommunication.TSS_AuthenticateAdmin(Rec, ConnectionParameters);
                    DEFiskalyCommunication.UpdateTSS_State(Rec, Rec."Fiskaly TSS State"::INITIALIZED, true, ConnectionParameters);
                    CurrPage.Update(false);
                end;
            }
            action(ShowClientsAtFiskaly)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Show Clients at Fiskaly';
                Image = LaunchWeb;
                ToolTip = 'Downloads a list of Fiskaly clients associated with this Technical Security System (TSS).';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    DEFiskalyCommunication.ShowTSSClientListAtFiskaly(Rec);
                end;
            }
            action(DisableTSS)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Disable TSS';
                Image = Reject;
                ToolTip = 'Disables selected Technical Security System (TSS) at Fiskaly.';

                trigger OnAction()
                var
                    ConnectionParameters: Record "NPR DE Audit Setup";
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                    ConfirmDisableQst: Label 'The operation cannot be undone. Are you sure you want to disable TSS %1?', Comment = '%1 - Technical Security System (TSS) Code';
                    IncorrectStateErr: Label 'Only a TSS in the state "UNINITIALIZED" or "INITIALIZED" can be disabled.';
                begin
                    Rec.TestField(SystemId);
                    Rec.TestField("Fiskaly TSS Created at");
                    if not (Rec."Fiskaly TSS State" in [Rec."Fiskaly TSS State"::UNINITIALIZED, Rec."Fiskaly TSS State"::INITIALIZED]) then
                        Error(IncorrectStateErr);
                    if not Confirm(ConfirmDisableQst, false, Rec.Code) then
                        exit;

                    DEFiskalyCommunication.CheckAdminPINAssigned(Rec);
                    ConnectionParameters.GetSetup(Rec);

                    CurrPage.SaveRecord();
                    DEFiskalyCommunication.TSS_AuthenticateAdmin(Rec, ConnectionParameters);
                    DEFiskalyCommunication.UpdateTSS_State(Rec, Rec."Fiskaly TSS State"::DISABLED, true, ConnectionParameters);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    internal procedure CopyRealToTemp()
    begin
        if not DETSSCode.FindSet() then
            exit;
        repeat
            Rec.TransferFields(DETSSCode);
            if not Rec.Insert() then
                Rec.Modify();
        until DETSSCode.Next() = 0;
    end;

    internal procedure DETSSCodeMappingDataToCreate(): Boolean
    begin
        exit(CheckIsDataSet());
    end;

    internal procedure DETSSCodeMappingDataToModify(): Boolean
    begin
        exit(CheckIsDataChanged());
    end;

    internal procedure CreateDETSSCodeMappingData()
    begin
        if not Rec.FindSet() then
            exit;
        repeat
            DETSSCode.TransferFields(Rec);
            if not DETSSCode.Insert() then
                DETSSCode.Modify();
        until Rec.Next() = 0;
    end;

    local procedure CheckIsDataSet(): Boolean
    begin
        if not Rec.FindSet() then
            exit(false);

        repeat
            if ((Rec."Code" <> '')
                and (Rec."Connection Parameter Set Code" <> '')) then
                exit(true);
        until Rec.Next() = 0;
    end;

    local procedure CheckIsDataChanged(): Boolean
    begin
        if not Rec.FindSet() then
            exit(false);

        repeat
            if ((Rec."Code" <> xRec."Code")
                or (Rec."Connection Parameter Set Code" <> xRec."Connection Parameter Set Code")) then
                exit(true);
        until Rec.Next() = 0;
    end;

    var
        DETSSCode: Record "NPR DE TSS";
        DESecretMgt: Codeunit "NPR DE Secret Mgt.";

}