﻿page 6014500 "NPR Replication Endpoints"
{
    Caption = 'Replication Service Endpoints';
    ContextSensitiveHelpPage = 'retail/replication/howto/replicationhowto.html';
    Editable = true;
    Extensible = true;
    PageType = ListPart;
    SourceTable = "NPR Replication Endpoint";
    SourceTableView = Sorting("Service Code", Enabled, "Sequence Order") order(ascending);
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("EndPoint ID"; Rec."EndPoint ID")
                {
                    ToolTip = 'Specifies the EndPoint ID.';
                    ApplicationArea = NPRRetail;
                }

                field("Endpoint Method"; Rec."Endpoint Method")
                {
                    ToolTip = 'Specifies Endpoint Method.';
                    ApplicationArea = NPRRetail;
                }
                field("Table ID"; Rec."Table ID")
                {
                    ToolTip = 'Specifies Table ID.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies Description of the Endpoint';
                    ApplicationArea = NPRRetail;
                }
                field(Path; Rec.Path)
                {
                    ToolTip = 'Specifies the Path which will be added to the base URL when sending the request.';
                    ApplicationArea = NPRRetail;
                }
                field("Sequence Order"; Rec."Sequence Order")
                {
                    ToolTip = 'Specifies order in which requests are executed.';
                    ApplicationArea = NPRRetail;
                }

                field("odata.maxpagesize"; Rec."odata.maxpagesize")
                {
                    ToolTip = 'Specifies the OData Maximum Page size for the web response.';
                    ApplicationArea = NPRRetail;
                    Caption = 'OData Max. Page Size';
                }
                field("Skip Import Entry No Data Resp"; Rec."Skip Import Entry No Data Resp")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Skip No Data Response';
                    ToolTip = 'Specifies if Import Entry creation will be skipped in case the response contains no new or modified records to be replicated.';
                }

                field(Enabled; Rec.Enabled)
                {
                    ToolTip = 'Specifies if the Endpoint is Enabled. If Disabled system will not execute import for this record.';
                    ApplicationArea = NPRRetail;
                }

                field("SQL Timestamp"; Rec."Replication Counter")
                {
                    ToolTip = 'Used to get records from related company that have changed since the last synchronization.';
                    ApplicationArea = NPRRetail;
                }

                field("Run OnInsert Trigger"; Rec."Run OnInsert Trigger")
                {
                    ToolTip = 'Specifies if OnInsert trigger runs when inserting a new record.';
                    ApplicationArea = NPRRetail;
                }

                field("Run OnModify Trigger"; Rec."Run OnModify Trigger")
                {
                    ToolTip = 'Specifies if OnModify trigger runs when inserting a new record.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenCard)
            {
                Caption = 'Open Card';
                ApplicationArea = NPRRetail;
                Image = Card;
                RunObject = Page "NPR Replication Endpoint";
                RunPageLink = "EndPoint ID" = field("EndPoint ID");
                ToolTip = 'Open Card Page';
            }
            action(SpecialFieldMappings)
            {
                Caption = 'Special Field Mappings';
                ApplicationArea = NPRRetail;
                Image = MapAccounts;
                ToolTip = 'Open Special Field Mappings.';
                trigger OnAction()
                begin
                    Rec.OpenSpecialFieldMappings();
                end;
            }

            action(GetLastReplicationCounter)
            {
                Caption = 'Get Last Replication Counter';
                ApplicationArea = NPRRetail;
                Image = GetSourceDoc;
                ToolTip = 'Updates the Replication Counter on the Endpoint to the Last Replication Counter from the Source database table. This should be used if the starting point of the Replication needs to be changed.';
                trigger OnAction()
                begin
                    Rec.UpdateLastReplicationCounterToLastCurrent();
                end;
            }

            action(Errors)
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'View endpoint error log entries.';
                Image = ErrorLog;
                Caption = 'Error Log';
                trigger OnAction()
                var
                    ReplicationAPI: Codeunit "NPR Replication API";
                begin
                    ReplicationAPI.ShowErrorLogEntries(Rec."Service Code", Rec."EndPoint ID");
                end;
            }
            action("Run Import")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Run Import only for selected Endpoint line.';
                Image = CompleteLine;
                trigger OnAction()
                var
                    ReplicationAPI: Codeunit "NPR Replication API";
                begin
                    ReplicationAPI.RunSpecificEndpointImportManually(Rec, '');
                end;
            }
        }
    }
}
