page 6060157 "NPR Event Word Layouts"
{
    Caption = 'Event Word Layouts';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Event Word Layout";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Usage; Rec.Usage)
                {

                    ToolTip = 'Specifies the audience to receive the document.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies a description of the report layout.';
                    ApplicationArea = NPRRetail;
                }
                field("Basic Layout Code"; Rec."Basic Layout Code")
                {

                    ToolTip = 'Specifies basic layout code on which potential specific layout changes will be based on.';
                    ApplicationArea = NPRRetail;
                }
                field("Basic Layout Description"; Rec."Basic Layout Description")
                {

                    ToolTip = 'Specifies a description of basic layout.';
                    ApplicationArea = NPRRetail;
                }
                field(HasLayout; Rec.Layout.HasValue)
                {

                    ToolTip = 'Specifies if current layout is loaded either by inheriting from basic layout or by manually importing it.';
                    Caption = 'Has Layout';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Use Req. Page Parameters"; Rec."Use Req. Page Parameters")
                {

                    ToolTip = 'Specifies if layout has any filters set. You can set filters by clicking in this field or by using action Request Page.';
                    ApplicationArea = NPRRetail;
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
                PromotedOnly = true;

                ToolTip = 'Make a copy of a layout.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.CopyRecord();
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
                PromotedOnly = true;
                PromotedCategory = Process;

                ToolTip = 'Import a layout Word file.';
                ApplicationArea = NPRRetail;

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
                PromotedOnly = true;
                PromotedCategory = Process;

                ToolTip = 'Export a layout to a Word file. Then you can Edit it in Word, save the changes to the file, and chose Import Layout action to import it back to BC.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.ExportLayout('', true);
                end;
            }
            action(UpdateWordLayout)
            {
                Caption = 'Update Layout';
                Image = UpdateXML;

                ToolTip = 'Update specific report layouts or all custom report layouts that might be affected by dataset changes.';
                ApplicationArea = NPRRetail;

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
                PromotedOnly = true;
                PromotedCategory = "Report";

                ToolTip = 'Preview the report as pdf.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.PreviewReport();
                end;
            }
            action(RequestPage)
            {
                Caption = 'Request Page';
                Image = "Report";
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = "Report";

                ToolTip = 'View or set filters to be applied to the report.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.RunReportRequestPage();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
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
    end;

    var
        Job: Record Job;
        UpdateSuccesMsg: Label 'Layout has been updated to use the current report design.';
        UpdateNotRequiredMsg: Label 'Layout is up-to-date. No further updates are required.';
        PageCaption: Text;

    procedure SetEvent(JobHere: Record Job)
    begin
        Job := JobHere;
        PageCaption := Job."No." + ' ' + CurrPage.Caption;
        CurrPage.Caption(PageCaption);
    end;
}

