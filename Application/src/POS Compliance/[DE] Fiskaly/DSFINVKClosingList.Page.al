﻿page 6014459 "NPR DSFINVK Closing List"
{
    Extensible = False;
    ApplicationArea = NPRDEFiscal;
    Caption = 'DSFINVK Closing List';
    PageType = List;
    SourceTable = "NPR DSFINVK Closing";
    UsageCategory = Lists;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("DSFINVK Closing No."; Rec."DSFINVK Closing No.")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Ordinal number of DSFINVK Register Closing.';
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'POS Unit No. of DSFINVK Register Closing.';
                }
                field("Closing Date"; Rec."Closing Date")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'DSFINVK Register Closing Date.';
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'POS Entry No. of DSFINVK Register Closing.';
                }
                field("Workshift Entry No."; Rec."Workshift Entry No.")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Workshift Entry No. of DSFINVK Register Closing.';
                }
                field(State; Rec.State)
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'DSFINVK Register Closing State on API.';
                }
                field("Has Error"; Rec."Has Error")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'DSFINVK Register Closing Error from API.';
                }
                field("Trigged Export"; Rec."Trigged Export")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Is Export started for DSFINVK Register Closing on API.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(FiskalySend)
            {
                Caption = 'Send to Fiskaly';
                Image = SendApprovalRequest;
                Visible = Rec."Has Error";
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = NPRDEFiscal;
                ToolTip = 'Send record to Fiskaly if not fiskalized.';

                trigger OnAction()
                var
                    ConnectionParameters: Record "NPR DE Audit Setup";
                    DSFINVKMng: Codeunit "NPR DE Fiskaly DSFINVK";
                    DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                    DSFINVKJson: JsonObject;
                    DSFINVKResponseJson: JsonToken;
                    Success: Boolean;
                begin
                    Success := ConnectionParameters.GetSetup(Rec);
                    if Success then
                        Success := DSFINVKMng.CreateDSFINVKDocument(DSFINVKJson, Rec);
                    if Success then begin
                        Rec."Closing ID" := CreateGuid(); //Fiskaly does not allow update of Cash Point Closings 
                        Success := DEFiskalyCommunication.SendRequest_DSFinV_K(DSFINVKJson, DSFINVKResponseJson, ConnectionParameters, Enum::"Http Request Type"::PUT, StrSubstNo('/cash_point_closings/%1', Format(Rec."Closing ID", 0, 4)));
                    end;

                    if not Success then
                        DEAuditMgt.SetDSFINVKErrorMsg(Rec)
                    else begin
                        Rec.State := Rec.State::PENDING;
                        Rec."Has Error" := false;
                        Clear(Rec."Error Message");
                        Rec.Modify();
                    end;
                    CurrPage.Update();
                end;
            }
            action(ShowError)
            {
                Caption = 'Show Error';
                Image = ShowWarning;
                Visible = Rec."Has Error";
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = NPRDEFiscal;
                ToolTip = 'Show Error Message.';

                trigger OnAction()
                var
                    StrIn: InStream;
                    ErrorMessage: Text;
                begin
                    Rec.CalcFields("Error Message");
                    Rec."Error Message".CreateInStream(StrIn, TextEncoding::UTF8);
                    StrIn.Read(ErrorMessage);
                    Message(ErrorMessage);
                end;
            }
        }
    }
}
