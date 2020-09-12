page 6150747 "NPR Unfinished POS Sale Trx"
{
    // NPR5.54/ALPO/20200203 CASE 364658 Resume POS Sale
    // NPR5.55/ALPO/20200812 CASE 391678 Log sale canceling to POS Entry

    Caption = 'Unfinished POS Sale Transactions';
    DataCaptionExpression = '';
    Editable = false;
    PageType = ListPlus;
    PromotedActionCategories = 'New,Process,Report,Filter';
    SourceTable = "NPR Sale POS";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                }
                field("Date"; Date)
                {
                    ApplicationArea = All;
                }
                field("Start Time"; "Start Time")
                {
                    ApplicationArea = All;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Customer Name"; "Customer Name")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                    ApplicationArea = All;
                }
                field("Payment Amount"; "Payment Amount")
                {
                    ApplicationArea = All;
                }
                field("POS Sale ID"; "POS Sale ID")
                {
                    ApplicationArea = All;
                }
                field("Retail ID"; "Retail ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
                field("Host Name"; "Host Name")
                {
                    ApplicationArea = All;
                }
                field("Device ID"; "Device ID")
                {
                    ApplicationArea = All;
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
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = false;
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        Error('Not Supported');
                        //POSResumeSale.DoSaveAsPOSQuote(Rec,FALSE);  //NPR5.55 [391678]-revoked
                        POSResumeSale.DoSaveAsPOSQuote(POSSession, Rec, false, false);  //NPR5.55 [391678]
                        CurrPage.Update(false);
                    end;
                }
                action(CancelSale)
                {
                    Caption = 'Cancel Sale';
                    Image = CancelAllLines;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = false;
                    ApplicationArea = All;

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
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ToolTip = 'Show all unfinished sale transactions for current cash register';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        SalePOS: Record "NPR Sale POS";
                    begin
                        SalePOS.Copy(Rec);
                        Reset;
                        SalePOS.CopyFilter("Register No.", "Register No.");
                        Ascending(false);
                        if FindFirst then;
                    end;
                }
            }
        }
    }

    var
        LeaveAsIsAndNewText: Label 'The following unfinished sale transactions exist in the database. Selecting ''Cancel'' will start a new sale leaving unfinished sale transactions untouched.';
        CancelAndNewText: Label 'The following unfinished sale transactions exist in the database. Note: Your settings do not allow you to postpone unfinished sale transaction resume process. You will have to walk though the list before starting a new sale.';
        HitCancelToStartNewText: Label 'Hit ''Cancel'' to start a new sale';
        POSSession: Codeunit "NPR POS Session";
        POSResumeSale: Codeunit "NPR POS Resume Sale Mgt.";
        AllowToPostpone: Boolean;

    procedure SetParameters(POSSessionIn: Codeunit "NPR POS Session")
    begin
        POSSession := POSSessionIn;
    end;
}

