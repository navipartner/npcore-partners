page 6184630 "NPR MM POS Member Profile"
{
    Extensible = false;
    Caption = 'POS Member Profile';
    PageType = Card;
    SourceTable = "NPR MM POS Member Profile";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Code field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Send Notification On Sale"; Rec."Send Notification On Sale")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if member notifications are going to be send after the end of the pos sale.';
                }
                field("Alteration Group"; Rec."Alteration Group")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies a Alteration Group code for limiting the alterations shown on the POS.';
                }
            }
            group(Print)
            {
                Caption = 'Print';
                field("Print Membership On Sale"; Rec."Print Membership On Sale")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if a membership is going to be printed after the end of the pos sale.';
                }
            }

            group(Admit)
            {
                Caption = 'Admit';
                field(EndOfSaleAdmitMethod; Rec.EndOfSaleAdmitMethod)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the End-Of-Sale Admit Method field.';
                }
                field(ScannerIdForUnitAdmitOnEndSale; Rec.ScannerIdForUnitAdmitOnEndSale)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Scanner ID For Unit Admit On End Of Sale field.';
                    Editable = false;
                    trigger OnDrillDown()
                    var
                        LookupPage: Page "NPR SG SpeedGateListPart";
                        PageAction: Action;
                        SpeedGates: Record "NPR SG SpeedGate";
                    begin
                        LookupPage.Editable(false);
                        LookupPage.LookupMode(true);
                        PageAction := LookupPage.RunModal();
                        if (PageAction = Action::OK) then begin
                            LookupPage.GetRecord(SpeedGates);
                            if (Rec.ScannerIdForUnitAdmitEoSId <> SpeedGates.Id) then
                                if (not Confirm('Are you sure you want to change the SpeedGate ID for admission used during end of sale?', false)) then
                                    Error('');
                            Rec.ScannerIdForUnitAdmitEoSId := SpeedGates.Id;
                            CurrPage.Update(true);
                        end;
                    end;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ClearScannerIdForUnitAdmitOnEndOfSale)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Clear Scanner ID For Unit Admit On End Of Sale';
                Image = Delete;
                ToolTip = 'Clears the scanner ID used to register arrival when admitting members at the end of sale.';
                trigger OnAction()
                begin
                    Clear(Rec.ScannerIdForUnitAdmitEoSId);
                    CurrPage.Update(true);
                end;
            }
        }
    }
}