page 6150747 "Unfinished POS Sale Transact."
{
    // NPR5.54/ALPO/20200203 CASE 364658 Resume POS Sale

    Caption = 'Unfinished POS Sale Transactions';
    DataCaptionExpression = '';
    Editable = false;
    PageType = ListPlus;
    PromotedActionCategories = 'New,Process,Report,Filter';
    SourceTable = "Sale POS";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Register No.";"Register No.")
                {
                }
                field("Sales Ticket No.";"Sales Ticket No.")
                {
                }
                field("Salesperson Code";"Salesperson Code")
                {
                }
                field(Date;Date)
                {
                }
                field("Start Time";"Start Time")
                {
                }
                field("Customer No.";"Customer No.")
                {
                }
                field(Name;Name)
                {
                    Visible = false;
                }
                field("Customer Name";"Customer Name")
                {
                }
                field("Location Code";"Location Code")
                {
                }
                field(Amount;Amount)
                {
                }
                field("Amount Including VAT";"Amount Including VAT")
                {
                }
                field("Payment Amount";"Payment Amount")
                {
                }
                field("POS Sale ID";"POS Sale ID")
                {
                }
                field("Retail ID";"Retail ID")
                {
                    Visible = false;
                }
                field("User ID";"User ID")
                {
                }
                field("Host Name";"Host Name")
                {
                }
                field("Device ID";"Device ID")
                {
                }
            }
            part(SaleLines;"POS Sale Lines Subpage")
            {
                Caption = 'POS Sale Lines';
                SubPageLink = "Register No."=FIELD("Register No."),
                              "Sales Ticket No."=FIELD("Sales Ticket No.");
            }
        }
        area(factboxes)
        {
            systempart(Control6014414;Notes)
            {
                Visible = false;
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

                    trigger OnAction()
                    begin
                        Error('Not Supported');
                        POSResumeSale.DoSaveAsPOSQuote(Rec,false);
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

                    trigger OnAction()
                    begin
                        Error('Not Supported');
                        POSResumeSale.DoCancelSale(Rec,POSSession);
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

                    trigger OnAction()
                    var
                        SalePOS: Record "Sale POS";
                    begin
                        SalePOS.Copy(Rec);
                        Reset;
                        SalePOS.CopyFilter("Register No.","Register No.");
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
        POSSession: Codeunit "POS Session";
        POSResumeSale: Codeunit "POS Resume Sale Mgt.";
        AllowToPostpone: Boolean;

    procedure SetParameters(POSSessionIn: Codeunit "POS Session")
    begin
        POSSession := POSSessionIn;
    end;
}

