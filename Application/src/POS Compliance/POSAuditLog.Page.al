page 6150673 "NPR POS Audit Log"
{
    Caption = 'POS Audit Log';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR POS Audit Log";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Table Name"; Rec."Table Name")
                {

                    ToolTip = 'Specifies the value of the Table Name field';
                    ApplicationArea = NPRRetail;
                }
                field(FormattedRecordID; FormattedRecordID)
                {

                    Caption = 'Record ID';
                    ToolTip = 'Specifies the value of the Record ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Action Type"; Rec."Action Type")
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Action Custom Subtype"; Rec."Action Custom Subtype")
                {

                    ToolTip = 'Specifies the value of the Action Custom Subtype field';
                    ApplicationArea = NPRRetail;
                }
                field("Acted on POS Entry No."; Rec."Acted on POS Entry No.")
                {

                    ToolTip = 'Specifies the value of the Acted on POS Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Acted on POS Entry Fiscal No."; Rec."Acted on POS Entry Fiscal No.")
                {

                    ToolTip = 'Specifies the value of the Acted on POS Entry Fiscal No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Active POS Unit No."; Rec."Active POS Unit No.")
                {

                    ToolTip = 'Specifies the value of the Active POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Active Salesperson Code"; Rec."Active Salesperson Code")
                {

                    ToolTip = 'Specifies the value of the Active Salesperson Code field';
                    ApplicationArea = NPRRetail;
                }
                field("User ID"; Rec."User ID")
                {

                    ToolTip = 'Specifies the value of the User ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Log Timestamp"; Rec."Log Timestamp")
                {

                    ToolTip = 'Specifies the value of the Log Timestamp field';
                    ApplicationArea = NPRRetail;
                }
                field("External Type"; Rec."External Type")
                {

                    ToolTip = 'Specifies the value of the External Type field';
                    ApplicationArea = NPRRetail;
                }
                field("External ID"; Rec."External ID")
                {

                    ToolTip = 'Specifies the value of the External ID field';
                    ApplicationArea = NPRRetail;
                }
                field("External Code"; Rec."External Code")
                {

                    ToolTip = 'Specifies the value of the External Code field';
                    ApplicationArea = NPRRetail;
                }
                field("External Description"; Rec."External Description")
                {

                    ToolTip = 'Specifies the value of the External Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Additional Information"; Rec."Additional Information")
                {

                    ToolTip = 'Specifies the value of the Additional Information field';
                    ApplicationArea = NPRRetail;
                }
                field(BaseValue; BaseValue)
                {

                    Caption = 'Signature Base Value';
                    ToolTip = 'Specifies the value of the Signature Base Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Signature Base Hash"; Rec."Signature Base Hash")
                {

                    ToolTip = 'Specifies the value of the Signature Base Hash field';
                    ApplicationArea = NPRRetail;
                }
                field(Signature; Signature)
                {

                    Caption = 'Signature';
                    ToolTip = 'Specifies the value of the Signature field';
                    ApplicationArea = NPRRetail;
                }
                field(PreviousSignature; PreviousSignature)
                {

                    Caption = 'Previous Signature';
                    ToolTip = 'Specifies the value of the Previous Signature field';
                    ApplicationArea = NPRRetail;
                }
                field("Certificate Thumbprint"; Rec."Certificate Thumbprint")
                {

                    ToolTip = 'Specifies the value of the Certificate Thumbprint field';
                    ApplicationArea = NPRRetail;
                }
                field("Certificate Implementation"; Rec."Certificate Implementation")
                {

                    ToolTip = 'Specifies the value of the Certificate Implementation field';
                    ApplicationArea = NPRRetail;
                }
                field("External Implementation"; Rec."External Implementation")
                {

                    ToolTip = 'Specifies the value of the External Implementation field';
                    ApplicationArea = NPRRetail;
                }
                field("Handled by External Impl."; Rec."Handled by External Impl.")
                {

                    ToolTip = 'Specifies the value of the Handled by External Impl. field';
                    ApplicationArea = NPRRetail;
                }
                field("Active POS Sale SystemId"; Rec."Active POS Sale SystemId")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'SystemID of the active POS sale header. Is transferred to POS Entry header SystemID when sale is completed';
                }
                field("Acted on POS Unit No."; Rec."Acted on POS Unit No.")
                {

                    ToolTip = 'Specifies the value of the Acted on POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Uploaded; Rec.Uploaded)
                {

                    ToolTip = 'Specifies the value of the Uploaded field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ValidateLog)
            {
                Caption = 'Validate Log';
                Image = Approval;

                ToolTip = 'Executes the Validate Log action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
                    POSAuditLog: Record "NPR POS Audit Log";
                begin
                    POSAuditLog.SetView(Rec.GetView());
                    POSAuditLogMgt.ValidateLog(POSAuditLog);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        InStream: InStream;
    begin
        Clear(Signature);
        Clear(PreviousSignature);
        Clear(BaseValue);

        Rec.CalcFields("Electronic Signature", "Previous Electronic Signature", "Signature Base Value");

        if Rec."Electronic Signature".HasValue() then begin
            Rec."Electronic Signature".CreateInStream(InStream);
            while (not InStream.EOS) do begin
                InStream.Read(Signature);
            end;
            Clear(InStream);
        end;

        if Rec."Previous Electronic Signature".HasValue() then begin
            Rec."Previous Electronic Signature".CreateInStream(InStream);
            while (not InStream.EOS) do begin
                InStream.Read(PreviousSignature);
            end;
            Clear(InStream);
        end;

        if Rec."Signature Base Value".HasValue() then begin
            Rec."Signature Base Value".CreateInStream(InStream);
            while (not InStream.EOS) do begin
                InStream.Read(BaseValue);
            end;
            Clear(InStream);
        end;

        FormattedRecordID := Format(Rec."Record ID");
    end;

    var
        FormattedRecordID: Text;
        Signature: Text;
        PreviousSignature: Text;
        BaseValue: Text;
}