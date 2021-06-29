page 6014657 "NPR MobilePayV10 Unit Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "NPR MobilePayV10 Unit Setup";

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field("Store ID"; Rec."Store ID")
                {
                    ApplicationArea = All;
                    Lookup = true;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        mobilePayIntegration: Codeunit "NPR MobilePayV10 Integration";
                        lookupValue: Text;
                    begin
                        if mobilePayIntegration.LookupStore(_eftSetup, lookupValue) then begin
                            Text := lookupValue;
                            CurrPage.Update(true);
                            exit(true);
                        end;
                    end;
                }
                field("Merchant PoS ID"; Rec."Merchant PoS ID")
                {
                    ApplicationArea = All;
                }
                field("MobilePay POS ID"; Rec."MobilePay POS ID")
                {
                    ApplicationArea = All;
                    Lookup = true;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        mobilePayIntegration: Codeunit "NPR MobilePayV10 Integration";
                        lookupValue: Text;
                    begin
                        if mobilePayIntegration.LookupPOS(_eftSetup, Rec) then begin
                            Text := Rec."MobilePay POS ID";
                            CurrPage.Update(true);
                            exit(true);
                        end;
                    end;
                }
                field("Beacon ID"; Rec."Beacon ID")
                {
                    ApplicationArea = All;
                }
                field("Only QR"; Rec."Only QR")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateInMobilePay)
            {
                ApplicationArea = All;
                Caption = 'Create In Mobilepay';
                Image = CopyCostBudget;

                trigger OnAction()
                var
                    mobilePayIntegration: Codeunit "NPR MobilePayV10 Integration";
                begin
                    mobilePayIntegration.CreatePOS(_eftSetup);
                end;
            }
            action(DeleteInMobilePay)
            {
                ApplicationArea = All;
                Caption = 'Delete In Mobilepay';
                Image = CloseDocument;

                trigger OnAction()
                var
                    mobilePayIntegration: Codeunit "NPR MobilePayV10 Integration";
                begin
                    mobilePayIntegration.DeletePOS(_eftSetup, Rec);
                end;
            }
        }
    }

    internal procedure SetGlobalEFTSetup(eftSetup: Record "NPR EFT Setup")
    begin
        _eftSetup := eftSetup;
    end;

    var
        _eftSetup: Record "NPR EFT Setup";
}