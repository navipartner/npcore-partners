xmlport 6014402 "NPR Import Replication Setup"
{
    Caption = 'Import Replication Setup';
    Direction = Import;
    Encoding = UTF8;
    PreserveWhiteSpace = true;
    UseRequestPage = true;
    schema
    {
        textelement(Root)
        {
            XmlName = 'ReplicationSetups';
            tableelement(TempReplicationServiceSetup; "NPR Replication Service Setup")
            {
                MinOccurs = Zero;
                UseTemporary = true;
                XmlName = 'ReplicationServiceSetup';
                SourceTableView = sorting("API Version");
                fieldelement(APIVersion; TempReplicationServiceSetup."API Version")
                { }
                fieldelement(Name; TempReplicationServiceSetup.Name)
                { }
                fieldelement(ServiceURL; TempReplicationServiceSetup."Service URL")
                { }
                fieldelement(Enabled; TempReplicationServiceSetup.Enabled)
                { }
                fieldelement(ExternalDatabase; TempReplicationServiceSetup."External Database")
                { }
                fieldelement(FromCompany; TempReplicationServiceSetup.FromCompany)
                { }
                fieldelement(FromCompanyID; TempReplicationServiceSetup.FromCompanyID)
                { }
                fieldelement(FromCompanyIDExternal; TempReplicationServiceSetup."From Company ID - External")
                { }
                fieldelement(FromCompanyTenant; TempReplicationServiceSetup."From Company Tenant")
                { }
                fieldelement(ErrorNotifyEmailAddress; TempReplicationServiceSetup."Error Notify Email Address")
                { }
                fieldelement(AuthType; TempReplicationServiceSetup.AuthType)
                { }
                fieldelement(UserName; TempReplicationServiceSetup.UserName)
                { }
                fieldelement(OAuth2SetupCode; TempReplicationServiceSetup."OAuth2 Setup Code")
                { }
                fieldelement(JobQueueEndTime; TempReplicationServiceSetup.JobQueueEndTime)
                { }
                fieldelement(JobQueueMinutesBetweenRun; TempReplicationServiceSetup.JobQueueMinutesBetweenRun)
                { }
                fieldelement(JobQueueProcessImportList; TempReplicationServiceSetup.JobQueueProcessImportList)
                { }
                fieldelement(JobQueueStartTime; TempReplicationServiceSetup.JobQueueStartTime)
                { }
                tableelement(TempReplicationEndpoint; "NPR Replication Endpoint")
                {
                    MinOccurs = Zero;
                    XmlName = 'ReplicationEndpoint';
                    LinkTable = TempReplicationServiceSetup;
                    LinkFields = "Service Code" = field("API Version");
                    UseTemporary = true;
                    SourceTableView = sorting("Service Code", "Endpoint ID");
                    fieldelement(EndpointId; TempReplicationEndpoint."EndPoint ID")
                    { }
                    fieldelement(Description; TempReplicationEndpoint.Description)
                    { }
                    fieldelement(Enabled; TempReplicationEndpoint.Enabled)
                    { }
                    fieldelement(Path; TempReplicationEndpoint.Path)
                    { }
                    fieldelement(SequenceOrder; TempReplicationEndpoint."Sequence Order")
                    { }
                    fieldelement(EndpointMethod; TempReplicationEndpoint."Endpoint Method")
                    { }
                    fieldelement(TableId; TempReplicationEndpoint."Table ID")
                    { }
                    fieldelement(RunOnInsert; TempReplicationEndpoint."Run OnInsert Trigger")
                    { }
                    fieldelement(RunOnModify; TempReplicationEndpoint."Run OnModify Trigger")
                    { }
                    fieldelement(ODataMaxPageSize; TempReplicationEndpoint."odata.maxpagesize")
                    { }
                    fieldelement(SkipImportEntry; TempReplicationEndpoint."Skip Import Entry No Data Resp")
                    { }
                    fieldelement(FixedFiler; TempReplicationEndpoint."Fixed Filter")
                    { }
                    fieldelement(ReplicationCounter; TempReplicationEndpoint."Replication Counter")
                    { }
                    tableelement(TempRepSpecialFieldMapping; "NPR Rep. Special Field Mapping")
                    {
                        MinOccurs = Zero;
                        XmlName = 'ReplicationEndpointSpecialFieldMapping';
                        LinkTable = TempReplicationEndpoint;
                        LinkFields = "Service Code" = field("Service Code"), "EndPoint ID" = field("EndPoint ID"), "Table ID" = field("Table ID");
                        UseTemporary = true;
                        SourceTableView = sorting("Service Code", "EndPoint ID", "Table ID", "Field Id", "Priority");
                        fieldelement(FieldID; TempRepSpecialFieldMapping."Field ID")
                        { }
                        fieldelement(APIFieldName; TempRepSpecialFieldMapping."API Field Name")
                        { }
                        fieldelement(WithValidation; TempRepSpecialFieldMapping."With Validation")
                        { }
                        fieldelement(Skip; TempRepSpecialFieldMapping.Skip)
                        { }
                        fieldelement(Priority; TempRepSpecialFieldMapping.Priority)
                        { }
                    }
                }
                trigger OnBeforeInsertRecord()
                var
                    ReplicationSetup: Record "NPR Replication Service Setup";
                begin
                    if ReplicationSetup.Get(TempReplicationServiceSetup."API Version") then begin
                        if ReplicationSetup.Enabled then
                            Error(CannotUpdateEnabledSetupErr, TempReplicationServiceSetup."API Version");
                        if not UpdateSetups then
                            Error(SetupAlreadyExistsErr, TempReplicationServiceSetup."API Version");
                    end;

                end;
            }
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                field(UpdateSetupsField; UpdateSetups)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Update existing setups';
                    ToolTip = 'Specifies if the existing setups will be updated (merged) with the imported ones.';
                }
                field(UpdateReplicationCounterField; UpdateReplicationCounter)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Update replication counter';
                    ToolTip = 'Specifies if the replication couter of the endpoints will be updated with the imported ones.';
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }

    trigger OnInitXmlPort()
    var
    begin
        UpdateSetups := true;
    end;

    trigger OnPostXmlPort()
    begin
        if TempReplicationServiceSetup.FindSet() then
            repeat
                ProcessRepSetup(TempReplicationServiceSetup);
            until TempReplicationServiceSetup.Next() = 0;
    end;


    local procedure ProcessRepSetup(var TempReplicationSetup: Record "NPR Replication Service Setup")
    var
    begin
        InsertReplicationSetup(TempReplicationSetup);
        ProcessReplicationEndpoints(TempReplicationSetup);
    end;

    local procedure InsertReplicationSetup(var TempReplicationSetup: Record "NPR Replication Service Setup")
    var
        ReplicationSetup: Record "NPR Replication Service Setup";
    begin
        if not ReplicationSetup.Get(TempReplicationSetup."API Version") then begin
            ReplicationSetup.Init();
            ReplicationSetup."API Version" := TempReplicationServiceSetup."API Version";
            ReplicationSetup.Insert();
        end;

        ReplicationSetup.Name := TempReplicationSetup.Name;
        ReplicationSetup."Service URL" := TempReplicationSetup."Service URL";
        ReplicationSetup."External Database" := TempReplicationSetup."External Database";
        ReplicationSetup.FromCompany := TempReplicationSetup.FromCompany;
        ReplicationSetup."From Company ID - External" := TempReplicationSetup."From Company ID - External";
        ReplicationSetup."From Company Tenant" := TempReplicationSetup."From Company Tenant";
        ReplicationSetup."Error Notify Email Address" := TempReplicationSetup."Error Notify Email Address";
        ReplicationSetup.AuthType := TempReplicationSetup.AuthType;
        if ReplicationSetup.UserName = '' then
            ReplicationSetup.UserName := TempReplicationSetup.UserName;
        ReplicationSetup."OAuth2 Setup Code" := TempReplicationSetup."OAuth2 Setup Code";
        ReplicationSetup.JobQueueEndTime := TempReplicationSetup.JobQueueEndTime;
        ReplicationSetup.JobQueueMinutesBetweenRun := TempReplicationSetup.JobQueueMinutesBetweenRun;
        ReplicationSetup.JobQueueProcessImportList := TempReplicationSetup.JobQueueProcessImportList;
        ReplicationSetup.JobQueueStartTime := TempReplicationSetup.JobQueueStartTime;
        ReplicationSetup.Modify();
    end;

    local procedure ProcessReplicationEndpoints(var TempReplicationSetup: Record "NPR Replication Service Setup")
    var
    begin
        TempReplicationEndpoint.SetRange("Service Code", TempReplicationSetup."API Version");
        if TempReplicationEndpoint.FindSet() then
            repeat
                ProcessReplicationEndpoint(TempReplicationEndpoint);
            until TempReplicationEndpoint.Next() = 0;
    end;

    local procedure ProcessReplicationEndpoint(var TempReplicationEndpoint: Record "NPR Replication Endpoint")
    begin
        InsertReplicationEndpoint(TempReplicationEndpoint);
        ProcessSpecialFieldsMappings(TempReplicationEndpoint);
    end;

    local procedure InsertReplicationEndpoint(var TempReplicationEndpoint: Record "NPR Replication Endpoint")
    var
        ReplicationEndpoint: Record "NPR Replication Endpoint";
        OldReplicationCounter: BigInteger;
    begin
        if not ReplicationEndpoint.Get(TempReplicationEndpoint."Service Code", TempReplicationEndpoint."EndPoint ID") then begin
            ReplicationEndpoint.Init();
            ReplicationEndpoint.TransferFields(TempReplicationEndpoint);
            if not UpdateReplicationCounter then
                ReplicationEndpoint."Replication Counter" := 0;
            ReplicationEndpoint.Insert();
        end else begin
            OldReplicationCounter := ReplicationEndpoint."Replication Counter";
            ReplicationEndpoint.TransferFields(TempReplicationEndpoint, false);
            if not UpdateReplicationCounter then
                ReplicationEndpoint."Replication Counter" := OldReplicationCounter;
            ReplicationEndpoint.Modify();
        end;
    end;

    local procedure ProcessSpecialFieldsMappings(var TempReplicationEndpoint: Record "NPR Replication Endpoint")
    var
    begin
        TempRepSpecialFieldMapping.SetRange("Service Code", TempReplicationEndpoint."Service Code");
        TempRepSpecialFieldMapping.SetRange("EndPoint ID", TempReplicationEndpoint."EndPoint ID");
        TempRepSpecialFieldMapping.SetRange("Table ID", TempReplicationEndpoint."Table ID");
        if TempRepSpecialFieldMapping.FindSet() then
            repeat
                InsertSpecialFieldMapping(TempRepSpecialFieldMapping);
            until TempRepSpecialFieldMapping.Next() = 0;
    end;

    local procedure InsertSpecialFieldMapping(var TempSpecialFieldMapping: Record "NPR Rep. Special Field Mapping")
    var
        SpecialFieldMapping: Record "NPR Rep. Special Field Mapping";
    begin
        if not SpecialFieldMapping.Get(TempSpecialFieldMapping."Service Code", TempSpecialFieldMapping."EndPoint ID", TempSpecialFieldMapping."Table ID",
         TempSpecialFieldMapping."Field ID", TempSpecialFieldMapping.Priority) then begin
            SpecialFieldMapping.Init();
            SpecialFieldMapping.TransferFields(TempSpecialFieldMapping);
            SpecialFieldMapping.Insert();
        end else begin
            SpecialFieldMapping.TransferFields(TempSpecialFieldMapping, false);
            SpecialFieldMapping.Modify();
        end;
    end;

    var
        SetupAlreadyExistsErr: Label 'Replication Setup %1 already exists.', Comment = '%1 = API Version';
        CannotUpdateEnabledSetupErr: Label 'Replication Setup %1 cannot be updated because it is Enabled.', Comment = '%1 = API Version';
        UpdateSetups: Boolean;
        UpdateReplicationCounter: Boolean;
}
