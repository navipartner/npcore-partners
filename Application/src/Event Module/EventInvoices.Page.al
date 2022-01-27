page 6151587 "NPR Event Invoices"
{
    Extensible = False;
    //New object created as a copy from standard page 1029
    Caption = 'Event Invoices';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    RefreshOnActivate = true;
    SourceTable = "Job Planning Line Invoice";
    SourceTableTemporary = true;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document Type"; Rec."Document Type")
                {

                    ToolTip = 'Specifies the value of the Document Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {

                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Line No."; Rec."Line No.")
                {

                    Visible = ShowDetails;
                    ToolTip = 'Specifies the value of the Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Quantity Transferred"; Rec."Quantity Transferred")
                {

                    ToolTip = 'Specifies the value of the Quantity Transferred field';
                    ApplicationArea = NPRRetail;
                }
                field("Transferred Date"; Rec."Transferred Date")
                {

                    Visible = ShowDetails;
                    ToolTip = 'Specifies the value of the Transferred Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Invoiced Date"; Rec."Invoiced Date")
                {

                    Visible = ShowDetails;
                    ToolTip = 'Specifies the value of the Invoiced Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Invoiced Amount (LCY)"; Rec."Invoiced Amount (LCY)")
                {

                    ToolTip = 'Specifies the value of the Invoiced Amount (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Invoiced Cost Amount (LCY)"; Rec."Invoiced Cost Amount (LCY)")
                {

                    ToolTip = 'Specifies the value of the Invoiced Cost Amount (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Job Ledger Entry No."; Rec."Job Ledger Entry No.")
                {

                    Visible = ShowDetails;
                    ToolTip = 'Specifies the value of the Job Ledger Entry No. field';
                    ApplicationArea = NPRRetail;
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
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    ToolTip = 'Executes the Open Sales Document action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        JobCreateInvoice: Codeunit "Job Create-Invoice";
                    begin
                        EventMgt.OpenSalesDocument(Rec);
                        JobCreateInvoice.FindInvoices(Rec, JobNo, JobTaskNo, JobPlanningLineNo, DetailLevel);
                        if Rec.Get(Rec."Job No.", Rec."Job Task No.", Rec."Job Planning Line No.", Rec."Document Type", Rec."Document No.", Rec."Line No.") then;
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

