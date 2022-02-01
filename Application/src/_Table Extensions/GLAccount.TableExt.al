tableextension 6014419 "NPR G/L Account" extends "G/L Account"
{
    fields
    {
        modify(Blocked)
        {
            trigger OnBeforeValidate()
            var
                POSPostingSetup: Record "NPR POS Posting Setup";
                BlockGLAcc1Err: Label 'You can''t block GL Account %1 as there are one or more active %2 that post to it. ', Comment = '%1 = GL Account, %2 = POS Posting Setup';
            begin
                if Rec.Blocked then begin
                    POSPostingSetup.SetRange("Account No.", Rec."No.");

                    if not POSPostingSetup.IsEmpty() then
                        Error(BlockGLAcc1Err, Rec."No.", POSPostingSetup.TableCaption());
                end;
            end;
        }
        field(6014400; "NPR Retail Payment"; Boolean)
        {
            Caption = 'NPR payment';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to "NPR Aux. G/L Account."';
        }
        field(6014402; "NPR Auto"; Boolean)
        {
            Caption = 'Auto';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            InitValue = true;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014403; "NPR Register Filter"; Code[10])
        {
            Caption = 'Register Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014404; "NPR Sales Ticket No. Filter"; Code[10])
        {
            Caption = 'Sales Ticket No. Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014405; "NPR Is Retail Payment"; Boolean)
        {
            Caption = 'Retail Payment';
            FieldClass = FlowField;
            CalcFormula = lookup("NPR Aux. G/L Account"."Retail Payment" where("No." = field("No.")));
        }

    }

    trigger OnBeforeDelete()
    begin
        NPRPreventDeleteOfBlockedAcc();
    end;

    var
        _AuxGLAccount: Record "NPR Aux. G/L Account";

    procedure NPRGetGLAccAdditionalFields(var AuxGLAccount: Record "NPR Aux. G/L Account")
    begin
        ReadGLAccAdditionalFields();
        AuxGLAccount := _AuxGLAccount;
    end;

    procedure NPRSetGLAccAdditionalFields(var AuxGLAccount: Record "NPR Aux. G/L Account")
    begin
        _AuxGLAccount := AuxGLAccount;
    end;

    procedure NPRSaveGLAccAdditionalFields()
    begin
        if _AuxGLAccount."No." <> '' then
            if not _AuxGLAccount.Modify() then
                _AuxGLAccount.Insert();
    end;

    procedure NPRDeleteGLAccAdditionalFields()
    begin
        ReadGLAccAdditionalFields();
        if _AuxGLAccount.Delete() then;
    end;

    local procedure ReadGLAccAdditionalFields()
    begin
        if _AuxGLAccount."No." <> Rec."No." then
            if not _AuxGLAccount.Get(Rec."No.") then begin
                _AuxGLAccount.Init();
                _AuxGLAccount."No." := Rec."No.";
            end;
    end;

    procedure NPRPreventDeleteOfBlockedAcc()
    var
        POSPostingSetup: Record "NPR POS Posting Setup";
        BlockGLAccErr: Label 'You cannot delete GL Account %1 as there are one or more active %2 that post to it. ', Comment = '%1 = "GL Account"."No.", %2 = "POS Posting Setup".TableCaption()';
    begin
        //In case Test Table Relation is skipped on POS Posting Setup, call this procedure before renaming G/L Account
        if Rec.Blocked then begin
            POSPostingSetup.SetRange("Account No.", Rec."No.");
            if not POSPostingSetup.IsEmpty() then
                Error(BlockGLAccErr, Rec."No.", POSPostingSetup.TableCaption());
        end;
    end;
}