page 6060157 "NPR Event Word Layouts"
{
    Caption = 'Event Word Layouts';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Event Word Layout";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Usage; Rec.Usage)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the audience to receive the document.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the report layout.';
                }
                field("Basic Layout Code"; Rec."Basic Layout Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies basic layout code on which potential specific layout changes will be based on.';
                }
                field("Basic Layout Description"; Rec."Basic Layout Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of basic layout.';
                }
                field("Layout.HASVALUE"; Rec.Layout.HasValue)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if current layout is loaded either by inheriting from basic layout or by manually importing it.';
                    Caption = 'Has Layout';
                    Editable = false;
                }
                field("Use Req. Page Parameters"; Rec."Use Req. Page Parameters")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if layout has any filters set. You can set filters by clicking in this field or by using action Request Page.';
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action(CopyRec)
            {
                Caption = 'Copy';
                Image = CopyDocument;
                Promoted = true;
                ApplicationArea = All;
                ToolTip = 'Make a copy of a layout.';

                trigger OnAction()
                begin
                    Rec.CopyRecord;
                end;
            }
        }
        area(processing)
        {
            action(ImportLayout)
            {
                Caption = 'Import Layout';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                ToolTip = 'Import a layout Word file.';

                trigger OnAction()
                begin
                    Rec.ImportLayout('');
                end;
            }
            action(ExportLayout)
            {
                Caption = 'Export Layout';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                ToolTip = 'Export a layout to a Word file.';

                trigger OnAction()
                begin
                    Rec.ExportLayout('', true);
                end;
            }
            action(EditLayout)
            {
                Caption = 'Edit Layout';
                Image = EditReminder;
                Promoted = true;
                PromotedCategory = Process;
                Visible = CanEdit;
                ApplicationArea = All;
                ToolTip = 'Edit the report layout in Word, make changes to the file, and close Word to continue.';

                trigger OnAction()
                begin
                    Rec.EditLayout;
                end;
            }
            action(UpdateWordLayout)
            {
                Caption = 'Update Layout';
                Image = UpdateXML;
                ApplicationArea = All;
                ToolTip = 'Update specific report layouts or all custom report layouts that might be affected by dataset changes.';

                trigger OnAction()
                begin
                    if Rec.UpdateLayout(false, false) then
                        Message(UpdateSuccesMsg)
                    else
                        Message(UpdateNotRequiredMsg);
                end;
            }
        }
        area(reporting)
        {
            action(PreviewReport)
            {
                Caption = 'Preview Report';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                ApplicationArea = All;
                ToolTip = 'Preview the report as pdf.';

                trigger OnAction()
                begin
                    Rec.PreviewReport;
                end;
            }
            action(RequestPage)
            {
                Caption = 'Request Page';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                ApplicationArea = All;
                ToolTip = 'View or set filters to be applied to the report.';

                trigger OnAction()
                begin
                    Rec.RunReportRequestPage();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CanEdit := IsWindowsClient;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Source Record ID" := Job.RecordId;
    end;

    trigger OnOpenPage()
    begin
        Rec.FilterGroup := 2;
        Rec.SetRange("Source Record ID", Job.RecordId);
        Rec.FilterGroup := 0;
        IsWindowsClient := false;
    end;

    var
        Job: Record Job;
        UpdateSuccesMsg: Label 'Layout has been updated to use the current report design.';
        UpdateNotRequiredMsg: Label 'Layout is up-to-date. No further updates are required.';
        CaptionTxt: Label '%1 - %2 %3', Locked = true;
        PageCaption: Text;
        CanEdit: Boolean;
        IsWindowsClient: Boolean;

    procedure SetEvent(JobHere: Record Job)
    begin
        Job := JobHere;
        PageCaption := Job."No." + ' ' + CurrPage.Caption;
        CurrPage.Caption(PageCaption);
    end;
}

