page 6184480 "NPR EFT POSUnit Param. Setup"
{
    // NPR5.46/MMV /20181008 CASE 290734 Created object
    // NPR5.48/BHR /20181206 CASE 338656 Added Missing Picture to Action

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
                ApplicationArea=All;
            }
            part(BinaryParams; "NPR EFTType POSUnit BLOB Param")
            {
                Caption = 'Binary Parameters';
                ShowFilter = false;
                SubPageLink = "Integration Type" = FIELD("EFT Integration Type"),
                              "POS Unit No." = FIELD("POS Unit No.");
                Visible = ShowPOSUnitBLOBParameter;
                ApplicationArea=All;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(MobilePay)
            {
                Caption = 'MobilePay';
                Visible = IsMobilePay;
                action("Register PoS")
                {
                    Caption = 'Register PoS';
                    Image = Add;
                    ApplicationArea=All;

                    trigger OnAction()
                    var
                        EFTMobilePayIntegration: Codeunit "NPR EFT MobilePay Integ.";
                    begin
                        EFTMobilePayIntegration.RegisterPoS(Rec);
                    end;
                }
                action("Update PoS Description")
                {
                    Caption = 'Update PoS Description';
                    Image = UpdateDescription;
                    ApplicationArea=All;

                    trigger OnAction()
                    var
                        EFTMobilePayIntegration: Codeunit "NPR EFT MobilePay Integ.";
                    begin
                        EFTMobilePayIntegration.UpdateRegisteredPoSName(Rec);
                    end;
                }
                action("Unregister PoS")
                {
                    Caption = 'Unregister PoS';
                    Image = UnApply;
                    ApplicationArea=All;

                    trigger OnAction()
                    var
                        EFTMobilePayIntegration: Codeunit "NPR EFT MobilePay Integ.";
                    begin
                        EFTMobilePayIntegration.UnRegisterPoS(Rec);
                    end;
                }
                action("Assign PoS Unit")
                {
                    Caption = 'Assign PoS Unit';
                    Image = AddAction;
                    ApplicationArea=All;

                    trigger OnAction()
                    var
                        EFTMobilePayIntegration: Codeunit "NPR EFT MobilePay Integ.";
                    begin
                        EFTMobilePayIntegration.AssignPoSUnitIdToPoS(Rec);
                    end;
                }
                action("Unassign PoS Unit")
                {
                    Caption = 'Unassign PoS Unit';
                    Image = Cancel;
                    ApplicationArea=All;

                    trigger OnAction()
                    var
                        EFTMobilePayIntegration: Codeunit "NPR EFT MobilePay Integ.";
                    begin
                        EFTMobilePayIntegration.UnAssignPoSUnitIdToPoS(Rec);
                    end;
                }
                action("Scan PoS Unit")
                {
                    Caption = 'Scan PoS Unit';
                    Image = MiniForm;
                    ApplicationArea=All;

                    trigger OnAction()
                    var
                        EFTMobilePayIntegration: Codeunit "NPR EFT MobilePay Integ.";
                    begin
                        EFTMobilePayIntegration.ReadPoSUnitAssignedPoSId(Rec);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        EFTTypePOSUnitGenParam: Record "NPR EFTType POSUnit Gen.Param.";
        EFTTypePOSUnitBlobParam: Record "NPR EFTType POSUnit BLOBParam.";
        EFTMobilePayIntegration: Codeunit "NPR EFT MobilePay Integ.";
    begin
        EFTTypePOSUnitGenParam.SetRange("Integration Type", "EFT Integration Type");
        EFTTypePOSUnitGenParam.SetRange("POS Unit No.", "POS Unit No.");
        ShowPOSUnitGenParameter := not EFTTypePOSUnitGenParam.IsEmpty;

        EFTTypePOSUnitBlobParam.SetRange("Integration Type", "EFT Integration Type");
        EFTTypePOSUnitBlobParam.SetRange("POS Unit No.", "POS Unit No.");
        ShowPOSUnitBLOBParameter := not EFTTypePOSUnitBlobParam.IsEmpty;

        IsMobilePay := "EFT Integration Type" = EFTMobilePayIntegration.IntegrationType(); //This check & page actions can be in V2 extension.
    end;

    var
        ShowPOSUnitGenParameter: Boolean;
        ShowPOSUnitBLOBParameter: Boolean;
        IsMobilePay: Boolean;
}

