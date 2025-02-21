page 6059982 "NPR POS Entry Sales & Payments"
{
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR POS Entry Sale & Payment";
    SourceTableView = sorting("POS Entry No.") order(descending);
    SourceTableTemporary = true;
    Caption = 'POS Entry Sales and Payments';
    ContextSensitiveHelpPage = 'docs/retail/posting_setup/explanation/accounting_entries/';
    Extensible = False;
    Editable = false;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-02-23';
    ObsoleteReason = 'Stability and optimization reasons.';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Type field.';
                }
                field("Entry Date"; Rec."Entry Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Entry Date field.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Document No. field.';
                }
                field("Starting Time"; Rec."Starting Time")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Starting Time field.';
                }
                field("Ending Time"; Rec."Ending Time")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Ending Time field.';
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the POS Store Code field.';
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the POS Unit No. field.';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Salesperson Code field.';
                }
                field(Type; Rec."Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Type field.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the No. field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description 2 field.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Variant Code field.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Customer No. field.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Quantity field.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Unit of Measure Code field.';
                }
                field("Amount Incl. VAT"; Rec."Amount Incl. VAT")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Amount Incl. VAT field.';
                }
                field("Line Discount %"; Rec."Line Discount %")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Line Discount % field.';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Unit Price field.';
                }
                field("Line Discount Amount Incl. VAT"; Rec."Line Discount Amount Incl. VAT")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Line Discount Amount field.';
                }
                field("VAT %"; Rec."VAT %")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the VAT % field.';
                }
                field("Post Item Entry Status"; Rec."Post Item Entry Status")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Post Item Entry Status field.';
                }
                field("Post Entry Status"; Rec."Post Entry Status")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Post Entry Status field.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group(Print)
            {
                Caption = 'Print';
                Image = Print;
                action("Print Entry")
                {
                    Caption = 'Print Entry';
                    Image = PrintCheck;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    ToolTip = 'Executes the Print Entry action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        POSEntry: Record "NPR POS Entry";
                        POSEntryManagement: Codeunit "NPR POS Entry Management";
                    begin
                        if POSEntry.Get(Rec."POS Entry No.") then
                            POSEntryManagement.PrintEntry(POSEntry, false);
                    end;
                }
                action("Print Entry Large")
                {
                    Caption = 'Print Entry Large';
                    Image = PrintCover;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    ToolTip = 'Executes the Print Entry Large action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        POSEntry: Record "NPR POS Entry";
                        POSEntryManagement: Codeunit "NPR POS Entry Management";
                    begin
                        if POSEntry.Get(Rec."POS Entry No.") then
                            POSEntryManagement.PrintEntry(POSEntry, true);
                    end;
                }
            }
        }
        area(Navigation)
        {
            action("EFT Transaction Requests")
            {
                Caption = 'EFT Transaction Requests';
                Image = CreditCardLog;
                RunObject = Page "NPR EFT Transaction Requests";
                RunPageLink = "Sales Ticket No." = FIELD("Document No.");
                ToolTip = 'Displays the EFT transactions requests.';
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
            }
        }
    }

    trigger OnOpenPage()
    var
        EntryNo: Text;
        LineNo: Integer;
    begin
        Rec.FilterGroup(4);
        EntryNo := Rec.GetFilter("POS Entry No.");
        Rec.FilterGroup(0);
        LineNo := 1;

        AddSalesLines(EntryNo, LineNo);
        AddPaymentLines(EntryNo, LineNo);
    end;

    local procedure AddSalesLines(EntryNo: Text; var LineNo: Integer)
    var
        POSEntrySalesLine: Query "NPR POS Entry Sales Line";
    begin
        if EntryNo <> '' then
            POSEntrySalesLine.SetFilter(POS_Entry_No_, EntryNo);
        if POSEntrySalesLine.Open() then begin
            while POSEntrySalesLine.Read() do begin
                Rec.Init();
                Rec."POS Entry No." := POSEntrySalesLine.POS_Entry_No_;
                Rec."Source Type" := Rec."Source Type"::Sale;
                Rec."Line No." := LineNo;
                LineNo += 1;

                Rec."Document No." := POSEntrySalesLine.Document_No_;
                Rec."POS Store Code" := POSEntrySalesLine.POS_Store_Code;
                Rec."POS Unit No." := POSEntrySalesLine.POS_Unit_No_;
                Rec."Salesperson Code" := POSEntrySalesLine.Salesperson_Code;
                Rec.Type := POSEntrySalesLine.Type;
                Rec."No." := POSEntrySalesLine.No_;
                Rec.Description := POSEntrySalesLine.Description;
                Rec."Description 2" := POSEntrySalesLine.Description_2;
                Rec."Customer No." := POSEntrySalesLine.Customer_No_;
                Rec.Quantity := POSEntrySalesLine.Quantity;
                Rec."Unit of Measure Code" := POSEntrySalesLine.Unit_of_Measure_Code;
                Rec."Unit Price" := POSEntrySalesLine.Unit_Price;
                Rec."Line Discount %" := POSEntrySalesLine.Line_Discount__;
                Rec."Amount Incl. VAT" := POSEntrySalesLine.Amount_Incl__VAT;
                Rec."Line Discount Amount Incl. VAT" := POSEntrySalesLine.Line_DIsc_Amount_Incl_Amount;
                Rec."VAT %" := POSEntrySalesLine.Vat_Pct;
                Rec."Variant Code" := POSEntrySalesLine.Variant_Code;
                Rec."Post Item Entry Status" := POSEntrySalesLine.Item_Entry_Post_Status + 1;
                Rec."Post Entry Status" := POSEntrySalesLine.Entry_Post_Status;
                Rec.Insert();
            end;
        end;
    end;

    local procedure AddPaymentLines(EntryNo: Text; var LineNo: Integer)
    var
        POSEntryPaymentLine: Query "NPR POS Entry Payment Line";
    begin
        if EntryNo <> '' then
            POSEntryPaymentLine.SetFilter(POS_Entry_No_, EntryNo);
        if POSEntryPaymentLine.Open() then begin
            while POSEntryPaymentLine.Read() do begin
                Rec.Init();
                Rec."POS Entry No." := POSEntryPaymentLine.POS_Entry_No_;
                Rec."Source Type" := Rec."Source Type"::Payment;
                Rec."Line No." := LineNo;
                LineNo += 1;

                Rec."Document No." := POSEntryPaymentLine.Document_No_;
                Rec."POS Store Code" := POSEntryPaymentLine.POS_Store_Code;
                Rec."POS Unit No." := POSEntryPaymentLine.POS_Unit_No_;
                Rec."Salesperson Code" := POSEntryPaymentLine.Salesperson_Code;
                Rec.Type := Rec.Type::" ";
                Rec."No." := POSEntryPaymentLine.POS_Payment_Method_Code;
                Rec.Description := POSEntryPaymentLine.Description;
                Rec."Description 2" := '';
                Rec."Customer No." := '';
                Rec.Quantity := 0;
                Rec."Unit of Measure Code" := '';
                Rec."Unit Price" := POSEntryPaymentLine.Amount;
                Rec."Line Discount %" := 0;
                Rec."Amount Incl. VAT" := POSEntryPaymentLine.Amount__Sales_Currency_;
                Rec."Post Entry Status" := POSEntryPaymentLine.Entry_Post_Status;

                Rec.Insert();
            end;
        end;
    end;
}