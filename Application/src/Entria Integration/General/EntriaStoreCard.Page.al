#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6150929 "NPR Entria Store Card"
{
    Extensible = false;
    Caption = 'Entria Store';
    PageType = Card;
    SourceTable = "NPR Entria Store";
    UsageCategory = None;
    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies a unique ID that will be used by Business Central to refer to this store.';
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description that will be used by Business Central to refer to this store.';
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                }
                field(Enabled; Rec.Enabled)
                {
                    ToolTip = 'Specifies whether this Entria store is enabled for integration.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(SalesOrderIntegrationArea)
            {
                Caption = 'Sales Order Integration';

                field("Sales Order Integration"; Rec."Sales Order Integration")
                {
                    Caption = 'Enabled';
                    ToolTip = 'Specifies whether sales order integration is enabled. If enabled, the system will set up and use a job queue to download completed orders from Entria.';
                    ApplicationArea = NPRRetail;
                }

                field("Last Orders Imported At"; Rec."Last Orders Imported At")
                {
                    Caption = 'Last Orders Imported At';
                    ToolTip = 'Specifies the timestamp of the last successfully imported order update for this store. Used as the starting point for incremental order sync (updated_at). When new orders are processed, this value is updated periodically during the job queue run.';
                    ApplicationArea = NPRRetail;
                }
                field("Process Order On Import"; Rec."Process Order On Import")
                {
                    Caption = 'Process Order On Import';
                    ToolTip = 'Specifies whether imported orders are processed immediately during Ecommerce document import, within the same transaction.';
                    ApplicationArea = NPRRetail;
                }
                field("Location Code"; Rec."Location Code")
                {
                    Caption = 'Location Code';
                    ToolTip = 'Specifies the Business Central location code that will be used when creating sales orders imported from this store.';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ToolTip = 'Specifies the default value of Global Dimension 1 to be applied to sales orders imported from this store.';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ToolTip = 'Specifies the default value of Global Dimension 2 to be applied to sales orders imported from this store.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Connection)
            {
                Caption = 'Connection Parameters';

                field("Entria Url"; Rec."Entria Url")
                {
                    ToolTip = 'Specifies the base URL to your Entria backend. For example, https://your-store.Entriajs.com. Each Entria URL represents a single store.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field("Entria API Key Input"; APIKeyInput)
                {
                    Caption = 'Entria API Key';
                    ToolTip = 'Specifies the Entria Secret API Key for authentication. Create a Secret API Key through the Entria Admin dashboard.';
                    ApplicationArea = NPRRetail;
                    ExtendedDatatype = Masked;
                    Editable = false;
                }
                field(TestEntriaConnection; _TestEntriaConnectionLbl)
                {
                    ApplicationArea = NPRRetail;
                    DrillDown = true;
                    Editable = false;
                    ShowCaption = false;
                    Style = StrongAccent;
                    StyleExpr = true;
                    trigger OnDrillDown()
                    begin
                        _EntriaIntegrationMgt.TestEntriaStoreConnection(Rec);
                    end;
                }
            }

        }
    }
    actions
    {
        area(Processing)
        {
            action(SetConnectionParameters)
            {
                Caption = 'Set Connection Parameters';
                ToolTip = 'Set the Connection Parameters used to authenticate requests to the Entria backend.';
                ApplicationArea = NPRRetail;
                Image = Setup;
                trigger OnAction()
                begin
                    _EntriaIntegrationMgt.UpsertConnectionParams(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(TestConnection)
            {
                Caption = 'Test connection';
                ToolTip = 'Tests the connection to the Entria store using the configured URL and API Key.';
                ApplicationArea = NPRRetail;
                Image = ValidateEmailLoggingSetup;
                trigger OnAction()
                begin
                    _EntriaIntegrationMgt.TestEntriaStoreConnection(Rec);
                end;
            }
        }
        area(Navigation)
        {
            action(Dimensions)
            {
                Caption = 'Dimensions';
                Image = Dimensions;
                RunObject = Page "Default Dimensions";
                RunPageLink = "Table ID" = const(Database::"NPR Entria Store"), "No." = field(Code);
                ShortCutKey = 'Alt+D';
                ToolTip = 'View or edit default dimensions for this Entria store. These dimensions will be applied to all sales orders imported from this store.';
                ApplicationArea = NPRRetail;
            }
            action(Orders)
            {
                Caption = 'Orders';
                ApplicationArea = NPRRetail;
                Image = OrderList;
                ToolTip = 'View the Ecommerce documents created from orders imported from this store.';
                trigger OnAction()
                var
                    EcomSalesHeader: Record "NPR Ecom Sales Header";
                begin
                    EcomSalesHeader.SetRange("Ecommerce Store Code", Rec.Code);
                    Page.Run(Page::"NPR Ecom Sales Documents", EcomSalesHeader);
                end;
            }
            action(JobQueueEntries)
            {
                Caption = 'Job Queue Entries';
                ApplicationArea = NPRRetail;
                Image = JobListSetup;
                ToolTip = 'View the job queue entries for Entria order import and processing.';
                trigger OnAction()
                var
                    JobQueueEntry: Record "Job Queue Entry";
                begin
                    JobQueueEntry.SetCurrentKey("Object Type to Run", "Object ID to Run");
                    JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
                    JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Entria Order Import JQ");
                    Page.Run(Page::"Job Queue Entries", JobQueueEntry);
                end;
            }
        }
        area(Promoted)
        {
            group(Home)
            {
                Caption = 'Connection';
                actionref(SetConnectionParameters_Promoted; SetConnectionParameters) { }
                actionref(TestConnection_Promoted; TestConnection) { }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        Clear(APIKeyInput);
        if Rec.HasAPIKey() then
            APIKeyInput := '***';
    end;

    var
        _EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
        _TestEntriaConnectionLbl: Label 'Test connection';
        APIKeyInput: Text;
}
#endif
