table 6150914 "NPR IRL Fiscalization Setup"
{
    Access = Internal;
    Caption = 'IRL Fiscalization Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR IRL Fiscalization Setup";
    LookupPageId = "NPR IRL Fiscalization Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(3; "Enable IRL Fiscal"; Boolean)
        {
            Caption = 'Enable IRL Fiscalization';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                IRLAuditMgt: Codeunit "NPR IRL Audit Mgt.";
                ConfirmUpdateRetentionPolicyLbl: Label 'To enable Ireland Fiscalization you must update the retention policy to 6 years?\\This action cannot be undone.';
            begin
                if Rec."Enable IRL Fiscal" then
                    if Dialog.Confirm(ConfirmUpdateRetentionPolicyLbl, false) then
                        IRLAuditMgt.UpdateRetentionPolicyTo6Years()
                    else
                        Error('');
            end;
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
        }
    }
}