pageextension 6014532 "NPR Company Information" extends "Company Information"
{
    actions
    {
        addlast(Processing)
        {
            action("NPR Check NP Retail License")
            {
                Caption = 'Check NP Retail License';
                Image = CheckDuplicates;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ApplicationArea = NPRRetail;
                ToolTip = 'Executes the Check NP Retail License action.';
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
