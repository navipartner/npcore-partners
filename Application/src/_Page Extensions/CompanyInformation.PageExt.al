pageextension 6014532 "NPR Company Information" extends "Company Information"
{
    actions
    {
        addlast(Processing)
        {
            action("NPR nvoke Case System Call")
            {
                Caption = 'Invoke Case System Call';
                Image = CheckDuplicates;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Executes the action which invokes the call to the case system.';
                ApplicationArea = NPRRetail;
                trigger OnAction()
                var
                    TempClientDiagnostic: Record "NPR Client Diagnostic v2" temporary;
                    ServiceTierUserMgt: Codeunit "NPR Service Tier User Mgt.";
                begin
                    TempClientDiagnostic."User Security ID" := UserSecurityId();
                    TempClientDiagnostic."User Login Type" := TempClientDiagnostic."User Login Type"::POS;
                    ServiceTierUserMgt.InitCaseSystemCallback(TempClientDiagnostic);
                end;
            }
        }
    }
}
