page 6151017 "NPR NpRv Sales Lines"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.55/MHA /20200512  CASE 402015 Updated object name and caption

    Caption = 'Retail Voucher Sales Lines';
    CardPageID = "NPR NpRv Sales Line Card";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
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
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Voucher Type"; "Voucher Type")
                {
                    ApplicationArea = All;
                }
                field("Voucher No."; "Voucher No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Document Source"; "Document Source")
                {
                    ApplicationArea = All;
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Sale Date"; "Sale Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Sale Line No."; "Sale Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Document Line No."; "Document Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Posting No."; "Posting No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Retail ID"; "Retail ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Id; Id)
                {
                    ApplicationArea = All;
                    Visible = false;
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

                trigger OnAction()
                var
                    SalesLine: Record "Sales Line";
                    SaleLinePOS: Record "NPR Sale Line POS";
                    NpRvSalesLineReferences: Page "NPR NpRv Sales Line Ref.";
                    Qty: Decimal;
                begin
                    //-NPR5.55 [402015]
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
                    //+NPR5.55 [402015]
                end;
            }
        }
    }
}

