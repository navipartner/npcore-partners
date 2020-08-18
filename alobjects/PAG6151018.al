page 6151018 "NpRv Sales Line Card"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.48/MHA /20190123  CASE 341711 Added Send Method fields
    // NPR5.55/MHA /20200512  CASE 402015 Updated object name
    // NPR5.55/MHA /20200701  CASE 397527 Added field 270 "Language Code"

    Caption = 'Issue Retail Voucher Card';
    DataCaptionExpression = Description;
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "NpRv Sales Line";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(Type;Type)
                {
                    Editable = false;
                }
                field("Voucher Type";"Voucher Type")
                {
                    Editable = false;
                }
                field(Description;Description)
                {
                }
                field("Voucher No.";"Voucher No.")
                {
                    Editable = false;
                }
                field("Reference No.";"Reference No.")
                {
                    Editable = false;
                }
                group(Control6014419)
                {
                    ShowCaption = false;
                    Visible = (Type = Type::"New Voucher") OR (Type = Type::"Top-Up") OR (Type = Type::"Partner Issue voucher");
                    field("Starting Date";"Starting Date")
                    {
                        Editable = (Type = Type::"New Voucher") OR (Type = Type::"Top-Up") OR (Type = Type::"Partner Issue voucher");
                    }
                }
            }
            group(Contact)
            {
                Caption = 'Contact';
                Visible = (Type = Type::"New Voucher") OR (Type = Type::"Top-Up") OR (Type = Type::"Partner Issue voucher");
                field("Customer No.";"Customer No.")
                {
                }
                field("Contact No.";"Contact No.")
                {

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Contact: Record Contact;
                    begin
                        if PAGE.RunModal(PAGE::"Touch Screen - CRM Contacts",Contact) <> ACTION::LookupOK then
                          exit;

                        Validate("Contact No.",Contact."No.");
                    end;
                }
                field(Name;Name)
                {
                }
                field("Name 2";"Name 2")
                {
                }
                field(Address;Address)
                {
                }
                field("Address 2";"Address 2")
                {
                }
                field("Post Code";"Post Code")
                {
                }
                field(City;City)
                {
                }
                field(County;County)
                {
                }
                field("Country/Region Code";"Country/Region Code")
                {
                }
                field("Send via Print";"Send via Print")
                {
                }
                field("Send via E-mail";"Send via E-mail")
                {
                }
                field("E-mail";"E-mail")
                {
                }
                field("Send via SMS";"Send via SMS")
                {
                }
                field("Phone No.";"Phone No.")
                {
                }
                field("Language Code";"Language Code")
                {
                    Importance = Additional;
                }
                field("Voucher Message";"Voucher Message")
                {
                    MultiLine = true;
                }
            }
            group(Document)
            {
                Caption = 'Document';
                group(Control6014429)
                {
                    Editable = false;
                    ShowCaption = false;
                    Visible = ("Document Source" = "Document Source"::POS);
                    field("Register No.";"Register No.")
                    {
                    }
                    field("Sales Ticket No.";"Sales Ticket No.")
                    {
                    }
                    field("Sale Type";"Sale Type")
                    {
                    }
                    field("Sale Date";"Sale Date")
                    {
                    }
                    field("Sale Line No.";"Sale Line No.")
                    {
                    }
                    field("Retail ID";"Retail ID")
                    {
                    }
                }
                group(Control6014435)
                {
                    Editable = false;
                    ShowCaption = false;
                    Visible = ("Document Source" = "Document Source"::"Sales Document") OR ("Document Source" = "Document Source"::"Payment Line");
                    field("Document Type";"Document Type")
                    {
                    }
                    field("Document No.";"Document No.")
                    {
                    }
                    field("Document Line No.";"Document Line No.")
                    {
                    }
                    field("External Document No.";"External Document No.")
                    {
                    }
                    field("Posting No.";"Posting No.")
                    {
                    }
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
                Image = BarCode;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

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

