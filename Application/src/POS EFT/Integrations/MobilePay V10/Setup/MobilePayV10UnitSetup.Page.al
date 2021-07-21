page 6014405 "NPR MobilePayV10 Unit Setup"
{
    PageType = Card;

    UsageCategory = Administration;
    SourceTable = "NPR MobilePayV10 Unit Setup";
    ApplicationArea = NPRRetail;
    Caption = 'MobilePayV10 Unit Setup';

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field("Store ID"; Rec."Store ID")
                {

                    Lookup = true;
                    ToolTip = 'Specifies the value of the Store ID field';
                    ApplicationArea = NPRRetail;
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

                    ToolTip = 'Specifies the value of the Merchant PoS ID field';
                    ApplicationArea = NPRRetail;
                }
                field("MobilePay POS ID"; Rec."MobilePay POS ID")
                {

                    Lookup = true;
                    ToolTip = 'Specifies the value of the MobilePay POS ID field';
                    ApplicationArea = NPRRetail;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        mobilePayIntegration: Codeunit "NPR MobilePayV10 Integration";
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

                    ToolTip = 'Specifies the value of the Beacon ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Only QR"; Rec."Only QR")
                {

                    ToolTip = 'Specifies the value of the Only QR field';
                    ApplicationArea = NPRRetail;
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

                Caption = 'Create In Mobilepay';
                Image = CopyCostBudget;
                ToolTip = 'Executes the Create In Mobilepay action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    mobilePayIntegration: Codeunit "NPR MobilePayV10 Integration";
                begin
                    mobilePayIntegration.CreatePOS(_eftSetup);
                end;
            }
            action(DeleteInMobilePay)
            {

                Caption = 'Delete In Mobilepay';
                Image = CloseDocument;
                ToolTip = 'Executes the Delete In Mobilepay action';
                ApplicationArea = NPRRetail;

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