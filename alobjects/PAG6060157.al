page 6060157 "Event Word Layouts"
{
    // NPR5.29/NPKNAV/20170127  CASE 248723 Transport NPR5.29 - 27 januar 2017
    // NPR5.55/ALPO/20200630 CASE 411779 Hide not supported "Edit Layout" button in Web Client

    Caption = 'Event Word Layouts';
    PageType = List;
    SourceTable = "Event Word Layout";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Usage; Usage)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Basic Layout Code"; "Basic Layout Code")
                {
                    ApplicationArea = All;
                }
                field("Basic Layout Description"; "Basic Layout Description")
                {
                    ApplicationArea = All;
                }
                field("Layout.HASVALUE"; Layout.HasValue)
                {
                    ApplicationArea = All;
                    Caption = 'Has Layout';
                    Editable = false;
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

                trigger OnAction()
                begin
                    CopyRecord;
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

                trigger OnAction()
                begin
                    ImportLayout('');
                end;
            }
            action(ExportLayout)
            {
                Caption = 'Export Layout';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    ExportLayout('', true);
                end;
            }
            action(EditLayout)
            {
                Caption = 'Edit Layout';
                Image = EditReminder;
                Promoted = true;
                PromotedCategory = Process;
                Visible = CanEdit;

                trigger OnAction()
                begin
                    EditLayout;
                end;
            }
            action(UpdateWordLayout)
            {
                Caption = 'Update Layout';
                Image = UpdateXML;

                trigger OnAction()
                begin
                    if UpdateLayout(false, false) then
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

                trigger OnAction()
                begin
                    PreviewReport;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CanEdit := IsWindowsClient;  //NPR5.55 [411779]
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Source Record ID" := Job.RecordId;
    end;

    trigger OnOpenPage()
    begin
        FilterGroup := 2;
        SetRange("Source Record ID", Job.RecordId);
        FilterGroup := 0;
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

