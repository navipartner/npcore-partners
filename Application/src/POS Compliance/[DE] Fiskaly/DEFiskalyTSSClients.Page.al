page 6150756 "NPR DE Fiskaly TSS Clients"
{
    Caption = 'DE Fiskaly TSS Clients';
    ContextSensitiveHelpPage = 'docs/fiscalization/germany/how-to/setup/';
    Editable = false;
    Extensible = False;
    ObsoleteReason = 'Page NPR DE POS Unit Aux. Info List should be used instead.';
    ObsoleteState = Pending;
    ObsoleteTag = '2025-01-12';
    PageType = List;
    SourceTable = "NPR DE POS Unit Aux. Info";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the POS Unit this Fiskaly client is created for.';
                }
                field("Cash Register Brand"; Rec."Cash Register Brand")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the POS unit cash register brand (manufacturer).';
                }
                field("Cash Register Model"; Rec."Cash Register Model")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the POS unit cash register model.';
                }
                field("Serial Number"; Rec."Serial Number")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the POS unit cash register serial number.';
                }
                field("TSS Code"; Rec."TSS Code")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the Technical Security System (TSS) the Fiskaly client is linked to.';
                }
                field("Client ID"; Rec.SystemId)
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the Fiskaly client ID.';
                }
                field("Fiskaly Client Created at"; Rec."Fiskaly Client Created at")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the date/time the client was created at Fiskaly.';
                }
                field("Fiskaly Client State"; Rec."Fiskaly Client State")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies last known state of the Fiskaly client.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DeregisterClient)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Deregister Fiskaly Client';
                Image = VoidCheck;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Deregisters previously created client at Fiskaly.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                    ConfirmDeregisterQst: Label 'The operation cannot be undone. Are you sure you want to deregister Fiskaly client for POS unit No. %1?', Comment = '%1 - POS Unit No.';
                begin
                    Rec.TestField("Fiskaly Client State", Rec."Fiskaly Client State"::REGISTERED);
                    if not Confirm(ConfirmDeregisterQst, false, Rec."POS Unit No.") then
                        exit;

                    DEFiskalyCommunication.UpdateTSSClient_State(Rec, Rec."Fiskaly Client State"::DEREGISTERED);
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
