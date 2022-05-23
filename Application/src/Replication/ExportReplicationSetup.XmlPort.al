xmlport 6014400 "NPR Export Replication Setup"
{
    Caption = 'Export Replication Setup';
    Direction = Export;
    Encoding = UTF8;
    PreserveWhiteSpace = true;
    schema
    {
        textelement(Root)
        {
            XmlName = 'ReplicationSetups';
            tableelement(NPRReplicationServiceSetup; "NPR Replication Service Setup")
            {
                MinOccurs = Zero;
                XmlName = 'ReplicationServiceSetup';
                fieldelement(APIVersion; NPRReplicationServiceSetup."API Version")
                { }
                fieldelement(Name; NPRReplicationServiceSetup.Name)
                { }
                fieldelement(ServiceURL; NPRReplicationServiceSetup."Service URL")
                { }
                fieldelement(Enabled; NPRReplicationServiceSetup.Enabled)
                { }
                fieldelement(ExternalDatabase; NPRReplicationServiceSetup."External Database")
                { }
                fieldelement(FromCompany; NPRReplicationServiceSetup.FromCompany)
                { }
                fieldelement(FromCompanyID; NPRReplicationServiceSetup.FromCompanyID)
                { }
                fieldelement(FromCompanyIDExternal; NPRReplicationServiceSetup."From Company ID - External")
                { }
                fieldelement(FromCompanyTenant; NPRReplicationServiceSetup."From Company Tenant")
                { }
                fieldelement(ErrorNotifyEmailAddress; NPRReplicationServiceSetup."Error Notify Email Address")
                { }
                fieldelement(AuthType; NPRReplicationServiceSetup.AuthType)
                { }
                fieldelement(UserName; NPRReplicationServiceSetup.UserName)
                { }
                fieldelement(OAuth2SetupCode; NPRReplicationServiceSetup."OAuth2 Setup Code")
                { }
                fieldelement(JobQueueEndTime; NPRReplicationServiceSetup.JobQueueEndTime)
                { }
                fieldelement(JobQueueMinutesBetweenRun; NPRReplicationServiceSetup.JobQueueMinutesBetweenRun)
                { }
                fieldelement(JobQueueProcessImportList; NPRReplicationServiceSetup.JobQueueProcessImportList)
                { }
                fieldelement(JobQueueStartTime; NPRReplicationServiceSetup.JobQueueStartTime)
                { }

                tableelement(NPRReplicationEndpoint; "NPR Replication Endpoint")
                {
                    MinOccurs = Zero;
                    XmlName = 'ReplicationEndpoint';
                    LinkTable = NPRReplicationServiceSetup;
                    LinkFields = "Service Code" = field("API Version");
                    fieldelement(EndpointId; NPRReplicationEndpoint."EndPoint ID")
                    { }
                    fieldelement(Description; NPRReplicationEndpoint.Description)
                    { }
                    fieldelement(Enabled; NPRReplicationEndpoint.Enabled)
                    { }
                    fieldelement(Path; NPRReplicationEndpoint.Path)
                    { }
                    fieldelement(SequenceOrder; NPRReplicationEndpoint."Sequence Order")
                    { }
                    fieldelement(EndpointMethod; NPRReplicationEndpoint."Endpoint Method")
                    { }
                    fieldelement(TableId; NPRReplicationEndpoint."Table ID")
                    { }
                    fieldelement(RunOnInsert; NPRReplicationEndpoint."Run OnInsert Trigger")
                    { }
                    fieldelement(RunOnModify; NPRReplicationEndpoint."Run OnModify Trigger")
                    { }
                    fieldelement(ODataMaxPageSize; NPRReplicationEndpoint."odata.maxpagesize")
                    { }
                    fieldelement(SkipImportEntry; NPRReplicationEndpoint."Skip Import Entry No Data Resp")
                    { }
                    fieldelement(FixedFiler; NPRReplicationEndpoint."Fixed Filter")
                    { }
                    fieldelement(ReplicationCounter; NPRReplicationEndpoint."Replication Counter")
                    { }

                    tableelement(NPRRepSpecialFieldMapping; "NPR Rep. Special Field Mapping")
                    {
                        MinOccurs = Zero;
                        XmlName = 'ReplicationEndpointSpecialFieldMapping';
                        LinkTable = NPRReplicationEndpoint;
                        LinkFields = "Service Code" = field("Service Code"), "EndPoint ID" = field("EndPoint ID"), "Table ID" = field("Table ID");
                        fieldelement(FieldID; NPRRepSpecialFieldMapping."Field ID")
                        { }
                        fieldelement(APIFieldName; NPRRepSpecialFieldMapping."API Field Name")
                        { }
                        fieldelement(WithValidation; NPRRepSpecialFieldMapping."With Validation")
                        { }
                        fieldelement(Skip; NPRRepSpecialFieldMapping.Skip)
                        { }
                        fieldelement(Priority; NPRRepSpecialFieldMapping.Priority)
                        { }
                    }
                }
            }
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
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
}
