page 6151017 "NPR NpRv Sales Lines"
{
    Caption = 'Retail Voucher Sales Lines';
    CardPageID = "NPR NpRv Sales Line Card";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR NpRv Sales Line";
    SourceTableView = SORTING(Type, "Voucher Type", "Voucher No.", "Reference No.");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Reference No."; Rec."Reference No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference No. field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Voucher Type"; Rec."Voucher Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Voucher Type field';
                }
                field("Voucher No."; Rec."Voucher No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Voucher No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Document Source"; Rec."Document Source")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Source field';
                }
                field("Register No."; Rec."Register No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("Sales Ticket No."; Rec."Sales Ticket No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                }
                field("Sale Date"; Rec."Sale Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sale Date field';
                }
                field("Sale Line No."; Rec."Sale Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sale Line No. field';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Document Type field';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Document Line No. field';
                }
                field("Posting No."; Rec."Posting No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Posting No. field';
                }
                field("Retail ID"; Rec."Retail ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Retail ID field';
                }
                field(Id; Rec.Id)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Id field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the References action';

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

