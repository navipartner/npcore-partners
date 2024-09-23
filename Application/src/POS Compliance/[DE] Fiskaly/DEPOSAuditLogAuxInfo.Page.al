page 6014426 "NPR DE POS Audit Log Aux. Info"
{
    Extensible = False;
    Caption = 'DE POS Audit Log';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR DE POS Audit Log Aux. Info";
    SourceTableView = SORTING("POS Entry No.") ORDER(Descending);
    ApplicationArea = NPRDEFiscal;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ToolTip = 'Specifies the value of the POS Entry No. field';
                    ApplicationArea = NPRDEFiscal;
                }
                field("NPR Version"; Rec."NPR Version")
                {
                    ToolTip = 'Specifies the value of the NPR Version field';
                    ApplicationArea = NPRDEFiscal;
                }
                field("TSS Code"; Rec."TSS Code")
                {
                    ToolTip = 'Specifies the Technical Security System (TSS) Code assinged to the transaction';
                    ApplicationArea = NPRDEFiscal;
                }
                field("TSS ID"; Rec."TSS ID")
                {
                    ToolTip = 'Specifies the value of the TSS ID on Fiskaly';
                    ApplicationArea = NPRDEFiscal;
                }
                field("Client ID"; Rec."Client ID")
                {
                    ToolTip = 'Specifies the value of the Client ID on Fiskaly';
                    ApplicationArea = NPRDEFiscal;
                }
                field("Transaction ID"; Rec."Transaction ID")
                {
                    ToolTip = 'Specifies the value of the Transaction ID on Fiskaly';
                    ApplicationArea = NPRDEFiscal;
                }
                field("Fiskaly Transaction Type"; Rec."Fiskaly Transaction Type")
                {
                    ToolTip = 'Specifies the Fiskaly transaction (receipt) type';
                    ApplicationArea = NPRDEFiscal;
                }
                field("Start Time"; Rec."Start Time")
                {
                    ToolTip = 'Specifies the value of the Start DateTime of transaction on Fiskaly';
                    ApplicationArea = NPRDEFiscal;
                }
                field("Finish Time"; Rec."Finish Time")
                {
                    ToolTip = 'Specifies the value of the Finish DateTime of transaction on Fiskaly';
                    ApplicationArea = NPRDEFiscal;
                }
                field("Fiskaly Transaction State"; Rec."Fiskaly Transaction State")
                {
                    ToolTip = 'Specifies the Fiskaly state of the transaction';
                    ApplicationArea = NPRDEFiscal;
                }
                field("Latest Revision"; Rec."Latest Revision")
                {
                    ToolTip = 'Specifies the latest revision number of the transaction on Fiskaly';
                    ApplicationArea = NPRDEFiscal;
                }
                field(Fiscalized; Rec."Fiscalization Status")
                {
                    ToolTip = 'Specifies if receipt is loged on TSS system';
                    ApplicationArea = NPRDEFiscal;
                }
                field("Error"; Rec."Has Error")
                {
                    ToolTip = 'Specifies the value of the Error Message if receipt is not loged on TSS system';
                    ApplicationArea = NPRDEFiscal;
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
                Visible = Rec."Fiscalization Status" <> Rec."Fiscalization Status"::Fiscalized;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Send record to Fiskaly if not fiskalized.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    DEFiskalyComm: Codeunit "NPR DE Fiskaly Communication";
                begin
                    if Rec."Fiscalization Status" = Rec."Fiscalization Status"::Fiscalized then
                        Rec.FieldError("Fiscalization Status");
                    DEFiskalyComm.SendDocument(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(GetTransactionInfo)
            {
                Caption = 'Get Transaction Info';
                Image = GetEntries;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Get transaction data from Fiskaly.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    DeAuditAux: Record "NPR DE POS Audit Log Aux. Info";
                    DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
                    DEFiskalyComm: Codeunit "NPR DE Fiskaly Communication";
                    ResponseJson: JsonToken;
                    HasData: Label 'This record has already been populated with Fiskaly related data.\Are you sure you want to overwrite it with data from Fiskaly?';
                begin
                    if Rec."Time Format" <> '' then
                        if not Confirm(HasData) then
                            exit;
                    DeAuditAux := Rec;
                    ResponseJson := DEFiskalyComm.GetTransaction(DeAuditAux, 0);
                    if not DEAuditMgt.DeAuxInfoInsertResponse(DeAuditAux, ResponseJson) then
                        Message(GetLastErrorText());
                    DeAuditAux.Modify();
                    CurrPage.Update(false);
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
                ToolTip = 'Show Error Message.';
                ApplicationArea = NPRRetail;

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
