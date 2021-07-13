page 6151091 "NPR Nc RapidConnect Setup"
{
    Caption = 'RapidConnect Setup';
    CardPageID = "NPR Nc RapidConnect Setup Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Nc RapidConnect Setup";
    UsageCategory = Lists;
    ApplicationArea = NPRNaviConnect;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Package Code"; Rec."Package Code")
                {

                    ToolTip = 'Specifies the value of the Package Code field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Export Enabled"; Rec."Export Enabled")
                {

                    ToolTip = 'Specifies the value of the Export Enabled field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Task Processor Code"; Rec."Task Processor Code")
                {

                    ToolTip = 'Specifies the value of the Task Processor Code field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Import Enabled"; Rec."Import Enabled")
                {

                    ToolTip = 'Specifies the value of the Import Enabled field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Import Type"; Rec."Import Type")
                {

                    ToolTip = 'Specifies the value of the Import Type field';
                    ApplicationArea = NPRNaviConnect;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Import)
            {
                Caption = 'Import';
                action("Download Ftp")
                {
                    Caption = 'Download Ftp';
                    Image = Delegate;
                    Visible = Rec."Import Enabled";

                    ToolTip = 'Executes the Download Ftp action';
                    ApplicationArea = NPRNaviConnect;

                    trigger OnAction()
                    var
                        NcImportType: Record "NPR Nc Import Type";
                        NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
                    begin
                        NcImportType.Get(Rec."Import Type");
                        NcSyncMgt.DownloadFtpType(NcImportType);
                    end;
                }
            }
        }
    }
}

