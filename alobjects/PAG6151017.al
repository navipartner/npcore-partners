page 6151017 "NpRv Sales Lines"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.55/MHA /20200512  CASE 402015 Updated object name and caption

    Caption = 'Retail Voucher Sales Lines';
    CardPageID = "NpRv Sales Line Card";
    Editable = false;
    PageType = List;
    SourceTable = "NpRv Sales Line";
    SourceTableView = SORTING(Type,"Voucher Type","Voucher No.","Reference No.");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Reference No.";"Reference No.")
                {
                }
                field(Type;Type)
                {
                }
                field("Voucher Type";"Voucher Type")
                {
                }
                field("Voucher No.";"Voucher No.")
                {
                }
                field(Description;Description)
                {
                }
                field("Document Source";"Document Source")
                {
                }
                field("Register No.";"Register No.")
                {
                    Visible = false;
                }
                field("Sales Ticket No.";"Sales Ticket No.")
                {
                    Visible = false;
                }
                field("Sale Date";"Sale Date")
                {
                    Visible = false;
                }
                field("Sale Line No.";"Sale Line No.")
                {
                    Visible = false;
                }
                field("Document Type";"Document Type")
                {
                    Visible = false;
                }
                field("Document No.";"Document No.")
                {
                    Visible = false;
                }
                field("Document Line No.";"Document Line No.")
                {
                    Visible = false;
                }
                field("Posting No.";"Posting No.")
                {
                    Visible = false;
                }
                field("Retail ID";"Retail ID")
                {
                    Visible = false;
                }
                field(Id;Id)
                {
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

                trigger OnAction()
                var
                    SalesLine: Record "Sales Line";
                    SaleLinePOS: Record "Sale Line POS";
                    NpRvSalesLineReferences: Page "NpRv Sales Line References";
                    Qty: Decimal;
                begin
                    //-NPR5.55 [402015]
                    Qty := 1;
                    case "Document Source" of
                      "Document Source"::POS:
                        begin
                          SaleLinePOS.SetRange("Retail ID","Retail ID");
                          if SaleLinePOS.FindFirst then
                            Qty := SaleLinePOS.Quantity;
                        end;
                      "Document Source"::"Sales Document":
                        begin
                          if SalesLine.Get("Document Type","Document No.","Document Line No.") then
                            Qty := SalesLine.Quantity;
                        end;
                    end;

                    NpRvSalesLineReferences.SetNpRvSalesLine(Rec,Qty);
                    NpRvSalesLineReferences.Run();
                    //+NPR5.55 [402015]
                end;
            }
        }
    }
}

