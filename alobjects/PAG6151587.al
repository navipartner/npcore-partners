page 6151587 "Event Invoices"
{
    // NPR5.49/TJ  /20190124 New object created as a copy from standard page 1029

    Caption = 'Event Invoices';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
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
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    Visible = ShowDetails;
                }
                field("Quantity Transferred"; "Quantity Transferred")
                {
                    ApplicationArea = All;
                }
                field("Transferred Date"; "Transferred Date")
                {
                    ApplicationArea = All;
                    Visible = ShowDetails;
                }
                field("Invoiced Date"; "Invoiced Date")
                {
                    ApplicationArea = All;
                    Visible = ShowDetails;
                }
                field("Invoiced Amount (LCY)"; "Invoiced Amount (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Invoiced Cost Amount (LCY)"; "Invoiced Cost Amount (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Job Ledger Entry No."; "Job Ledger Entry No.")
                {
                    ApplicationArea = All;
                    Visible = ShowDetails;
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
        EventMgt: Codeunit "Event Management";

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

