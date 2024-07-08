page 6014499 "NPR Replication Setup List"
{
    ApplicationArea = NPRRetail;
    Caption = 'Replication API Setup List';
    CardPageId = "NPR Replication Setup Card";
    ContextSensitiveHelpPage = 'docs/retail/replication/how-to/setup/';
    Editable = false;
    Extensible = true;
    PageType = List;
    SourceTable = "NPR Replication Service Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("API Version"; Rec."API Version")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Setup Code.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Setup Name.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the Setup is Enabled. If Disabled system will not execute import for the endpoints related to this Setup ';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {

            action("Create Default Setup")
            {
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                ToolTip = 'Creates pre-defined replication setups, replication endpoints and replication endpoint special field mappings.';
                Image = InsertFromCheckJournal;
                trigger OnAction()
                begin
                    Rec.OnRegisterService();
                end;
            }
            action("Update Custom Endpoints")
            {
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                ToolTip = 'Runs code that subscribes to this action with the purpose of modifying standard NP Retail Enpoints path with Custom Paths.';
                Image = UpdateDescription;
                trigger OnAction()
                var
                    ReplicationRegister: Codeunit "NPR Replication Register";
                    Handled: Boolean;
                begin
                    ReplicationRegister.OnUpdateCustomEndpoints(Handled);
                    if Handled then
                        Message(UpdatedCustomEnpointsMsg)
                    else
                        Message(NotUpdatedCustomEnpointsMsg);
                end;
            }

            action(ImportReplicationSetups)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Import Replication Setups';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = false;
                PromotedOnly = true;
                ToolTip = 'Import a file with Replication Setups.';

                trigger OnAction()
                var
                begin
                    XMLPORT.Run(XMLPORT::"NPR Import Replication Setup", true, true);
                end;
            }

            action(ExportSetup)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Export Replication Setups';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = false;
                PromotedOnly = true;
                ToolTip = 'Export one or more Replication Setups to a file.';

                trigger OnAction()
                var
                    ReplicationSetup: Record "NPR Replication Service Setup";
                    TempBlob: Codeunit "Temp Blob";
                    FileManagement: Codeunit "File Management";
                    ExportSetup: XMLport "NPR Export Replication Setup";
                    OutStr: OutStream;
                    ExportFileName: Text;
                begin
                    CurrPage.SetSelectionFilter(ReplicationSetup);
                    TempBlob.CreateOutStream(OutStr);
                    ExportSetup.SetTableView(ReplicationSetup);
                    ExportSetup.SetDestination(OutStr);
                    ExportSetup.Export();
                    ExportFileName := DELCHR(Rec.TableCaption, '=', ' ') + '_' + CompanyName() + '.xml';
                    FileManagement.BLOBExport(TempBlob, ExportFileName, true);
                end;
            }
        }
        area(Reporting)
        {
            action("Check Missing Fields")
            {
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Report;
                ToolTip = 'Check if there are missing fields from other extensions that are not handled by the replication.';
                Image = CheckList;
                RunObject = report "NPR Rep. Check Missing Fields";
            }
        }
    }
    var
        UpdatedCustomEnpointsMsg: Label 'Custom Endpoints updated.';
        NotUpdatedCustomEnpointsMsg: Label 'There is no code defined to update Custom Endpoints.';

}
