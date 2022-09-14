page 6184480 "NPR EFT POSUnit Param. Setup"
{
    Extensible = False;
    UsageCategory = None;
    Caption = 'EFT POS Unit Parameter Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ShowFilter = false;
    SourceTable = "NPR EFT Setup";

    layout
    {
        area(content)
        {
            part(GenericParams; "NPR EFTType POSUnit Gen.Param.")
            {
                Caption = 'Generic Parameters';
                ShowFilter = false;
                SubPageLink = "Integration Type" = FIELD("EFT Integration Type"),
                              "POS Unit No." = FIELD("POS Unit No.");
                Visible = ShowPOSUnitGenParameter;
                ApplicationArea = NPRRetail;

            }
            part(BinaryParams; "NPR EFTType POSUnit BLOB Param")
            {
                Caption = 'Binary Parameters';
                ShowFilter = false;
                SubPageLink = "Integration Type" = FIELD("EFT Integration Type"),
                              "POS Unit No." = FIELD("POS Unit No.");
                Visible = ShowPOSUnitBLOBParameter;
                ApplicationArea = NPRRetail;

            }
        }
    }

    trigger OnOpenPage()
    var
        EFTTypePOSUnitGenParam: Record "NPR EFTType POSUnit Gen.Param.";
        EFTTypePOSUnitBlobParam: Record "NPR EFTType POSUnit BLOBParam.";
    begin
        EFTTypePOSUnitGenParam.SetRange("Integration Type", Rec."EFT Integration Type");
        EFTTypePOSUnitGenParam.SetRange("POS Unit No.", Rec."POS Unit No.");
        ShowPOSUnitGenParameter := not EFTTypePOSUnitGenParam.IsEmpty();

        EFTTypePOSUnitBlobParam.SetRange("Integration Type", Rec."EFT Integration Type");
        EFTTypePOSUnitBlobParam.SetRange("POS Unit No.", Rec."POS Unit No.");
        ShowPOSUnitBLOBParameter := not EFTTypePOSUnitBlobParam.IsEmpty();
    end;

    var
        ShowPOSUnitGenParameter: Boolean;
        ShowPOSUnitBLOBParameter: Boolean;
}
