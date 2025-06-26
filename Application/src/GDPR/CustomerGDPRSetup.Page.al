page 6151150 "NPR Customer GDPR Setup"
{
    Extensible = False;
    Caption = 'Customer GDPR Setup';
    ContextSensitiveHelpPage = 'docs/retail/gdpr/intro/';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR Customer GDPR SetUp";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            group(General)
            {
                field("Anonymize After"; Rec."Anonymize After")
                {

                    ToolTip = 'Specifies the value of the Anonymize After field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Posting Group Filter"; Rec."Customer Posting Group Filter")
                {

                    ToolTip = 'Specifies the value of the Customer Posting Group Filter field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if (PAGE.RunModal(0, CustPostingGrp) = ACTION::LookupOK) then
                            Rec."Customer Posting Group Filter" := CustPostingGrp.Code;
                    end;
                }
                field("Gen. Bus. Posting Group Filter"; Rec."Gen. Bus. Posting Group Filter")
                {

                    ToolTip = 'Specifies the value of the Gen. Bus. Posting Group Filter field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if (PAGE.RunModal(0, GenBusPostingGrp) = ACTION::LookupOK) then
                            Rec."Gen. Bus. Posting Group Filter" := GenBusPostingGrp.Code;
                    end;
                }
                field("No of Customers"; Rec."No of Customers")
                {

                    ToolTip = 'Specifies the value of the No of Customers field';
                    ApplicationArea = NPRRetail;
                }

                field(EnableJobQueue; Rec."Enable Job Queue")
                {

                    ToolTip = 'Enqueue job queue entries for anonymization';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Extract Customers")
            {
                Caption = 'Extract Customers';
                Image = Customer;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Extract Customers action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    NPGDPRMgmt: Codeunit "NPR NP GDPR Management";
                begin
                    NPGDPRMgmt.PopulateCustToAnonymise();
                end;
            }
        }
        area(navigation)
        {
            action("Web Requests")
            {
                Caption = 'Web Requests';
                Ellipsis = true;
                Image = AbsenceCategory;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = Page "NPR GDPR Anonymization Req.";

                ToolTip = 'Executes the Web Requests action';
                ApplicationArea = NPRRetail;
            }
            action(JobQueueEntries)
            {

                Caption = 'Job Queue Entries';
                Image = JobLines;
                ToolTip = 'Executes the Job Queue Entries action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    GDPRManagement: Codeunit "NPR NP GDPR Management";
                begin
                    GDPRManagement.ShowJobQueueEntries(Rec);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin

        Rec.Reset();
        if (not Rec.Get()) then begin
            Rec.Init();
            Rec.Insert();
        end;

    end;

    var
        GenBusPostingGrp: Record "Gen. Business Posting Group";
        CustPostingGrp: Record "Customer Posting Group";
}

