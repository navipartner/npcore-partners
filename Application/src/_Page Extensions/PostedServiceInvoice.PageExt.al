pageextension 6014432 "NPR Posted Service Invoice" extends "Posted Service Invoice"
{
    actions
    {
        addlast(processing)
        {
            action("NPR NPRUpdateFromCustomer")
            {
                Caption = 'Update OIOUBL fields from Customer';
                ToolTip = 'Transfer OIOUBL fields from Customer to Document';
                ApplicationArea = NPRRetail;
                Image = DocumentEdit;
                Ellipsis = true;
                Visible = OIOUBLInstalled;

                trigger OnAction()
                var
                    UpdateDocument: Codeunit "NPR OIOUBL Update Document";
                begin
                    UpdateDocument.ServiceInvoiceSetOIOUBLFieldsFromCustomer(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        OIOUBLInstalled: Boolean;

    trigger OnOpenPage()
    var
        OIOUBLSetup: Record "NPR OIOUBL Setup";
    begin
        OIOUBLInstalled := OIOUBLSetup.IsOIOUBLInstalled();
    end;
}
