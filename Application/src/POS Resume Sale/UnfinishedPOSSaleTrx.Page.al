page 6150747 "NPR Unfinished POS Sale Trx"
{
    Caption = 'Unfinished POS Sale Transactions';
    DataCaptionExpression = '';
    Editable = false;
    PageType = ListPlus;
    UsageCategory = Administration;

    PromotedActionCategories = 'New,Process,Report,Filter';
    SourceTable = "NPR POS Sale";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Register No."; Rec."Register No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Ticket No."; Rec."Sales Ticket No.")
                {

                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {

                    ToolTip = 'Specifies the value of the Salesperson Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Date"; Rec.Date)
                {

                    ToolTip = 'Specifies the value of the Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Start Time"; Rec."Start Time")
                {

                    ToolTip = 'Specifies the value of the Start Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer No."; Rec."Customer No.")
                {

                    ToolTip = 'Specifies the value of the Customer No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Name"; Rec."Customer Name")
                {

                    ToolTip = 'Specifies the value of the Customer Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Location Code"; Rec."Location Code")
                {

                    ToolTip = 'Specifies the value of the Location Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Amount; Rec.Amount)
                {

                    ToolTip = 'Specifies the value of the Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {

                    ToolTip = 'Specifies the value of the Amount Including VAT field';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Amount"; Rec."Payment Amount")
                {

                    ToolTip = 'Specifies the value of the Payment Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("User ID"; Rec."User ID")
                {

                    ToolTip = 'Specifies the value of the User ID field';
                    ApplicationArea = NPRRetail;
                }
            }
            part(SaleLines; "NPR POS Sale Lines Subpage")
            {
                Caption = 'POS Sale Lines';
                SubPageLink = "Register No." = FIELD("Register No."),
                              "Sales Ticket No." = FIELD("Sales Ticket No.");
                ApplicationArea = NPRRetail;

            }
        }
        area(factboxes)
        {
            systempart(Control6014414; Notes)
            {
                Visible = false;
                ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Park Sale action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Error('Not Supported');
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

                    ToolTip = 'Executes the Cancel Sale action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Error('Not Supported');
                    end;
                }
            }
            group(Show)
            {
                Caption = 'Show';
                action(ShowAllForUnit)
                {
                    Caption = 'All For POS Unit';
                    Image = GetLines;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ToolTip = 'Show all unfinished sale transactions for current POS unit';
                    ApplicationArea = NPRRetail;


                    trigger OnAction()
                    var
                        SalePOS: Record "NPR POS Sale";
                    begin
                        SalePOS.Copy(Rec);
                        Rec.Reset();
                        SalePOS.CopyFilter("Register No.", Rec."Register No.");
                        Rec.Ascending(false);
                        if Rec.FindFirst() then;
                    end;
                }
            }
        }
    }

    var
        POSSession: Codeunit "NPR POS Session";

    procedure SetParameters(POSSessionIn: Codeunit "NPR POS Session")
    begin
        POSSession := POSSessionIn;
    end;
}

