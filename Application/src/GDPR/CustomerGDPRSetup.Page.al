page 6151150 "NPR Customer GDPR Setup"
{
    Caption = 'Customer GDPR Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR Customer GDPR SetUp";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Anonymize After"; "Anonymize After")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Anonymize After field';
                }
                field("Customer Posting Group Filter"; "Customer Posting Group Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Posting Group Filter field';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if (PAGE.RunModal(0, CustPostingGrp) = ACTION::LookupOK) then
                            "Customer Posting Group Filter" := CustPostingGrp.Code;
                    end;
                }
                field("Gen. Bus. Posting Group Filter"; "Gen. Bus. Posting Group Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gen. Bus. Posting Group Filter field';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if (PAGE.RunModal(0, GenBusPostingGrp) = ACTION::LookupOK) then
                            "Gen. Bus. Posting Group Filter" := GenBusPostingGrp.Code;
                    end;
                }
                field("No of Customers"; "No of Customers")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No of Customers field';
                }

                field(EnableJobQueue; "Enable Job Queue")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enqueue job queue entries for anonymization';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Extract Customers action';

                trigger OnAction()
                var
                    GDPRSetup: Record "NPR Customer GDPR SetUp";
                    DateFormulaTxt: Text[250];
                    VarPeriod: DateFormula;
                    VarEntryNo: Integer;
                    Window: Dialog;
                    Customer: Record Customer;
                    CLE: Record "Cust. Ledger Entry";
                    CustToAnonymize: Record "NPR Customers to Anonymize";
                    ILE: Record "Item Ledger Entry";
                    NoCLE: Boolean;
                    NoILE: Boolean;
                    NoTrans: Boolean;
                begin

                    CustToAnonymize.Reset();
                    if (CustToAnonymize.FindFirst()) then
                        if (not Confirm(Text000, false)) then
                            exit;

                    CustToAnonymize.Reset();
                    CustToAnonymize.DeleteAll;

                    if (GDPRSetup.Get) then;

                    DateFormulaTxt := '-' + Format(GDPRSetup."Anonymize After");
                    Evaluate(VarPeriod, DateFormulaTxt);

                    VarEntryNo := 1;
                    Window.Open('Customer #1##################');
                    Customer.Reset();
                    Customer.SetRange(Customer."NPR Anonymized", false);
                    Customer.SetFilter(Customer."Customer Posting Group", GDPRSetup."Customer Posting Group Filter");
                    Customer.SetFilter(Customer."Gen. Bus. Posting Group", GDPRSetup."Gen. Bus. Posting Group Filter");
                    Customer.SetFilter("Last Date Modified", '<>%1', 0D);
                    if (Customer.FindSet()) then
                        repeat
                            Window.Update(1, Customer."No.");

                            NoTrans := true;

                            CLE.Reset();
                            CLE.SetCurrentKey("Customer No.", "Posting Date", "Currency Code");
                            CLE.SetRange("Customer No.", Customer."No.");
                            NoTrans := CLE.FindFirst();

                            if (NoTrans) then begin
                                ILE.Reset();
                                ILE.SetCurrentKey("Source Type", "Source No.", "Item No.", "Variant Code", "Posting Date");
                                ILE.SetRange(ILE."Source Type", ILE."Source Type"::Customer);
                                ILE.SetRange(ILE."Source No.", Customer."No.");
                                NoTrans := ILE.FindFirst();
                            end;

                            if (NoTrans) then begin
                                if (Today - Customer."Last Date Modified") >= (Today - CalcDate(VarPeriod, Today)) then begin
                                    CustToAnonymize.Init;
                                    CustToAnonymize."Entry No" := VarEntryNo;
                                    CustToAnonymize."Customer No" := Customer."No.";
                                    CustToAnonymize."Customer Name" := Customer.Name;
                                    CustToAnonymize.Insert();
                                    VarEntryNo += 1;
                                end;
                            end else begin

                                NoCLE := false;
                                NoILE := false;
                                CLE.Reset();
                                CLE.SetCurrentKey("Customer No.", "Posting Date", "Currency Code");
                                CLE.SetRange("Customer No.", Customer."No.");
                                CLE.SetFilter("Posting Date", '>%1', CalcDate(VarPeriod, Today));
                                if (not CLE.FindFirst()) then
                                    NoCLE := true;

                                ILE.Reset();
                                ILE.SetCurrentKey("Source Type", "Source No.", "Item No.", "Variant Code", "Posting Date");
                                ILE.SetRange(ILE."Source Type", ILE."Source Type"::Customer);
                                ILE.SetRange(ILE."Source No.", Customer."No.");
                                ILE.SetFilter("Posting Date", '>%1', CalcDate(VarPeriod, Today));
                                if (not ILE.FindFirst()) then
                                    NoILE := true;

                                if (NoILE and NoCLE) then begin
                                    CustToAnonymize.Init;
                                    CustToAnonymize."Entry No" := VarEntryNo;
                                    CustToAnonymize."Customer No" := Customer."No.";
                                    CustToAnonymize."Customer Name" := Customer.Name;
                                    CustToAnonymize.Insert();
                                    VarEntryNo += 1;
                                end;
                            end;
                        until Customer.Next = 0;
                    Window.Close;
                    Message('Completed');
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
                ApplicationArea = All;
                ToolTip = 'Executes the Web Requests action';
            }
            action(JobQueueEntries)
            {
                ApplicationArea = All;
                Caption = 'Job Queue Entries';
                Image = JobLines;
                ToolTip = 'Executes the Job Queue Entries action';

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

        Reset();
        if (not Get) then begin
            Init;
            Insert();
        end;

    end;

    var
        GenBusPostingGrp: Record "Gen. Business Posting Group";
        CustPostingGrp: Record "Customer Posting Group";
        Text000: Label 'Existing Customers will be lost, do you want to continue?';
}

