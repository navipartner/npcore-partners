page 6184641 "NPR RS E-Invoice Selection"
{
    Caption = 'RS E-Invoice Selection';
    UsageCategory = None;
    PageType = List;
    SourceTable = "NPR RS E-Invoice Document";
    SourceTableTemporary = true;
    Extensible = false;
    Editable = true;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Documents)
            {
                field("Purchase Invoice ID"; Rec."Purchase Invoice ID")
                {
                    ToolTip = 'Specifies the value of the Invoice ID field.';
                    Editable = false;
                    ApplicationArea = NPRRSEInvoice;
                }
                field(Direction; Rec.Direction)
                {
                    ToolTip = 'Specifies the value of the Direction field.';
                    Editable = false;
                    ApplicationArea = NPRRSEInvoice;
                }
                field("Supplier No."; Rec."Supplier No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Supplier No. field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field("Supplier Name"; Rec."Supplier Name")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Supplier Name field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the value of the Document Type field.';
                    ApplicationArea = NPRRSEInvoice;
                    trigger OnValidate()
                    begin
                        CheckIfSelectedDocumentTypeIsValid();
                    end;
                }
                field("Creation Date"; Rec."Creation Date")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Creation Date field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field("Sending Date"; Rec."Sending Date")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Sending Date field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field("Invoice Document No."; Rec."Invoice Document No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Invoice Document No. field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field("Document Status"; FormatDocumentStatus)
                {
                    Caption = 'Status';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Status field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Customer Name field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field(Amount; Rec.Amount)
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Amount field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field(Prepayment; Rec.Prepayment)
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Prepayment field.';
                    ApplicationArea = NPRRSEInvoice;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        RSEInvoiceStatus: Enum "NPR RS E-Invoice Status";
    begin
        FormatDocumentStatus := RSEInvoiceStatus.Names().Get(RSEInvoiceStatus.Ordinals.IndexOf(Rec."Invoice Status".AsInteger()));
    end;

    local procedure CheckIfSelectedDocumentTypeIsValid()
    var
        DocumentTypeIncorrectErr: Label '%1 of documents must be %2, %3 or %4', Comment = '%1 = Document  Type Caption, %2 = Document  Type, %3 = Document  Type, %4 = Document  Type';
        DocumentTypeCannotBeChanged: Label '%1 Document Type cannot be changed.';
        CannotManuallySelectPurchCrMemoErr: Label 'You cannot manually choose Purchase Credit Memo Document Type';
    begin
        case true of
            (Rec."Document Type" in [Rec."Document Type"::"Sales Cr. Memo", Rec."Document Type"::"Sales Invoice"]):
                Error(DocumentTypeIncorrectErr, Rec.FieldCaption("Document Type"), Rec."Document Type"::"Purchase Order", Rec."Document Type"::"Purchase Invoice", Rec."Document Type"::"Purchase Cr. Memo");
            (xRec."Document Type" in [Rec."Document Type"::"Purchase Cr. Memo"]) and (not (Rec."Document Type" in [Rec."Document Type"::" "])):
                Error(DocumentTypeCannotBeChanged, Rec."Document Type"::"Purchase Cr. Memo");
            (xRec."Document Type" in [Rec."Document Type"::"Purchase Invoice"]) and (not (Rec."Document Type" in [Rec."Document Type"::" "])):
                Error(DocumentTypeCannotBeChanged, Rec."Document Type"::"Purchase Invoice");
            (Rec."Document Type" in [Rec."Document Type"::"Purchase Cr. Memo"]):
                Error(CannotManuallySelectPurchCrMemoErr);
        end;
    end;

    var
        FormatDocumentStatus: Text;
}