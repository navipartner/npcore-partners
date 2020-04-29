page 6184475 "EFT Payment Parameter Setup"
{
    // NPR5.46/MMV /20181008 CASE 290734 Created object

    Caption = 'EFT Payment Parameter Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ShowFilter = false;
    SourceTable = "EFT Setup";

    layout
    {
        area(content)
        {
            part(GenericParams;"EFT Type Payment Gen. Param.")
            {
                Caption = 'Generic Parameters';
                SubPageLink = "Integration Type"=FIELD("EFT Integration Type"),
                              "Payment Type POS"=FIELD("Payment Type POS");
                Visible = ShowPaymentGenParameter;
            }
            part(BinaryParams;"EFT Type Payment BLOB Param.")
            {
                Caption = 'Binary Parameters';
                SubPageLink = "Integration Type"=FIELD("EFT Integration Type"),
                              "Payment Type POS"=FIELD("Payment Type POS");
                Visible = ShowPaymentBLOBParameter;
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        EFTTypePaymentGenParam: Record "EFT Type Payment Gen. Param.";
        EFTTypePaymentBlobParam: Record "EFT Type Payment BLOB Param.";
    begin
        EFTTypePaymentGenParam.SetRange("Integration Type", "EFT Integration Type");
        EFTTypePaymentGenParam.SetRange("Payment Type POS", "Payment Type POS");
        ShowPaymentGenParameter := not EFTTypePaymentGenParam.IsEmpty;

        EFTTypePaymentBlobParam.SetRange("Integration Type", "EFT Integration Type");
        EFTTypePaymentBlobParam.SetRange("Payment Type POS", "Payment Type POS");
        ShowPaymentBLOBParameter := not EFTTypePaymentBlobParam.IsEmpty;
    end;

    var
        ShowPaymentGenParameter: Boolean;
        ShowPaymentBLOBParameter: Boolean;
}

