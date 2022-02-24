page 6184480 "NPR EFT POSUnit Param. Setup"
{
    Extensible = False;
    // NPR5.46/MMV /20181008 CASE 290734 Created object
    // NPR5.48/BHR /20181206 CASE 338656 Added Missing Picture to Action

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

                    ToolTip = 'Executes the Register PoS action';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Update PoS Description action';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Unregister PoS action';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Assign PoS Unit action';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Unassign PoS Unit action';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Scan PoS Unit action';
                    ApplicationArea = NPRRetail;

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
        EFTTypePOSUnitGenParam.SetRange("Integration Type", Rec."EFT Integration Type");
        EFTTypePOSUnitGenParam.SetRange("POS Unit No.", Rec."POS Unit No.");
        ShowPOSUnitGenParameter := not EFTTypePOSUnitGenParam.IsEmpty();

        EFTTypePOSUnitBlobParam.SetRange("Integration Type", Rec."EFT Integration Type");
        EFTTypePOSUnitBlobParam.SetRange("POS Unit No.", Rec."POS Unit No.");
        ShowPOSUnitBLOBParameter := not EFTTypePOSUnitBlobParam.IsEmpty();

        IsMobilePay := Rec."EFT Integration Type" = EFTMobilePayIntegration.IntegrationType(); //This check & page actions can be in V2 extension.
    end;

    var
        ShowPOSUnitGenParameter: Boolean;
        ShowPOSUnitBLOBParameter: Boolean;
        IsMobilePay: Boolean;
}

