page 6184639 "NPR TM POS Ticket Profile"
{
    Extensible = false;
    Caption = 'POS Ticket Profile';
    PageType = Card;
    SourceTable = "NPR TM POS Ticket Profile";
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
            }
            group(Print)
            {
                Caption = 'Print';
                field("Print Ticket On Sale"; Rec."Print Ticket On Sale")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if a ticket is going to be printed after the end of the pos sale.';
                }
            }

            group(Admit)
            {
                Caption = 'Admit';
                field(EndOfSaleAdmitMethod; Rec."EndOfSaleAdmitMethod")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the method used to admit tickets at the end of sale.';
                }
                field(ShowSpinnerDuringWorkflowAdmit; Rec."ShowSpinnerDuringWorkflowAdmit")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if a spinner is going to be shown during the workflow admit.';
                }
                field(ScannerIdForUnitAdmitOnEndOfSale; Rec.ScannerIdForUnitAdmitOnEndSale)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the scanner ID used to select the ticket profile when admitting tickets at the end of sale.';

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
                field(ScannerIdForUnitAdmitEoSId; Rec.ScannerIdForUnitAdmitEoSId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the scanner ID used to select the ticket profile when admitting tickets at the end of sale.';
                    Visible = false;
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
                ToolTip = 'Clears the scanner ID used to select the ticket profile when admitting tickets at the end of sale.';
                trigger OnAction()
                begin
                    Clear(Rec.ScannerIdForUnitAdmitEoSId);
                    CurrPage.Update(true);
                end;
            }
        }
    }
}