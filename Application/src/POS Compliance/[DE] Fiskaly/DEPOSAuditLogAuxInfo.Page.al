page 6014426 "NPR DE POS Audit Log Aux. Info"
{
    Caption = 'DE POS Audit Log Aux. Info';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR DE POS Audit Log Aux. Info";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Entry No. field';
                }
                field("NPR Version"; Rec."NPR Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Version field';
                }
                field("TSS ID"; Rec."TSS ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the TSS ID on Fiskaly';
                }
                field("Client ID"; Rec."Client ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client ID on Fiskaly';
                }
                field("Transaction ID"; Rec."Transaction ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction ID on Fiskaly';
                }
                field("Start Time"; Rec."Start Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Start DateTime of transaction on Fiskaly';
                }
                field("Finish Time"; Rec."Finish Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Finish DateTime of transaction on Fiskaly';
                }
                field(Fiscalized; Rec."Fiscalization Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if receipt is loged on TSS system';
                }
                field("Error"; Rec."Has Error")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error Message if receipt is not loged on TSS system';
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
                ApplicationArea = All;
                ToolTip = 'Send record to Fiskaly if not fiskalized.';

                trigger OnAction()
                var
                    POSEntry: Record "NPR POS Entry";
                    POSUnitAux: Record "NPR DE POS Unit Aux. Info";
                    DEAuditSetup: Record "NPR DE Audit Setup";
                    DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
                    DEFiskalyComm: Codeunit "NPR DE Fiskaly Communication";
                    DocumentJson: JsonObject;
                    ResponseJson: JsonObject;
                    StrOut: OutStream;
                begin
                    if Rec."Fiscalization Status" = Rec."Fiscalization Status"::Fiscalized then
                        exit;
                    POSEntry.Get(Rec."POS Entry No.");
                    POSUnitAux.Get(POSEntry."POS Unit No.");
                    DEAuditSetup.Get();
                    DEAuditMgt.CreateDocumentJson(Rec."POS Entry No.", POSUnitAux, DocumentJson);

                    if not DEFiskalyComm.SendDocument(Rec, DocumentJson, ResponseJson, DEAuditSetup) then
                        DEAuditMgt.SetErrorMsg(Rec)
                    else
                        if not DEAuditMgt.DeAuxInfoInsertResponse(Rec, ResponseJson) then
                            DEAuditMgt.SetErrorMsg(Rec);

                    DEAuditSetup.Modify();
                    Rec.Modify();
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
                ApplicationArea = All;
                ToolTip = 'Get transaction data from Fiskaly.';

                trigger OnAction()
                var
                    DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
                    DEFiskalyComm: Codeunit "NPR DE Fiskaly Communication";
                    ResponseJson: JsonObject;
                    StrOut: OutStream;
                    HasData: Label 'This record have data, do you really want to get data from Fiskaly?';
                begin
                    IF Rec."Time Format" <> '' THEN
                        IF NOT CONFIRM(HasData) THEN
                            EXIT;
                    ResponseJson := DEFiskalyComm.GetTransaction(Format(Rec."TSS ID", 0, 4), Format(Rec."Transaction ID", 0, 4));

                    IF NOT DEAuditMgt.DeAuxInfoInsertResponse(Rec, ResponseJson) THEN
                        Message(GETLASTERRORTEXT);

                    Rec.MODIFY;
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
                ApplicationArea = All;
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