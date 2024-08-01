table 6150832 "NPR RS EI Aux Customer"
{
    Access = Internal;
    Caption = 'RS EI Aux Customer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
            DataClassification = CustomerContent;
        }
        field(2; "NPR RS EI JBKJS Code"; Code[5])
        {
            Caption = 'RS EI JBKJS Code';
            Numeric = true;
            DataClassification = CustomerContent;
        }
        field(3; "NPR RS EI JMBG"; Code[13])
        {
            Caption = 'RS EI JMBG';
            Numeric = true;
            DataClassification = CustomerContent;
        }
        field(4; "NPR RS E-Invoice Customer"; Boolean)
        {
            Caption = 'RS E-Invoice Customer';
            DataClassification = CustomerContent;
        }
        field(5; "NPR RS EI CIR Customer"; Boolean)
        {
            Caption = 'RS EI CIR Customer';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Customer No.")
        {
            Clustered = true;
        }
    }

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    internal procedure ReadRSEIAuxCustomerFields(Customer: Record Customer)
    var
        RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
    begin
        if not RSEInvoiceMgt.IsRSEInvoiceEnabled() then
            exit;
        if not Rec.Get(Customer."No.") then begin
            Rec.Init();
            Rec."Customer No." := Customer."No.";
        end;
    end;

    internal procedure SaveRSEIAuxCustomerFields()
    begin
        if not Insert() then
            Modify();
    end;
#endif
}