table 6248725 "NPR RO Fiscalisation Setup"
{
    Access = Internal;
    Caption = 'RO Fiscalization Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR RO Fiscalisation Setup";
    LookupPageId = "NPR RO Fiscalisation Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(3; "Enable RO Fiscal"; Boolean)
        {
            Caption = 'Enable RO Fiscalization';
            DataClassification = CustomerContent;
        }
        field(90; "Enable POS Entry CLE Posting"; Boolean)
        {
            Caption = 'Enable POS Entry Cust. Ledg. Entry Posting';
            DataClassification = CustomerContent;
        }
        field(91; "Enable Legal Ent. CLE Posting"; Boolean)
        {
            Caption = 'Enable Legal Entities Cust. Ledg. Entry Posting';
            DataClassification = CustomerContent;
        }
        field(92; "Customer Posting Group Filter"; Text[2048])
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