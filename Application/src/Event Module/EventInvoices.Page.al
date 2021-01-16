page 6151587 "NPR Event Invoices"
{
    // NPR5.49/TJ  /20190124 New object created as a copy from standard page 1029

    Caption = 'Event Invoices';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    RefreshOnActivate = true;
    SourceTable = "Job Planning Line Invoice";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Type field';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    Visible = ShowDetails;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field("Quantity Transferred"; "Quantity Transferred")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity Transferred field';
                }
                field("Transferred Date"; "Transferred Date")
                {
                    ApplicationArea = All;
                    Visible = ShowDetails;
                    ToolTip = 'Specifies the value of the Transferred Date field';
                }
                field("Invoiced Date"; "Invoiced Date")
                {
                    ApplicationArea = All;
                    Visible = ShowDetails;
                    ToolTip = 'Specifies the value of the Invoiced Date field';
                }
                field("Invoiced Amount (LCY)"; "Invoiced Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Invoiced Amount (LCY) field';
                }
                field("Invoiced Cost Amount (LCY)"; "Invoiced Cost Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Invoiced Cost Amount (LCY) field';
                }
                field("Job Ledger Entry No."; "Job Ledger Entry No.")
                {
                    ApplicationArea = All;
                    Visible = ShowDetails;
                    ToolTip = 'Specifies the value of the Job Ledger Entry No. field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(OpenSalesDocument)
                {
                    Caption = 'Open Sales Document';
                    Ellipsis = true;
                    Image = GetSourceDoc;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Open Sales Document action';

                    trigger OnAction()
                    var
                        JobCreateInvoice: Codeunit "Job Create-Invoice";
                    begin
                        EventMgt.OpenSalesDocument(Rec);
                        JobCreateInvoice.FindInvoices(Rec, JobNo, JobTaskNo, JobPlanningLineNo, DetailLevel);
                        if Get("Job No.", "Job Task No.", "Job Planning Line No.", "Document Type", "Document No.", "Line No.") then;
                    end;
                }
            }
        }
    }

    trigger OnInit()
    begin
        ShowDetails := true;
    end;

    trigger OnOpenPage()
    var
        JobCreateInvoice: Codeunit "Job Create-Invoice";
    begin
        EventMgt.FindInvoices(Rec, JobNo, JobTaskNo, JobPlanningLineNo, DetailLevel);
    end;

    var
        JobNo: Code[20];
        JobTaskNo: Code[20];
        JobPlanningLineNo: Integer;
        DetailLevel: Option All,"Per Job","Per Job Task","Per Job Planning Line";
        ShowDetails: Boolean;
        EventMgt: Codeunit "NPR Event Management";

    procedure SetPrJob(Job: Record Job)
    begin
        DetailLevel := DetailLevel::"Per Job";
        JobNo := Job."No.";
        ShowDetails := false;
    end;

    procedure SetPrJobTask(JobTask: Record "Job Task")
    begin
        DetailLevel := DetailLevel::"Per Job Task";
        JobNo := JobTask."Job No.";
        JobTaskNo := JobTask."Job Task No.";
        ShowDetails := false;
    end;

    procedure SetPrJobPlanningLine(JobPlanningLine: Record "Job Planning Line")
    begin
        DetailLevel := DetailLevel::"Per Job Planning Line";
        JobNo := JobPlanningLine."Job No.";
        JobTaskNo := JobPlanningLine."Job Task No.";
        JobPlanningLineNo := JobPlanningLine."Line No.";
        ShowDetails := false;
    end;
}

