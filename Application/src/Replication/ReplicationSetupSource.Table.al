table 6014634 "NPR Replication Setup (Source)"
{
    Access = Internal;
    Caption = 'Replication Setup (Source Company)';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(10; "Enable Replication Counter"; Boolean)
        {
            Caption = 'Enable Replication Counter';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if not "Enable Replication Counter" then begin
                    CheckCompanyIsUsedAsSourceInOtherCompanies();
                    if not Confirm(StrSubstNo(ConfirmDisableRepCounterLbl, CompanyName)) then
                        Error('');
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

    local procedure CheckCompanyIsUsedAsSourceInOtherCompanies()
    var
        Company: Record Company;
        ReplicationServiceSetup: Record "NPR Replication Service Setup";
    begin
        Company.SetFilter(Name, '<>%1', CompanyName());
        if Company.FindSet() then
            repeat
                Clear(ReplicationServiceSetup);
                ReplicationServiceSetup.ChangeCompany(Company.Name);
                ReplicationServiceSetup.SetRange(FromCompany, CompanyName());
                if not ReplicationServiceSetup.IsEmpty() then
                    Error(CompanyIsUsedAsSourceCompanyErr, CompanyName, Company.Name);
            until Company.Next() = 0;
    end;

    var
        CompanyIsUsedAsSourceCompanyErr: Label 'Company ''%1'' is used as Source Company in Company ''%2''. You cannot disable Replication Counter because this would break the Data Replication process.';
        ConfirmDisableRepCounterLbl: Label 'Are you sure you want to disable Replication Counter in company ''%1''? This action will cause the Data Replication process work incorrectly if other companies will use this company as Source Company for the Replication.';

}
