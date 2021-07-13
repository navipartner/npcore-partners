page 6151017 "NPR NpRv Sales Lines"
{
    Caption = 'Retail Voucher Sales Lines';
    CardPageID = "NPR NpRv Sales Line Card";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR NpRv Sales Line";
    SourceTableView = SORTING(Type, "Voucher Type", "Voucher No.", "Reference No.");
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Reference No."; Rec."Reference No.")
                {

                    ToolTip = 'Specifies the value of the Reference No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Voucher Type"; Rec."Voucher Type")
                {

                    ToolTip = 'Specifies the value of the Voucher Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Voucher No."; Rec."Voucher No.")
                {

                    ToolTip = 'Specifies the value of the Voucher No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Document Source"; Rec."Document Source")
                {

                    ToolTip = 'Specifies the value of the Document Source field';
                    ApplicationArea = NPRRetail;
                }
                field("Register No."; Rec."Register No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Ticket No."; Rec."Sales Ticket No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Sale Date"; Rec."Sale Date")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Sale Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Sale Line No."; Rec."Sale Line No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Sale Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Document Type"; Rec."Document Type")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Document Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Document Line No."; Rec."Document Line No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Document Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Posting No."; Rec."Posting No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Posting No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Retail ID"; Rec."Retail ID")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Retail ID field';
                    ApplicationArea = NPRRetail;
                }
                field(Id; Rec.Id)
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Id field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(References)
            {
                Caption = 'References';
                Image = List;

                ToolTip = 'Executes the References action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    SalesLine: Record "Sales Line";
                    SaleLinePOS: Record "NPR POS Sale Line";
                    NpRvSalesLineReferences: Page "NPR NpRv Sales Line Ref.";
                    Qty: Decimal;
                begin
                    Qty := 1;
                    case Rec."Document Source" of
                        Rec."Document Source"::POS:
                            begin
                                if SaleLinePOS.GetBySystemId(Rec."Retail ID") then
                                    Qty := SaleLinePOS.Quantity;
                            end;
                        Rec."Document Source"::"Sales Document":
                            begin
                                if SalesLine.Get(Rec."Document Type", Rec."Document No.", Rec."Document Line No.") then
                                    Qty := SalesLine.Quantity;
                            end;
                    end;

                    NpRvSalesLineReferences.SetNpRvSalesLine(Rec, Qty);
                    NpRvSalesLineReferences.Run();
                end;
            }
        }
    }
}

