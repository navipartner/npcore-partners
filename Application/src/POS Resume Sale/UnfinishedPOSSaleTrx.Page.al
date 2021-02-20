page 6150747 "NPR Unfinished POS Sale Trx"
{
    Caption = 'Unfinished POS Sale Transactions';
    DataCaptionExpression = '';
    Editable = false;
    PageType = ListPlus;
    UsageCategory = Administration;
    ApplicationArea = All;
    PromotedActionCategories = 'New,Process,Report,Filter';
    SourceTable = "NPR Sale POS";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Register No."; Rec."Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Register No. field';
                }
                field("Sales Ticket No."; Rec."Sales Ticket No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field("Date"; Rec.Date)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date field';
                }
                field("Start Time"; Rec."Start Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Start Time field';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Name field';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Including VAT field';
                }
                field("Payment Amount"; Rec."Payment Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Amount field';
                }
                field("POS Sale ID"; Rec."POS Sale ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Sale ID field';
                }
                field("Retail ID"; Rec."Retail ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Retail ID field';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("Host Name"; Rec."Host Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Host Name field';
                }
                field("Device ID"; Rec."Device ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Device ID field';
                }
            }
            part(SaleLines; "NPR POS Sale Lines Subpage")
            {
                Caption = 'POS Sale Lines';
                SubPageLink = "Register No." = FIELD("Register No."),
                              "Sales Ticket No." = FIELD("Sales Ticket No.");
                ApplicationArea = All;
            }
        }
        area(factboxes)
        {
            systempart(Control6014414; Notes)
            {
                Visible = false;
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("Actions")
            {
                Caption = 'Actions';
                action(ParkSale)
                {
                    Caption = 'Park Sale';
                    Image = TransferToGeneralJournal;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Park Sale action';

                    trigger OnAction()
                    begin
                        Error('Not Supported');
                        POSResumeSale.DoSaveAsPOSQuote(POSSession, Rec, false, false);
                        CurrPage.Update(false);
                    end;
                }
                action(CancelSale)
                {
                    Caption = 'Cancel Sale';
                    Image = CancelAllLines;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Cancel Sale action';

                    trigger OnAction()
                    begin
                        Error('Not Supported');
                        POSResumeSale.DoCancelSale(Rec, POSSession);
                        CurrPage.Update(false);
                    end;
                }
            }
            group(Show)
            {
                Caption = 'Show';
                action(ShowAllForCashRegister)
                {
                    Caption = 'All For Register';
                    Image = GetLines;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ToolTip = 'Show all unfinished sale transactions for current cash register';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        SalePOS: Record "NPR Sale POS";
                    begin
                        SalePOS.Copy(Rec);
                        Rec.Reset;
                        SalePOS.CopyFilter("Register No.", "Register No.");
                        Rec.Ascending(false);
                        if Rec.FindFirst then;
                    end;
                }
            }
        }
    }

    var
        POSSession: Codeunit "NPR POS Session";
        POSResumeSale: Codeunit "NPR POS Resume Sale Mgt.";

    procedure SetParameters(POSSessionIn: Codeunit "NPR POS Session")
    begin
        POSSession := POSSessionIn;
    end;
}

