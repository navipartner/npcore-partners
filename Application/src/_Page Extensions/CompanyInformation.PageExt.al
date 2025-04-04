pageextension 6014532 "NPR Company Information" extends "Company Information"
{
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    layout
    {
        addlast(General)
        {
            group("NPR RS E-Invoicing")
            {
                field("NPR RS EI JBKJS Code"; RSEIAuxCompanyInfo."NPR RS EI JBKJS Code")
                {
                    Caption = 'RS EI JBKJS Code';
                    ApplicationArea = NPRRSEInvoice;
                    ToolTip = 'Specifies the value of the JBKJS Code field.';
                    Numeric = true;

                    trigger OnValidate()
                    var
                        RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
                    begin
                        RSEInvoiceMgt.CheckJKBJSFormatValidity(RSEIAuxCompanyInfo."NPR RS EI JBKJS Code");
                        RSEIAuxCompanyInfo.SaveRSEIAuxCompanyInformationFields();
                    end;
                }
            }
        }
    }
#endif
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
                    Company: Record Company;
                    TempClientDiagnostic: Record "NPR Client Diagnostic v2" temporary;
                    EnvironmentInformation: Codeunit "Environment Information";
                begin
                    if EnvironmentInformation.IsSandbox() then
                        exit;

                    if Company.Get(CompanyName()) then
                        if Company."Evaluation Company" then
                            exit;

                    TempClientDiagnostic."User Security ID" := UserSecurityId();
                    TempClientDiagnostic."User Login Type" := TempClientDiagnostic."User Login Type"::BC;
                    if Codeunit.Run(Codeunit::"NPR Invoke CaseSystem Login", TempClientDiagnostic) then;
                end;
            }
        }
    }

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    trigger OnAfterGetCurrRecord()
    begin
        RSEIAuxCompanyInfo.ReadRSEIAuxCompanyInfoFields(Rec);
    end;

    var
        RSEIAuxCompanyInfo: Record "NPR RS EI Aux Company Info";
#endif
}

