﻿page 6150756 "NPR DE Fiskaly TSS Clients"
{
    Extensible = False;
    Caption = 'DE Fiskaly TSS Clients';
    PageType = List;
    SourceTable = "NPR DE POS Unit Aux. Info";
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ToolTip = 'Specifies the POS Unit this Fiskaly client is created for.';
                    ApplicationArea = NPRRetail;
                }
                field("Cash Register Brand"; Rec."Cash Register Brand")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the POS unit cash register brand.';
                }
                field("Cash Register Model"; Rec."Cash Register Model")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the POS unit cash register model.';
                }
                field("Serial Number"; Rec."Serial Number")
                {
                    ToolTip = 'Specifies the POS unit cash register serial number.';
                    ApplicationArea = NPRRetail;
                }
                field("TSS Code"; Rec."TSS Code")
                {
                    ToolTip = 'Specifies the Technical Security System (TSS) the Fiskaly client is linked to.';
                    ApplicationArea = NPRRetail;
                }
                field("Client ID"; Rec.SystemId)
                {
                    ToolTip = 'Specifies the Fiskaly client ID.';
                    ApplicationArea = NPRRetail;
                }
                field("Fiskaly Client Created at"; Rec."Fiskaly Client Created at")
                {
                    ToolTip = 'Specifies the date/time the client was created at Fiskaly.';
                    ApplicationArea = NPRRetail;
                }
                field("Fiskaly Client State"; Rec."Fiskaly Client State")
                {
                    ToolTip = 'Specifies last known state of the Fiskaly client.';
                    ApplicationArea = NPRRetail;
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
                Caption = 'Deregister Fiskaly Client';
                Image = VoidCheck;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Deregisters previously created client at Fiskaly.';
                ApplicationArea = NPRRetail;

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
