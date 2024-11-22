table 6060058 "NPR CRO Fiscalization Setup"
{
    Access = Internal;
    Caption = 'CRO Fiscalization Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR CRO Fiscalization Setup";
    LookupPageId = "NPR CRO Fiscalization Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Enable CRO Fiscal"; Boolean)
        {
            Caption = 'Enable CRO Fiscalization';
            DataClassification = CustomerContent;
        }
        field(3; "Signing Certificate"; BLOB)
        {
            Caption = 'Signing Certificate';
            DataClassification = CustomerContent;
        }
        field(4; "Signing Certificate Password"; Text[250])
        {
            Caption = 'Signing Certificate Password';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(5; "Signing Certificate Thumbprint"; Text[250])
        {
            Caption = 'Signing Certificate Thumbprint';
            DataClassification = CustomerContent;
        }
        field(10; "Environment URL"; Text[2048])
        {
            Caption = 'Environment URL';
            DataClassification = CustomerContent;
        }
        field(15; "Bill No. Series"; Code[20])
        {
            Caption = 'Bill No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(20; "Certificate Subject OIB"; Code[11])
        {
            Caption = 'Certificate Subject OIB';
            DataClassification = CustomerContent;
        }
        field(21; "Print Receipt On Sales Doc."; Boolean)
        {
            Caption = 'Auto Print Receipt On Sales Document';
            DataClassification = CustomerContent;
        }
        field(30; "Enable POS Entry CLE Posting"; Boolean)
        {
            Caption = 'Enable POS Entry Cust. Ledg. Entry Posting';
            DataClassification = CustomerContent;
        }
        field(31; "Enable Legal Ent. CLE Posting"; Boolean)
        {
            Caption = 'Enable Legal Entities Cust. Ledg. Entry Posting';
            DataClassification = CustomerContent;
        }
        field(32; "Customer Posting Group Filter"; Text[2048])
        {
            Caption = 'Customer Posting Group Filter';
            DataClassification = CustomerContent;
            trigger OnLookup()
            var
                CustomerPostingGroup: Record "Customer Posting Group";
                SelectionFilterManagement: Codeunit SelectionFilterManagement;
                CustomerPostingGroups: Page "Customer Posting Groups";
                RecRef: RecordRef;
            begin
                if CustomerPostingGroup.IsEmpty() then
                    exit;
                CustomerPostingGroups.SetTableView(CustomerPostingGroup);
                CustomerPostingGroups.Editable(false);
                CustomerPostingGroups.LookupMode(true);
                if CustomerPostingGroups.RunModal() = Action::LookupOK then begin
                    CustomerPostingGroups.SetSelectionFilter(CustomerPostingGroup);
                    RecRef.GetTable(CustomerPostingGroup);
                    "Customer Posting Group Filter" := CopyStr(SelectionFilterManagement.GetSelectionFilter(RecRef, CustomerPostingGroup.FieldNo(Code)), 1, MaxStrLen("Customer Posting Group Filter"));
                end;
            end;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}