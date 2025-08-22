page 6185090 "NPR AttractionWalletCard"
{
    Extensible = False;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR AttractionWallet";
    Caption = 'Attraction Wallet';
    Editable = true;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                Caption = 'Attraction Wallet Details';
                field(ReferenceNumber; Rec.ReferenceNumber)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Reference Number field.';
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(OriginatesFromItemNo; Rec.OriginatesFromItemNo)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Originates From Item No. field.';
                }
                field(PrintCount; Rec.PrintCount)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Print Count field.';
                }
                field(LastPrintAt; Rec.LastPrintAt)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Last Print Date field.';
                }
                field(ExpirationDate; Rec.ExpirationDate)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Expiration Date field.';
                }
                field(EntryNo; Rec.EntryNo)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Entry No. field.';
                    Visible = false;
                    Editable = false;
                }
                field(SystemId; Rec.SystemId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the System ID field.';
                    Visible = false;
                    Editable = false;
                }
            }

            part(Assets; "NPR AttractionWalletAssets")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Assets';
                UpdatePropagation = Both;
                Editable = false;
            }

            part(ExternalReferences; "NPR AttractionWalletExtRefs")
            {
                ApplicationArea = NPRRetail;
                Caption = 'External References';
                UpdatePropagation = Both;
                Editable = false;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(PrintWallet)
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Print Wallet';
                Caption = 'Print';
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                trigger OnAction()
                var
                    WalletMgr: Codeunit "NPR AttractionWallet";
                begin
                    WalletMgr.PrintWallet(Rec.EntryNo, Enum::"NPR WalletPrintType"::WALLET);
                    CurrPage.Update(false);
                end;
            }
            action(CreateNewExternalRef)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Create New External Reference';
                ToolTip = 'Running this action will create a new external reference';
                Image = Line;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    WalletMgr: Codeunit "NPR AttractionWallet";
                begin
                    WalletMgr.CreateNewExternalReference(Rec.EntryNo);
                    CurrPage.Update(false);
                end;
            }
        }
    }


    trigger OnAfterGetRecord()
    var
        TempSelectedWallets: Record "NPR AttractionWallet" temporary;
    begin
        TempSelectedWallets.TransferFields(Rec, true);
        TempSelectedWallets.SystemId := Rec.SystemId;
        TempSelectedWallets.Insert();

        CurrPage.Assets.Page.ShowSelectedAssets(TempSelectedWallets);
        CurrPage.ExternalReferences.Page.ShowSelectedWallets(TempSelectedWallets);
    end;
}