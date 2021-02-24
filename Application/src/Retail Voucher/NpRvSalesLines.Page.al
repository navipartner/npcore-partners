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
                field("Reference No."; "Reference No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference No. field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Voucher Type"; "Voucher Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Voucher Type field';
                }
                field("Voucher No."; "Voucher No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Voucher No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Document Source"; "Document Source")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Source field';
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                }
                field("Sale Date"; "Sale Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sale Date field';
                }
                field("Sale Line No."; "Sale Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sale Line No. field';
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Document Type field';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("Document Line No."; "Document Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Document Line No. field';
                }
                field("Posting No."; "Posting No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Posting No. field';
                }
                field("Retail ID"; "Retail ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Retail ID field';
                }
                field(Id; Id)
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
                    SaleLinePOS: Record "NPR Sale Line POS";
                    NpRvSalesLineReferences: Page "NPR NpRv Sales Line Ref.";
                    Qty: Decimal;
                begin
                    Qty := 1;
                    case "Document Source" of
                        "Document Source"::POS:
                            begin
                                SaleLinePOS.SetRange("Retail ID", "Retail ID");
                                if SaleLinePOS.FindFirst then
                                    Qty := SaleLinePOS.Quantity;
                            end;
                        "Document Source"::"Sales Document":
                            begin
                                if SalesLine.Get("Document Type", "Document No.", "Document Line No.") then
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

