page 6060001 "GIM - Import Document"
{
    Caption = 'GIM - Import Document';
    PageType = Document;
    SourceTable = "GIM - Import Document";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No.";"No.")
                {
                }
                field("Document Type";"Document Type")
                {
                }
                field("Sender ID";"Sender ID")
                {
                }
                field("Data Format Code";"Data Format Code")
                {
                }
                field("File Name";"File Name")
                {
                    Editable = false;
                }
                field("File Extension";"File Extension")
                {
                    Editable = false;
                }
                field("Data Source";"Data Source")
                {
                    Editable = false;
                }
                field(Control9;Process)
                {
                    Editable = false;
                    ShowCaption = false;
                }
                field("User ID";"User ID")
                {
                    Editable = false;
                }
                field("Created At";"Created At")
                {
                    Editable = false;
                }
                field("Paused at Process Code";"Paused at Process Code")
                {
                    Editable = false;
                }
                field("Process Name";"Process Name")
                {
                    Editable = false;
                }
            }
            part(Log;"GIM - Import Document Subpage")
            {
                SubPageLink = "Document No."=FIELD("No.");
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(ActionGroup33)
            {
                Caption = 'General';
                action(ViewFile)
                {
                    Caption = 'View File';
                    Image = View;

                    trigger OnAction()
                    begin
                        ExportFileAndView(true);
                    end;
                }
                action(Notify)
                {
                    Caption = 'Notify';
                    Image = SendTo;

                    trigger OnAction()
                    begin
                        CurrPage.Log.PAGE.Notify();
                    end;
                }
            }
            group(ActionGroup17)
            {
                Caption = 'Mapping';
                action("Preview Mapping")
                {
                    Caption = 'Preview Mapping';
                    Image = ViewPage;
                    RunObject = Page "GIM - Mapping 2";
                    RunPageLink = "Document No."=FIELD("No.");
                    Visible = false;
                }
                action(Mapping)
                {
                    Caption = 'Mapping';
                    Image = SetupColumns;

                    trigger OnAction()
                    begin
                        DefineMapping2();
                    end;
                }
            }
            group(Process)
            {
                Caption = 'Process';
                action(StartImportProcess)
                {
                    Caption = 'Start';
                    Image = Process;

                    trigger OnAction()
                    begin
                        StartProcess();
                    end;
                }
                action(ContinueProcess)
                {
                    Caption = 'Continue';
                    Image = Continue;

                    trigger OnAction()
                    begin
                        ContinueProcess();
                    end;
                }
                action(RepeatProcess)
                {
                    Caption = 'Repeat';
                    Image = Refresh;

                    trigger OnAction()
                    begin
                        RepeatProcess();
                    end;
                }
                action(GoToPrevious)
                {
                    Caption = 'Go to previous';
                    Image = PreviousRecord;

                    trigger OnAction()
                    begin
                        GoToPreviousProcess();
                    end;
                }
                action(ResetProcess)
                {
                    Caption = 'Reset';
                    Image = Restore;

                    trigger OnAction()
                    begin
                        ResetProcess();
                    end;
                }
                action(ResetCurrentProcess)
                {
                    Caption = 'Reset Current Process';
                    Image = Restore;

                    trigger OnAction()
                    begin
                        ResetCurrentProcessStage();
                    end;
                }
            }
            group(Buffer)
            {
                Caption = 'Buffer';
                action("Import Buffer")
                {
                    Caption = 'Import Buffer';
                    Image = Import;
                    RunObject = Page "GIM - Import Buffer";
                    RunPageLink = "Document No."=FIELD("No.");
                }
                action("Import Entities")
                {
                    Caption = 'Import Entities';
                    Image = ImportChartOfAccounts;
                    RunObject = Page "GIM - Import Entities 2";
                    RunPageLink = "Document No."=FIELD("No.");
                }
                action("Preview Data Creation")
                {
                    Caption = 'Preview Data Creation';
                    Image = PreviewChecks;

                    trigger OnAction()
                    begin
                        PreviewData();
                    end;
                }
                action("Preview File Data")
                {
                    Caption = 'Preview File Data';
                    Image = PreviewChecks;

                    trigger OnAction()
                    begin
                        PreviewFileData();
                    end;
                }
            }
        }
    }
}

