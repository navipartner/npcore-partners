page 6151297 "NPR SI POS Store Mapping"
{
    ApplicationArea = NPRSIFiscal;
    Caption = 'SI POS Store Mapping';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR SI POS Store Mapping";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(POSStoreMappingLines)
            {
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the POS Store Code.';
                }
                field(Registered; Rec.Registered)
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies if the related POS Store is Registered.';
                    Editable = false;
                }
                field("Cadastral Number"; Rec."Cadastral Number")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the Cadastral Number of the related registered POS Store.';
                    ShowMandatory = true;
                }
                field("Building Number"; Rec."Building Number")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the Building Number of the related registered POS Store.';
                    ShowMandatory = true;
                }
                field("Building Section Number"; Rec."Building Section Number")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the Building Section Number of the related registered POS Store.';
                    ShowMandatory = true;
                }
                field("Validity Date"; Rec."Validity Date")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the Validity Date of the registration.';
                    ShowMandatory = true;
                }
                field("Receipt No. Series"; Rec."Receipt No. Series")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the Receipt No. Series for the related POS Store.';
                    ShowMandatory = true;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Register)
            {
                Caption = 'Register POS Store';
                Promoted = true;
                PromotedOnly = true;
                Image = Registered;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = NPRSIFiscal;
                ToolTip = 'Executes the Register POS Store action.';

                trigger OnAction()
                var
                    SITaxCommunicationMgt: Codeunit "NPR SI Tax Communication Mgt.";
                begin
                    SITaxCommunicationMgt.RegisterPOSStore(Rec);
                end;
            }
            action(MarkRegistered)
            {
                Caption = 'Mark POS Store as Registered';
                Promoted = true;
                PromotedOnly = true;
                Image = Approve;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = NPRSIFiscal;
                ToolTip = 'Executes the Mark POS Store as Registered action.';

                trigger OnAction()
                var
                    ConfirmManagement: Codeunit "Confirm Management";
                    ShouldMarkStoreAsRegisteredQst: Label 'This action should be used only if your POS Store was previously registered with the Tax Authority. Are you sure you want to mark POS Store %1 as registered?', Comment = '%1 = POS Store Code';
                begin
                    if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(ShouldMarkStoreAsRegisteredQst, Rec."POS Store Code"), false) then
                        exit;
                    Rec.Registered := true;
                    Rec.Modify();
                end;
            }
        }
    }
}