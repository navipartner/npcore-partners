page 6014504 "NPR Replication Endpoint"
{

    Caption = 'Replication Endpoint';
    Extensible = true;
    PageType = Card;
    SourceTable = "NPR Replication Endpoint";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("EndPoint ID"; Rec."EndPoint ID")
                {
                    ToolTip = 'Specifies the EndPoint ID.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies Description of the Endpoint';
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
                field(Path; Rec.Path)
                {
                    ToolTip = 'Specifies the Path which will be added to the base URL when sending the request.';
                    ApplicationArea = NPRRetail;
                    MultiLine = true;
                }
                field("Fixed Filter"; Rec."Fixed Filter")
                {
                    ToolTip = 'Specifies the Fixed Filter which will be added to the base URL when sending the request. Example: number gt ''10003'' and number lt ''10008''. See: https://docs.microsoft.com/en-us/dynamics-nav/using-filter-expressions-in-odata-uris ';
                    ApplicationArea = NPRRetail;
                    MultiLine = true;
                }
                field("SQL Timestamp"; Rec."Replication Counter")
                {
                    ToolTip = 'Used to get records from related company that have changed since the last synchronization.';
                    ApplicationArea = NPRRetail;
                }
                field("Sequence Order"; Rec."Sequence Order")
                {
                    ToolTip = 'Specifies order in which requests are executed.';
                    ApplicationArea = NPRRetail;
                }
                field("odata.maxpagesize"; Rec."odata.maxpagesize")
                {
                    ToolTip = 'Specifies the maximum number of records per page returned by the endpoint request.';
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

                field("Skip Import Entry No Data Resp"; Rec."Skip Import Entry No Data Resp")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if Import Entry creation will be skipped in case the response contains no new or modified records to be replicated.';
                }

                field(Enabled; Rec.Enabled)
                {
                    ToolTip = 'Specifies if the Endpoint is Enabled. If Disabled system will not execute import for this record.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(SpecialFieldMappings)
            {
                Caption = 'Special Field Mappings';
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = MapAccounts;
                ToolTip = 'Open Special Field Mappings.';
                trigger OnAction()
                begin
                    Rec.OpenSpecialFieldMappings();
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
        }

        area(Processing)
        {
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