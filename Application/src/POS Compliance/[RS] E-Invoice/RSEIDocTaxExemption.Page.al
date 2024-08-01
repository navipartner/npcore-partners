page 6184661 "NPR RS EI Doc. Tax Exemption"
{
    Caption = 'RS E-Invoice Document Tax Exemption Reasons';
    ApplicationArea = NPRRSEInvoice;
    UsageCategory = Administration;
    Extensible = false;
    PageType = List;
    SourceTable = "NPR RS EI Doc. Tax Exemption";
    InsertAllowed = false;
    DeleteAllowed = false;
    AdditionalSearchTerms = 'Serbia E-Invoice Document Tax Exemption Reasons,RS E Invoice Document Tax Exemption Reasons';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the value of the Document No. field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field("Tax Category"; Rec."Tax Category")
                {
                    ToolTip = 'Specifies the value of the Tax Category field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field("Tax Exemption Reason Code"; Rec."Tax Exemption Reason Code")
                {
                    ToolTip = 'Specifies the value of the Tax Exemption Reason Code field.';
                    ApplicationArea = NPRRSEInvoice;
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        RSEITaxExemptionReason: Record "NPR RS EI Tax Exemption Reason";
                        RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
                    begin
                        RSEITaxExemptionReason.SetRange("Tax Category", RSEInvoiceMgt.GetAllowedTaxCategoryName(Rec."Tax Category".AsInteger()));
                        if Page.RunModal(Page::"NPR RS EI Tax Ex. Reasons", RSEITaxExemptionReason) = Action::LookupOK then begin
                            Rec."Tax Exemption Reason Code" := RSEITaxExemptionReason."Tax Exemption Reason Code";
                            Rec."Tax Exemption Reason Text" := RSEITaxExemptionReason."Tax Exemption Reason Text";
                        end
                    end;
#endif
                }
                field("Tax Exemption Reason Text"; Rec."Tax Exemption Reason Text")
                {
                    ToolTip = 'Specifies the value of the Tax Exemption Reason Text field.';
                    ApplicationArea = NPRRSEInvoice;
                }
            }
        }
    }
}