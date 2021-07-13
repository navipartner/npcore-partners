page 6014459 "NPR DSFINVK Closing List"
{
    ApplicationArea = NPRRetail;
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
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Ordinal number of DSFINVK Register Closing.';
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'POS Unit No. of DSFINVK Register Closing.';
                }
                field("Closing Date"; Rec."Closing Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'DSFINVK Register Closing Date.';
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'POS Entry No. of DSFINVK Register Closing.';
                }
                field("Workshift Entry No."; Rec."Workshift Entry No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Workshift Entry No. of DSFINVK Register Closing.';
                }
                field(State; Rec.State)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'DSFINVK Register Closing State on API.';
                }
                field("Has Error"; Rec."Has Error")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'DSFINVK Register Closing Error from API.';
                }
                field("Trigged Export"; Rec."Trigged Export")
                {
                    ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;
                ToolTip = 'Send record to Fiskaly if not fiskalized.';

                trigger OnAction()
                var
                    DEAuditSetup: Record "NPR DE Audit Setup";
                    DSFINVKMng: Codeunit "NPR DE Fiskaly DSFINVK";
                    DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                    DSFINVKJson: JsonObject;
                    DSFINVKResponseJson: JsonObject;
                    AccessToken: Text;
                begin
                    DEAuditSetup.Get();

                    if not DSFINVKMng.CreateDSFINVKDocument(DSFINVKJson, Rec) then
                        DEAuditMgt.SetDSFINVKErrorMsg(Rec);

                    if not DEAuditMgt.GetJwtToken(AccessToken) then
                        DEAuditMgt.SetDSFINVKErrorMsg(Rec);

                    Rec."Closing ID" := CreateGuid(); //Fiskaly does not allow update of Cash Point Closings 
                    if not DEFiskalyCommunication.SendDSFINVK(DSFINVKJson, DSFINVKResponseJson, DEAuditSetup, 'PUT', '/cash_point_closings/' + Format(Rec."Closing ID", 0, 4), AccessToken) then begin
                        DEAuditMgt.SetDSFINVKErrorMsg(Rec);
                        exit;
                    end;

                    Rec.State := Rec.State::PENDING;
                    Rec."Has Error" := false;
                    Clear(Rec."Error Message");
                    Rec.Modify();
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
                ApplicationArea = NPRRetail;
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