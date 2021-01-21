page 6150747 "NPR Unfinished POS Sale Trx"
{
    // NPR5.54/ALPO/20200203 CASE 364658 Resume POS Sale
    // NPR5.55/ALPO/20200812 CASE 391678 Log sale canceling to POS Entry

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
            repeater(Group)
            {
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Register No. field';
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field("Date"; Date)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date field';
                }
                field("Start Time"; "Start Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Start Time field';
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Customer Name"; "Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Name field';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Including VAT field';
                }
                field("Payment Amount"; "Payment Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Amount field';
                }
                field("POS Sale ID"; "POS Sale ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Sale ID field';
                }
                field("Retail ID"; "Retail ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Retail ID field';
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("Host Name"; "Host Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Host Name field';
                }
                field("Device ID"; "Device ID")
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

