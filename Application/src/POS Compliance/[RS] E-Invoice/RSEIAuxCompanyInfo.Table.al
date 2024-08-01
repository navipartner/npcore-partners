table 6150831 "NPR RS EI Aux Company Info"
{
    Access = Internal;
    Caption = 'RS EI Aux Company Information';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Company Info SystemId"; Guid)
        {
            Caption = 'Company Info SystemId';
            TableRelation = "Company Information".SystemId;
            DataClassification = CustomerContent;
        }
        field(2; "NPR RS EI JBKJS Code"; Code[5])
        {
            Caption = 'RS EI JBKJS Code';
            Numeric = true;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Company Info SystemId")
        {
            Clustered = true;
        }
    }

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    internal procedure ReadRSEIAuxCompanyInfoFields(CompanyInfo: Record "Company Information")
    var
        RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
    begin
        if not RSEInvoiceMgt.IsRSEInvoiceEnabled() then
            exit;
        if not Rec.Get(CompanyInfo.SystemId) then begin
            Rec.Init();
            Rec.SystemId := CompanyInfo.SystemId;
        end;
    end;

    internal procedure SaveRSEIAuxCompanyInformationFields()
    begin
        if not Insert() then
            Modify();
    end;
#endif
}