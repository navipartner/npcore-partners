table 6150828 "NPR AT Fiscalization Setup"
{
    Access = Internal;
    Caption = 'AT Fiscalization Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR AT Fiscalization Setup";
    LookupPageId = "NPR AT Fiscalization Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "AT Fiscal Enabled"; Boolean)
        {
            Caption = 'AT Fiscalization Enabled';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ATAuditMgt: Codeunit "NPR AT Audit Mgt.";
            begin
                ATAuditMgt.InitATFiscalJobQueues("AT Fiscal Enabled");
            end;
        }
        field(20; "Fiskaly API URL"; Text[250])
        {
            Caption = 'Fiskaly API URL';
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;
        }
        field(30; Training; Boolean)
        {
            Caption = 'Training';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    internal procedure GetWithCheck()
    begin
        Get();
        TestField(SystemId);
        TestField("Fiskaly API URL");
    end;

    internal procedure GetFONParticipantId(): Text
    begin
        if IsNullGuid(SystemId) then
            exit('');

        exit('FONParticipantId_' + SystemId);
    end;

    internal procedure GetFONUserId(): Text
    begin
        if IsNullGuid(SystemId) then
            exit('');

        exit('FONUserId_' + SystemId);
    end;

    internal procedure GetFONUserPIN(): Text
    begin
        if IsNullGuid(SystemId) then
            exit('');

        exit('FONUserPIN_' + SystemId);
    end;
}