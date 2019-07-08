page 6184480 "EFT POS Unit Parameter Setup"
{
    // NPR5.46/MMV /20181008 CASE 290734 Created object
    // NPR5.48/BHR /20181206 CASE 338656 Added Missing Picture to Action

    Caption = 'EFT POS Unit Parameter Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ShowFilter = false;
    SourceTable = "EFT Setup";

    layout
    {
        area(content)
        {
            part(GenericParams;"EFT Type POS Unit Gen. Param.")
            {
                Caption = 'Generic Parameters';
                ShowFilter = false;
                SubPageLink = "Integration Type"=FIELD("EFT Integration Type"),
                              "POS Unit No."=FIELD("POS Unit No.");
                Visible = ShowPOSUnitGenParameter;
            }
            part(BinaryParams;"EFT Type POS Unit BLOB Param.")
            {
                Caption = 'Binary Parameters';
                ShowFilter = false;
                SubPageLink = "Integration Type"=FIELD("EFT Integration Type"),
                              "POS Unit No."=FIELD("POS Unit No.");
                Visible = ShowPOSUnitBLOBParameter;
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

                    trigger OnAction()
                    var
                        EFTMobilePayIntegration: Codeunit "EFT MobilePay Integration";
                    begin
                        EFTMobilePayIntegration.RegisterPoS(Rec);
                    end;
                }
                action("Update PoS Description")
                {
                    Caption = 'Update PoS Description';
                    Image = UpdateDescription;

                    trigger OnAction()
                    var
                        EFTMobilePayIntegration: Codeunit "EFT MobilePay Integration";
                    begin
                        EFTMobilePayIntegration.UpdateRegisteredPoSName(Rec);
                    end;
                }
                action("Unregister PoS")
                {
                    Caption = 'Unregister PoS';
                    Image = UnApply;

                    trigger OnAction()
                    var
                        EFTMobilePayIntegration: Codeunit "EFT MobilePay Integration";
                    begin
                        EFTMobilePayIntegration.UnRegisterPoS(Rec);
                    end;
                }
                action("Assign PoS Unit")
                {
                    Caption = 'Assign PoS Unit';
                    Image = AddAction;

                    trigger OnAction()
                    var
                        EFTMobilePayIntegration: Codeunit "EFT MobilePay Integration";
                    begin
                        EFTMobilePayIntegration.AssignPoSUnitIdToPoS(Rec);
                    end;
                }
                action("Unassign PoS Unit")
                {
                    Caption = 'Unassign PoS Unit';
                    Image = Cancel;

                    trigger OnAction()
                    var
                        EFTMobilePayIntegration: Codeunit "EFT MobilePay Integration";
                    begin
                        EFTMobilePayIntegration.UnAssignPoSUnitIdToPoS(Rec);
                    end;
                }
                action("Scan PoS Unit")
                {
                    Caption = 'Scan PoS Unit';
                    Image = MiniForm;

                    trigger OnAction()
                    var
                        EFTMobilePayIntegration: Codeunit "EFT MobilePay Integration";
                    begin
                        EFTMobilePayIntegration.ReadPoSUnitAssignedPoSId(Rec);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        EFTTypePOSUnitGenParam: Record "EFT Type POS Unit Gen. Param.";
        EFTTypePOSUnitBlobParam: Record "EFT Type POS Unit BLOB Param.";
        EFTMobilePayIntegration: Codeunit "EFT MobilePay Integration";
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

