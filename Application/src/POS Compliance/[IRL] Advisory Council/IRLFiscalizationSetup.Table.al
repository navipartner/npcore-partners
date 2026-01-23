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
#if (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
                IRLAuditMgt: Codeunit "NPR IRL Audit Mgt.";
#endif
                ConfirmUpdateRetentionPolicyMsg: Label 'To enable Ireland Fiscalization you must extend the retention policy to 6 years.\\This action cannot be undone.';
            begin
                if Rec."Enable IRL Fiscal" then
                    if Dialog.Confirm(ConfirmUpdateRetentionPolicyMsg, false) then begin
#if (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
                        IRLAuditMgt.UpdateRetentionPolicyTo6Years();
#endif
                        if not Rec."IRL Ret. Policy Extended" then
                            Rec."IRL Ret. Policy Extended" := true
                    end else
                        Error('')

            end;
        }
        field(4; "IRL Ret. Policy Extended"; Boolean)
        {
            Caption = 'IRL Retention Policy Extended';
            DataClassification = CustomerContent;
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
            AllowInCustomizations = Never;
#endif
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
        }
    }
}