tableextension 6014419 "NPR G/L Account" extends "G/L Account"
{
    fields
    {
        field(6014400; "NPR Retail Payment"; Boolean)
        {
            Caption = 'NPR payment';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Moved to "NPR Aux. G/L Account."';
        }
        field(6014402; "NPR Auto"; Boolean)
        {
            Caption = 'Auto';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            InitValue = true;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used.';
        }
        field(6014403; "NPR Register Filter"; Code[10])
        {
            Caption = 'Register Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used.';
        }
        field(6014404; "NPR Sales Ticket No. Filter"; Code[10])
        {
            Caption = 'Sales Ticket No. Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used.';
        }
        field(6014405; "NPR Is Retail Payment"; Boolean)
        {
            Caption = 'Retail Payment';
            FieldClass = FlowField;
            CalcFormula = lookup("NPR Aux. G/L Account"."Retail Payment" where("No." = field("No.")));
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Removing unnecesarry table extensions.';
        }

    }

    keys
    {
#IF NOT (BC17 or BC18 or BC19 or BC20)
        key("NPR Key1"; SystemRowVersion)
        {
        }
#ENDIF
    }
    var
        _AuxGLAccount: Record "NPR Aux. G/L Account";

    internal procedure NPRGetGLAccAdditionalFields(var AuxGLAccount: Record "NPR Aux. G/L Account")
    begin
        ReadGLAccAdditionalFields();
        AuxGLAccount := _AuxGLAccount;
    end;

    internal procedure NPRSetGLAccAdditionalFields(var AuxGLAccount: Record "NPR Aux. G/L Account")
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

}
