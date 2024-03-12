page 6151144 "NPR RS KEP Book Entries"
{
    ApplicationArea = NPRRSRLocal;
    Caption = 'KEP Book Entries';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR RS KEP Book";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(StartBalances)
            {
                Caption = 'Start Balances';
                Editable = false;

                field(StartBalanceAmount; StartBalanceAmount)
                {
                    ApplicationArea = NPRRSRLocal;
                    Caption = 'Start Balance Amount';
                    ToolTip = 'Specifies the value of the Start Balance Amount.';
                }
                group(Amounts)
                {
                    ShowCaption = false;
                    field(DebitAmount; StartDebitAmount)
                    {
                        ApplicationArea = NPRRSRLocal;
                        Caption = 'Debit Amount';
                        ToolTip = 'Specifies the value of the Debit Amount.';
                    }
                    field(CreditAmount; StartCreditAmount)
                    {
                        ApplicationArea = NPRRSRLocal;
                        Caption = 'Credit Amount';
                        ToolTip = 'Specifies the value of the Credit Amount.';
                    }
                }
            }
            repeater(General)
            {
                Editable = false;
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Location related to this KEP Book Entry.';
                }
                field(Year; Rec.Year)
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Year of creation related KEP Book Entry.';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Entry No. of the related KEP Book Entry.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Document Description of the related KEP Book Entry.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Posting Date of the related KEP Book Entry.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Document Type of the related KEP Book Entry.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Document Number of the related KEP Book Entry.';
                }
                field("Debit Amout"; Rec."Debit Amount")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Debit Amount of the related KEP Book Entry.';
                }
                field("Credit Amount"; Rec."Credit Amount")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Credit Amount of the related KEP Book Entry.';
                }
            }
            group(TotalBalances)
            {
                Caption = 'Total Balances';
                Editable = false;
                field(TotalDebit; TotalDebit)
                {
                    ApplicationArea = NPRRSRLocal;
                    Caption = 'Total Debit';
                    ToolTip = 'Specifies the Total Debit Amount of the related KEP Book Entries.';
                }
                field(TotalCredit; TotalCredit)
                {
                    ApplicationArea = NPRRSRLocal;
                    Caption = 'Total Credit';
                    ToolTip = 'Specifies the Total Credit Amount of the related KEP Book Entries.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("&Navigate")
            {
                ApplicationArea = NPRRSRLocal;
                Caption = 'Find entries...';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ShortCutKey = 'Ctrl+Alt+Q';
                ToolTip = 'Find entries and documents that exist for the document number and posting date on the selected document. (Formerly this action was named Navigate.)';

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    Navigate.SetDoc(Rec."Posting Date", Rec."Document No.");
                    Navigate.Run();
                end;
            }
            action("Print KEP Book")
            {
                ApplicationArea = NPRRSRLocal;
                Caption = 'Print KEP Book';
                Image = PrintCheck;
                Promoted = true;
                PromotedCategory = Report;
                ToolTip = 'Executes the Print KEP Book action.';
                trigger OnAction()
                var
                    RSKEPBook: Report "NPR RS KEP Book";
                begin
                    RSKEPBook.SetPOSStore(POSStore.Code);
                    RSKEPBook.RunModal();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        LocationCode: Code[10];
    begin
        if Page.RunModal(Page::"NPR POS Store List", POSStore) = Action::LookupOK then
            LocationCode := POSStore."Location Code"
        else
            Error(POSStoreSelectionMandatoryLbl);

        if LocationCode = '' then
            Error(LocationNotSetLbl);

        RSKEPBookMgt.CreateKEPBookDataset(Rec, LocationCode, Date2DMY(Today(), 3));
        RSKEPBookMgt.GetStartBalanceAmounts(StartDebitAmount, StartCreditAmount, LocationCode, Date2DMY(Today(), 3) - 1);
        StartBalanceAmount := StartDebitAmount - StartCreditAmount;

        Rec.CalcSums("Debit Amount", "Credit Amount");
        TotalDebit := Rec."Debit Amount";
        TotalCredit := Rec."Credit Amount";
    end;

    var
        POSStore: Record "NPR POS Store";
        RSKEPBookMgt: Codeunit "NPR RS KEP Book Mgt.";
        StartCreditAmount: Decimal;
        StartDebitAmount: Decimal;
        StartBalanceAmount: Decimal;
        TotalCredit: Decimal;
        TotalDebit: Decimal;
        LocationNotSetLbl: Label 'Location Code must be set for POS Store.';
        POSStoreSelectionMandatoryLbl: Label 'You must select POS Store in order to open page KEP Book Entries';
}