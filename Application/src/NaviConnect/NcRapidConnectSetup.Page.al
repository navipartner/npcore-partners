page 6151091 "NPR Nc RapidConnect Setup"
{
    Caption = 'RapidConnect Setup';
    CardPageID = "NPR Nc RapidConnect Setup Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Nc RapidConnect Setup";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Package Code"; Rec."Package Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Package Code field';
                }
                field("Export Enabled"; Rec."Export Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Export Enabled field';
                }
                field("Task Processor Code"; Rec."Task Processor Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Task Processor Code field';
                }
                field("Import Enabled"; Rec."Import Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Import Enabled field';
                }
                field("Import Type"; Rec."Import Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Import Type field';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Download Ftp action';

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

