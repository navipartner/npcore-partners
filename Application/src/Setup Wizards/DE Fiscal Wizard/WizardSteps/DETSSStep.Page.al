page 6184945 "NPR DE TSS Step"
{
    Caption = 'DE Technical Security Systems';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR DE TSS";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Repeater)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies a unique code of the TSS. The code is used internally by the system.';
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a short description of the TSS.';
                    ApplicationArea = NPRRetail;
                }
                field(SystemId; Rec.SystemId)
                {
                    ToolTip = 'Specifies an id, which was used to create the TSS at Fiskaly.';
                    ApplicationArea = NPRRetail;
                }
                field("Connection Parameter Set Code"; Rec."Connection Parameter Set Code")
                {
                    ToolTip = 'Specifies connection parameters to be used for the TSS, when exchanging data with Fiskaly.';
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                }
                field("Fiskaly TSS Created at"; Rec."Fiskaly TSS Created at")
                {
                    ToolTip = 'Specifies the date/time the TSS was created at Fiskaly.';
                    ApplicationArea = NPRRetail;
                }
                field("Fiskaly TSS State"; Rec."Fiskaly TSS State")
                {
                    ToolTip = 'Specifies last known state of the TSS at Fiskaly.';
                    ApplicationArea = NPRRetail;
                }
                field(TSSAdminPUK; TSSAdminPUK)
                {
                    Caption = 'TSS Admin PUK';
                    ToolTip = 'Specifies the Admin PUK of the TSS, assigned by Fiskaly.';
                    Editable = false;
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    var
                        TSSAdminPUKLbl: Label 'TSS Admin PUK: %1';
                    begin
                        Message(TSSAdminPUKLbl, DESecretMgt.GetSecretKey(Rec.AdminPUKSecretLbl()));
                    end;
                }
                field(TSSAdminPIN; TSSAdminPIN)
                {
                    Caption = 'TSS Admin PIN';
                    ToolTip = 'Specifies the Admin PIN of the TSS, assigned by Fiskaly.';
                    Editable = false;
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    var
                        TSSAdminPINLbl: Label 'TSS Admin PIN: %1';
                    begin
                        Message(TSSAdminPINLbl, DESecretMgt.GetSecretKey(Rec.AdminPINSecretLbl()));
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Create TSS")
            {
                Caption = 'Create Fiskaly TSS';
                ToolTip = 'Creates Technical Security System (TSS) at Fiskaly for DE fiscalization.';
                Image = InsertFromCheckJournal;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = NPRRetail;

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
                Caption = 'Set as Uninitialized';
                ToolTip = 'Change status of selected Technical Security System (TSS) to ''Uninitialized''. Should be run, if current status of TSS is ''Created''.';
                Image = UnitConversions;
                ApplicationArea = NPRRetail;

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
                Caption = 'Assign Admin PIN';
                ToolTip = 'Assignes new admin PIN to selected Technical Security System (TSS) at Fiskaly.';
                Image = CustomerCode;
                ApplicationArea = NPRRetail;

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
                Caption = 'Initialize TSS';
                ToolTip = 'Initializes selected Technical Security System (TSS) at Fiskaly.';
                Image = Approval;
                ApplicationArea = NPRRetail;

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
        }
    }

    trigger OnAfterGetRecord()
    begin
        if DESecretMgt.HasSecretKey(Rec.AdminPUKSecretLbl()) then
            TSSAdminPUK := '***'
        else
            TSSAdminPUK := '';
        if DESecretMgt.HasSecretKey(Rec.AdminPINSecretLbl()) then
            TSSAdminPIN := '***'
        else
            TSSAdminPIN := '';
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        TSSAdminPUK := '';
        TSSAdminPIN := ''
    end;

    var
        DESecretMgt: Codeunit "NPR DE Secret Mgt.";
        TSSAdminPIN: Text[200];
        TSSAdminPUK: Text[200];
}