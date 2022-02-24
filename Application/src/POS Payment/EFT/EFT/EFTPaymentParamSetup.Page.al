page 6184475 "NPR EFT Payment Param. Setup"
{
    Extensible = False;
    // NPR5.46/MMV /20181008 CASE 290734 Created object

    UsageCategory = None;
    Caption = 'EFT Payment Parameter Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ShowFilter = false;
    SourceTable = "NPR EFT Setup";

    layout
    {
        area(content)
        {
            part(GenericParams; "NPR EFT Type Pay. Gen. Param.")
            {
                Caption = 'Generic Parameters';
                SubPageLink = "Integration Type" = FIELD("EFT Integration Type"),
                              "Payment Type POS" = FIELD("Payment Type POS");
                Visible = ShowPaymentGenParameter;
                ApplicationArea = NPRRetail;

            }
            part(BinaryParams; "NPR EFT Type Paym. BLOB Param.")
            {
                Caption = 'Binary Parameters';
                SubPageLink = "Integration Type" = FIELD("EFT Integration Type"),
                              "Payment Type POS" = FIELD("Payment Type POS");
                Visible = ShowPaymentBLOBParameter;
                ApplicationArea = NPRRetail;

            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        EFTTypePaymentGenParam: Record "NPR EFT Type Pay. Gen. Param.";
        EFTTypePaymentBlobParam: Record "NPR EFTType Paym. BLOB Param.";
    begin
        EFTTypePaymentGenParam.SetRange("Integration Type", Rec."EFT Integration Type");
        EFTTypePaymentGenParam.SetRange("Payment Type POS", Rec."Payment Type POS");
        ShowPaymentGenParameter := not EFTTypePaymentGenParam.IsEmpty();

        EFTTypePaymentBlobParam.SetRange("Integration Type", Rec."EFT Integration Type");
        EFTTypePaymentBlobParam.SetRange("Payment Type POS", Rec."Payment Type POS");
        ShowPaymentBLOBParameter := not EFTTypePaymentBlobParam.IsEmpty();
    end;

    var
        ShowPaymentGenParameter: Boolean;
        ShowPaymentBLOBParameter: Boolean;
}

